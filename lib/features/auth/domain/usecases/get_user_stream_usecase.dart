import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class GetUserStreamUseCase {
  final AuthRepository repository;

  GetUserStreamUseCase(this.repository);

  Stream<UserModel?> call() {
    return repository.userStream;
  }
}
