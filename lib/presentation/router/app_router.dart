import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../screens/auth/link_data_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/folders/folder_form_screen.dart';
import '../screens/folders/folders_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/decks/decks_screen.dart';
import '../screens/decks/deck_form_screen.dart';
import '../screens/decks/deck_detail_screen.dart';
import '../screens/cards/card_form_screen.dart';
import '../screens/cards/legacy_migration_screen.dart';
import '../screens/cards/trash_screen.dart';
import '../screens/cards/import_screen.dart';
import '../screens/cards/export_screen.dart';
import '../screens/study/study_screen.dart';
import '../screens/study/session_summary_screen.dart';
import '../screens/tags/tag_management_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/accessibility_settings_screen.dart';
import '../screens/settings/language_settings_screen.dart';
import '../screens/ai_cards/ai_cards_hub_screen.dart';
import '../screens/ai_cards/create_from_text_screen.dart';
import '../screens/ai_cards/create_from_pdf_screen.dart';
import '../screens/ai_cards/generation_config_screen.dart';
import '../screens/ai_cards/generation_progress_screen.dart';
import '../screens/ai_cards/review_drafts_screen.dart';
import '../screens/ai_cards/import_to_deck_screen.dart';
import '../screens/ai_cards/ai_history_screen.dart';
import '../screens/subscription/plans_screen.dart';
import '../screens/subscription/paywall_screen.dart';
import '../screens/subscription/subscription_settings_screen.dart';
import '../screens/subscription/ai_credits_screen.dart';
import '../screens/privacy/consent_screen.dart';
import '../screens/privacy/privacy_settings_screen.dart';
import '../screens/privacy/data_export_screen.dart';
import '../screens/privacy/delete_account_screen.dart';
import '../screens/privacy/security_log_screen.dart';
import '../screens/backup/backup_screen.dart';
import '../screens/backup/sync_settings_screen.dart';
import '../screens/backup/conflict_resolution_screen.dart';
import '../../domain/entities/study_session.dart';

part 'app_router.g.dart';

/// Route paths constants.
abstract class AppRoutes {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const linkData = '/link-data';
  static const home = '/';
  static const folders = '/folders';
  static const folderForm = '/folders/form';
  static const decks = '/decks';
  static const deckForm = '/decks/form';
  static const deckDetail = '/decks/detail';
  static const deckTrash = '/decks/trash';
  static const cardForm = '/cards/form';
  static const cardMigration = '/cards/migration';
  static const importCards = '/cards/import';
  static const exportDeck = '/decks/export';
  static const study = '/study';
  static const sessionSummary = '/study/summary';
  static const tags = '/tags';
  static const stats = '/stats';
  static const settings = '/settings';
  static const settingsAccessibility = '/settings/accessibility';
  static const settingsLanguage = '/settings/language';

  // AI Cards routes
  static const aiCardsHub = '/ai-cards';
  static const aiFromPdf = '/ai-cards/pdf';
  static const aiFromText = '/ai-cards/text';
  static const aiFromTopic = '/ai-cards/topic';
  static const aiConfig = '/ai-cards/config';
  static const aiProgress = '/ai-cards/progress';
  static const aiReview = '/ai-cards/review';
  static const aiImport = '/ai-cards/import';
  static const aiHistory = '/ai-cards/history';

  // Subscription routes (EP82)
  static const subscriptionPlans = '/subscription/plans';
  static const subscriptionPaywall = '/subscription/paywall';
  static const subscriptionSettings = '/subscription/settings';
  static const subscriptionCredits = '/subscription/credits';

  // Privacy routes (EP83)
  static const privacyConsent = '/privacy/consent';
  static const privacySettings = '/privacy/settings';
  static const privacyDataExport = '/privacy/export';
  static const privacyDeleteAccount = '/privacy/delete';
  static const privacySecurityLog = '/privacy/security';

  // Backup/Sync routes (EP84)
  static const backupManagement = '/backup';
  static const syncSettings = '/sync/settings';
  static const syncConflicts = '/sync/conflicts';
}

/// Alias for backward compatibility with screens using AppRouter.
typedef AppRouter = AppRoutes;

