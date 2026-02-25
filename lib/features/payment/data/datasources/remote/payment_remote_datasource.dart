import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_client.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/core/services/storage/token_service.dart';
import 'package:hotelspot/features/payment/data/datasources/payment_datasource.dart';

final paymentRemoteDatasourceProvider = Provider<IPaymentRemoteDatasource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  return PaymentRemoteDatasource(
    apiClient: apiClient,
    tokenService: tokenService,
  );
});

class PaymentRemoteDatasource implements IPaymentRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  PaymentRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<Map<String, dynamic>> initiateKhaltiPayment({
    required String bookingId,
    required double totalPrice,
    required String fullName,
    required String email,
  }) async {
    try {
      final token = _tokenService.getToken();

      final data = {
        'bookingId': bookingId,
        'totalPrice': totalPrice,
        'fullName': fullName,
        'email': email,
      };

      // ✅ debug logs
      print('=== PAYMENT REQUEST ===');
      print(
        'URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.initiateKhaltiPayment}',
      );
      print('Data: $data');
      print('Token: $token');
      print('======================');

      final response = await _apiClient.post(
        ApiEndpoints.initiateKhaltiPayment,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Khalti initiate response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error initiating Khalti payment: $e');
      if (e is DioException) {
        print('❌ Error response: ${e.response?.data}');
        print('❌ Status code: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyKhaltiPayment(String pidx) async {
    try {
      final token = _tokenService.getToken();

      print('=== VERIFY REQUEST ===');
      print('URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.verifyKhaltiPayment}');
      print('pidx: $pidx');
      print('Token: $token');
      print('=====================');

      final response = await _apiClient.post(
        ApiEndpoints.verifyKhaltiPayment,
        data: {'pidx': pidx},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Khalti verify response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error verifying Khalti payment: $e');
      if (e is DioException) {
        print('❌ Error response: ${e.response?.data}');
        print('❌ Status code: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }
}
