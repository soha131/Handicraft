import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserModel> call({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    return await repository.register(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  }
}
