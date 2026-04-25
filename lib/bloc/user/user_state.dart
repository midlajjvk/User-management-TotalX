part of 'user_bloc.dart';

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
  const UserLoaded({required this.users});

  @override
  List<Object?> get props => [users];
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
