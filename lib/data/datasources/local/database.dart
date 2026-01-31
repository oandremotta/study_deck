import 'package:drift/drift.dart';

import 'tables/user_table.dart';
import 'tables/folder_table.dart';
import 'tables/deck_table.dart';
import 'tables/card_table.dart';
import 'tables/tag_table.dart';
import 'tables/card_tag_table.dart';
import 'tables/study_session_table.dart';
import 'tables/card_srs_table.dart';
import 'tables/card_review_table.dart';
import 'tables/user_stats_table.dart';
import 'tables/ai_project_table.dart';
import 'tables/ai_card_draft_table.dart';
import 'daos/user_dao.dart';
import 'daos/folder_dao.dart';
import 'daos/deck_dao.dart';
import 'daos/card_dao.dart';
import 'daos/tag_dao.dart';
import 'daos/study_dao.dart';
import 'daos/ai_card_dao.dart';

// Conditional import for web/native
import 'connection/connection.dart'
    if (dart.library.io) 'connection/native.dart'
    if (dart.library.html) 'connection/web.dart' as connection;

part 'database.g.dart';

/// Main database class for local storage.
///
/// Uses Drift (SQLite) for type-safe database operations.
/// Supports both web (WASM) and native (SQLite) platforms.
@DriftDatabase(
  tables: [
    UserTable,
    FolderTable,
    DeckTable,
    CardTable,
    TagTable,
    CardTagTable,
    StudySessionTable,
    CardSrsTable,
    CardReviewTable,
    UserStatsTable,
    AiProjectTable,
    AiCardDraftTable,
  ],
  daos: [UserDao, FolderDao, DeckDao, CardDao, TagDao, StudyDao, AiCardDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.connect());

  /// Constructor for testing with custom executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add card, tag, and card_tag tables
          await m.createTable(cardTable);
          await m.createTable(tagTable);
          await m.createTable(cardTagTable);
        }
        if (from < 3) {
          // Add study-related tables
          await m.createTable(studySessionTable);
          await m.createTable(cardSrsTable);
          await m.createTable(cardReviewTable);
          await m.createTable(userStatsTable);
        }
        if (from < 4) {
          // Add UC33/UC34 columns to user_stats
          await customStatement(
            'ALTER TABLE user_stats ADD COLUMN streak_freezes INTEGER NOT NULL DEFAULT 1',
          );
          await customStatement(
            'ALTER TABLE user_stats ADD COLUMN weekly_cards_goal INTEGER NOT NULL DEFAULT 100',
          );
          await customStatement(
            'ALTER TABLE user_stats ADD COLUMN weekly_cards_studied INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE user_stats ADD COLUMN weekly_sessions_goal INTEGER NOT NULL DEFAULT 7',
          );
          await customStatement(
            'ALTER TABLE user_stats ADD COLUMN weekly_sessions_completed INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE user_stats ADD COLUMN week_start_date INTEGER',
          );
        }
        if (from < 5) {
          // Add AI card generation tables
          await m.createTable(aiProjectTable);
          await m.createTable(aiCardDraftTable);
        }
        if (from < 6) {
          // Add pedagogical fields to card_table (EP60-EP62)
          await customStatement(
            'ALTER TABLE card_table ADD COLUMN summary TEXT',
          );
          await customStatement(
            'ALTER TABLE card_table ADD COLUMN key_phrase TEXT',
          );
        }
        if (from < 7) {
          // Add pedagogical fields to ai_card_drafts (UC167/UC168)
          await customStatement(
            'ALTER TABLE ai_card_drafts ADD COLUMN summary TEXT',
          );
          await customStatement(
            'ALTER TABLE ai_card_drafts ADD COLUMN key_phrase TEXT',
          );
          await customStatement(
            'ALTER TABLE ai_card_drafts ADD COLUMN needs_review INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (from < 8) {
          // UC201-203: Add audio fields to card_table
          await customStatement(
            'ALTER TABLE card_table ADD COLUMN audio_url TEXT',
          );
          await customStatement(
            'ALTER TABLE card_table ADD COLUMN pronunciation_url TEXT',
          );
        }
      },
    );
  }
}
