import '../models/admin_models.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  // Dev-mode in-memory fallback
  final List<AdminUserRow> _devUsers = [];
  final List<AdminWorkshopRow> _devWorkshops = [];
  final List<AdminReviewRow> _devReviews = [];

  AdminRepositoryImpl({required this.remoteDataSource});

  bool _isFirebaseError(Object e) {
    final msg = e.toString();
    return msg.contains('no-app') ||
        msg.contains('core/') ||
        msg.contains('FirebaseException') ||
        msg.contains('cloud_firestore');
  }

  @override
  Future<Map<String, int>> getDashboardStats() async {
    try {
      return await remoteDataSource.getDashboardStats();
    } catch (e) {
      if (_isFirebaseError(e)) {
        return {
          'users': _devUsers.length,
          'workshops': _devWorkshops.length,
          'bookings': 0,
          'reviews': _devReviews.length,
        };
      }
      rethrow;
    }
  }

  @override
  Stream<List<AdminUserRow>> getAllUsers() {
    try {
      return remoteDataSource.getAllUsers().map(
            (list) => list.map(AdminUserRow.fromMap).toList(),
          );
    } catch (e) {
      if (_isFirebaseError(e)) return Stream.value(_devUsers);
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await remoteDataSource.deleteUser(uid);
    } catch (e) {
      if (_isFirebaseError(e)) {
        _devUsers.removeWhere((u) => u.uid == uid);
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await remoteDataSource.updateUserRole(uid, newRole);
    } catch (e) {
      if (_isFirebaseError(e)) {
        final idx = _devUsers.indexWhere((u) => u.uid == uid);
        if (idx != -1) {
          _devUsers[idx] = AdminUserRow(
            uid: _devUsers[idx].uid,
            name: _devUsers[idx].name,
            email: _devUsers[idx].email,
            role: newRole,
            createdAt: _devUsers[idx].createdAt,
          );
        }
        return;
      }
      rethrow;
    }
  }

  @override
  Stream<List<AdminWorkshopRow>> getAllWorkshops() {
    try {
      return remoteDataSource
          .getAllWorkshopsAdmin()
          .map((list) => list.map(AdminWorkshopRow.fromMap).toList());
    } catch (e) {
      if (_isFirebaseError(e)) return Stream.value(_devWorkshops);
      rethrow;
    }
  }

  @override
  Future<void> deleteWorkshop(String workshopId) async {
    try {
      await remoteDataSource.deleteWorkshopAdmin(workshopId);
    } catch (e) {
      if (_isFirebaseError(e)) {
        _devWorkshops.removeWhere((w) => w.id == workshopId);
        return;
      }
      rethrow;
    }
  }

  @override
  Stream<List<AdminReviewRow>> getAllReviews() {
    try {
      return remoteDataSource
          .getAllReviewsAdmin()
          .map((list) => list.map(AdminReviewRow.fromMap).toList());
    } catch (e) {
      if (_isFirebaseError(e)) return Stream.value(_devReviews);
      rethrow;
    }
  }

  @override
  Future<void> deleteReview(String reviewId, String workshopId) async {
    try {
      await remoteDataSource.deleteReviewAdmin(reviewId, workshopId);
    } catch (e) {
      if (_isFirebaseError(e)) {
        _devReviews.removeWhere((r) => r.id == reviewId);
        return;
      }
      rethrow;
    }
  }
}
