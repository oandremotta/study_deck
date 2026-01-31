import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/image_service.dart';
import 'auth_providers.dart';

/// Provider for the image service.
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

/// State for image picking/uploading.
class CardImageState {
  final XFile? selectedImage;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final bool isUploading;
  final String? error;
  final double uploadProgress;

  const CardImageState({
    this.selectedImage,
    this.imageBytes,
    this.imageUrl,
    this.isUploading = false,
    this.error,
    this.uploadProgress = 0,
  });

  CardImageState copyWith({
    XFile? selectedImage,
    Uint8List? imageBytes,
    String? imageUrl,
    bool? isUploading,
    String? error,
    double? uploadProgress,
  }) {
    return CardImageState(
      selectedImage: selectedImage ?? this.selectedImage,
      imageBytes: imageBytes ?? this.imageBytes,
      imageUrl: imageUrl ?? this.imageUrl,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  /// Whether an image is selected (local or remote).
  bool get hasImage => selectedImage != null || imageUrl != null || imageBytes != null;

  /// Clear all image data.
  CardImageState clear() {
    return const CardImageState();
  }
}

/// Notifier for managing card image state.
class CardImageNotifier extends StateNotifier<CardImageState> {
  final ImageService _imageService;
  final Ref _ref;

  CardImageNotifier(this._imageService, this._ref) : super(const CardImageState());

  /// Initialize with existing image URL.
  void initWithUrl(String? url) {
    if (url != null) {
      state = state.copyWith(imageUrl: url);
    }
  }

  /// Pick image from gallery.
  Future<void> pickFromGallery() async {
    state = state.copyWith(error: null);

    final xFile = await _imageService.pickFromGallery();
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      state = state.copyWith(
        selectedImage: xFile,
        imageBytes: bytes,
      );
    }
  }

  /// Pick image from camera.
  Future<void> pickFromCamera() async {
    state = state.copyWith(error: null);

    final xFile = await _imageService.pickFromCamera();
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      state = state.copyWith(
        selectedImage: xFile,
        imageBytes: bytes,
      );
    }
  }

  /// Upload the selected image to Firebase Storage.
  Future<String?> uploadImage(String cardId) async {
    debugPrint('=== CardImageNotifier.uploadImage started ===');
    debugPrint('cardId: $cardId');
    debugPrint('selectedImage: ${state.selectedImage?.name}');
    debugPrint('imageBytes: ${state.imageBytes?.length}');

    if (state.selectedImage == null && state.imageBytes == null) {
      debugPrint('No new image, returning existing URL: ${state.imageUrl}');
      return state.imageUrl; // Return existing URL if no new image
    }

    final user = _ref.read(authRepositoryProvider).currentUser;
    debugPrint('Current user: ${user?.id}');
    if (user == null) {
      debugPrint('ERROR: User not authenticated');
      state = state.copyWith(error: 'Usuário não autenticado');
      return null;
    }

    state = state.copyWith(isUploading: true, error: null);
    debugPrint('Starting upload...');

    try {
      String? url;

      if (state.selectedImage != null) {
        debugPrint('Uploading from XFile...');
        url = await _imageService.uploadFromXFile(
          userId: user.id,
          cardId: cardId,
          xFile: state.selectedImage!,
        );
      } else if (state.imageBytes != null) {
        debugPrint('Uploading from bytes...');
        url = await _imageService.uploadImage(
          userId: user.id,
          cardId: cardId,
          imageBytes: state.imageBytes!,
        );
      }

      debugPrint('Upload completed! URL: $url');
      state = state.copyWith(
        isUploading: false,
        imageUrl: url,
      );

      return url;
    } catch (e) {
      debugPrint('!!! Upload FAILED: $e');
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Remove the current image.
  Future<void> removeImage({String? cardId}) async {
    final user = _ref.read(authRepositoryProvider).currentUser;

    // Delete from Firebase if there's a URL and user is authenticated
    if (state.imageUrl != null && user != null) {
      try {
        await _imageService.deleteImageByUrl(state.imageUrl!);
      } catch (e) {
        debugPrint('Error deleting image: $e');
      }
    }

    state = state.clear();
  }

  /// Clear state without deleting from storage.
  void clear() {
    state = state.clear();
  }
}

/// Provider for card image state, auto-disposed when not used.
final cardImageNotifierProvider =
    StateNotifierProvider.autoDispose<CardImageNotifier, CardImageState>((ref) {
  final imageService = ref.watch(imageServiceProvider);
  return CardImageNotifier(imageService, ref);
});
