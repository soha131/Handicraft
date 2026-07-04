import '../../data/models/admin_models.dart';

abstract class AdminRepository {
  Future<Map<String, int>> getDashboardStats();

  Stream<List<AdminUserRow>> getAllUsers();
  Future<void> deleteUser(String uid);
  Future<void> updateUserRole(String uid, String newRole);

  Stream<List<AdminWorkshopRow>> getAllWorkshops();
  Future<void> deleteWorkshop(String workshopId);

  Stream<List<AdminReviewRow>> getAllReviews();
  Future<void> deleteReview(String reviewId, String workshopId);
}
