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
import '../screens/cards/trash_screen.dart';
import '../screens/cards/import_screen.dart';
import '../screens/cards/export_screen.dart';
import '../screens/study/study_screen.dart';
import '../screens/study/session_summary_screen.dart';
import '../screens/tags/tag_management_screen.dart';
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
  static const importCards = '/cards/import';
  static const exportDeck = '/decks/export';
  static const study = '/study';
  static const sessionSummary = '/study/summary';
  static const tags = '/tags';
}

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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
