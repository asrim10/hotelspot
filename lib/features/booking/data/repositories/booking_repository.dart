import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/services/connectivity/network_info.dart';
import 'package:hotelspot/features/booking/data/datasources/booking_datasource.dart';
import 'package:hotelspot/features/booking/data/datasources/local/booking_local_datasource.dart';
import 'package:hotelspot/features/booking/data/datasources/remote/booking_remote_datasource.dart';
import 'package:hotelspot/features/booking/data/models/booking_api_model.dart';
import 'package:hotelspot/features/booking/data/models/booking_hive_model.dart';
import 'package:hotelspot/features/booking/domain/entities/booking_entity.dart';
import 'package:hotelspot/features/booking/domain/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  final bookingLocalDatasource = ref.read(bookingLocalDatasourceProvider);
  final bookingRemoteDatasource = ref.read(bookingRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return BookingRepository(
    bookingLocalDatasource: bookingLocalDatasource,
    bookingRemoteDatasource: bookingRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class BookingRepository implements IBookingRepository {
  final IBookingLocalDataSource _bookingLocalDatasource;
  final IBookingRemoteDataSource _bookingRemoteDataSource;
  final NetworkInfo _networkInfo;

  BookingRepository({
    required IBookingLocalDataSource bookingLocalDatasource,
    required IBookingRemoteDataSource bookingRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _bookingLocalDatasource = bookingLocalDatasource,
       _bookingRemoteDataSource = bookingRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, BookingEntity>> createBooking(
    BookingEntity booking,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = BookingApiModel.fromEntity(booking);
        final result = await _bookingRemoteDataSource.createBooking(apiModel);

        // Save to local database for offline access
        final hiveModel = BookingHiveModel.fromEntity(result.toEntity());
        await _bookingLocalDatasource.createBooking(hiveModel);

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to create booking",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final hiveModel = BookingHiveModel.fromEntity(booking);
        final result = await _bookingLocalDatasource.createBooking(hiveModel);
        return Right(result.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyBookings() async {
    if (await _networkInfo.isConnected) {
      try {
        final bookings = await _bookingRemoteDataSource.getMyBookings();

        // Save to local database for offline access
        for (final booking in bookings) {
          final hiveModel = BookingHiveModel.fromEntity(booking.toEntity());
          await _bookingLocalDatasource.createBooking(hiveModel);
        }

        return Right(BookingApiModel.toEntityList(bookings));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to fetch bookings",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        // Get userId from session - you'll need to implement this
        // For now, passing empty string - update based on your session management
        final bookings = await _bookingLocalDatasource.getMyBookings('');
        return Right(BookingHiveModel.toEntityList(bookings));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingById(
    String bookingId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final booking = await _bookingRemoteDataSource.getBookingById(
          bookingId,
        );

        // Save to local database
        final hiveModel = BookingHiveModel.fromEntity(booking.toEntity());
        await _bookingLocalDatasource.createBooking(hiveModel);

        return Right(booking.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to fetch booking",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final booking = await _bookingLocalDatasource.getBookingById(bookingId);
        if (booking != null) {
          return Right(booking.toEntity());
        }
        return const Left(LocalDatabaseFailure(message: 'Booking not found'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bookingRemoteDataSource.cancelBooking(
          bookingId,
          reason,
        );

        // Update local database
        await _bookingLocalDatasource.cancelBooking(bookingId);

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to cancel booking",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final booking = await _bookingLocalDatasource.cancelBooking(bookingId);
        if (booking != null) {
          return const Right(true);
        }
        return const Left(
          LocalDatabaseFailure(message: 'Failed to cancel booking'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final booking = await _bookingRemoteDataSource.updatePaymentStatus(
          bookingId,
          paymentStatus,
        );

        // Update local database
        final hiveModel = BookingHiveModel.fromEntity(booking.toEntity());
        await _bookingLocalDatasource.updateBooking(hiveModel);

        return Right(booking.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ??
                "Failed to update payment status",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final booking = await _bookingLocalDatasource.updatePaymentStatus(
          bookingId,
          paymentStatus,
        );
        if (booking != null) {
          return Right(booking.toEntity());
        }
        return const Left(
          LocalDatabaseFailure(message: 'Failed to update payment status'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updatePaymentMethod(
    String bookingId,
    String paymentMethod,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final booking = await _bookingRemoteDataSource.updatePaymentMethod(
          bookingId,
          paymentMethod,
        );

        // Update local database
        final hiveModel = BookingHiveModel.fromEntity(booking.toEntity());
        await _bookingLocalDatasource.updateBooking(hiveModel);

        return Right(booking.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ??
                "Failed to update payment method",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final booking = await _bookingLocalDatasource.updatePaymentMethod(
          bookingId,
          paymentMethod,
        );
        if (booking != null) {
          return Right(booking.toEntity());
        }
        return const Left(
          LocalDatabaseFailure(message: 'Failed to update payment method'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final booking = await _bookingRemoteDataSource.updateBookingStatus(
          bookingId,
          status,
        );

        // Update local database
        final hiveModel = BookingHiveModel.fromEntity(booking.toEntity());
        await _bookingLocalDatasource.updateBooking(hiveModel);

        return Right(booking.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ??
                "Failed to update booking status",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final booking = await _bookingLocalDatasource.updateBookingStatus(
          bookingId,
          status,
        );
        if (booking != null) {
          return Right(booking.toEntity());
        }
        return const Left(
          LocalDatabaseFailure(message: 'Failed to update booking status'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBooking(String bookingId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bookingRemoteDataSource.deleteBooking(bookingId);

        // Delete from local database
        await _bookingLocalDatasource.deleteBooking(bookingId);

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to delete booking",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _bookingLocalDatasource.deleteBooking(bookingId);
        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
