import 'package:equatable/equatable.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';

enum ReviewStatus { initial, loading, loaded, error, created, updated, deleted }

class ReviewState extends Equatable {
  final ReviewStatus status;
  final String? errorMessage;
  final ReviewEntity? selectedReview;
  final List<ReviewEntity> reviews;
  final List<ReviewEntity> myReviews;

  const ReviewState({
    this.status = ReviewStatus.initial,
    this.errorMessage,
    this.selectedReview,
    this.reviews = const [],
    this.myReviews = const [],
  });

  ReviewState copyWith({
    ReviewStatus? status,
    String? errorMessage,
    ReviewEntity? selectedReview,
    List<ReviewEntity>? reviews,
    List<ReviewEntity>? myReviews,
  }) {
    return ReviewState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedReview: selectedReview ?? this.selectedReview,
      reviews: reviews ?? this.reviews,
      myReviews: myReviews ?? this.myReviews,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    selectedReview,
    reviews,
    myReviews,
  ];
}
