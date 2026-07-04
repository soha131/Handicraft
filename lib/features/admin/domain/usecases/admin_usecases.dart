import '../repositories/admin_repository.dart';
import '../../data/models/admin_models.dart';

class GetAdminStatsUseCase {
  final AdminRepository repository;
  GetAdminStatsUseCase(this.repository);
  Future<Map<String, int>> call() => repository.getDashboardStats();
}

class GetAllUsersAdminUseCase {
  final AdminRepository repository;
  GetAllUsersAdminUseCase(this.repository);
  Stream<List<AdminUserRow>> call() => repository.getAllUsers();
}

class DeleteUserAdminUseCase {
  final AdminRepository repository;
  DeleteUserAdminUseCase(this.repository);
  Future<void> call(String uid) => repository.deleteUser(uid);
}

class UpdateUserRoleUseCase {
  final AdminRepository repository;
  UpdateUserRoleUseCase(this.repository);
  Future<void> call(String uid, String newRole) => repository.updateUserRole(uid, newRole);
}

class GetAllWorkshopsAdminUseCase {
  final AdminRepository repository;
  GetAllWorkshopsAdminUseCase(this.repository);
  Stream<List<AdminWorkshopRow>> call() => repository.getAllWorkshops();
}

class DeleteWorkshopAdminUseCase {
  final AdminRepository repository;
  DeleteWorkshopAdminUseCase(this.repository);
  Future<void> call(String workshopId) => repository.deleteWorkshop(workshopId);
}

class GetAllReviewsAdminUseCase {
  final AdminRepository repository;
  GetAllReviewsAdminUseCase(this.repository);
  Stream<List<AdminReviewRow>> call() => repository.getAllReviews();
}

class DeleteReviewAdminUseCase {
  final AdminRepository repository;
  DeleteReviewAdminUseCase(this.repository);
  Future<void> call(String reviewId, String workshopId) => repository.deleteReview(reviewId, workshopId);
}
