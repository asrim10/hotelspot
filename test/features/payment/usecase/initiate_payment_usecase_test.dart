import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelspot/features/payment/domain/usecases/initiate_paayment_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/payment/domain/entities/payment_entity.dart';
import 'package:hotelspot/features/payment/domain/repositories/payment_repository.dart';

// Mock
class MockPaymentRepository extends Mock implements IPaymentRepository {}

void main() {
  late InitiatePaymentUsecase initiatePaymentUsecase;
  late MockPaymentRepository mockPaymentRepository;
  late InitiatePaymentParams tParams;
  late PaymentEntity tPaymentEntity;

  setUp(() {
    mockPaymentRepository = MockPaymentRepository();
    initiatePaymentUsecase = InitiatePaymentUsecase(
      paymentRepository: mockPaymentRepository,
    );
    tParams = const InitiatePaymentParams(
      bookingId: 'booking-001',
      totalPrice: 499.99,
      fullName: 'John Doe',
      email: 'johndoe@email.com',
    );
    tPaymentEntity = const PaymentEntity(
      bookingId: 'booking-001',
      totalPrice: 499.99,
      fullName: 'John Doe',
      email: 'johndoe@email.com',
      pidx: 'pidx-abc123',
      paymentUrl: 'https://khalti.com/pay/abc123',
      paymentStatus: 'pending',
    );
  });

  group('InitiatePaymentUsecase', () {
    // Returns PaymentEntity on success
    test(
      'should return PaymentEntity when payment is initiated successfully',
      () async {
        when(
          () => mockPaymentRepository.initiateKhaltiPayment(
            bookingId: any(named: 'bookingId'),
            totalPrice: any(named: 'totalPrice'),
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async => Right(tPaymentEntity));

        final result = await initiatePaymentUsecase(tParams);

        expect(result, Right<Failure, PaymentEntity>(tPaymentEntity));
        verify(
          () => mockPaymentRepository.initiateKhaltiPayment(
            bookingId: 'booking-001',
            totalPrice: 499.99,
            fullName: 'John Doe',
            email: 'johndoe@email.com',
          ),
        ).called(1);
        verifyNoMoreInteractions(mockPaymentRepository);
      },
    );

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Payment initiation failed');
      when(
        () => mockPaymentRepository.initiateKhaltiPayment(
          bookingId: any(named: 'bookingId'),
          totalPrice: any(named: 'totalPrice'),
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await initiatePaymentUsecase(tParams);

      expect(result, const Left<Failure, PaymentEntity>(tFailure));
      verify(
        () => mockPaymentRepository.initiateKhaltiPayment(
          bookingId: 'booking-001',
          totalPrice: 499.99,
          fullName: 'John Doe',
          email: 'johndoe@email.com',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockPaymentRepository);
    });

    // Passes correct params to repository
    test('should call repository with correct params', () async {
      when(
        () => mockPaymentRepository.initiateKhaltiPayment(
          bookingId: any(named: 'bookingId'),
          totalPrice: any(named: 'totalPrice'),
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => Right(tPaymentEntity));

      await initiatePaymentUsecase(tParams);

      verify(
        () => mockPaymentRepository.initiateKhaltiPayment(
          bookingId: 'booking-001',
          totalPrice: 499.99,
          fullName: 'John Doe',
          email: 'johndoe@email.com',
        ),
      ).called(1);
    });
  });
}
