import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/reviews/domain/usecases/create_review_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/delete_review_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/ger_review_by_id_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/get_my_reviews_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/get_reviews_by_hotel_id_usecase.dart';
import 'package:hotelspot/features/reviews/domain/usecases/update_review_usecase.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';

final reviewViewmodelProvider = NotifierProvider<ReviewViewmodel, ReviewState>(
  ReviewViewmodel.new,
);

class ReviewViewmodel extends Notifier<ReviewState> {
  late final GetReviewsByHotelIdUsecase _getReviewsByHotelIdUsecase;
  late final GetMyReviewsUsecase _getMyReviewsUsecase;
  late final GetReviewByIdUsecase _getReviewByIdUsecase;
  late final CreateReviewUsecase _createReviewUsecase;
  late final UpdateReviewUsecase _updateReviewUsecase;
  late final DeleteReviewUsecase _deleteReviewUsecase;

  @override
  ReviewState build() {
    _getReviewsByHotelIdUsecase = ref.read(getReviewsByHotelIdUsecaseProvider);
    _getMyReviewsUsecase = ref.read(getMyReviewsUsecaseProvider);
    _getReviewByIdUsecase = ref.read(getReviewByIdUsecaseProvider);
    _createReviewUsecase = ref.read(createReviewUsecaseProvider);
    _updateReviewUsecase = ref.read(updateReviewUsecaseProvider);
    _deleteReviewUsecase = ref.read(deleteReviewUsecaseProvider);
    return const ReviewState();
  }

  Future<void> getReviewsByHotelId(String hotelId) async {
    state = state.copyWith(status: ReviewStatus.loading);

    final result = await _getReviewsByHotelIdUsecase(
      GetReviewsByHotelIdParams(hotelId: hotelId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (reviews) =>
          state = state.copyWith(status: ReviewStatus.loaded, reviews: reviews),
    );
  }

  Future<void> getMyReviews() async {
    state = state.copyWith(status: ReviewStatus.loading);

    final result = await _getMyReviewsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (myReviews) => state = state.copyWith(
        status: ReviewStatus.loaded,
        myReviews: myReviews,
      ),
    );
  }

  Future<void> getReviewById(String reviewId) async {
    state = state.copyWith(status: ReviewStatus.loading);

    final result = await _getReviewByIdUsecase(
      GetReviewByIdParams(reviewId: reviewId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (review) => state = state.copyWith(
        status: ReviewStatus.loaded,
        selectedReview: review,
      ),
    );
  }

  Future<void> createReview({
    required String hotelId,
    required double rating,
    required String comment,
  }) async {
    state = state.copyWith(status: ReviewStatus.loading);

    final result = await _createReviewUsecase(
      CreateReviewParams(hotelId: hotelId, rating: rating, comment: comment),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: ReviewStatus.created);
        getReviewsByHotelId(hotelId);
      },
    );
  }

  // Update review
  Future<void> updateReview({
    required String reviewId,
    required String userId,
    required String hotelId,
    required String fullName,
    required String email,
    required double rating,
    required String comment,
  }) async {
    state = state.copyWith(status: ReviewStatus.loading);

    final result = await _updateReviewUsecase(
      UpdateReviewParams(
        reviewId: reviewId,
        userId: userId,
        hotelId: hotelId,
        fullName: fullName,
        email: email,
        rating: rating,
        comment: comment,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: ReviewStatus.updated);
        getReviewsByHotelId(hotelId);
      },
    );
  }

  Future<void> deleteReview({
    required String reviewId,
    required String hotelId,
  }) async {
    state = state.copyWith(status: ReviewStatus.loading);

    final result = await _deleteReviewUsecase(
      DeleteReviewParams(reviewId: reviewId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: ReviewStatus.deleted);
        getReviewsByHotelId(hotelId);
      },
    );
  }
}
