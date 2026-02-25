import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/payment/domain/usecases/initiate_paayment_usecase.dart';
import 'package:hotelspot/features/payment/domain/usecases/verify_payment_usecase.dart';
import 'package:hotelspot/features/payment/presentation/state/payment_state.dart';

final paymentViewmodelProvider =
    NotifierProvider<PaymentViewmodel, PaymentState>(PaymentViewmodel.new);

class PaymentViewmodel extends Notifier<PaymentState> {
  late final InitiatePaymentUsecase _initiatePaymentUsecase;
  late final VerifyPaymentUsecase _verifyPaymentUsecase;

  @override
  PaymentState build() {
    _initiatePaymentUsecase = ref.read(initiatePaymentUsecaseProvider);
    _verifyPaymentUsecase = ref.read(verifyPaymentUsecaseProvider);
    return const PaymentState();
  }

  // Initiate Khalti payment
  Future<void> initiatePayment({
    required String bookingId,
    required double totalPrice,
    required String fullName,
    required String email,
  }) async {
    state = state.copyWith(status: PaymentStatus.loading);

    final result = await _initiatePaymentUsecase(
      InitiatePaymentParams(
        bookingId: bookingId,
        totalPrice: totalPrice,
        fullName: fullName,
        email: email,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PaymentStatus.error,
        errorMessage: failure.message,
      ),
      (payment) => state = state.copyWith(
        status: PaymentStatus.initiated,
        payment: payment,
        paymentUrl: payment.paymentUrl, // ← open this in WebView
        pidx: payment.pidx, // ← save for verify
      ),
    );
  }

  // Verify Khalti payment
  Future<void> verifyPayment(String pidx) async {
    state = state.copyWith(status: PaymentStatus.loading);

    final result = await _verifyPaymentUsecase(VerifyPaymentParams(pidx: pidx));

    result.fold(
      (failure) => state = state.copyWith(
        status: PaymentStatus.error,
        errorMessage: failure.message,
      ),
      (payment) => state = state.copyWith(
        status: PaymentStatus.verified,
        payment: payment,
      ),
    );
  }

  // Reset state
  void reset() {
    state = const PaymentState();
  }
}
