import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_client.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/booking/data/datasources/booking_datasource.dart';
import 'package:hotelspot/features/booking/data/models/booking_api_model.dart';

final bookingRemoteDatasourceProvider = Provider<IBookingRemoteDataSource>((
  ref,
) {
  return BookingRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class BookingRemoteDatasource implements IBookingRemoteDataSource {
  final ApiClient _apiClient;

  BookingRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<BookingApiModel> createBooking(BookingApiModel booking) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createBooking(),
        data: booking.toJson(),
      );

      if (response.data["success"] == true) {
        final data = response.data["data"] as Map<String, dynamic>;
        return BookingApiModel.fromJson(data);
      }

      throw Exception(response.data["message"] ?? 'Failed to create booking');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data["message"] ?? 'Network error: ${e.message}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  @override
  Future<List<BookingApiModel>> getMyBookings() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myBookings);

      if (response.data["success"] == true) {
        final data = response.data["data"] as List;
        return data
            .map(
              (json) => BookingApiModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data["message"] ?? 'Network error: ${e.message}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  @override
  Future<BookingApiModel> getBookingById(String bookingId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.bookingById(bookingId),
      );

      if (response.data["success"] == true) {
        final data = response.data["data"] as Map<String, dynamic>;
        return BookingApiModel.fromJson(data);
      }

      throw Exception(response.data["message"] ?? 'Booking not found');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data["message"] ?? 'Network error: ${e.message}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching booking: $e');
    }
  }

  @override
  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.updateBooking(bookingId),
        data: {'status': 'cancelled', 'cancellationReason': reason},
      );

      return response.data["success"] == true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data["message"] ?? 'Network error: ${e.message}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }

  @override
  Future<BookingApiModel> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.updateBooking(bookingId),
        data: {'paymentStatus': paymentStatus},
      );

      if (response.data["success"] == true) {
        final data = response.data["data"] as Map<String, dynamic>;
        return BookingApiModel.fromJson(data);
      }

      throw Exception(
        response.data["message"] ?? 'Failed to update payment status',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data["message"] ?? 'Network error: ${e.message}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating payment status: $e');
    }
  }

  @override
  Future<BookingApiModel> updatePaymentMethod(
    String bookingId,
    String paymentMethod,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.updateBooking(bookingId),
        data: {'paymentMethod': paymentMethod},
      );

      if (response.data["success"] == true) {
        final data = response.data["data"] as Map<String, dynamic>;
        return BookingApiModel.fromJson(data);
      }

      throw Exception(
        response.data["message"] ?? 'Failed to update payment method',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data["message"] ?? 'Network error: ${e.message}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating payment method: $e');
    }
  }

  @override
  Future<BookingApiModel> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.updateBooking(bookingId),
        data: {'status': status},
      );

      if (response.data["success"] == true) {
        final data = response.data["data"] as Map<String, dynamic>;
        return BookingApiModel.fromJson(data);
      }

      throw Exception(
        response.data["message"] ?? 'Failed to update booking status',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data["message"] ?? 'Network error: ${e.message}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating booking status: $e');
    }
  }

  @override
  Future<bool> deleteBooking(String bookingId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.deleteBooking(bookingId),
      );

      return response.data["success"] == true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data["message"] ?? 'Network error: ${e.message}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting booking: $e');
    }
  }
}
