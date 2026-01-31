import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/public_deck.dart';

/// UC227-UC234: Community service for deck sharing and discovery.
///
/// Handles:
/// - Sharing decks publicly (UC227)
/// - Browsing public decks (UC228)
/// - Importing public decks (UC229)
/// - Rating decks (UC230)
/// - Featuring quality decks (UC231)
/// - Reporting and moderation (UC232-UC233)
/// - Removing shared decks (UC234)
class CommunityService {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  static const String _publicDecksCollection = 'public_decks';
  static const String _ratingsCollection = 'deck_ratings';
  static const String _reportsCollection = 'deck_reports';
  static const String _importsCollection = 'deck_imports';

  CommunityService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// UC227: Share a deck publicly.
  Future<PublicDeck> shareDeck({
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
    final id = _uuid.v4();
    final now = DateTime.now();

    final publicDeck = PublicDeck(
      id: id,
      originalDeckId: originalDeckId,
      creatorId: creatorId,
      creatorName: creatorName,
      name: name,
      description: description,
      category: category,
      cardCount: cardCount,
      sampleCards: sampleCards,
      tags: tags,
      sharedAt: now,
      updatedAt: now,
      moderationStatus: ModerationStatus.pending,
    );

    await _firestore.collection(_publicDecksCollection).doc(id).set({
      ...publicDeck.toMap(),
      'searchTerms': _generateSearchTerms(name, description, tags),
    });

    debugPrint('CommunityService: Shared deck $id');
    return publicDeck;
  }

  /// UC228: Get public decks by category.
  Future<List<PublicDeck>> getDecksByCategory(
    String category, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _firestore
        .collection(_publicDecksCollection)
        .where('category', isEqualTo: category)
        .where('moderationStatus', whereIn: ['pending', 'approved'])
        .orderBy('importCount', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _parsePublicDeck(doc)).toList();
  }

  /// UC228: Get recommended decks.
  Future<List<PublicDeck>> getRecommendedDecks({int limit = 10}) async {
    final snapshot = await _firestore
        .collection(_publicDecksCollection)
        .where('isRecommended', isEqualTo: true)
        .where('moderationStatus', isEqualTo: 'approved')
        .orderBy('importCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => _parsePublicDeck(doc)).toList();
  }

  /// UC228: Search public decks.
  Future<List<PublicDeck>> searchDecks(String query, {int limit = 20}) async {
    final searchTerms = query.toLowerCase().split(' ');

    final snapshot = await _firestore
        .collection(_publicDecksCollection)
        .where('searchTerms', arrayContainsAny: searchTerms)
        .where('moderationStatus', whereIn: ['pending', 'approved'])
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => _parsePublicDeck(doc)).toList();
  }

  /// UC229: Record import of a public deck.
  Future<void> recordImport({
    required String publicDeckId,
    required String userId,
  }) async {
    // Record the import
    await _firestore.collection(_importsCollection).add({
      'publicDeckId': publicDeckId,
      'userId': userId,
      'importedAt': FieldValue.serverTimestamp(),
    });

    // Increment import count
    await _firestore.collection(_publicDecksCollection).doc(publicDeckId).update({
      'importCount': FieldValue.increment(1),
    });

    // Check for recommendation eligibility
    await _checkAndUpdateRecommendation(publicDeckId);
  }

  /// UC230: Rate a deck.
  Future<void> rateDeck({
    required String publicDeckId,
    required String userId,
    required DeckRating rating,
  }) async {
    final ratingDoc = await _firestore
        .collection(_ratingsCollection)
        .where('publicDeckId', isEqualTo: publicDeckId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    // Check if user already rated
    if (ratingDoc.docs.isNotEmpty) {
      final existingRating = ratingDoc.docs.first;
      final oldRating = existingRating.data()['rating'] as String;

      // Update existing rating
      await existingRating.reference.update({
        'rating': rating.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update counts
      final deckRef = _firestore.collection(_publicDecksCollection).doc(publicDeckId);
      if (oldRating != rating.name) {
        if (rating == DeckRating.useful) {
          await deckRef.update({
            'usefulCount': FieldValue.increment(1),
            'notUsefulCount': FieldValue.increment(-1),
          });
        } else {
          await deckRef.update({
            'usefulCount': FieldValue.increment(-1),
            'notUsefulCount': FieldValue.increment(1),
          });
        }
      }
    } else {
      // New rating
      await _firestore.collection(_ratingsCollection).add({
        'publicDeckId': publicDeckId,
        'userId': userId,
        'rating': rating.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update counts
      final field = rating == DeckRating.useful ? 'usefulCount' : 'notUsefulCount';
      await _firestore.collection(_publicDecksCollection).doc(publicDeckId).update({
        field: FieldValue.increment(1),
      });
    }

    // Check for recommendation eligibility
    await _checkAndUpdateRecommendation(publicDeckId);
  }

  /// UC231: Check and update recommendation status.
  Future<void> _checkAndUpdateRecommendation(String publicDeckId) async {
    final doc = await _firestore.collection(_publicDecksCollection).doc(publicDeckId).get();
    if (!doc.exists) return;

    final deck = _parsePublicDeck(doc);

    if (deck.qualifiesForRecommendation && !deck.isRecommended) {
      await _firestore.collection(_publicDecksCollection).doc(publicDeckId).update({
        'isRecommended': true,
      });
      debugPrint('CommunityService: Deck $publicDeckId now recommended');
    }
  }

  /// UC232: Report a deck.
  Future<void> reportDeck({
    required String publicDeckId,
    required String userId,
    required ReportReason reason,
    String? details,
  }) async {
    final reportId = _uuid.v4();

    await _firestore.collection(_reportsCollection).doc(reportId).set({
      'id': reportId,
      'publicDeckId': publicDeckId,
      'reporterUserId': userId,
      'reason': reason.name,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
      'status': ReportStatus.pending.name,
    });

    // Increment report count
    await _firestore.collection(_publicDecksCollection).doc(publicDeckId).update({
      'reportCount': FieldValue.increment(1),
    });

    debugPrint('CommunityService: Deck $publicDeckId reported');
  }

  /// UC233: Get pending reports (for moderation).
  Future<List<DeckReport>> getPendingReports({int limit = 50}) async {
    final snapshot = await _firestore
        .collection(_reportsCollection)
        .where('status', isEqualTo: ReportStatus.pending.name)
        .orderBy('createdAt')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DeckReport(
        id: data['id'],
        publicDeckId: data['publicDeckId'],
        reporterUserId: data['reporterUserId'],
        reason: ReportReason.values.byName(data['reason']),
        details: data['details'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        status: ReportStatus.values.byName(data['status']),
      );
    }).toList();
  }

  /// UC233: Moderate a deck (approve/reject/remove).
  Future<void> moderateDeck({
    required String publicDeckId,
    required ModerationStatus status,
    String? moderatorNote,
  }) async {
    await _firestore.collection(_publicDecksCollection).doc(publicDeckId).update({
      'moderationStatus': status.name,
      'moderatorNote': moderatorNote,
      'moderatedAt': FieldValue.serverTimestamp(),
    });

    // If removed, also update reports
    if (status == ModerationStatus.removed) {
      final reports = await _firestore
          .collection(_reportsCollection)
          .where('publicDeckId', isEqualTo: publicDeckId)
          .where('status', isEqualTo: ReportStatus.pending.name)
          .get();

      for (final doc in reports.docs) {
        await doc.reference.update({
          'status': ReportStatus.actionTaken.name,
        });
      }
    }

    debugPrint('CommunityService: Moderated deck $publicDeckId -> $status');
  }

  /// UC234: Remove own deck from community.
  Future<void> removeOwnDeck({
    required String publicDeckId,
    required String userId,
  }) async {
    final doc = await _firestore.collection(_publicDecksCollection).doc(publicDeckId).get();

    if (!doc.exists) {
      throw Exception('Deck não encontrado');
    }

    if (doc.data()?['creatorId'] != userId) {
      throw Exception('Você não tem permissão para remover este deck');
    }

    await _firestore.collection(_publicDecksCollection).doc(publicDeckId).delete();
    debugPrint('CommunityService: Deck $publicDeckId removed by owner');
  }

  /// Get user's shared decks.
  Future<List<PublicDeck>> getUserSharedDecks(String userId) async {
    final snapshot = await _firestore
        .collection(_publicDecksCollection)
        .where('creatorId', isEqualTo: userId)
        .orderBy('sharedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _parsePublicDeck(doc)).toList();
  }

  /// Check if user has already imported a deck.
  Future<bool> hasUserImported(String publicDeckId, String userId) async {
    final snapshot = await _firestore
        .collection(_importsCollection)
        .where('publicDeckId', isEqualTo: publicDeckId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get user's rating for a deck.
  Future<DeckRating?> getUserRating(String publicDeckId, String userId) async {
    final snapshot = await _firestore
        .collection(_ratingsCollection)
        .where('publicDeckId', isEqualTo: publicDeckId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final rating = snapshot.docs.first.data()['rating'] as String;
    return DeckRating.values.byName(rating);
  }

  // ============ Helpers ============

  List<String> _generateSearchTerms(
    String name,
    String? description,
    List<String> tags,
  ) {
    final terms = <String>{};

    // Add name words
    for (final word in name.toLowerCase().split(' ')) {
      if (word.length >= 3) terms.add(word);
    }

    // Add description words
    if (description != null) {
      for (final word in description.toLowerCase().split(' ')) {
        if (word.length >= 3) terms.add(word);
      }
    }

    // Add tags
    for (final tag in tags) {
      terms.add(tag.toLowerCase());
    }

    return terms.toList();
  }

  PublicDeck _parsePublicDeck(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PublicDeck(
      id: doc.id,
      originalDeckId: data['originalDeckId'],
      creatorId: data['creatorId'],
      creatorName: data['creatorName'],
      name: data['name'],
      description: data['description'],
      category: data['category'],
      cardCount: data['cardCount'],
      importCount: data['importCount'] ?? 0,
      usefulCount: data['usefulCount'] ?? 0,
      notUsefulCount: data['notUsefulCount'] ?? 0,
      isRecommended: data['isRecommended'] ?? false,
      averageRetention: data['averageRetention']?.toDouble(),
      sampleCards: List<String>.from(data['sampleCards'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      sharedAt: (data['sharedAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      moderationStatus: ModerationStatus.values.byName(
        data['moderationStatus'] ?? 'pending',
      ),
      reportCount: data['reportCount'] ?? 0,
    );
  }
}

extension on PublicDeck {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalDeckId': originalDeckId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'name': name,
      'description': description,
      'category': category,
      'cardCount': cardCount,
      'importCount': importCount,
      'usefulCount': usefulCount,
      'notUsefulCount': notUsefulCount,
      'isRecommended': isRecommended,
      'averageRetention': averageRetention,
      'sampleCards': sampleCards,
      'tags': tags,
      'sharedAt': Timestamp.fromDate(sharedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'moderationStatus': moderationStatus.name,
      'reportCount': reportCount,
    };
  }
}
