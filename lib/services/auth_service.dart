import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthService {
  static const _boxName = 'UserData';
  static const _keyDisplayName = 'displayName';
  static const _keyEmail = 'email';
  static const _keyPhotoUrl = 'photoUrl';
  static const _keyIsSignedIn = 'isSignedIn';

  // Standard Android sign-in — scopes only, no serverClientId needed because
  // this app has no backend server that exchanges tokens.  The SHA-1
  // fingerprint registered in Firebase Console must match the signing
  // certificate of the installed APK (debug or release).
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Box get _box => Hive.box(_boxName);

  /// Returns the cached signed-in state (no network call).
  bool get isSignedIn =>
      _box.get(_keyIsSignedIn, defaultValue: false) as bool;

  String get displayName =>
      _box.get(_keyDisplayName, defaultValue: '') as String;

  String get email => _box.get(_keyEmail, defaultValue: '') as String;

  String? get photoUrl => _box.get(_keyPhotoUrl) as String?;

  /// Performs an interactive Google Sign-In (always shows the account picker).
  ///
  /// Returns `true` on success, `false` when the user dismisses the picker or
  /// cancels, and throws a [PlatformException] for genuine sign-in errors.
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false; // user dismissed the picker

      await _persistUser(account);
      return true;
    } on PlatformException catch (e) {
      // sign_in_cancelled is raised on some Android versions when the user
      // presses back; treat it as a normal cancellation, not an error.
      if (e.code == 'sign_in_cancelled') return false;
      debugPrint('Google Sign-In error [${e.code}]: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
    } finally {
      await _clearUser();
    }
  }

  /// Silently restores a previously signed-in session.
  /// Returns true when a session is successfully restored.
  Future<bool> restoreSession() async {
    try {
      GoogleSignInAccount? account;
      try {
        account = await _googleSignIn.signInSilently();
      } catch (e) {
        debugPrint('Google silent restore failed: $e');
        return false;
      }
      if (account != null) {
        await _persistUser(account);
        return true;
      }
    } catch (e) {
      debugPrint('Google session restore error: $e');
    }
    return false;
  }

  Future<void> _persistUser(GoogleSignInAccount account) async {
    await _box.putAll({
      _keyIsSignedIn: true,
      _keyDisplayName: account.displayName ?? '',
      _keyEmail: account.email,
      _keyPhotoUrl: account.photoUrl,
    });
  }

  Future<void> _clearUser() async {
    await _box.putAll({
      _keyIsSignedIn: false,
      _keyDisplayName: '',
      _keyEmail: '',
      _keyPhotoUrl: null,
    });
  }
}
