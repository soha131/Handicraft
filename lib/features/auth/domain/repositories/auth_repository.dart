import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String role,
  });
  Future<void> forgotPassword({required String email});
  Future<void> logout();
  
  // Unified UserModel stream for clean reactive architecture
  Stream<UserModel?> get userStream;
  Future<UserModel?> getCurrentUser();
}
