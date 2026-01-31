import 'package:drift/drift.dart';

/// Table for storing AI card generation projects.
class AiProjectTable extends Table {
  @override
  String get tableName => 'ai_projects';

  /// Unique identifier.
  TextColumn get id => text()();

  /// User who created this project.
  TextColumn get userId => text()();

  /// Source type: 'pdf', 'text', 'topic'.
  TextColumn get sourceType => text()();

  /// Original file name (for PDF source).
  TextColumn get fileName => text().nullable()();

  /// Firebase Storage path for PDF.
  TextColumn get pdfStoragePath => text().nullable()();

  /// Extracted or pasted text content.
  TextColumn get extractedText => text().nullable()();

  /// Topic/subject for generation (for topic source).
  TextColumn get topic => text().nullable()();

  /// Generation configuration as JSON.
  TextColumn get configJson => text().withDefault(const Constant('{}'))();

  /// Current status: 'created', 'extracting', 'generating', 'review', 'completed', 'failed'.
  TextColumn get status => text().withDefault(const Constant('created'))();

  /// Error message if failed.
  TextColumn get errorMessage => text().nullable()();

  /// Number of cards requested.
  IntColumn get requestedCardCount =>
      integer().withDefault(const Constant(10))();

  /// Number of cards actually generated.
  IntColumn get generatedCardCount =>
      integer().withDefault(const Constant(0))();

  /// Number of cards approved by user.
  IntColumn get approvedCardCount =>
      integer().withDefault(const Constant(0))();

  /// Target deck for import.
  TextColumn get targetDeckId => text().nullable()();

  /// When the project was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the project was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  /// When the project was completed.
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
