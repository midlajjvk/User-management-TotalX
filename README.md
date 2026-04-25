# TotalX - User Management App

A Flutter user management application built with BLoC state management and Firebase.

## Features

- **Google Sign-In** — Firebase Authentication with Google
- **Add User** — Add users with name, phone number, age and profile image
- **Search Users** — Search by name or phone number
- **Sort by Age** — Filter users by age category (Older: above 60, Younger: below 60)
- **Lazy Loading** — Pagination with Firestore cursor-based loading

## Tech Stack

- **Flutter** — UI framework
- **Firebase Auth** — Google Sign-In
- **Cloud Firestore** — User data storage
- **Firebase Storage** — Profile image storage
- **BLoC** — State management
- **Image Picker** — Camera and gallery image selection

## Folder Structure

```
lib/
├── bloc/
│   ├── auth/         # Auth BLoC (events, states)
│   └── user/         # User BLoC (events, states)
├── models/           # UserModel, AuthModel
├── screens/          # LoginScreen, HomeScreen, AddUserScreen
├── services/         # AuthService, UserService
├── utils/            # AppTheme, AppConstants
├── widgets/          # UserTile, SortBottomSheet, AppButton
└── main.dart
```

## Setup

1. Clone the repository
```bash
git clone https://github.com/midlajjvk/User-management-TotalX.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Screenshots

| Login | Home | Add User |
|-------|------|----------|
| Google Sign-In screen | User list with search and sort | Add user form with image picker |

## APK

Download the latest APK from the [Releases](https://github.com/midlajjvk/User-management-TotalX/releases) section.
