/// Result type for operations that can fail.
///
/// [Either] represents a value that can be one of two types:
/// - [Left] containing a failure/error
/// - [Right] containing a success value
///
/// This allows for type-safe error handling without throwing exceptions.
sealed class Either<L, R> {
  const Either();

  /// Returns true if this is a [Left] (failure).
  bool get isLeft => this is Left<L, R>;

  /// Returns true if this is a [Right] (success).
  bool get isRight => this is Right<L, R>;

  /// Folds the either into a single value.
  ///
  /// If this is [Left], calls [onLeft] with the left value.
  /// If this is [Right], calls [onRight] with the right value.
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);

  /// Maps the right value if present.
  Either<L, T> map<T>(T Function(R right) mapper);

  /// Maps the left value if present.
  Either<T, R> mapLeft<T>(T Function(L left) mapper);

  /// FlatMaps the right value if present.
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper);

  /// Returns the right value or a default value.
  R getOrElse(R Function() defaultValue);

  /// Returns the right value or null.
  R? getOrNull();
}

/// Represents a failure/left value.
final class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onLeft(value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) mapper) => Left(value);

  @override
  Either<T, R> mapLeft<T>(T Function(L left) mapper) => Left(mapper(value));

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) => Left(value);

  @override
  R getOrElse(R Function() defaultValue) => defaultValue();

  @override
  R? getOrNull() => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Left<L, R> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Represents a success/right value.
final class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onRight(value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) mapper) => Right(mapper(value));

  @override
  Either<T, R> mapLeft<T>(T Function(L left) mapper) => Right(value);

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) =>
      mapper(value);

  @override
  R getOrElse(R Function() defaultValue) => value;

  @override
  R? getOrNull() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Right<L, R> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
