import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/booking/data/repositories/booking_repository.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

class DeleteBookingUsecaseParams extends Equatable {
  final String bookingId;

  const DeleteBookingUsecaseParams({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

// Provider for DeleteBookingUsecase
final deleteBookingUsecaseProvider = Provider<DeleteBookingUsecase>((ref) {
  final bookingRepository = ref.read(bookingRepositoryProvider);
  return DeleteBookingUsecase(bookingRepository: bookingRepository);
});

class DeleteBookingUsecase
    implements UsecaseWithParams<bool, DeleteBookingUsecaseParams> {
  final IBookingRepository _bookingRepository;

  DeleteBookingUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteBookingUsecaseParams params) {
    return _bookingRepository.deleteBooking(params.bookingId);
  }
}
