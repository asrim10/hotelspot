import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/reviews/data/repositories/review_repository.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/domain/repositories/review_repository.dart';

class GetReviewsByHotelIdParams extends Equatable {
  final String hotelId;
  const GetReviewsByHotelIdParams({required this.hotelId});

  @override
  List<Object?> get props => [hotelId];
}

final getReviewsByHotelIdUsecaseProvider = Provider<GetReviewsByHotelIdUsecase>(
  (ref) {
    return GetReviewsByHotelIdUsecase(
      reviewRepository: ref.read(reviewRepositoryProvider),
    );
  },
);

class GetReviewsByHotelIdUsecase
    implements
        UsecaseWithParams<List<ReviewEntity>, GetReviewsByHotelIdParams> {
  final IReviewRepository _reviewRepository;
  GetReviewsByHotelIdUsecase({required IReviewRepository reviewRepository})
    : _reviewRepository = reviewRepository;

  @override
  Future<Either<Failure, List<ReviewEntity>>> call(
    GetReviewsByHotelIdParams params,
  ) {
    return _reviewRepository.getReviewsByHotelId(params.hotelId);
  }
}
