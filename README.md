# Framy

Gerenciador pessoal de filmes desenvolvido em Flutter com Firebase como backend.

## Funcionalidades

- Cadastro e autenticação de usuários (Firebase Auth)
- Gerenciamento de filmes com capa via API OMDb
- Gêneros personalizados por usuário
- Avaliações com nota (1–5 estrelas) e comentário
- Busca de filmes por título (case-insensitive)
- Listagem em tempo real com StreamBuilder
- Estatísticas da coleção por status e gênero

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.10.8`
- [Firebase CLI](https://firebase.google.com/docs/cli) instalado e autenticado
- Conta no [Firebase Console](https://console.firebase.google.com/) com projeto configurado
- Chave gratuita da [OMDb API](https://www.omdbapi.com/apikey.aspx)

## Configuração do Firebase

No Firebase Console, certifique-se de que os seguintes serviços estão ativos:

1. **Authentication** → provedor E-mail/Senha habilitado2. **Firestore Database** → criado em modo produção com as regras abaixo

### Regras do Firestore

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{col}/{docId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }
    match /usuarios/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## Configuração da chave OMDb

Crie (ou edite) o arquivo `.env` na raiz do projeto com sua chave:

```
OMDB_API_KEY=sua_chave_aqui
```

> O arquivo `.env` está no `.gitignore` e nunca é commitado. Use `.env.example` como referência.

## Executando o projeto

```bash
# 1. Instalar dependências
flutter pub get

# 2. Rodar no dispositivo/emulador conectado
flutter run

# 3. Rodar em plataforma específica
flutter run -d android
flutter run -d ios
flutter run -d chrome
```

## Build para produção

### Android

```bash
flutter build apk --release
# Saída: build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release
# Saída: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web
# Saída: build/web/
```

## Deploy no Firebase Hosting (Web)

```bash
# 1. Build da versão web
flutter build web

# 2. Inicializar Firebase Hosting (apenas na primeira vez)
firebase init hosting
# Quando perguntado pelo diretório público, informe: build/web
# Configure como single-page app: yes

# 3. Deploy
firebase deploy --only hosting
```

## Estrutura do projeto

```
lib/
├── core/
│   ├── app_theme.dart        # Tema global
│   └── validators.dart       # Validação de senha e e-mail
├── models/
│   ├── movie.dart            # Modelo de filme (Firestore)
│   ├── user_profile.dart     # Perfil do usuário
│   ├── genre.dart            # Gênero personalizado
│   └── review.dart           # Avaliação de filme
├── repositories/
│   ├── auth_repository.dart  # Auth + gravação em usuarios/
│   ├── movie_repository.dart # CRUD + stream de filmes/
│   ├── genre_repository.dart # CRUD + stream de generos/
│   └── review_repository.dart# CRUD + stream de avaliacoes/
├── services/
│   └── omdb_service.dart     # Consumo da API OMDb
├── viewmodels/
│   ├── auth_viewmodel.dart
│   ├── movie_viewmodel.dart
│   └── genre_viewmodel.dart
├── views/
│   ├── auth/                 # Login, cadastro, recuperação de senha
│   ├── home/                 # Tela principal com navegação inferior
│   ├── specific/             # Detalhe, adição, edição, busca, stats
│   └── about/
└── main.dart
```

## Coleções no Firestore

| Coleção       | Descrição                         |
|---------------|-----------------------------------|
| `usuarios`    | Perfil do usuário autenticado     |
| `filmes`      | Filmes cadastrados por usuário    |
| `generos`     | Gêneros personalizados            |
| `avaliacoes`  | Avaliações (nota + comentário)    |

## Dependências principais

| Pacote             | Uso                                  |
|--------------------|--------------------------------------|
| `firebase_auth`    | Autenticação de usuários             |
| `cloud_firestore`  | Banco de dados em tempo real         |
| `provider`         | Gerenciamento de estado              |
| `http`             | Requisições à API OMDb               |
| `flutter_dotenv`   | Leitura de variáveis de ambiente     |
| `image_picker`     | Seleção de imagens                   |
