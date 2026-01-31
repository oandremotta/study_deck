import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/community_service.dart';
import '../../domain/entities/public_deck.dart';

// ============ Service Provider ============

/// Provider for community service.
final communityServiceProvider = Provider<CommunityService>((ref) {
  return CommunityService();
});

// ============ Public Decks Providers ============

/// Provider for recommended decks.
final recommendedDecksProvider =
    FutureProvider<List<PublicDeck>>((ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getRecommendedDecks();
});

/// Provider for decks by category.
final decksByCategoryProvider =
    FutureProvider.family<List<PublicDeck>, String>((ref, category) async {
  final service = ref.watch(communityServiceProvider);
  return service.getDecksByCategory(category);
});

/// Provider for searching decks.
final searchDecksProvider =
    FutureProvider.family<List<PublicDeck>, String>((ref, query) async {
  final service = ref.watch(communityServiceProvider);
  return service.searchDecks(query);
});

/// Provider for user's shared decks.
final userSharedDecksProvider =
    FutureProvider.family<List<PublicDeck>, String>((ref, userId) async {
  final service = ref.watch(communityServiceProvider);
  return service.getUserSharedDecks(userId);
});

// ============ Direct Functions ============

/// UC227: Share a deck publicly.
Future<PublicDeck> shareDeckDirect(
  CommunityService service, {
  required String originalDeckId,
  required String creatorId,
  required String creatorName,
  required String name,
  String? description,
  required String category,
  required int cardCount,
  required List<String> sampleCards,
  List<String> tags = const [],
}) async {
  return service.shareDeck(
    originalDeckId: originalDeckId,
    creatorId: creatorId,
    creatorName: creatorName,
    name: name,
    description: description,
    category: category,
    cardCount: cardCount,
    sampleCards: sampleCards,
    tags: tags,
  );
}

/// UC229: Record deck import.
Future<void> recordImportDirect(
  CommunityService service, {
  required String publicDeckId,
  required String userId,
}) async {
  await service.recordImport(publicDeckId: publicDeckId, userId: userId);
}

/// UC230: Rate a deck.
Future<void> rateDeckDirect(
  CommunityService service, {
  required String publicDeckId,
  required String userId,
  required DeckRating rating,
}) async {
  await service.rateDeck(
    publicDeckId: publicDeckId,
    userId: userId,
    rating: rating,
  );
}

/// UC232: Report a deck.
Future<void> reportDeckDirect(
  CommunityService service, {
  required String publicDeckId,
  required String userId,
  required ReportReason reason,
  String? details,
}) async {
  await service.reportDeck(
    publicDeckId: publicDeckId,
    userId: userId,
    reason: reason,
    details: details,
  );
}

/// UC233: Moderate a deck.
Future<void> moderateDeckDirect(
  CommunityService service, {
  required String publicDeckId,
  required ModerationStatus status,
  String? moderatorNote,
}) async {
  await service.moderateDeck(
    publicDeckId: publicDeckId,
    status: status,
    moderatorNote: moderatorNote,
  );
}

/// UC234: Remove own deck from community.
Future<void> removeOwnDeckDirect(
  CommunityService service, {
  required String publicDeckId,
  required String userId,
}) async {
  await service.removeOwnDeck(publicDeckId: publicDeckId, userId: userId);
}

/// Check if user imported a deck.
Future<bool> hasUserImportedDirect(
  CommunityService service, {
  required String publicDeckId,
  required String userId,
}) async {
  return service.hasUserImported(publicDeckId, userId);
}

/// Get user's rating for a deck.
Future<DeckRating?> getUserRatingDirect(
  CommunityService service, {
  required String publicDeckId,
  required String userId,
}) async {
  return service.getUserRating(publicDeckId, userId);
}
