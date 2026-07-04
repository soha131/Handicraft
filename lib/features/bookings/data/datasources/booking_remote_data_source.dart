import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BookingRemoteDataSource {
  Future<void> createBooking(Map<String, dynamic> bookingData, String bookingId, String workshopId);
  Future<void> cancelBooking(String bookingId, String workshopId);
  Stream<List<Map<String, dynamic>>> getUserBookings(String userId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createBooking(Map<String, dynamic> bookingData, String bookingId, String workshopId) async {
    final batch = firestore.batch();

    // Create booking document
    final bookingRef = firestore.collection('bookings').doc(bookingId);
    batch.set(bookingRef, bookingData);

    // Increment bookedSpots in workshop document
    final workshopRef = firestore.collection('workshops').doc(workshopId);
    batch.update(workshopRef, {
      'bookedSpots': FieldValue.increment(1),
    });

    await batch.commit();
  }

  @override
  Future<void> cancelBooking(String bookingId, String workshopId) async {
    final batch = firestore.batch();

    // Update booking status to cancelled
    final bookingRef = firestore.collection('bookings').doc(bookingId);
    batch.update(bookingRef, {'status': 'cancelled'});

    // Decrement bookedSpots in workshop document
    final workshopRef = firestore.collection('workshops').doc(workshopId);
    batch.update(workshopRef, {
      'bookedSpots': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  @override
  Stream<List<Map<String, dynamic>>> getUserBookings(String userId) {
    return firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
