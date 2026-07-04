import 'dart:io';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRepository {
  /// Fetch the latest profile from Firestore for [uid].
  Future<UserModel> getProfile(String uid);

  /// Update display name and/or bio in Firestore (and Firebase Auth displayName).
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
  });

  /// Upload a new photo to Firebase Storage and save the URL to Firestore.
  Future<UserModel> updateProfilePhoto({
    required String uid,
    required File imageFile,
  });


}
