import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/booking_model.dart';
import '../../domain/usecases/booking_usecases.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final CreateBookingUseCase createUseCase;
  final CancelBookingUseCase cancelUseCase;
  final GetUserBookingsUseCase getUserBookingsUseCase;

  StreamSubscription? _bookingsSubscription;

  BookingCubit({
    required this.createUseCase,
    required this.cancelUseCase,
    required this.getUserBookingsUseCase,
  }) : super(BookingInitial());

  void loadUserBookings(String userId) {
    emit(BookingLoading());
    _bookingsSubscription?.cancel();
    _bookingsSubscription = getUserBookingsUseCase(userId).listen(
      (bookings) {
        emit(BookingLoaded(bookings));
      },
      onError: (error) {
        emit(BookingError(_cleanErrorMessage(error.toString())));
      },
    );
  }

  Future<void> createBooking(BookingModel booking) async {
    emit(BookingActionLoading());
    try {
      await createUseCase(booking);
      emit(const BookingActionSuccess('Workshop booked successfully!'));
    } catch (e) {
      emit(BookingError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> cancelBooking(String bookingId, String workshopId) async {
    emit(BookingActionLoading());
    try {
      await cancelUseCase(bookingId, workshopId);
      emit(const BookingActionSuccess('Booking cancelled successfully.'));
    } catch (e) {
      emit(BookingError(_cleanErrorMessage(e.toString())));
    }
  }

  String _cleanErrorMessage(String rawError) {
    return rawError.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }
}
