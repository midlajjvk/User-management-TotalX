part of 'user_bloc.dart';

enum SortCategory { all, older, younger }

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final List<UserModel> users;
  final SortCategory sortCategory;
  final bool hasReachedMax;

  const UserLoaded({
    required this.users,
    this.sortCategory = SortCategory.all,
    this.hasReachedMax = false,
  });

  UserLoaded copyWith({
    List<UserModel>? users,
    SortCategory? sortCategory,
    bool? hasReachedMax,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      sortCategory: sortCategory ?? this.sortCategory,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [users, sortCategory, hasReachedMax];
}

class UserSearching extends UserState {
  const UserSearching();
}

class UserSearchLoaded extends UserState {
  final List<UserModel> users;
  final String query;
  const UserSearchLoaded({required this.users, required this.query});

  @override
  List<Object?> get props => [users, query];
}

class UserAdding extends UserState {
  const UserAdding();
}

class UserAddSuccess extends UserState {
  const UserAddSuccess();
}

class UserFailure extends UserState {
  final String message;
  const UserFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
