import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/errors/exceptions.dart';
import '../contracts/auth_remote_datasource.dart';

/// Firebase implementation of [AuthRemoteDatasource].
///
/// This class handles all Firebase Authentication operations.
class FirebaseAuthDatasource implements AuthRemoteDatasource {
  final fb.FirebaseAuth _firebaseAuth;
  GoogleSignIn? _googleSignIn;

  FirebaseAuthDatasource({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn;

  /// Lazy initialization of GoogleSignIn to avoid web client ID errors at startup.
  GoogleSignIn get _google => _googleSignIn ??= GoogleSignIn();

  @override
  Stream<RemoteUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return RemoteUser(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    });
  }

  @override
  RemoteUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return RemoteUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  @override
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  @override
  Future<RemoteUser> signInWithGoogle() async {
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) {
        throw const AuthException(
          message: 'Google sign in was cancelled',
          code: 'google-sign-in-cancelled',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(
          message: 'Failed to sign in with Google',
          code: 'google-sign-in-failed',
        );
      }

      return RemoteUser(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Firebase auth error',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<RemoteUser> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(
          message: 'Failed to sign in with Apple',
          code: 'apple-sign-in-failed',
        );
      }

      // Apple only provides name on first sign in
      String? displayName = user.displayName;
      if (displayName == null &&
          appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        displayName =
            '${appleCredential.givenName} ${appleCredential.familyName}';
        await user.updateDisplayName(displayName);
      }

      return RemoteUser(
        id: user.uid,
        email: user.email,
        displayName: displayName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AuthException(
        message: e.message,
        code: 'apple-sign-in-error',
        originalError: e,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Firebase auth error',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<RemoteUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(
          message: 'Failed to sign in with email',
          code: 'email-sign-in-failed',
        );
      }

      return RemoteUser(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Firebase auth error',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<RemoteUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(
          message: 'Failed to create account',
          code: 'email-sign-up-failed',
        );
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      return RemoteUser(
        id: user.uid,
        email: user.email,
        displayName: displayName ?? user.displayName,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Firebase auth error',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      // Only sign out from Google if it was initialized
      if (_googleSignIn != null) {
        await _google.signOut();
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Failed to sign out',
        code: e.code,
        originalError: e,
      );
    }
  }
}
