import 'package:drift/drift.dart';

/// Table for storing AI-generated card drafts.
class AiCardDraftTable extends Table {
  @override
  String get tableName => 'ai_card_drafts';

  /// Unique identifier.
  TextColumn get id => text()();

  /// ID of the parent AI project.
  TextColumn get projectId => text()();

  /// Front side content (question).
  TextColumn get front => text()();

  /// Back side content (answer).
  TextColumn get back => text()();

  /// Optional hint.
  TextColumn get hint => text().nullable()();

  /// Tags suggested by AI as JSON array.
  TextColumn get suggestedTagsJson =>
      text().withDefault(const Constant('[]'))();

  /// Difficulty level: 'easy', 'medium', 'hard'.
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();

  /// Review status: 'pending', 'approved', 'edited', 'rejected'.
  TextColumn get reviewStatus =>
      text().withDefault(const Constant('pending'))();

  /// Whether this might be a duplicate of existing card.
  BoolColumn get isPotentialDuplicate =>
      boolean().withDefault(const Constant(false))();

  /// ID of similar existing card (if duplicate detected).
  TextColumn get similarCardId => text().nullable()();

  /// AI confidence score (0.0 to 1.0).
  RealColumn get confidenceScore =>
      real().withDefault(const Constant(0.8))();

  /// Short answer/summary (≤240 chars) - pedagogical field.
  TextColumn get summary => text().nullable()();

  /// Memory anchor phrase (≤120 chars) - pedagogical field.
  TextColumn get keyPhrase => text().nullable()();

  /// Whether this draft needs human review due to fallback applied (UC168).
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();

  /// Order index for display.
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  /// When the draft was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the draft was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
