import '../repositories/profile_repository.dart';

class ChangePasswordUseCase {
  final ProfileRepository repository;
  ChangePasswordUseCase(this.repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) =>
      repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}
