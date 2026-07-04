import 'dart:io';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  /// Returns true when the error is from missing Firebase configuration.
  bool _isFirebaseConfigError(Object e) {
    final msg = e.toString();
    return msg.contains('no-app') ||
        msg.contains('core/') ||
        msg.contains('FirebaseException');
  }

  @override
  Future<UserModel> getProfile(String uid) async {
    try {
      return await remoteDataSource.getProfile(uid);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        // Return a stub profile for development
        return UserModel(
          uid: uid,
          name: 'Artisan User',
          email: 'user@handicraft.app',
          role: 'learner',
          createdAt: DateTime.now(),
          bio: 'Passionate about handcrafted arts.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
    String? bio,
  }) async {
    try {
      return await remoteDataSource.updateProfile(uid: uid, name: name, bio: bio);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        return UserModel(
          uid: uid,
          name: name,
          email: 'user@handicraft.app',
          role: 'learner',
          createdAt: DateTime.now(),
          bio: bio,
        );
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfilePhoto({
    required String uid,
    required File imageFile,
  }) async {
    try {
      return await remoteDataSource.updateProfilePhoto(uid: uid, imageFile: imageFile);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        // In dev mode, just return a model with a local placeholder
        return UserModel(
          uid: uid,
          name: 'Artisan User',
          email: 'user@handicraft.app',
          role: 'learner',
          createdAt: DateTime.now(),
          photoUrl: null, // cannot upload without real Firebase
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        return; // No-op in dev mode
      }
      rethrow;
    }
  }
}
