part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthUserChanged extends AuthEvent {
  final AuthModel user;
  const AuthUserChanged({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUserSignedOut extends AuthEvent {
  const AuthUserSignedOut();
}
