import 'package:equatable/equatable.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';

enum BookingStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  cancelling,
  cancelled,
  deleting,
  deleted,
  error,
}

class BookingState extends Equatable {
  final BookingStatus status;
  final List<BookingEntity> bookings;
  final BookingEntity? currentBooking;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.initial,
    this.bookings = const [],
    this.currentBooking,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status,
    List<BookingEntity>? bookings,
    BookingEntity? currentBooking,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      currentBooking: currentBooking ?? this.currentBooking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookings, currentBooking, errorMessage];
}
