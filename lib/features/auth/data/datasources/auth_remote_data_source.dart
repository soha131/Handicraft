import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> login({required String email, required String password});
  Future<UserCredential> register({required String email, required String password});
  Future<void> saveUserData(UserModel userModel);
  Future<UserModel?> getUserData(String uid);
  Future<void> forgotPassword({required String email});
  Future<void> logout();
  Stream<User?> get userStream;
  User? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserCredential> login({required String email, required String password}) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<UserCredential> register({required String email, required String password}) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> saveUserData(UserModel userModel) async {
    await firestore.collection('users').doc(userModel.uid).set(userModel.toMap());
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Stream<User?> get userStream => firebaseAuth.authStateChanges();

  @override
  User? get currentUser => firebaseAuth.currentUser;
}
