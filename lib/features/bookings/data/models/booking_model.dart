import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  final String id;
  final String workshopId;
  final String userId;
  final DateTime bookingDate;
  final String status; // e.g. 'active', 'cancelled', 'completed'

  const BookingModel({
    required this.id,
    required this.workshopId,
    required this.userId,
    required this.bookingDate,
    this.status = 'active',
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookingModel(
      id: docId,
      workshopId: map['workshopId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      bookingDate: map['bookingDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['bookingDate'] as int)
          : DateTime.now(),
      status: map['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workshopId': workshopId,
      'userId': userId,
      'bookingDate': bookingDate.millisecondsSinceEpoch,
      'status': status,
    };
  }

  BookingModel copyWith({
    String? id,
    String? workshopId,
    String? userId,
    DateTime? bookingDate,
    String? status,
  }) {
    return BookingModel(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      userId: userId ?? this.userId,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workshopId,
        userId,
        bookingDate,
        status,
      ];
}
