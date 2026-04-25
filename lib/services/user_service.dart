import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:totalx_app/models/user_model.dart';
import 'package:totalx_app/utils/app_constants.dart';

class UserResult {
  final List<UserModel> users;
  final List<DocumentSnapshot> docs;
  const UserResult({required this.users, required this.docs});
}

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

  Future<UserResult> getUsers({DocumentSnapshot? lastDocument}) async {
    try {
      Query query = _usersCollection
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return UserResult(
        users: snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        docs: snapshot.docs,
      );
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<List<UserModel>> searchUsers({required String query}) async {
    try {
      final lowerQuery = query.toLowerCase().trim();

      final nameQuery = await _usersCollection
          .where('nameLower', isGreaterThanOrEqualTo: lowerQuery)
          .where('nameLower', isLessThan: '${lowerQuery}z')
          .limit(20)
          .get();

      final phoneQuery = await _usersCollection
          .where('phoneSearch', isGreaterThanOrEqualTo: query)
          .where('phoneSearch', isLessThan: '${query}z')
          .limit(20)
          .get();

      final Map<String, UserModel> resultsMap = {};
      for (final doc in nameQuery.docs) {
        resultsMap[doc.id] = UserModel.fromFirestore(doc);
      }
      for (final doc in phoneQuery.docs) {
        resultsMap[doc.id] = UserModel.fromFirestore(doc);
      }

      return resultsMap.values.toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  Future<UserResult> getUsersByAgeCategory({
    required bool isOlder,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query;
      if (isOlder) {
        query = _usersCollection
            .where('age', isGreaterThan: 60)
            .orderBy('age', descending: true)
            .limit(AppConstants.pageSize);
      } else {
        query = _usersCollection
            .where('age', isLessThanOrEqualTo: 60)
            .orderBy('age')
            .limit(AppConstants.pageSize);
      }
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      final snapshot = await query.get();
      return UserResult(
        users: snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        docs: snapshot.docs,
      );
    } catch (e) {
      throw Exception('Failed to fetch users by age: $e');
    }
  }
}
