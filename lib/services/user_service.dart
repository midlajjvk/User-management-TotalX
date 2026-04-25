import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:totalx_app/models/user_model.dart';
import 'package:totalx_app/utils/app_constants.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid;

  UserService({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required Uuid uuid,
  })  : _firestore = firestore,
        _storage = storage,
        _uuid = uuid;

  CollectionReference get _usersCollection =>
      _firestore.collection(AppConstants.usersCollection);

  Future<void> addUser({
    required String name,
    required String phoneNumber,
    required int age,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      final id = _uuid.v4();
      final user = UserModel(
        id: id,
        name: name,
        phoneNumber: phoneNumber,
        age: age,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _usersCollection.doc(id).set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage
          .ref()
          .child(AppConstants.userImagesPath)
          .child(fileName);

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final snapshot = await _usersCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }
}
