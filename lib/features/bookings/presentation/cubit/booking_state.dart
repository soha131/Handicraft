import 'package:equatable/equatable.dart';
import '../../data/models/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  
  const BookingLoaded(this.bookings);
  
  @override
  List<Object?> get props => [bookings];
}

class BookingActionLoading extends BookingState {}

class BookingActionSuccess extends BookingState {
  final String message;
  
  const BookingActionSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class BookingError extends BookingState {
  final String message;
  
  const BookingError(this.message);
  
  @override
  List<Object?> get props => [message];
}
