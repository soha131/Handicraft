import 'package:uuid/uuid.dart';

import '../models/booking_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final Uuid _uuid = const Uuid();

  // In-memory fallback for dev mode
  final List<BookingModel> _devBookings = [];

  BookingRepositoryImpl({required this.remoteDataSource});

  bool _isFirebaseConfigError(Object e) {
    final msg = e.toString();
    return msg.contains('no-app') ||
        msg.contains('core/') ||
        msg.contains('FirebaseException') ||
        msg.contains('cloud_firestore');
  }

  @override
  Future<void> createBooking(BookingModel booking) async {
    try {
      final docId = _uuid.v4();
      final newBooking = booking.copyWith(id: docId);
      await remoteDataSource.createBooking(newBooking.toMap(), docId, newBooking.workshopId);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        final docId = _uuid.v4();
        _devBookings.add(booking.copyWith(id: docId));
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> cancelBooking(String bookingId, String workshopId) async {
    try {
      await remoteDataSource.cancelBooking(bookingId, workshopId);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        final index = _devBookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _devBookings[index] = _devBookings[index].copyWith(status: 'cancelled');
        }
        return;
      }
      rethrow;
    }
  }

  @override
  Stream<List<BookingModel>> getUserBookings(String userId) {
    try {
      return remoteDataSource.getUserBookings(userId).map((list) {
        return list.map((map) => BookingModel.fromMap(map, map['id'] as String)).toList();
      }).handleError((e) {
        if (_isFirebaseConfigError(e)) {
          return Stream.value(_devBookings.where((b) => b.userId == userId).toList());
        }
        throw e;
      });
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        return Stream.value(_devBookings.where((b) => b.userId == userId).toList());
      }
      rethrow;
    }
  }
}
