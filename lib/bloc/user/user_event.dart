part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserFetchRequested extends UserEvent {
  const UserFetchRequested();
}

class UserSearchRequested extends UserEvent {
  final String query;
  const UserSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

class UserAddRequested extends UserEvent {
  final String name;
  final String phoneNumber;
  final int age;
  final File? imageFile;

  const UserAddRequested({
    required this.name,
    required this.phoneNumber,
    required this.age,
    this.imageFile,
  });

  @override
  List<Object?> get props => [name, phoneNumber, age];
}
