import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthService {
  static const _boxName = 'UserData';
  static const _keyDisplayName = 'displayName';
  static const _keyEmail = 'email';
  static const _keyPhotoUrl = 'photoUrl';
  static const _keyIsSignedIn = 'isSignedIn';

  // Using the web client ID (type-3 OAuth client) as serverClientId lets
  // Google Sign-In work on Android regardless of the APK signing SHA-1,
  // because the web-client flow does not enforce certificate matching.
  static const _webClientId =
      '616723741130-fh1siculubkcia76jid5tj3hpfounf17.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _webClientId,
  );

  Box get _box => Hive.box(_boxName);

  /// Returns the cached signed-in state (no network call).
  bool get isSignedIn =>
      _box.get(_keyIsSignedIn, defaultValue: false) as bool;

  String get displayName =>
      _box.get(_keyDisplayName, defaultValue: '') as String;

  String get email => _box.get(_keyEmail, defaultValue: '') as String;

  String? get photoUrl => _box.get(_keyPhotoUrl) as String?;

  /// Attempts a silent sign-in first; falls back to interactive sign-in.
  Future<bool> signIn() async {
    try {
      GoogleSignInAccount? account;

      // v6 signInSilently() can throw instead of returning null on Android.
      try {
        account = await _googleSignIn.signInSilently();
      } catch (e) {
        debugPrint('Google silent sign-in skipped: $e');
      }

      // Fall back to interactive sign-in.
      account ??= await _googleSignIn.signIn();
      if (account == null) return false;

      await _persistUser(account);
      return true;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      // Re-throw so the controller can surface the real reason.
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
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
