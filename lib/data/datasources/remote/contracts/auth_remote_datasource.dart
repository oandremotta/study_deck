/// Contract for remote authentication operations.
///
/// This interface defines all remote authentication operations.
/// Implementations can use Firebase, Supabase, or any other backend.
///
/// **Migration point**: To switch from Firebase to another backend,
/// create a new implementation of this interface.
abstract class AuthRemoteDatasource {
  /// Stream of authentication state changes.
  ///
  /// Emits the current remote user when auth state changes.
  /// Emits null when user signs out.
  Stream<RemoteUser?> get authStateChanges;

  /// Gets the currently authenticated remote user.
  RemoteUser? get currentUser;

  /// Signs in with Google.
  Future<RemoteUser> signInWithGoogle();

  /// Signs in with Apple.
  Future<RemoteUser> signInWithApple();

  /// Signs in with email and password.
  Future<RemoteUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new account with email and password.
  Future<RemoteUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Checks if there's an active session.
  bool get isAuthenticated;
}

/// Represents a user from the remote authentication service.
///
/// This is a simple DTO that maps to the domain [User] entity.
class RemoteUser {
  final String id;
  final String? email;
  final String? displayName;

  const RemoteUser({
    required this.id,
    this.email,
    this.displayName,
  });
}
