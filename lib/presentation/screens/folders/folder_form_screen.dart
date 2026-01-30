import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/folder.dart';
import '../../providers/folder_providers.dart';

/// Screen for creating or editing a folder.
///
/// Implements UC04 (Create folder) and UC05 (Edit folder).
class FolderFormScreen extends ConsumerStatefulWidget {
  final String? folderId;

  const FolderFormScreen({
    super.key,
    this.folderId,
  });

  @override
  ConsumerState<FolderFormScreen> createState() => _FolderFormScreenState();
}

class _FolderFormScreenState extends ConsumerState<FolderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  Folder? _existingFolder;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.folderId != null;
    if (_isEditing) {
      _loadFolder();
    }
  }

  Future<void> _loadFolder() async {
    final repo = ref.read(folderRepositoryProvider);
    final result = await repo.getFolderById(widget.folderId!);

    result.fold(
      (failure) {
        context.showErrorSnackBar(failure.message);
        context.pop();
      },
      (folder) {
        if (folder != null) {
          setState(() {
            _existingFolder = folder;
            _nameController.text = folder.name;
          });
        } else {
          context.showErrorSnackBar('Pasta nao encontrada');
          context.pop();
        }
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar pasta' : 'Nova pasta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: !_isEditing,
                decoration: const InputDecoration(
                  labelText: 'Nome da pasta',
                  hintText: 'Ex: Matematica, Ingles, Historia...',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome da pasta';
                  }
                  return null;
                },
              ),
              const Spacer(),
              FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Salvar' : 'Criar pasta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(folderRepositoryProvider);
      final name = _nameController.text.trim();

      if (_isEditing) {
        await updateFolderDirect(repository, widget.folderId!, name);
      } else {
        await createFolderDirect(repository, name);
      }

      if (mounted) {
        context.showSnackBar(
          _isEditing ? 'Pasta atualizada' : 'Pasta criada',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
