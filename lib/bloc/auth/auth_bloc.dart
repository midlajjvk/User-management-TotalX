import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totalx_app/models/auth_model.dart';
import 'package:totalx_app/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  StreamSubscription? _authSubscription;

  AuthBloc({required this.authService}) : super(const AuthInitial()) {
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthUserSignedOut>(_onUserSignedOut);

    _authSubscription = authService.authStateChanges.listen((user) {
      if (user != null) {
        add(AuthUserChanged(user: user));
      } else {
        add(const AuthUserSignedOut());
      }
    });
  }

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAuthenticated(user: event.user));
  }

  Future<void> _onUserSignedOut(
    AuthUserSignedOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUnauthenticated());
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authService.signInWithGoogle();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailureState(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authService.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailureState(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
