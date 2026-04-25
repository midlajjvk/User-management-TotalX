import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthModel extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AuthModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory AuthModel.fromFirebaseUser(User user) {
    return AuthModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
