import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/update_profile_photo_usecase.dart';
import '../../../auth/data/models/user_model.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateProfilePhotoUseCase updateProfilePhotoUseCase;

  ProfileCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updateProfilePhotoUseCase,
  }) : super(ProfileInitial());

  /// Load the current user's profile from Firestore.
  Future<void> loadProfile(String uid) async {
    emit(ProfileLoading());
    try {
      final user = await getProfileUseCase(uid);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_clean(e)));
    }
  }

  /// Initialize directly from an already-loaded [UserModel] (e.g. from AuthCubit).
  void initFromUser(UserModel user) {
    emit(ProfileLoaded(user));
  }

  /// Update display name
  Future<void> updateProfile({
    required String uid,
    required String name,
  }) async {
    final current = _currentUser();
    if (current == null) return;

    emit(ProfileUpdating(current));
    try {
      final updated = await updateProfileUseCase(uid: uid, name: name);
      emit(ProfileUpdateSuccess(updated, 'Profile updated successfully!'));
    } catch (e) {
      emit(ProfileError(_clean(e)));
    }
  }

  /// Pick and upload a new avatar photo.
  Future<void> updatePhoto({required String uid, required File imageFile}) async {
    final current = _currentUser();
    if (current == null) return;

    emit(ProfileUpdating(current));
    try {
      final updated = await updateProfilePhotoUseCase(uid: uid, imageFile: imageFile);
      emit(ProfileUpdateSuccess(updated, 'Profile photo updated!'));
    } catch (e) {
      emit(ProfileError(_clean(e)));
    }
  }



  /// Get current UserModel from state (if loaded).
  UserModel? _currentUser() {
    final s = state;
    if (s is ProfileLoaded) return s.user;
    if (s is ProfileUpdating) return s.user;
    if (s is ProfileUpdateSuccess) return s.user;
    return null;
  }

  String _clean(Object e) {
    final msg = e.toString();
    if (msg.contains('wrong-password') || msg.contains('invalid-credential')) {
      return 'Current password is incorrect.';
    } else if (msg.contains('weak-password')) {
      return 'New password is too weak (min 6 characters).';
    } else if (msg.contains('requires-recent-login')) {
      return 'Please log out and log back in before changing your password.';
    }
    return msg.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }
}
