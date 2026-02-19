import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/delete_booking_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/get_booking_by_id_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/get_my_booking_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/update_booking_status_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/update_payment_method_usecase.dart';
import 'package:hotelspot/features/booking/domain/usecases/update_payment_status_usecase.dart';
import 'package:hotelspot/features/booking/presentation/state/booking_state.dart';

final bookingViewModelProvider =
    NotifierProvider<BookingViewModel, BookingState>(() => BookingViewModel());

class BookingViewModel extends Notifier<BookingState> {
  late final CreateBookingUsecase _createBookingUsecase;
  late final GetMyBookingsUsecase _getMyBookingsUsecase;
  late final GetBookingByIdUsecase _getBookingByIdUsecase;
  late final CancelBookingUsecase _cancelBookingUsecase;
  late final UpdatePaymentStatusUsecase _updatePaymentStatusUsecase;
  late final UpdatePaymentMethodUsecase _updatePaymentMethodUsecase;
  late final UpdateBookingStatusUsecase _updateBookingStatusUsecase;
  late final DeleteBookingUsecase _deleteBookingUsecase;

  @override
  BookingState build() {
    _createBookingUsecase = ref.read(createBookingUsecaseProvider);
    _getMyBookingsUsecase = ref.read(getMyBookingsUsecaseProvider);
    _getBookingByIdUsecase = ref.read(getBookingByIdUsecaseProvider);
    _cancelBookingUsecase = ref.read(cancelBookingUsecaseProvider);
    _updatePaymentStatusUsecase = ref.read(updatePaymentStatusUsecaseProvider);
    _updatePaymentMethodUsecase = ref.read(updatePaymentMethodUsecaseProvider);
    _updateBookingStatusUsecase = ref.read(updateBookingStatusUsecaseProvider);
    _deleteBookingUsecase = ref.read(deleteBookingUsecaseProvider);
    return const BookingState();
  }

  // Create Booking
  Future<void> createBooking(BookingEntity booking) async {
    state = state.copyWith(status: BookingStatus.creating);

    final params = CreateBookingUsecaseParams(booking: booking);
    final result = await _createBookingUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (createdBooking) {
        state = state.copyWith(
          status: BookingStatus.created,
          currentBooking: createdBooking,
          bookings: [...state.bookings, createdBooking],
        );
      },
    );
  }

  // Get My Bookings
  Future<void> getMyBookings() async {
    state = state.copyWith(status: BookingStatus.loading);

    final result = await _getMyBookingsUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (bookings) {
        state = state.copyWith(
          status: BookingStatus.loaded,
          bookings: bookings,
        );
      },
    );
  }

  // Get Booking By ID
  Future<void> getBookingById(String bookingId) async {
    state = state.copyWith(status: BookingStatus.loading);

    final params = GetBookingByIdUsecaseParams(bookingId: bookingId);
    final result = await _getBookingByIdUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (booking) {
        state = state.copyWith(
          status: BookingStatus.loaded,
          currentBooking: booking,
        );
      },
    );
  }

  // Cancel Booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    state = state.copyWith(status: BookingStatus.cancelling);

    final params = CancelBookingUsecaseParams(
      bookingId: bookingId,
      reason: reason,
    );
    final result = await _cancelBookingUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        if (success) {
          // Update the bookings list to reflect the cancelled status
          final updatedBookings = state.bookings.map((booking) {
            if (booking.bookingId == bookingId) {
              return BookingEntity(
                bookingId: booking.bookingId,
                userId: booking.userId,
                hotelId: booking.hotelId,
                fullName: booking.fullName,
                email: booking.email,
                checkInDate: booking.checkInDate,
                checkOutDate: booking.checkOutDate,
                totalPrice: booking.totalPrice,
                paymentMethod: booking.paymentMethod,
                paymentStatus: booking.paymentStatus,
                status: 'cancelled',
                createdAt: booking.createdAt,
                updatedAt: DateTime.now(),
              );
            }
            return booking;
          }).toList();

          state = state.copyWith(
            status: BookingStatus.cancelled,
            bookings: updatedBookings,
          );
        } else {
          state = state.copyWith(
            status: BookingStatus.error,
            errorMessage: "Failed to cancel booking",
          );
        }
      },
    );
  }

  // Update Payment Status
  Future<void> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  ) async {
    state = state.copyWith(status: BookingStatus.updating);

    final params = UpdatePaymentStatusUsecaseParams(
      bookingId: bookingId,
      paymentStatus: paymentStatus,
    );
    final result = await _updatePaymentStatusUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (updatedBooking) {
        // Update the bookings list
        final updatedBookings = state.bookings.map((booking) {
          if (booking.bookingId == bookingId) {
            return updatedBooking;
          }
          return booking;
        }).toList();

        state = state.copyWith(
          status: BookingStatus.updated,
          currentBooking: updatedBooking,
          bookings: updatedBookings,
        );
      },
    );
  }

  // Update Payment Method
  Future<void> updatePaymentMethod(
    String bookingId,
    String paymentMethod,
  ) async {
    state = state.copyWith(status: BookingStatus.updating);

    final params = UpdatePaymentMethodUsecaseParams(
      bookingId: bookingId,
      paymentMethod: paymentMethod,
    );
    final result = await _updatePaymentMethodUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (updatedBooking) {
        // Update the bookings list
        final updatedBookings = state.bookings.map((booking) {
          if (booking.bookingId == bookingId) {
            return updatedBooking;
          }
          return booking;
        }).toList();

        state = state.copyWith(
          status: BookingStatus.updated,
          currentBooking: updatedBooking,
          bookings: updatedBookings,
        );
      },
    );
  }

  // Update Booking Status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    state = state.copyWith(status: BookingStatus.updating);

    final params = UpdateBookingStatusUsecaseParams(
      bookingId: bookingId,
      status: status,
    );
    final result = await _updateBookingStatusUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (updatedBooking) {
        // Update the bookings list
        final updatedBookings = state.bookings.map((booking) {
          if (booking.bookingId == bookingId) {
            return updatedBooking;
          }
          return booking;
        }).toList();

        state = state.copyWith(
          status: BookingStatus.updated,
          currentBooking: updatedBooking,
          bookings: updatedBookings,
        );
      },
    );
  }

  // Delete Booking
  Future<void> deleteBooking(String bookingId) async {
    state = state.copyWith(status: BookingStatus.deleting);

    final params = DeleteBookingUsecaseParams(bookingId: bookingId);
    final result = await _deleteBookingUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        if (success) {
          // Remove the booking from the list
          final updatedBookings = state.bookings
              .where((booking) => booking.bookingId != bookingId)
              .toList();

          state = state.copyWith(
            status: BookingStatus.deleted,
            bookings: updatedBookings,
            currentBooking: null,
          );
        } else {
          state = state.copyWith(
            status: BookingStatus.error,
            errorMessage: "Failed to delete booking",
          );
        }
      },
    );
  }

  // Reset state
  void resetState() {
    state = const BookingState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(status: BookingStatus.initial, errorMessage: null);
  }
}
