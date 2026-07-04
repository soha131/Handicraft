import '../../../auth/data/models/user_model.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<UserModel> call({
    required String uid,
    required String name,
    String? bio,
  }) =>
      repository.updateProfile(uid: uid, name: name, bio: bio);
}
