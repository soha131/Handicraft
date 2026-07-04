import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

/// Profile loaded and ready to display.
class ProfileLoaded extends ProfileState {
  final UserModel user;
  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// An operation (update, photo, password) is in progress.
class ProfileUpdating extends ProfileState {
  final UserModel user; // keep current user visible during update
  const ProfileUpdating(this.user);

  @override
  List<Object?> get props => [user];
}

/// Profile updated successfully; carries a success message.
class ProfileUpdateSuccess extends ProfileState {
  final UserModel user;
  final String message;
  const ProfileUpdateSuccess(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after password changed successfully.
class PasswordChangeSuccess extends ProfileState {}
