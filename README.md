# TotalX App

A Flutter user management application built with **Clean Architecture** and **BLoC** state management.

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants & routes
│   ├── error/            # Failure classes
│   └── theme/            # App theme & colors
│
├── data/
│   ├── datasources/
│   │   └── remote/       # Firebase data sources
│   ├── models/           # Data models (extend entities)
│   └── repositories/     # Repository implementations
│
├── domain/
│   ├── entities/         # Pure business objects
│   ├── repositories/     # Abstract repository contracts
│   └── usecases/         # One use case per file
│       ├── auth/
│       └── user/
│
├── presentation/
│   ├── blocs/
│   │   ├── auth/         # AuthBloc (event/state/bloc)
│   │   └── user/         # UserBloc (event/state/bloc)
│   ├── pages/
│   │   ├── auth/         # LoginPage
│   │   └── users/        # UserListPage, AddUserPage
│   └── widgets/
│       ├── common/       # AppButton
│       └── user/         # UserListTile, SortBottomSheet
│
├── firebase_options.dart
├── main.dart
└── service_locator.dart  # GetIt DI setup
```

---

## 🚀 Features

| Feature | Details |
|---|---|
| Google Sign-In | Firebase Auth via `google_sign_in` |
| Add User | Name, Phone Number, Age, Profile Image |
| User List | Lazy loading with pagination (10/page) |
| Search | By name or phone number (prefix search) |
| Sort | All / Older (Age > 60) / Younger (Age ≤ 60) |
| State Management | BLoC (`flutter_bloc`) |
| Architecture | Clean Architecture (Data → Domain → Presentation) |
| DI | `get_it` service locator |
| Image Upload | Firebase Storage |
| Shimmer Loading | `shimmer` package |

---

## ⚙️ Setup

### 1. Clone & Install

```bash
git clone https://github.com/YOUR_USERNAME/totalx_app.git
cd totalx_app
flutter pub get
```

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com) and create a project.
2. Enable **Authentication → Google Sign-In**.
3. Create a **Firestore Database** (start in test mode, then apply `firestore.rules`).
4. Enable **Firebase Storage**.
5. Install the Firebase CLI and FlutterFire CLI:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

6. Run FlutterFire configure (auto-generates `firebase_options.dart`):

```bash
flutterfire configure
```

7. For Android, download `google-services.json` and place it at `android/app/google-services.json`.
8. Add your SHA-1 fingerprint to the Firebase Android app (required for Google Sign-In):

```bash
cd android && ./gradlew signingReport
```

### 3. Firestore Indexes

Deploy the composite indexes needed for sorting:

```bash
firebase deploy --only firestore:indexes
```

### 4. Run

```bash
flutter run
```

---

## 🗂️ Recommended Git Commit History

```
feat: initial flutter project setup with clean architecture
feat: add firebase & dependencies (pubspec.yaml)
feat: core layer - theme, constants, failure classes
feat: domain layer - entities, repositories, use cases
feat: data layer - models, datasources, repository impls
feat: auth bloc - events, states, bloc
feat: user bloc - events, states, bloc with pagination
feat: service locator (get_it) dependency injection
feat: login page with google sign-in UI
feat: user list page with lazy loading and shimmer
feat: add user page with form validation and image picker
feat: sort bottom sheet - older/younger age categories
feat: search users by name and phone number
fix: firestore composite index for age-based queries
chore: add firestore security rules
```

---

## 📋 Firestore Data Structure

```
users/{userId}
  ├── name: "Sam Curren"
  ├── nameLower: "sam curren"       ← for search
  ├── phoneNumber: "9876543210"
  ├── phoneSearch: "9876543210"     ← for search
  ├── age: 43
  ├── imageUrl: "https://..."       ← nullable
  └── createdAt: Timestamp
```

---

## 🔐 Security Rules

See `firestore.rules` — authenticated users can read/write. Creates are validated for required fields and age range.

---

## 📦 Tech Stack

- **Flutter** 3.10+
- **Firebase** (Auth, Firestore, Storage)
- **flutter_bloc** 8.x — BLoC state management
- **get_it** — dependency injection
- **dartz** — functional Either types
- **equatable** — value equality
- **cached_network_image** — image caching
- **shimmer** — loading skeletons
- **image_picker** — camera/gallery
