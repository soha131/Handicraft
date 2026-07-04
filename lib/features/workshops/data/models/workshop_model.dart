import 'package:equatable/equatable.dart';

class WorkshopModel extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String? imageUrl;
  final String category;
  final bool isOnline;
  final List<String> toolsRequired;
  final DateTime startDateTime;
  final double price;
  final String? location; // optional if online
  final int capacity;
  final int bookedSpots;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;

  const WorkshopModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.isOnline,
    required this.toolsRequired,
    required this.startDateTime,
    required this.price,
    this.location,
    this.capacity = 10,
    this.bookedSpots = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    required this.createdAt,
  });

  factory WorkshopModel.fromMap(Map<String, dynamic> map, String docId) {
    return WorkshopModel(
      id: docId,
      ownerId: map['ownerId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      category: map['category'] as String? ?? 'Other',
      isOnline: map['isOnline'] as bool? ?? false,
      toolsRequired: List<String>.from(map['toolsRequired'] ?? []),
      startDateTime: map['startDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startDateTime'] as int)
          : DateTime.now(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] as String?,
      capacity: map['capacity'] as int? ?? 10,
      bookedSpots: map['bookedSpots'] as int? ?? 0,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: map['totalReviews'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'isOnline': isOnline,
      'toolsRequired': toolsRequired,
      'startDateTime': startDateTime.millisecondsSinceEpoch,
      'price': price,
      'location': location,
      'capacity': capacity,
      'bookedSpots': bookedSpots,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  WorkshopModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    bool? isOnline,
    List<String>? toolsRequired,
    DateTime? startDateTime,
    double? price,
    String? location,
    int? capacity,
    int? bookedSpots,
    double? averageRating,
    int? totalReviews,
    DateTime? createdAt,
  }) {
    return WorkshopModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isOnline: isOnline ?? this.isOnline,
      toolsRequired: toolsRequired ?? this.toolsRequired,
      startDateTime: startDateTime ?? this.startDateTime,
      price: price ?? this.price,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      bookedSpots: bookedSpots ?? this.bookedSpots,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        imageUrl,
        category,
        isOnline,
        toolsRequired,
        startDateTime,
        price,
        location,
        capacity,
        bookedSpots,
        averageRating,
        totalReviews,
        createdAt,
      ];
}
