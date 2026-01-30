import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';
import '../../domain/entities/tag.dart';
import '../providers/tag_providers.dart';

/// Widget for selecting tags for a card.
///
/// Displays selected tags as chips and provides a bottom sheet for selection.
class TagSelectionWidget extends ConsumerWidget {
  final List<String> selectedTagIds;
  final ValueChanged<List<String>> onChanged;

  const TagSelectionWidget({
    super.key,
    required this.selectedTagIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(watchTagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (opcional)',
          style: context.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        tagsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (allTags) {
            final selectedTags = allTags
                .where((tag) => selectedTagIds.contains(tag.id))
                .toList();

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...selectedTags.map((tag) => Chip(
                      avatar: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _hexToColor(tag.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      label: Text(tag.name),
                      onDeleted: () {
                        final newIds = List<String>.from(selectedTagIds)
                          ..remove(tag.id);
                        onChanged(newIds);
                      },
                    )),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar tag'),
                  onPressed: () => _showTagSelectionSheet(
                    context,
                    ref,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showTagSelectionSheet(
    BuildContext context,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TagSelectionSheet(
        selectedTagIds: selectedTagIds,
        onChanged: onChanged,
      ),
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

class _TagSelectionSheet extends ConsumerStatefulWidget {
  final List<String> selectedTagIds;
  final ValueChanged<List<String>> onChanged;

  const _TagSelectionSheet({
    required this.selectedTagIds,
    required this.onChanged,
  });

  @override
  ConsumerState<_TagSelectionSheet> createState() => _TagSelectionSheetState();
}

class _TagSelectionSheetState extends ConsumerState<_TagSelectionSheet> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedTagIds);
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(watchTagsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Selecionar tags',
                    style: context.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      widget.onChanged(_selectedIds);
                      Navigator.pop(context);
                    },
                    child: const Text('Concluir'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: tagsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Erro ao carregar tags')),
                data: (allTags) => ListView(
                controller: scrollController,
                children: [
                  ...allTags.map((tag) => ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _selectedIds.contains(tag.id),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedIds.add(tag.id);
                                  } else {
                                    _selectedIds.remove(tag.id);
                                  }
                                });
                              },
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _hexToColor(tag.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        title: Text(tag.name),
                        subtitle: Text(
                          '${tag.cardCount} ${tag.cardCount == 1 ? 'card' : 'cards'}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) => _handleTagMenu(context, tag, value),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Excluir'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            if (_selectedIds.contains(tag.id)) {
                              _selectedIds.remove(tag.id);
                            } else {
                              _selectedIds.add(tag.id);
                            }
                          });
                        },
                      )),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colorScheme.outline,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 16),
                    ),
                    title: const Text('Criar nova tag'),
                    onTap: () => _showCreateTagDialog(context),
                  ),
                ],
              ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateTagDialog(BuildContext context) async {
    final tag = await showDialog<Tag>(
      context: context,
      builder: (dialogContext) => const _QuickTagCreateDialog(),
    );

    if (tag != null && mounted) {
      setState(() {
        _selectedIds.add(tag.id);
      });
    }
  }

  void _handleTagMenu(BuildContext context, Tag tag, String action) {
    switch (action) {
      case 'edit':
        _showEditTagDialog(context, tag);
        break;
      case 'delete':
        _showDeleteTagDialog(context, tag);
        break;
    }
  }

  void _showEditTagDialog(BuildContext context, Tag tag) async {
    final updatedTag = await showDialog<Tag>(
      context: context,
      builder: (dialogContext) => _TagEditDialog(tag: tag),
    );

    if (updatedTag != null && mounted) {
      // Tag updated, list will refresh automatically via stream
    }
  }

  void _showDeleteTagDialog(BuildContext context, Tag tag) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir tag'),
        content: tag.cardCount > 0
            ? Text(
                'A tag "${tag.name}" está sendo usada em ${tag.cardCount} card(s). '
                'Ela será removida de todos os cards.',
              )
            : Text('Deseja excluir a tag "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repository = ref.read(tagRepositoryProvider);
                await deleteTagDirect(repository, tag.id);
                if (mounted) {
                  setState(() {
                    _selectedIds.remove(tag.id);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

class _TagEditDialog extends ConsumerStatefulWidget {
  final Tag tag;

  const _TagEditDialog({required this.tag});

  @override
  ConsumerState<_TagEditDialog> createState() => _TagEditDialogState();
}

class _TagEditDialogState extends ConsumerState<_TagEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag.name);
    _selectedColor = widget.tag.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar tag'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome da tag',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome da tag';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Cor',
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Tag.availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _hexToColor(color),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: context.colorScheme.onSurface,
                              width: 2,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: _getContrastColor(color),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(tagRepositoryProvider);
      final tag = await updateTagDirect(
        repository,
        id: widget.tag.id,
        name: _nameController.text.trim(),
        color: _selectedColor,
      );

      if (mounted) {
        Navigator.pop(context, tag);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  Color _getContrastColor(String hex) {
    final color = _hexToColor(hex);
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

class _QuickTagCreateDialog extends ConsumerStatefulWidget {
  const _QuickTagCreateDialog();

  @override
  ConsumerState<_QuickTagCreateDialog> createState() =>
      _QuickTagCreateDialogState();
}

class _QuickTagCreateDialogState extends ConsumerState<_QuickTagCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = Tag.availableColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova tag'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome da tag',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome da tag';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Cor',
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Tag.availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _hexToColor(color),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: context.colorScheme.onSurface,
                              width: 2,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: _getContrastColor(color),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _create,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Criar'),
        ),
      ],
    );
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(tagRepositoryProvider);
      final tag = await createTagDirect(
        repository,
        name: _nameController.text.trim(),
        color: _selectedColor,
      );

      if (mounted) {
        Navigator.pop(context, tag);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  Color _getContrastColor(String hex) {
    final color = _hexToColor(hex);
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
