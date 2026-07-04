import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_user_stream_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final LogoutUseCase logoutUseCase;
  final GetUserStreamUseCase getUserStreamUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  StreamSubscription? _userStreamSubscription;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.logoutUseCase,
    required this.getUserStreamUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    _subscribeToUserStream();
  }

  void _subscribeToUserStream() {
    _userStreamSubscription = getUserStreamUseCase().listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    }, onError: (error) {
      emit(AuthError(error.toString()));
    });
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await loginUseCase(email, password);
    } catch (e) {
      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    emit(AuthLoading());
    try {
      await registerUseCase(
        email: email,
        password: password,
        name: name,
        role: role,
      );
    } catch (e) {
      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    emit(AuthLoading());
    try {
      await forgotPasswordUseCase(email);
      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
    } catch (e) {
      emit(AuthError(_cleanErrorMessage(e.toString())));
    }
  }

  String _cleanErrorMessage(String rawError) {
    if (rawError.contains('invalid-email')) {
      return 'The email address is badly formatted.';
    } else if (rawError.contains('user-not-found')) {
      return 'No user found for this email address.';
    } else if (rawError.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (rawError.contains('email-already-in-use')) {
      return 'The email address is already in use by another account.';
    } else if (rawError.contains('weak-password')) {
      return 'The password is too weak. Must be at least 6 characters.';
    }
    return rawError.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }

  @override
  Future<void> close() {
    _userStreamSubscription?.cancel();
    return super.close();
  }
}
