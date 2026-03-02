import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/payment/domain/entities/payment_entity.dart';
import 'package:hotelspot/features/payment/domain/repositories/payment_repository.dart';
import 'package:hotelspot/features/payment/domain/usecases/verify_payment_usecase.dart';

// Mock
class MockPaymentRepository extends Mock implements IPaymentRepository {}

void main() {
  late VerifyPaymentUsecase verifyPaymentUsecase;
  late MockPaymentRepository mockPaymentRepository;
  late VerifyPaymentParams tParams;
  late PaymentEntity tPaymentEntity;

  setUp(() {
    mockPaymentRepository = MockPaymentRepository();
    verifyPaymentUsecase = VerifyPaymentUsecase(
      paymentRepository: mockPaymentRepository,
    );
    tParams = const VerifyPaymentParams(pidx: 'pidx-abc123');
    tPaymentEntity = const PaymentEntity(
      bookingId: 'booking-001',
      totalPrice: 499.99,
      fullName: 'John Doe',
      email: 'johndoe@email.com',
      pidx: 'pidx-abc123',
      paymentStatus: 'paid',
      khaltiStatus: 'Completed',
    );
  });

  group('VerifyPaymentUsecase', () {
    // Returns PaymentEntity on successful verification
    test(
      'should return PaymentEntity when payment is verified successfully',
      () async {
        when(
          () => mockPaymentRepository.verifyKhaltiPayment(any()),
        ).thenAnswer((_) async => Right(tPaymentEntity));

        final result = await verifyPaymentUsecase(tParams);

        expect(result, Right<Failure, PaymentEntity>(tPaymentEntity));
        verify(
          () => mockPaymentRepository.verifyKhaltiPayment('pidx-abc123'),
        ).called(1);
        verifyNoMoreInteractions(mockPaymentRepository);
      },
    );

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Payment verification failed');
      when(
        () => mockPaymentRepository.verifyKhaltiPayment(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await verifyPaymentUsecase(tParams);

      expect(result, const Left<Failure, PaymentEntity>(tFailure));
      verify(
        () => mockPaymentRepository.verifyKhaltiPayment('pidx-abc123'),
      ).called(1);
      verifyNoMoreInteractions(mockPaymentRepository);
    });

    // Passes correct pidx to repository
    test('should call repository with correct pidx from params', () async {
      when(
        () => mockPaymentRepository.verifyKhaltiPayment(any()),
      ).thenAnswer((_) async => Right(tPaymentEntity));

      await verifyPaymentUsecase(tParams);

      final captured = verify(
        () => mockPaymentRepository.verifyKhaltiPayment(captureAny()),
      ).captured;

      expect(captured.first, equals('pidx-abc123'));
    });
  });
}
