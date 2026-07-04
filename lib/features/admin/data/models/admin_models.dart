import 'package:equatable/equatable.dart';

// Lightweight DTO used in admin tables — no separate entity class needed
class AdminUserRow extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  const AdminUserRow({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory AdminUserRow.fromMap(Map<String, dynamic> map) {
    return AdminUserRow(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'learner',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [uid, name, email, role, createdAt];
}

class AdminWorkshopRow extends Equatable {
  final String id;
  final String title;
  final String category;
  final String ownerId;
  final double price;
  final int bookedSpots;
  final int capacity;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;

  const AdminWorkshopRow({
    required this.id,
    required this.title,
    required this.category,
    required this.ownerId,
    required this.price,
    required this.bookedSpots,
    required this.capacity,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
  });

  factory AdminWorkshopRow.fromMap(Map<String, dynamic> map) {
    return AdminWorkshopRow(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      bookedSpots: map['bookedSpots'] as int? ?? 0,
      capacity: map['capacity'] as int? ?? 10,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: map['totalReviews'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, title, category, ownerId, price, bookedSpots, capacity, createdAt];
}

class AdminReviewRow extends Equatable {
  final String id;
  final String workshopId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const AdminReviewRow({
    required this.id,
    required this.workshopId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory AdminReviewRow.fromMap(Map<String, dynamic> map) {
    return AdminReviewRow(
      id: map['id'] as String? ?? '',
      workshopId: map['workshopId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Unknown',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, workshopId, userId, userName, rating, comment, createdAt];
}
