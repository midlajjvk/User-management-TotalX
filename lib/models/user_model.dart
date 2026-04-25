import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final int age;
  final String? imageUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.age,
    this.imageUrl,
    required this.createdAt,
  });

  bool get isOlder => age > 60;
  bool get isYounger => age <= 60;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'age': age,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'nameLower': name.toLowerCase(),
      'phoneSearch': phoneNumber,
    };
  }

  @override
  List<Object?> get props => [id, name, phoneNumber, age, imageUrl, createdAt];
}
