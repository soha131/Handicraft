import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role; // 'learner' | 'workshop_owner'
  final DateTime createdAt;
  final String? photoUrl;
  final String? bio;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.photoUrl,
    this.bio,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
    String? photoUrl,
    String? bio,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (bio != null) 'bio': bio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? 'Artisan User',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'learner',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
    );
  }

  /// Role display label used throughout the UI
  String get roleLabel {
    switch (role) {
      case 'workshop_owner':
        return 'Workshop Owner';
      case 'admin':
        return 'Admin';
      default:
        return 'Learner';
    }
  }

  bool get isOwner => role == 'workshop_owner';

  @override
  List<Object?> get props => [uid, name, email, role, createdAt, photoUrl, bio];
}
