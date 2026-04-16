import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthService {
  static const _boxName = 'UserData';
  static const _keyDisplayName = 'displayName';
  static const _keyEmail = 'email';
  static const _keyPhotoUrl = 'photoUrl';
  static const _keyIsSignedIn = 'isSignedIn';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Box get _box => Hive.box(_boxName);

  /// Returns the cached signed-in state (no network call).
  bool get isSignedIn => _box.get(_keyIsSignedIn, defaultValue: false) as bool;

  String get displayName => _box.get(_keyDisplayName, defaultValue: '') as String;

  String get email => _box.get(_keyEmail, defaultValue: '') as String;

  String? get photoUrl => _box.get(_keyPhotoUrl) as String?;

  /// Attempts a silent sign-in first; falls back to interactive sign-in.
  Future<bool> signIn() async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
      if (account == null) return false;
      await _persistUser(account);
      return true;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return false;
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

  /// Restores a previously signed-in session without showing UI.
  Future<void> restoreSession() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        await _persistUser(account);
      }
    } catch (e) {
      debugPrint('Google silent sign-in error: $e');
    }
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
