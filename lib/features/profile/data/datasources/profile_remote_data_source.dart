import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String uid);
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
  });
  Future<UserModel> updateProfilePhoto({
    required String uid,
    required File imageFile,
  });

}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.storage,
  });

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  @override
  Future<UserModel> getProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Profile not found for uid: $uid');
    }
    return UserModel.fromMap(doc.data()!);
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
  }) async {
    final updates = <String, dynamic>{
      'name': name,
    };

    await _users.doc(uid).update(updates);

    // Also update Firebase Auth displayName
    final fbUser = firebaseAuth.currentUser;
    if (fbUser != null) {
      await fbUser.updateDisplayName(name);
    }

    return getProfile(uid);
  }

  @override
  Future<UserModel> updateProfilePhoto({
    required String uid,
    required File imageFile,
  }) async {
    // Upload to Firebase Storage at avatars/{uid}.jpg
    final ref = storage.ref().child('avatars/$uid.jpg');
    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Save URL to Firestore
    await _users.doc(uid).update({'photoUrl': downloadUrl});

    // Also update Firebase Auth photo URL
    final fbUser = firebaseAuth.currentUser;
    if (fbUser != null) {
      await fbUser.updatePhotoURL(downloadUrl);
    }

    return getProfile(uid);
  }


}