/// Provider for the GoRouter instance.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    // Redirect logic removed to avoid Riverpod ref issues
    // Navigation is handled manually in screens
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.linkData,
        name: 'linkData',
        builder: (context, state) => const LinkDataScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.folders,
        name: 'folders',
        builder: (context, state) => const FoldersScreen(),
      ),
      GoRoute(
        path: AppRoutes.folderForm,
        name: 'folderForm',
        builder: (context, state) {
          final folderId = state.uri.queryParameters['id'];
          return FolderFormScreen(folderId: folderId);
        },
      ),
      // Deck routes
      GoRoute(
        path: AppRoutes.decks,
        name: 'decks',
        builder: (context, state) {
          final folderId = state.uri.queryParameters['folderId'];
          final folderName = state.uri.queryParameters['folderName'];
          return DecksScreen(folderId: folderId, folderName: folderName);
        },
      ),
      GoRoute(
        path: AppRoutes.deckForm,
        name: 'deckForm',
        builder: (context, state) {
          final deckId = state.uri.queryParameters['id'];
          final folderId = state.uri.queryParameters['folderId'];
          return DeckFormScreen(deckId: deckId, folderId: folderId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.deckDetail}/:id',
        name: 'deckDetail',
        builder: (context, state) {
          final deckId = state.pathParameters['id']!;
          return DeckDetailScreen(deckId: deckId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.deckTrash}/:id',
        name: 'deckTrash',
        builder: (context, state) {
          final deckId = state.pathParameters['id']!;
          return TrashScreen(deckId: deckId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.exportDeck}/:id',
        name: 'exportDeck',
        builder: (context, state) {
          final deckId = state.pathParameters['id']!;
          return ExportScreen(deckId: deckId);
        },
      ),
      // Card routes
      GoRoute(
        path: AppRoutes.cardForm,
        name: 'cardForm',
        builder: (context, state) {
          final deckId = state.uri.queryParameters['deckId']!;
          final cardId = state.uri.queryParameters['id'];
          return CardFormScreen(deckId: deckId, cardId: cardId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.cardMigration}/:deckId',
        name: 'cardMigration',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId']!;
          return LegacyMigrationScreen(deckId: deckId);
        },
      ),
      GoRoute(
        path: AppRoutes.importCards,
        name: 'importCards',
        builder: (context, state) {
          final deckId = state.uri.queryParameters['deckId']!;
          return ImportScreen(deckId: deckId);
        },
      ),
      // Study routes
      GoRoute(
        path: AppRoutes.study,
        name: 'study',
        builder: (context, state) {
          final deckId = state.uri.queryParameters['deckId'];
          final modeStr = state.uri.queryParameters['mode'] ?? 'studyNow';
          final mode = StudyMode.values.firstWhere(
            (m) => m.name == modeStr,
            orElse: () => StudyMode.studyNow,
          );
          return StudyScreen(deckId: deckId, mode: mode);
        },
      ),
      GoRoute(
        path: AppRoutes.sessionSummary,
        name: 'sessionSummary',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['sessionId']!;
          return SessionSummaryScreen(sessionId: sessionId);
        },
      ),
      // Tag routes
      GoRoute(
        path: AppRoutes.tags,
        name: 'tags',
        builder: (context, state) => const TagManagementScreen(),
      ),
      // Stats routes
      GoRoute(
        path: AppRoutes.stats,
        name: 'stats',
        builder: (context, state) => const StatsScreen(),
      ),
      // Settings routes
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsAccessibility,
        name: 'settingsAccessibility',
        builder: (context, state) => const AccessibilitySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsLanguage,
        name: 'settingsLanguage',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      // AI Cards routes
      GoRoute(
        path: AppRoutes.aiCardsHub,
        name: 'aiCardsHub',
        builder: (context, state) => const AiCardsHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiFromText,
        name: 'aiFromText',
        builder: (context, state) => const CreateFromTextScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiFromPdf,
        name: 'aiFromPdf',
        builder: (context, state) => const CreateFromPdfScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.aiConfig}/:projectId',
        name: 'aiConfig',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return GenerationConfigScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.aiProgress}/:projectId',
        name: 'aiProgress',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return GenerationProgressScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.aiReview}/:projectId',
        name: 'aiReview',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ReviewDraftsScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.aiImport}/:projectId',
        name: 'aiImport',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ImportToDeckScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.aiHistory,
        name: 'aiHistory',
        builder: (context, state) => const AiHistoryScreen(),
      ),
      // Subscription routes
      GoRoute(
        path: AppRoutes.subscriptionPlans,
        name: 'subscriptionPlans',
        builder: (context, state) => const PlansScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionPaywall,
        name: 'subscriptionPaywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionSettings,
        name: 'subscriptionSettings',
        builder: (context, state) => const SubscriptionSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionCredits,
        name: 'subscriptionCredits',
        builder: (context, state) => const AiCreditsScreen(),
      ),
      // Privacy routes
      GoRoute(
        path: AppRoutes.privacyConsent,
        name: 'privacyConsent',
        builder: (context, state) => const ConsentScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacySettings,
        name: 'privacySettings',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyDataExport,
        name: 'privacyDataExport',
        builder: (context, state) => const DataExportScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyDeleteAccount,
        name: 'privacyDeleteAccount',
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacySecurityLog,
        name: 'privacySecurityLog',
        builder: (context, state) => const SecurityLogScreen(),
      ),
      // Backup/Sync routes
      GoRoute(
        path: AppRoutes.backupManagement,
        name: 'backupManagement',
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: AppRoutes.syncSettings,
        name: 'syncSettings',
        builder: (context, state) => const SyncSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.syncConflicts,
        name: 'syncConflicts',
        builder: (context, state) => const ConflictResolutionScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
