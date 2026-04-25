import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totalx_app/models/user_model.dart';
import 'package:totalx_app/services/user_service.dart';
import 'package:totalx_app/utils/app_constants.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;
  List<DocumentSnapshot> _lastDocuments = [];

  UserBloc({required this.userService}) : super(const UserInitial()) {
    on<UserFetchRequested>(_onFetchRequested);
    on<UserFetchMoreRequested>(_onFetchMoreRequested);
    on<UserSearchRequested>(_onSearchRequested);
    on<UserSortChanged>(_onSortChanged);
    on<UserAddRequested>(_onAddRequested);
  }

  Future<void> _onFetchRequested(
    UserFetchRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    _lastDocuments = [];
    try {
      final result = await userService.getUsers();
      _lastDocuments = result.docs;
      emit(UserLoaded(
        users: result.users,
        hasReachedMax: result.users.length < AppConstants.pageSize,
      ));
    } catch (e) {
      emit(UserFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchMoreRequested(
    UserFetchMoreRequested event,
    Emitter<UserState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserLoaded) return;
    if (currentState.hasReachedMax) return;

    try {
      final lastDoc = _lastDocuments.isNotEmpty ? _lastDocuments.last : null;
      final isOlderSort = currentState.sortCategory == SortCategory.older;
      final isYoungerSort = currentState.sortCategory == SortCategory.younger;

      late final UserResult result;

      if (isOlderSort || isYoungerSort) {
        result = await userService.getUsersByAgeCategory(
          isOlder: isOlderSort,
          lastDocument: lastDoc,
        );
      } else {
        result = await userService.getUsers(lastDocument: lastDoc);
      }

      _lastDocuments.addAll(result.docs);
      emit(currentState.copyWith(
        users: [...currentState.users, ...result.users],
        hasReachedMax: result.users.length < AppConstants.pageSize,
      ));
    } catch (e) {
      emit(UserFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSearchRequested(
    UserSearchRequested event,
    Emitter<UserState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(const UserFetchRequested());
      return;
    }
    emit(const UserSearching());
    try {
      final users = await userService.searchUsers(query: event.query.trim());
      emit(UserSearchLoaded(users: users, query: event.query));
    } catch (e) {
      emit(UserFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSortChanged(
    UserSortChanged event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    _lastDocuments = [];
    try {
      if (event.category == SortCategory.all) {
        final result = await userService.getUsers();
        _lastDocuments = result.docs;
        emit(UserLoaded(
          users: result.users,
          sortCategory: SortCategory.all,
          hasReachedMax: result.users.length < AppConstants.pageSize,
        ));
      } else {
        final result = await userService.getUsersByAgeCategory(
          isOlder: event.category == SortCategory.older,
        );
        _lastDocuments = result.docs;
        emit(UserLoaded(
          users: result.users,
          sortCategory: event.category,
          hasReachedMax: result.users.length < AppConstants.pageSize,
        ));
      }
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
