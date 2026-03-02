import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/payment/presentation/view_model/payment_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/payment/domain/entities/payment_entity.dart';
import 'package:hotelspot/features/payment/domain/usecases/initiate_paayment_usecase.dart';
import 'package:hotelspot/features/payment/domain/usecases/verify_payment_usecase.dart';
import 'package:hotelspot/features/payment/presentation/state/payment_state.dart';

// Mocks
class MockInitiatePaymentUsecase extends Mock
    implements InitiatePaymentUsecase {}

class MockVerifyPaymentUsecase extends Mock implements VerifyPaymentUsecase {}

// Fakes
class FakeInitiatePaymentParams extends Fake implements InitiatePaymentParams {}

class FakeVerifyPaymentParams extends Fake implements VerifyPaymentParams {}

void main() {
  late MockInitiatePaymentUsecase mockInitiatePaymentUsecase;
  late MockVerifyPaymentUsecase mockVerifyPaymentUsecase;
  late ProviderContainer container;
  late PaymentEntity tPaymentEntity;

  setUpAll(() {
    registerFallbackValue(FakeInitiatePaymentParams());
    registerFallbackValue(FakeVerifyPaymentParams());
  });

  setUp(() {
    mockInitiatePaymentUsecase = MockInitiatePaymentUsecase();
    mockVerifyPaymentUsecase = MockVerifyPaymentUsecase();

    tPaymentEntity = const PaymentEntity(
      bookingId: 'booking-001',
      totalPrice: 499.99,
      fullName: 'John Doe',
      email: 'johndoe@email.com',
      pidx: 'pidx-abc123',
      paymentUrl: 'https://khalti.com/pay/abc123',
      paymentStatus: 'pending',
    );

    container = ProviderContainer(
      overrides: [
        initiatePaymentUsecaseProvider.overrideWithValue(
          mockInitiatePaymentUsecase,
        ),
        verifyPaymentUsecaseProvider.overrideWithValue(
          mockVerifyPaymentUsecase,
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  PaymentViewmodel readViewModel() =>
      container.read(paymentViewmodelProvider.notifier);

  PaymentState readState() => container.read(paymentViewmodelProvider);

  group('PaymentViewmodel', () {
    group('initial state', () {
      test('should have correct initial state', () {
        expect(readState().status, equals(PaymentStatus.initial));
        expect(readState().payment, isNull);
        expect(readState().paymentUrl, isNull);
        expect(readState().pidx, isNull);
        expect(readState().errorMessage, isNull);
      });
    });

    group('initiatePayment', () {
      test('should emit loading then initiated status on success', () async {
        when(
          () => mockInitiatePaymentUsecase(any()),
        ).thenAnswer((_) async => Right(tPaymentEntity));

        await readViewModel().initiatePayment(
          bookingId: 'booking-001',
          totalPrice: 499.99,
          fullName: 'John Doe',
          email: 'johndoe@email.com',
        );

        expect(readState().status, equals(PaymentStatus.initiated));
        expect(readState().payment, equals(tPaymentEntity));
        expect(readState().paymentUrl, equals('https://khalti.com/pay/abc123'));
        expect(readState().pidx, equals('pidx-abc123'));
      });

      test('should emit error status when initiatePayment fails', () async {
        const tFailure = ApiFailure(message: 'Payment initiation failed');
        when(
          () => mockInitiatePaymentUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().initiatePayment(
          bookingId: 'booking-001',
          totalPrice: 499.99,
          fullName: 'John Doe',
          email: 'johndoe@email.com',
        );

        expect(readState().status, equals(PaymentStatus.error));
        expect(readState().errorMessage, equals('Payment initiation failed'));
      });
    });

    group('verifyPayment', () {
      test('should emit loading then verified status on success', () async {
        final verifiedPayment = const PaymentEntity(
          bookingId: 'booking-001',
          totalPrice: 499.99,
          fullName: 'John Doe',
          email: 'johndoe@email.com',
          pidx: 'pidx-abc123',
          paymentStatus: 'paid',
          khaltiStatus: 'Completed',
        );
        when(
          () => mockVerifyPaymentUsecase(any()),
        ).thenAnswer((_) async => Right(verifiedPayment));

        await readViewModel().verifyPayment('pidx-abc123');

        expect(readState().status, equals(PaymentStatus.verified));
        expect(readState().payment, equals(verifiedPayment));
      });

      test('should emit error status when verifyPayment fails', () async {
        const tFailure = ApiFailure(message: 'Payment verification failed');
        when(
          () => mockVerifyPaymentUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        await readViewModel().verifyPayment('pidx-abc123');

        expect(readState().status, equals(PaymentStatus.error));
        expect(readState().errorMessage, equals('Payment verification failed'));
      });
    });

    group('reset', () {
      test('should reset state back to initial', () async {
        when(
          () => mockInitiatePaymentUsecase(any()),
        ).thenAnswer((_) async => Right(tPaymentEntity));
        await readViewModel().initiatePayment(
          bookingId: 'booking-001',
          totalPrice: 499.99,
          fullName: 'John Doe',
          email: 'johndoe@email.com',
        );

        readViewModel().reset();

        expect(readState().status, equals(PaymentStatus.initial));
        expect(readState().payment, isNull);
        expect(readState().paymentUrl, isNull);
        expect(readState().pidx, isNull);
        expect(readState().errorMessage, isNull);
      });
    });
  });
}
