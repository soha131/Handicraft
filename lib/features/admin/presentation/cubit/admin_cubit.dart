import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_models.dart';
import '../../domain/usecases/admin_usecases.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final GetAdminStatsUseCase getStatsUseCase;
  final GetAllUsersAdminUseCase getUsersUseCase;
  final DeleteUserAdminUseCase deleteUserUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;
  final GetAllWorkshopsAdminUseCase getWorkshopsUseCase;
  final DeleteWorkshopAdminUseCase deleteWorkshopUseCase;
  final GetAllReviewsAdminUseCase getReviewsUseCase;
  final DeleteReviewAdminUseCase deleteReviewUseCase;

  StreamSubscription? _usersSubscription;
  StreamSubscription? _workshopsSubscription;
  StreamSubscription? _reviewsSubscription;

  List<AdminUserRow> _allUsers = [];

  AdminCubit({
    required this.getStatsUseCase,
    required this.getUsersUseCase,
    required this.deleteUserUseCase,
    required this.updateUserRoleUseCase,
    required this.getWorkshopsUseCase,
    required this.deleteWorkshopUseCase,
    required this.getReviewsUseCase,
    required this.deleteReviewUseCase,
  }) : super(AdminInitial());

  // ── Dashboard ───────────────────────────────────────────────────────────────
  Future<void> loadStats() async {
    emit(AdminLoading());
    try {
      final stats = await getStatsUseCase();
      emit(AdminStatsLoaded(stats));
    } catch (e) {
      emit(AdminError(_clean(e)));
    }
  }

  // ── Users ────────────────────────────────────────────────────────────────────
  void loadUsers() {
    emit(AdminLoading());
    _usersSubscription?.cancel();
    _usersSubscription = getUsersUseCase().listen(
      (users) {
        _allUsers = users;
        emit(AdminUsersLoaded(users: users, filtered: users));
      },
      onError: (e) => emit(AdminError(_clean(e))),
    );
  }

  void filterUsers(String query) {
    final q = query.toLowerCase().trim();
    final filtered = q.isEmpty
        ? _allUsers
        : _allUsers
            .where((u) =>
                u.name.toLowerCase().contains(q) ||
                u.email.toLowerCase().contains(q) ||
                u.role.toLowerCase().contains(q))
            .toList();
    emit(AdminUsersLoaded(users: _allUsers, query: query, filtered: filtered));
  }

  Future<void> deleteUser(String uid) async {
    emit(AdminActionLoading());
    try {
      await deleteUserUseCase(uid);
      emit(const AdminActionSuccess('User deleted successfully.'));
    } catch (e) {
      emit(AdminError(_clean(e)));
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    emit(AdminActionLoading());
    try {
      await updateUserRoleUseCase(uid, newRole);
      emit(const AdminActionSuccess('User role updated.'));
    } catch (e) {
      emit(AdminError(_clean(e)));
    }
  }

  // ── Workshops ────────────────────────────────────────────────────────────────
  void loadWorkshops() {
    emit(AdminLoading());
    _workshopsSubscription?.cancel();
    _workshopsSubscription = getWorkshopsUseCase().listen(
      (workshops) => emit(AdminWorkshopsLoaded(workshops)),
      onError: (e) => emit(AdminError(_clean(e))),
    );
  }

  Future<void> deleteWorkshop(String workshopId) async {
    emit(AdminActionLoading());
    try {
      await deleteWorkshopUseCase(workshopId);
      emit(const AdminActionSuccess('Workshop and all its bookings/reviews deleted.'));
    } catch (e) {
      emit(AdminError(_clean(e)));
    }
  }

  // ── Reviews ──────────────────────────────────────────────────────────────────
  void loadReviews() {
    emit(AdminLoading());
    _reviewsSubscription?.cancel();
    _reviewsSubscription = getReviewsUseCase().listen(
      (reviews) => emit(AdminReviewsLoaded(reviews)),
      onError: (e) => emit(AdminError(_clean(e))),
    );
  }

  Future<void> deleteReview(String reviewId, String workshopId) async {
    emit(AdminActionLoading());
    try {
      await deleteReviewUseCase(reviewId, workshopId);
      emit(const AdminActionSuccess('Review removed.'));
    } catch (e) {
      emit(AdminError(_clean(e)));
    }
  }

  String _clean(Object e) =>
      e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _workshopsSubscription?.cancel();
    _reviewsSubscription?.cancel();
    return super.close();
  }
}
