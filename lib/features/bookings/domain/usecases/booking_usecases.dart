import '../repositories/booking_repository.dart';
import '../../data/models/booking_model.dart';

class CreateBookingUseCase {
  final BookingRepository repository;
  
  CreateBookingUseCase(this.repository);
  
  Future<void> call(BookingModel booking) {
    return repository.createBooking(booking);
  }
}

class CancelBookingUseCase {
  final BookingRepository repository;
  
  CancelBookingUseCase(this.repository);
  
  Future<void> call(String bookingId, String workshopId) {
    return repository.cancelBooking(bookingId, workshopId);
  }
}

class GetUserBookingsUseCase {
  final BookingRepository repository;
  
  GetUserBookingsUseCase(this.repository);
  
  Stream<List<BookingModel>> call(String userId) {
    return repository.getUserBookings(userId);
  }
}
