import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/services/pdf_service.dart';
import '../../../domain/entities/ai_project.dart';
import '../../providers/ai_card_providers.dart';
import '../../router/app_router.dart';

/// Screen for creating cards from PDF (UC129-UC131).
class CreateFromPdfScreen extends ConsumerStatefulWidget {
  const CreateFromPdfScreen({super.key});

  @override
  ConsumerState<CreateFromPdfScreen> createState() =>
      _CreateFromPdfScreenState();
}

class _CreateFromPdfScreenState extends ConsumerState<CreateFromPdfScreen> {
  PlatformFile? _selectedFile;
  String? _extractedText;
  bool _isLoading = false;
  bool _isExtracting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerar de PDF'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecione um arquivo PDF',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A IA ira extrair o texto do PDF e criar flashcards com os conceitos mais importantes.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // File picker area
            _buildFilePickerArea(context),

            const SizedBox(height: 16),

            // File info
            if (_selectedFile != null) ...[
              _buildFileInfo(context),
              const SizedBox(height: 16),
            ],

            // Extracted text preview
            if (_extractedText != null) ...[
              _buildTextPreview(context),
              const SizedBox(height: 16),
            ],

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: context.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: context.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Continue button
            FilledButton(
              onPressed: _extractedText != null && !_isLoading ? _continue : null,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerArea(BuildContext context) {
    return InkWell(
      onTap: _isExtracting ? null : _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.outline,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        child: Column(
          children: [
            if (_isExtracting) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Extraindo texto do PDF...',
                style: context.textTheme.bodyMedium,
              ),
            ] else ...[
              Icon(
                _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                size: 48,
                color: _selectedFile != null
                    ? Colors.green
                    : context.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                _selectedFile != null
                    ? 'Toque para trocar o arquivo'
                    : 'Toque para selecionar PDF',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Maximo: ${PdfService.maxFileSizeMb} MB',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo(BuildContext context) {
    final file = _selectedFile!;
    final sizeKb = (file.size / 1024).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$sizeKb KB',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (_extractedText != null)
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextPreview(BuildContext context) {
    final charCount = _extractedText!.length;
    final preview = _extractedText!.length > 500
        ? '${_extractedText!.substring(0, 500)}...'
        : _extractedText!;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Texto extraido ($charCount caracteres)',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  preview,
                  style: context.textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final pdfService = ref.read(pdfServiceProvider);
      final file = await pdfService.pickPdfFile();

      if (file == null) return;

      // Validate file
      final error = pdfService.validatePdf(file);
      if (error != null) {
        setState(() => _errorMessage = error);
        return;
      }

      setState(() {
        _selectedFile = file;
        _extractedText = null;
        _isExtracting = true;
      });

      // Extract text
      final text = await pdfService.extractText(file.bytes!);

      // Check if text is too short
      if (pdfService.isTextTooShort(text)) {
        setState(() {
          _isExtracting = false;
          _errorMessage =
              'Texto extraido muito curto (${text.length} caracteres). '
              'O PDF pode conter imagens sem texto.';
        });
        return;
      }

      // Check if text is too long
      if (pdfService.isTextTooLong(text)) {
        setState(() {
          _isExtracting = false;
          _errorMessage =
              'Texto muito longo (${text.length} caracteres). '
              'Use um PDF menor ou divida o conteudo.';
        });
        return;
      }

      setState(() {
        _extractedText = text;
        _isExtracting = false;
      });
    } catch (e) {
      setState(() {
        _isExtracting = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _continue() async {
    if (_extractedText == null || _selectedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(aiCardRepositoryProvider);
      final project = await createAiProjectDirect(
        repository,
        sourceType: AiSourceType.pdf,
        fileName: _selectedFile!.name,
        extractedText: _extractedText,
      );

      if (mounted) {
        context.pushReplacement(
          '${AppRouter.aiConfig}/${project.id}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar('Erro ao criar projeto: $e');
      }
    }
  }
}
