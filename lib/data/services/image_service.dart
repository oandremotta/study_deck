import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Service for handling image operations (UC115, UC116, UC121-UC124).
///
/// Handles:
/// - Image picking from gallery/camera
/// - Image compression (UC124)
/// - Upload to Firebase Storage (UC115, UC123)
/// - Delete from Firebase Storage (UC116)
class ImageService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;
  final Uuid _uuid;

  /// Maximum file size in bytes (2MB - UC124).
  static const int maxFileSizeBytes = 2 * 1024 * 1024;

  /// Compression quality (0-100).
  static const int compressionQuality = 80;

  /// Maximum image dimension.
  static const int maxImageDimension = 1200;

  ImageService({
    FirebaseStorage? storage,
    ImagePicker? picker,
    Uuid? uuid,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker(),
        _uuid = uuid ?? const Uuid();

  /// Check if camera is available (not on web).
  bool get isCameraAvailable => !kIsWeb;

  /// Pick image from gallery.
  /// Uses file_picker on web, image_picker on mobile.
  Future<XFile?> pickFromGallery() async {
    try {
      if (kIsWeb) {
        // Use file_picker for web
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          if (file.bytes != null) {
            // Create XFile from bytes for web
            return XFile.fromData(
              file.bytes!,
              name: file.name,
              mimeType: _getMimeType(file.extension),
            );
          }
        }
        return null;
      }

      // Use image_picker for mobile
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxImageDimension.toDouble(),
        maxHeight: maxImageDimension.toDouble(),
        imageQuality: compressionQuality,
      );
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera (mobile only).
  Future<XFile?> pickFromCamera() async {
    if (kIsWeb) {
      debugPrint('Camera not available on web');
      return null;
    }

    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxImageDimension.toDouble(),
        maxHeight: maxImageDimension.toDouble(),
        imageQuality: compressionQuality,
      );
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Get MIME type from file extension.
  String _getMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  /// Compress image bytes (UC124).
  Future<Uint8List?> compressImage(Uint8List bytes) async {
    try {
      // Skip compression on web (flutter_image_compress doesn't support web well)
      if (kIsWeb) {
        return bytes;
      }

      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: maxImageDimension,
        minHeight: maxImageDimension,
        quality: compressionQuality,
        format: CompressFormat.jpeg,
      );

      return result;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return bytes; // Return original if compression fails
    }
  }

  /// Compress image file.
  Future<File?> compressImageFile(File file) async {
    try {
      if (kIsWeb) return file;

      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${_uuid.v4()}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        minWidth: maxImageDimension,
        minHeight: maxImageDimension,
        quality: compressionQuality,
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : file;
    } catch (e) {
      debugPrint('Error compressing image file: $e');
      return file;
    }
  }

  /// Upload image to Firebase Storage (UC115, UC123).
  ///
  /// Path structure: /users/{userId}/cards/{cardId}/image.jpg
  Future<String?> uploadImage({
    required String userId,
    required String cardId,
    required Uint8List imageBytes,
    String? fileName,
  }) async {
    try {
      // Validate file size (UC124)
      if (imageBytes.length > maxFileSizeBytes) {
        debugPrint('Image too large: ${imageBytes.length} bytes');
        // Try to compress
        final compressed = await compressImage(imageBytes);
        if (compressed != null && compressed.length <= maxFileSizeBytes) {
          return _doUpload(
            userId: userId,
            cardId: cardId,
            imageBytes: compressed,
            fileName: fileName,
          );
        }
        throw Exception('Imagem muito grande. Máximo: 2MB');
      }

      return _doUpload(
        userId: userId,
        cardId: cardId,
        imageBytes: imageBytes,
        fileName: fileName,
      );
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<String?> _doUpload({
    required String userId,
    required String cardId,
    required Uint8List imageBytes,
    String? fileName,
  }) async {
    debugPrint('=== DEBUG: _doUpload started ===');
    debugPrint('userId: $userId');
    debugPrint('cardId: $cardId');
    debugPrint('imageBytes length: ${imageBytes.length}');
    debugPrint('kIsWeb: $kIsWeb');

    // UC123: Organize images in Firebase Storage
    final storagePath = 'users/$userId/cards/$cardId/${fileName ?? 'image.jpg'}';
    debugPrint('storagePath: $storagePath');

    debugPrint('Getting storage ref...');
    final ref = _storage.ref().child(storagePath);
    debugPrint('Storage ref obtained: ${ref.fullPath}');

    // Set metadata
    debugPrint('Creating metadata...');
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'cardId': cardId,
        'userId': userId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
    debugPrint('Metadata created');

    // Upload
    debugPrint('Starting putData...');
    try {
      final uploadTask = ref.putData(imageBytes, metadata);
      debugPrint('putData called, waiting for completion...');

      // Wait for completion
      final snapshot = await uploadTask;
      debugPrint('Upload completed! Bytes transferred: ${snapshot.bytesTransferred}');

      // Get download URL
      debugPrint('Getting download URL...');
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (uploadError) {
      debugPrint('!!! Upload error: $uploadError');
      debugPrint('!!! Error type: ${uploadError.runtimeType}');
      rethrow;
    }
  }

  /// Upload image from XFile (for image_picker results).
  Future<String?> uploadFromXFile({
    required String userId,
    required String cardId,
    required XFile xFile,
  }) async {
    debugPrint('=== DEBUG: uploadFromXFile started ===');
    debugPrint('userId: $userId, cardId: $cardId');
    debugPrint('xFile name: ${xFile.name}, path: ${xFile.path}');

    try {
      debugPrint('Reading bytes from XFile...');
      final bytes = await xFile.readAsBytes();
      debugPrint('Bytes read: ${bytes.length}');
      final compressed = await compressImage(bytes);

      return uploadImage(
        userId: userId,
        cardId: cardId,
        imageBytes: compressed ?? bytes,
        fileName: 'image.jpg',
      );
    } catch (e) {
      debugPrint('Error uploading from XFile: $e');
      rethrow;
    }
  }

  /// Delete image from Firebase Storage (UC116).
  Future<void> deleteImage({
    required String userId,
    required String cardId,
  }) async {
    try {
      final storagePath = 'users/$userId/cards/$cardId/image.jpg';
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
      if (e is FirebaseException && e.code == 'object-not-found') {
        debugPrint('Image not found, nothing to delete');
        return;
      }
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }

  /// Delete image by URL.
  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        debugPrint('Image not found, nothing to delete');
        return;
      }
      debugPrint('Error deleting image by URL: $e');
      rethrow;
    }
  }

  /// Validate image format (UC124).
  bool isValidFormat(String? mimeType) {
    if (mimeType == null) return false;
    const validTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];
    return validTypes.contains(mimeType.toLowerCase());
  }

  /// Get file extension from mime type.
  String getExtension(String? mimeType) {
    switch (mimeType?.toLowerCase()) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      default:
        return 'jpg';
    }
  }
}
