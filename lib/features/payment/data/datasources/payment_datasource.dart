abstract class IPaymentRemoteDatasource {
  Future<Map<String, dynamic>> initiateKhaltiPayment({
    required String bookingId,
    required double totalPrice,
    required String fullName,
    required String email,
  });

  Future<Map<String, dynamic>> verifyKhaltiPayment(String pidx);
}
