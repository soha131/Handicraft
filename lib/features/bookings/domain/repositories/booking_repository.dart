import '../../data/models/booking_model.dart';

abstract class BookingRepository {
  Future<void> createBooking(BookingModel booking);
  Future<void> cancelBooking(String bookingId, String workshopId);
  Stream<List<BookingModel>> getUserBookings(String userId);
}
