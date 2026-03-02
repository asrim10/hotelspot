import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/usecases/create_review_usecase.dart';

// Mock
class MockReviewRepository extends Mock implements IReviewRepository {}

class FakeReviewEntity extends Fake implements ReviewEntity {}

void main() {
  late CreateReviewUsecase createReviewUsecase;
  late MockReviewRepository mockReviewRepository;
  late CreateReviewParams tParams;

  setUpAll(() {
    registerFallbackValue(FakeReviewEntity());
  });

  setUp(() {
    mockReviewRepository = MockReviewRepository();
    createReviewUsecase = CreateReviewUsecase(
      reviewRepository: mockReviewRepository,
    );
    tParams = const CreateReviewParams(
      hotelId: 'hotel-123',
      rating: 4.5,
      comment: 'Great hotel!',
    );
  });

  group('CreateReviewUsecase', () {
    // Returns true on successful review creation
    test('should return true when review is created successfully', () async {
      when(
        () => mockReviewRepository.createReview(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await createReviewUsecase(tParams);

      expect(result, const Right<Failure, bool>(true));
      verify(() => mockReviewRepository.createReview(any())).called(1);
      verifyNoMoreInteractions(mockReviewRepository);
    });

    // Returns failure on api error
    test('should return ApiFailure when repository fails', () async {
      const tFailure = ApiFailure(message: 'Failed to create review');
      when(
        () => mockReviewRepository.createReview(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      final result = await createReviewUsecase(tParams);

      expect(result, const Left<Failure, bool>(tFailure));
      verify(() => mockReviewRepository.createReview(any())).called(1);
      verifyNoMoreInteractions(mockReviewRepository);
    });

    // Passes correct ReviewEntity built from params to repository
    test(
      'should call repository with correct ReviewEntity from params',
      () async {
        when(
          () => mockReviewRepository.createReview(any()),
        ).thenAnswer((_) async => const Right(true));

        await createReviewUsecase(tParams);

        final captured = verify(
          () => mockReviewRepository.createReview(captureAny()),
        ).captured;

        final capturedEntity = captured.first as ReviewEntity;
        expect(capturedEntity.hotelId, equals('hotel-123'));
        expect(capturedEntity.rating, equals(4.5));
        expect(capturedEntity.comment, equals('Great hotel!'));
      },
    );

    // ReviewEntity is built with empty userId and fullName
    test('should build ReviewEntity with empty userId and fullName', () async {
      when(
        () => mockReviewRepository.createReview(any()),
      ).thenAnswer((_) async => const Right(true));

      await createReviewUsecase(tParams);

      final captured = verify(
        () => mockReviewRepository.createReview(captureAny()),
      ).captured;

      final capturedEntity = captured.first as ReviewEntity;
      expect(capturedEntity.userId, isEmpty);
      expect(capturedEntity.fullName, isEmpty);
      expect(capturedEntity.email, isEmpty);
    });
  });
}
