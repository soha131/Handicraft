import '../../../auth/data/models/user_model.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<UserModel> call(String uid) => repository.getProfile(uid);
}
