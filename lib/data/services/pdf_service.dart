import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Service for handling PDF operations (UC129-UC131).
///
/// Handles:
/// - PDF file picking
/// - Text extraction from PDF
/// - Upload to Firebase Storage
/// - Delete from Firebase Storage
class PdfService {
  final FirebaseStorage _storage;

  /// Maximum file size in MB.
  static const int maxFileSizeMb = 10;

  /// Maximum file size in bytes.
  static const int maxFileSizeBytes = maxFileSizeMb * 1024 * 1024;

  PdfService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Pick a PDF file from the device.
  ///
  /// Returns the selected file or null if cancelled.
  Future<PlatformFile?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;

      // Validate file size (UC131)
      if (file.size > maxFileSizeBytes) {
        throw Exception(
          'Arquivo muito grande. Maximo: $maxFileSizeMb MB',
        );
      }

      return file;
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      rethrow;
    }
  }

  /// Extract text from PDF bytes (UC130).
  ///
  /// Uses Syncfusion PDF library for extraction.
  Future<String> extractText(Uint8List pdfBytes) async {
    try {
      debugPrint('Extracting text from PDF (${pdfBytes.length} bytes)...');

      // Load PDF document
      final document = PdfDocument(inputBytes: pdfBytes);

      // Extract text from all pages
      final extractor = PdfTextExtractor(document);
      final buffer = StringBuffer();

      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(startPageIndex: i);
        if (pageText.isNotEmpty) {
          buffer.writeln(pageText);
          buffer.writeln(); // Add spacing between pages
        }
      }

      // Dispose document
      document.dispose();

      final text = buffer.toString().trim();
      debugPrint('Extracted ${text.length} characters from PDF');

      if (text.isEmpty) {
        throw Exception(
          'Nao foi possivel extrair texto do PDF. '
          'O arquivo pode ser uma imagem escaneada.',
        );
      }

      return text;
    } catch (e) {
      debugPrint('Error extracting PDF text: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao processar PDF: $e');
    }
  }

  /// Upload PDF to Firebase Storage.
  ///
  /// Path structure: /users/{userId}/ai-projects/{projectId}/source.pdf
  Future<String> uploadPdf({
    required String userId,
    required String projectId,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      debugPrint('Uploading PDF: $fileName (${pdfBytes.length} bytes)');

      final storagePath = 'users/$userId/ai-projects/$projectId/$fileName';
      final ref = _storage.ref().child(storagePath);

      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        customMetadata: {
          'projectId': projectId,
          'userId': userId,
          'originalFileName': fileName,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putData(pdfBytes, metadata);
      await uploadTask;

      debugPrint('PDF uploaded successfully');
      return storagePath;
    } catch (e) {
      debugPrint('Error uploading PDF: $e');
      throw Exception('Erro ao enviar PDF: $e');
    }
  }

  /// Delete PDF from Firebase Storage.
  Future<void> deletePdf(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
      debugPrint('PDF deleted: $storagePath');
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        debugPrint('PDF not found, nothing to delete');
        return;
      }
      debugPrint('Error deleting PDF: $e');
      rethrow;
    }
  }

  /// Get download URL for a PDF.
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting PDF URL: $e');
      throw Exception('Erro ao obter URL do PDF');
    }
  }

  /// Validate PDF file.
  ///
  /// Returns error message or null if valid.
  String? validatePdf(PlatformFile file) {
    // Check extension
    if (file.extension?.toLowerCase() != 'pdf') {
      return 'Apenas arquivos PDF sao permitidos';
    }

    // Check size
    if (file.size > maxFileSizeBytes) {
      return 'Arquivo muito grande. Maximo: $maxFileSizeMb MB';
    }

    // Check if has bytes
    if (file.bytes == null || file.bytes!.isEmpty) {
      return 'Arquivo vazio ou corrompido';
    }

    return null;
  }

  /// Get estimated text length from PDF size.
  ///
  /// Rough estimate: ~1000 chars per 10KB of PDF.
  int estimateTextLength(int pdfSizeBytes) {
    return (pdfSizeBytes / 10240 * 1000).round();
  }

  /// Check if text is too short for meaningful card generation.
  bool isTextTooShort(String text, {int minChars = 200}) {
    return text.length < minChars;
  }

  /// Check if text is too long (may need chunking).
  bool isTextTooLong(String text, {int maxChars = 50000}) {
    return text.length > maxChars;
  }
}
