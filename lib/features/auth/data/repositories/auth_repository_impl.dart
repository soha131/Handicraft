import 'dart:async';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  
  // Static development fallback parameters
  static UserModel? _mockUser;
  static final StreamController<UserModel?> _mockUserStreamController = StreamController<UserModel?>.broadcast();

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final credential = await remoteDataSource.login(email: email, password: password);
      final user = await remoteDataSource.getUserData(credential.user!.uid);
      if (user == null) {
        throw Exception("User profile not found in Firestore database.");
      }
      return user;
    } catch (e) {
      if (e.toString().contains('no-app') || e.toString().contains('core/')) {
        final mockName = email.split('@')[0];
        final mock = UserModel(
          uid: 'mock_uid_123',
          name: mockName,
          email: email,
          role: 'learner',
          createdAt: DateTime.now(),
        );
        _mockUser = mock;
        _mockUserStreamController.add(mock);
        return mock;
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final credential = await remoteDataSource.register(email: email, password: password);
      final user = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
      await remoteDataSource.saveUserData(user);
      return user;
    } catch (e) {
      if (e.toString().contains('no-app') || e.toString().contains('core/')) {
        final mockName = name.isEmpty ? email.split('@')[0] : name;
        final mock = UserModel(
          uid: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
          name: mockName,
          email: email,
          role: role,
          createdAt: DateTime.now(),
        );
        _mockUser = mock;
        _mockUserStreamController.add(mock);
        return mock;
      }
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
    } catch (e) {
      if (e.toString().contains('no-app') || e.toString().contains('core/')) {
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      if (e.toString().contains('no-app') || e.toString().contains('core/')) {
        _mockUser = null;
        _mockUserStreamController.add(null);
        return;
      }
      rethrow;
    }
  }

  @override
  Stream<UserModel?> get userStream {
    try {
      return remoteDataSource.userStream.asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;
        try {
          return await remoteDataSource.getUserData(firebaseUser.uid);
        } catch (_) {
          return null;
        }
      });
    } catch (_) {
      return _mockUserStreamController.stream;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = remoteDataSource.currentUser;
      if (firebaseUser == null) return null;
      return await remoteDataSource.getUserData(firebaseUser.uid);
    } catch (_) {
      return _mockUser;
    }
  }
}
