import 'dart:io';
import '../../../auth/data/models/user_model.dart';
import '../repositories/profile_repository.dart';

class UpdateProfilePhotoUseCase {
  final ProfileRepository repository;
  UpdateProfilePhotoUseCase(this.repository);

  Future<UserModel> call({
    required String uid,
    required File imageFile,
  }) =>
      repository.updateProfilePhoto(uid: uid, imageFile: imageFile);
}
