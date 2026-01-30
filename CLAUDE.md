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

**Study/SRS** (`lib/presentation/providers/study_providers.dart`):
- `markCardAsMasteredDirect(repository, cardId)` - UC27: Marcar card como dominado
- `resetCardProgressDirect(repository, cardId)` - UC28: Resetar progresso de um card
- `resetDeckProgressDirect(repository, deckId)` - UC28: Resetar progresso de todo o deck

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

## Problema: Provider Perde Estado Após Navegação

### Cenário
AsyncNotifier com `build()` que busca dados ativos causa problemas quando:
1. Tela A usa `notifierProvider` e modifica estado
2. Navega para Tela B que também usa `notifierProvider`
3. Tela B faz `ref.watch()` que dispara `build()` novamente
4. `build()` busca dados "ativos" que não existem mais após a operação

### Exemplo Real: StudySession
```dart
// StudyNotifier.build() busca sessão ATIVA
@override
FutureOr<StudySession?> build() async {
  final result = await ref.read(studyRepositoryProvider).getActiveSession();
  return result.fold((f) => null, (s) => s);
}

// Problema: Após completar sessão, ela não é mais "ativa"
// SessionSummaryScreen faz ref.watch(studyNotifierProvider)
// build() é chamado novamente e retorna null
```

### Solução: Provider Dedicado para Consultas Específicas
```dart
// Criar provider que busca por ID, não por estado "ativo"
final sessionByIdProvider = FutureProvider.family<StudySession?, String>((ref, sessionId) async {
  final result = await ref.watch(studyRepositoryProvider).getSessionById(sessionId);
  return result.fold((f) => null, (s) => s);
});

// Uso na tela
final sessionAsync = ref.watch(sessionByIdProvider(sessionId));
```

## Stream Providers para UI Reativa

Para listas que precisam atualizar automaticamente, use os stream providers:

- `watchTagsProvider` - Lista de tags (atualiza em tempo real)
- `watchDecksProvider` - Lista de decks
- `watchDecksByFolderProvider(folderId)` - Decks por pasta
- `watchCardsByDeckProvider(deckId)` - Cards por deck
- `watchFoldersProvider` - Lista de pastas

**Study Providers**:
- `studyRepositoryProvider` - Repositório de estudo/SRS
- `userStatsProvider` - Estatísticas do usuário (XP, streak, level)
- `watchUserStatsProvider` - Stream de estatísticas (atualização em tempo real)
- `activeSessionProvider` - Sessão de estudo ativa
- `sessionByIdProvider(id)` - Buscar sessão por ID (para tela de resumo)
- `deckStudyStatsProvider(deckId)` - Estatísticas SRS do deck
- `studyQueueProvider({deckId, mode, limit})` - Fila de cards para estudar
- `studyNotifierProvider` - Notifier para gerenciar sessão de estudo

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

## Problemas Comuns no Ambiente Windows

### 1. Erro "ng: command not found" no Bash

**Problema**: Todo comando bash mostra `/c/Users/andre/.bashrc: line 4: ng: command not found`

**Causa**: Há uma configuração de Angular CLI no `.bashrc` que não está instalada.

**Solução**:
- Este erro é inofensivo - IGNORAR
- Sempre verificar o exit code: `comando 2>&1; echo "Exit: $?"`
- Exit code 0 = sucesso, mesmo sem output visível

### 2. Output de Comandos Não Aparece

**Problema**: Comandos como `flutter build web` executam mas não mostram output.

**Soluções**:
```bash
# Verificar exit code
comando 2>&1; echo "Exit: $?"

# Redirecionar para arquivo
comando > output.txt 2>&1; cat output.txt

# Usar tail para ver últimas linhas
comando 2>&1 | tail -50
```

### 3. Build Runner Não Gera Arquivos .g.dart

**Problema**: `dart run build_runner build` completa com sucesso mas arquivos `.g.dart` não são criados ou atualizados.

**Diagnóstico**:
```bash
# Verificar se arquivo foi gerado
ls -la lib/presentation/providers/*.g.dart

# Ver timestamp do arquivo
stat arquivo.g.dart | grep Modify
```

**Soluções**:
1. Limpar e regenerar:
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

2. Deletar .g.dart manualmente e regenerar:
   ```bash
   rm lib/path/to/file.g.dart
   dart run build_runner build
   ```

3. **Workaround**: Se build_runner continuar falhando, criar provider manualmente:
   ```dart
   // Em vez de usar @riverpod annotation:
   // @riverpod
   // Future<Session?> sessionById(Ref ref, String id) async { ... }

   // Usar definição manual:
   final sessionByIdProvider = FutureProvider.family<Session?, String>((ref, id) async {
     final result = await ref.watch(repositoryProvider).getSessionById(id);
     return result.fold((f) => null, (s) => s);
   });
   ```

4. Se precisar criar .g.dart manualmente, copiar estrutura de outro arquivo similar e adaptar.

### 4. Caminhos de Arquivo no Windows

**Usar**:
- Git Bash: `/c/workspace/tech-attom/study_deck`
- Windows: `c:\workspace\tech-attom\study_deck`

**Comandos que funcionam bem**:
```bash
cd /c/workspace/tech-attom/study_deck && flutter pub get
```

## Comandos Úteis

```bash
# Regenerar código (providers, database)
dart run build_runner build --delete-conflicting-outputs

# Rodar na web
flutter run -d chrome

# Build web
flutter build web

# Verificar se build funcionou
flutter build web 2>&1; echo "Exit: $?"

# Analisar erros em arquivo específico
flutter analyze lib/path/to/file.dart
```

## Textos da UI (Português)

- Criar: "Criar", "Novo/Nova"
- Editar: "Editar", "Salvar"
- Excluir: "Excluir"
- Cancelar: "Cancelar"
- Sucesso: "Card criado", "Deck atualizado", etc.
- Erro: "Erro ao criar card", usar `context.showErrorSnackBar()`
