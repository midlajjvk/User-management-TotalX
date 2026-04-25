import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totalx_app/models/user_model.dart';
import 'package:totalx_app/services/user_service.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  UserBloc({required this.userService}) : super(const UserInitial()) {
    on<UserFetchRequested>(_onFetchRequested);
    on<UserAddRequested>(_onAddRequested);
  }

  Future<void> _onFetchRequested(
    UserFetchRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final users = await userService.getUsers();
      emit(UserLoaded(users: users));
    } catch (e) {
      emit(UserFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddRequested(
    UserAddRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserAdding());
    try {
      await userService.addUser(
        name: event.name,
        phoneNumber: event.phoneNumber,
        age: event.age,
        imageFile: event.imageFile,
      );
      emit(const UserAddSuccess());
    } catch (e) {
      emit(UserFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
