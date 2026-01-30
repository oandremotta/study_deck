# Study Deck - Diretrizes de Desenvolvimento

## Arquitetura

Este projeto usa Flutter com:
- **Riverpod** para gerenciamento de estado
- **Drift** (SQLite) para persistência com IndexedDB na web
- **GoRouter** para navegação
- **Either pattern** (fpdart) para tratamento de erros

## IMPORTANTE: Padrão para Operações de Mutação (CRUD)

### Problema: "Bad state: Future already completed"

O uso de `AsyncNotifier` com `state = AsyncLoading()` causa erros quando providers são invalidados durante operações assíncronas. Isso ocorre porque:

1. O notifier inicia uma operação async e define `state = AsyncLoading()`
2. Durante a operação, outro código invalida o provider
3. O Riverpod tenta rebuildar o notifier
4. O notifier original tenta completar, mas o estado já foi descartado

### Solução: Usar Funções Diretas

**NUNCA** use `CardNotifier`, `DeckNotifier`, `TagNotifier` ou `FolderNotifier` para operações de mutação em widgets.

**SEMPRE** use as funções diretas:

```dart
// ERRADO - Causa "Future already completed"
final notifier = ref.read(cardNotifierProvider.notifier);
final card = await notifier.createCard(...);

// CORRETO - Usar funções diretas
final repository = ref.read(cardRepositoryProvider);
try {
  final card = await createCardDirect(repository, ...);
  // sucesso
} catch (e) {
  // erro
}
```

### Funções Diretas Disponíveis

**Cards** (`lib/presentation/providers/card_providers.dart`):
- `createCardDirect(repository, {deckId, front, back, hint?, tagIds?})`
- `updateCardDirect(repository, {id, front?, back?, hint?, tagIds?})`
- `softDeleteCardDirect(repository, id)`
- `restoreCardDirect(repository, id)`
- `permanentlyDeleteCardDirect(repository, id)`

**Decks** (`lib/presentation/providers/deck_providers.dart`):
- `createDeckDirect(repository, {name, description?, folderId?})`
- `updateDeckDirect(repository, {id, name?, description?, folderId?})`
- `deleteDeckDirect(repository, id, action)`

**Tags** (`lib/presentation/providers/tag_providers.dart`):
- `createTagDirect(repository, {name, color})`
- `updateTagDirect(repository, {id, name?, color?})`
- `deleteTagDirect(repository, id)`

**Folders** (`lib/presentation/providers/folder_providers.dart`):
- `createFolderDirect(repository, {name, parentId?})`
- `updateFolderDirect(repository, {id, name?, parentId?})`
- `deleteFolderDirect(repository, id)`

### Padrão de Uso em Widgets

```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final repository = ref.read(xxxRepositoryProvider);
    await createXxxDirect(repository, ...);

    if (mounted) {
      context.showSnackBar('Sucesso');
      context.pop();
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isLoading = false);
      context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
```

## Stream Providers para UI Reativa

Para listas que precisam atualizar automaticamente, use os stream providers:

- `watchTagsProvider` - Lista de tags (atualiza em tempo real)
- `watchDecksProvider` - Lista de decks
- `watchDecksByFolderProvider(folderId)` - Decks por pasta
- `watchCardsByDeckProvider(deckId)` - Cards por deck
- `watchFoldersProvider` - Lista de pastas

## Estrutura de Pastas

```
lib/
├── core/           # Extensões, utilidades
├── data/           # Implementações de repositórios, database
├── domain/         # Entidades, interfaces de repositório
└── presentation/
    ├── providers/  # Riverpod providers
    ├── router/     # GoRouter config
    ├── screens/    # Telas organizadas por feature
    └── widgets/    # Widgets reutilizáveis
```

## Comandos Úteis

```bash
# Regenerar código (providers, database)
dart run build_runner build --delete-conflicting-outputs

# Rodar na web
flutter run -d chrome

# Build web
flutter build web
```

## Textos da UI (Português)

- Criar: "Criar", "Novo/Nova"
- Editar: "Editar", "Salvar"
- Excluir: "Excluir"
- Cancelar: "Cancelar"
- Sucesso: "Card criado", "Deck atualizado", etc.
- Erro: "Erro ao criar card", usar `context.showErrorSnackBar()`
