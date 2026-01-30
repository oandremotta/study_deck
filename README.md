# Study Deck

Aplicativo de flashcards para estudo com suporte a sincronização na nuvem.

## Tecnologias

| Categoria | Tecnologia |
|-----------|------------|
| Framework | Flutter 3.7+ |
| State Management | Riverpod + Riverpod Generator |
| Navegacao | GoRouter |
| Banco Local | Drift (SQLite) |
| Backend | Firebase (Auth + Firestore) |
| Autenticacao | Google Sign-In, Apple Sign-In |

## Arquitetura

O projeto segue **Clean Architecture** com separacao em camadas:

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp configuration
├── firebase_options.dart        # Firebase config (gerado)
│
├── core/                        # Utilitarios compartilhados
│   ├── constants/               # Constantes da aplicacao
│   ├── errors/                  # Exceptions e Failures
│   ├── extensions/              # Extensions do Dart/Flutter
│   ├── theme/                   # Cores e tema
│   └── utils/                   # Either e outros utils
│
├── domain/                      # Regras de negocio (sem dependencias externas)
│   ├── entities/                # Entidades puras
│   │   ├── user.dart
│   │   ├── folder.dart
│   │   ├── deck.dart
│   │   ├── card.dart
│   │   └── tag.dart
│   └── repositories/            # Contratos (interfaces)
│       ├── auth_repository.dart
│       ├── user_repository.dart
│       ├── folder_repository.dart
│       ├── deck_repository.dart
│       ├── card_repository.dart
│       └── tag_repository.dart
│
├── data/                        # Implementacoes
│   ├── models/                  # DTOs (conversao entity <-> DB/API)
│   ├── repositories/            # Implementacao dos repositorios
│   └── datasources/
│       ├── local/               # SQLite (Drift)
│       │   ├── connection/      # Conexao DB (native/web)
│       │   ├── database.dart    # Definicao do banco
│       │   ├── tables/          # Definicao das tabelas
│       │   └── daos/            # Data Access Objects
│       └── remote/              # Firebase
│           ├── contracts/       # Interfaces dos datasources
│           └── firebase/        # Implementacoes Firebase
│
└── presentation/                # UI
    ├── router/                  # Rotas (GoRouter)
    ├── providers/               # Providers Riverpod
    └── screens/                 # Telas
        ├── onboarding/
        ├── auth/
        ├── home/
        ├── folders/
        ├── decks/
        └── cards/
```

## Entidades Principais

| Entidade | Descricao |
|----------|-----------|
| **User** | Usuario do app |
| **Folder** | Pasta para organizar decks |
| **Deck** | Baralho de flashcards |
| **Card** | Flashcard (frente/verso) com suporte a midia e soft delete |
| **Tag** | Etiqueta para categorizar cards |

## Pre-requisitos

- Flutter SDK 3.7+
- Dart SDK 3.7+
- Android Studio / Xcode (para emuladores)
- Conta no Firebase

## Configuracao do Firebase

### 1. Criar projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto
3. Ative **Authentication** (Email/Password, Google, Apple)
4. Ative **Cloud Firestore**

### 2. Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 3. Configurar Firebase no projeto

```bash
flutterfire configure --project=SEU_PROJETO_ID
```

Isso vai gerar o arquivo `lib/firebase_options.dart` automaticamente.

### 4. Configuracoes adicionais

**Android:** O arquivo `android/app/google-services.json` sera gerado automaticamente.

**iOS:** O arquivo `ios/Runner/GoogleService-Info.plist` sera gerado automaticamente.

**Google Sign-In (Android):** Adicione a SHA-1 do seu keystore no Firebase Console.

```bash
# Debug SHA-1
cd android && ./gradlew signingReport
```

## Como Rodar

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Gerar codigo (Drift, Riverpod, GoRouter)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Executar o app

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

## Comandos Uteis

```bash
# Instalar dependencias
flutter pub get

# Gerar codigo (uma vez)
dart run build_runner build --delete-conflicting-outputs

# Gerar codigo (watch mode)
dart run build_runner watch --delete-conflicting-outputs

# Rodar testes
flutter test

# Analisar codigo
flutter analyze

# Build Android (APK)
flutter build apk --release

# Build Android (App Bundle)
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release
```

## Estrutura do Banco de Dados (Drift/SQLite)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    users    │     │   folders   │     │    decks    │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id (PK)     │◄────│ user_id     │     │ id (PK)     │
│ email       │     │ id (PK)     │◄────│ folder_id   │
│ name        │     │ name        │     │ user_id     │
│ ...         │     │ ...         │     │ name        │
└─────────────┘     └─────────────┘     │ ...         │
                                        └──────┬──────┘
                                               │
                    ┌─────────────┐            │
                    │    tags     │            │
                    ├─────────────┤            │
                    │ id (PK)     │            │
                    │ name        │            ▼
                    │ ...         │     ┌─────────────┐
                    └──────┬──────┘     │    cards    │
                           │            ├─────────────┤
                           │            │ id (PK)     │
                           ▼            │ deck_id     │
                    ┌─────────────┐     │ front       │
                    │  card_tags  │     │ back        │
                    ├─────────────┤     │ deleted_at  │
                    │ card_id     │◄────│ ...         │
                    │ tag_id      │     └─────────────┘
                    └─────────────┘
```

## Variaveis de Ambiente

Crie um arquivo `.env` na raiz (opcional, para configuracoes extras):

```env
# Exemplo
API_KEY=sua_api_key
```

> **Nota:** O arquivo `.env` esta no `.gitignore` e nao deve ser commitado.

## Arquivos Sensiveis (NAO COMMITAR)

Os seguintes arquivos contem chaves e credenciais e estao no `.gitignore`:

- `lib/firebase_options.dart` - Configuracoes do Firebase
- `android/app/google-services.json` - Chaves Firebase Android
- `ios/Runner/GoogleService-Info.plist` - Chaves Firebase iOS
- `android/key.properties` - Senhas do keystore
- Arquivos `.env`

## Contribuindo

1. Crie uma branch: `git checkout -b feature/minha-feature`
2. Commit suas mudancas: `git commit -m 'Add minha feature'`
3. Push para a branch: `git push origin feature/minha-feature`
4. Abra um Pull Request
