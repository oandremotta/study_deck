import '../entities/user.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';

/// Contract for authentication operations.
///
/// This interface defines all authentication-related operations.
/// Implementations can use Firebase, Supabase, or any other backend.
abstract class AuthRepository {
  /// Stream of authentication state changes.
  ///
  /// Emits the current user when auth state changes.
  /// Emits null when user signs out.
  Stream<User?> get authStateChanges;

  /// Gets the currently authenticated user.
  ///
  /// Returns null if no user is authenticated.
  User? get currentUser;

  /// Creates and uses a local-only profile without authentication.
  ///
  /// UC01 - Use without account.
  Future<Either<Failure, User>> useWithoutAccount();

  /// Signs in with Google.
  ///
  /// UC02 - Sign in with Google.
  Future<Either<Failure, User>> signInWithGoogle();

  /// Signs in with Apple.
  ///
  /// UC02 - Sign in with Apple.
  Future<Either<Failure, User>> signInWithApple();

  /// Signs in with email and password.
  ///
  /// UC02 - Sign in with email.
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new account with email and password.
  ///
  /// UC02 - Create account with email.
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs out the current user.
  Future<Either<Failure, void>> signOut();

  /// Checks if there's an active session.
  bool get isAuthenticated;

  /// Checks if the current user is anonymous (local only).
  bool get isAnonymous;
}
