import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../contracts/data_remote_datasource.dart';

/// Firebase Firestore implementation of [DataRemoteDatasource].
///
/// This class handles all Firestore data operations.
class FirebaseFirestoreDatasource implements DataRemoteDatasource {
  final FirebaseFirestore _firestore;

  FirebaseFirestoreDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _foldersCollection =>
      _firestore.collection('folders');

  CollectionReference<Map<String, dynamic>> get _decksCollection =>
      _firestore.collection('decks');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<List<RemoteFolder>> getFolders(String userId) async {
    try {
      final snapshot = await _foldersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => _folderFromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get folders',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<RemoteFolder> createFolder({
    required String userId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    try {
      final docRef = await _foldersCollection.add({
        'userId': userId,
        'name': name,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      return RemoteFolder(
        id: docRef.id,
        name: name,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create folder',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<RemoteFolder> updateFolder({
    required String remoteId,
    required String name,
    required DateTime updatedAt,
  }) async {
    try {
      await _foldersCollection.doc(remoteId).update({
        'name': name,
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      final doc = await _foldersCollection.doc(remoteId).get();
      return _folderFromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update folder',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteFolder(String remoteId) async {
    try {
      await _foldersCollection.doc(remoteId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete folder',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<List<RemoteDeck>> getDecks(String userId) async {
    try {
      final snapshot = await _decksCollection
          .where('userId', isEqualTo: userId)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => _deckFromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get decks',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<RemoteDeck> createDeck({
    required String userId,
    required String name,
    String? description,
    String? folderId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    try {
      final docRef = await _decksCollection.add({
        'userId': userId,
        'name': name,
        'description': description,
        'folderId': folderId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      return RemoteDeck(
        id: docRef.id,
        name: name,
        description: description,
        userId: userId,
        folderId: folderId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create deck',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<RemoteDeck> updateDeck({
    required String remoteId,
    required String name,
    String? description,
    String? folderId,
    required DateTime updatedAt,
  }) async {
    try {
      await _decksCollection.doc(remoteId).update({
        'name': name,
        'description': description,
        'folderId': folderId,
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      final doc = await _decksCollection.doc(remoteId).get();
      return _deckFromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update deck',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteDeck(String remoteId) async {
    try {
      await _decksCollection.doc(remoteId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete deck',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteDecksByFolder(String remoteFolderId) async {
    try {
      final snapshot = await _decksCollection
          .where('folderId', isEqualTo: remoteFolderId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete decks',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> moveDecksToRoot(String remoteFolderId) async {
    try {
      final snapshot = await _decksCollection
          .where('folderId', isEqualTo: remoteFolderId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'folderId': null});
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to move decks',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null || !data.containsKey('lastSyncAt')) return null;

      final timestamp = data['lastSyncAt'] as Timestamp?;
      return timestamp?.toDate();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get last sync time',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<bool> hasData(String userId) async {
    try {
      // Check if user has any folders
      final foldersSnapshot = await _foldersCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (foldersSnapshot.docs.isNotEmpty) return true;

      // Check if user has any decks
      final decksSnapshot = await _decksCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return decksSnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to check for data',
        code: e.code,
        originalError: e,
      );
    }
  }

  RemoteFolder _folderFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RemoteFolder(
      id: doc.id,
      name: data['name'] as String,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  RemoteDeck _deckFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RemoteDeck(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      userId: data['userId'] as String,
      folderId: data['folderId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
