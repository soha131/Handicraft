import 'package:equatable/equatable.dart';
import '../../data/models/admin_models.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

// Dashboard
class AdminStatsLoaded extends AdminState {
  final Map<String, int> stats;
  const AdminStatsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

// Users
class AdminUsersLoaded extends AdminState {
  final List<AdminUserRow> users;
  final String query;
  final List<AdminUserRow> filtered;

  const AdminUsersLoaded({
    required this.users,
    this.query = '',
    required this.filtered,
  });
  @override
  List<Object?> get props => [users, query, filtered];
}

// Workshops
class AdminWorkshopsLoaded extends AdminState {
  final List<AdminWorkshopRow> workshops;
  const AdminWorkshopsLoaded(this.workshops);
  @override
  List<Object?> get props => [workshops];
}

// Reviews
class AdminReviewsLoaded extends AdminState {
  final List<AdminReviewRow> reviews;
  const AdminReviewsLoaded(this.reviews);
  @override
  List<Object?> get props => [reviews];
}

class AdminActionLoading extends AdminState {}

class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}
