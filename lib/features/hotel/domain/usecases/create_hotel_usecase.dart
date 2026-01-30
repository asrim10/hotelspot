import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:hotelspot/features/hotel/data/repositories/hotel_repository.dart';

class CreateHotelParams extends Equatable {
  final String name;
  final String location;
  final double rating;
  final String? description;
  final File? image;
  final File? video;

  const CreateHotelParams({
    required this.name,
    required this.location,
    required this.rating,
    this.description,
    this.image,
    this.video,
  });

  @override
  List<Object?> get props => [
    name,
    location,
    rating,
    description,
    image,
    video,
  ];
}

final createHotelUsecaseProvider = Provider<CreateHotelUsecase>((ref) {
  final hotelRepository = ref.read(hotelRepositoryProvider);
  return CreateHotelUsecase(hotelRepository: hotelRepository);
});

class CreateHotelUsecase implements UsecaseWithParams<bool, CreateHotelParams> {
  final IHotelRepository _hotelRepository;
  CreateHotelUsecase({required IHotelRepository hotelRepository})
    : _hotelRepository = hotelRepository;

  @override
  Future<Either<Failure, bool>> call(CreateHotelParams params) {
    final entity = HotelEntity(
      hotelId: '',
      name: params.name,
      location: params.location,
      rating: params.rating,
      description: params.description,
      image: params.image,
      video: params.video,
    );
    return _hotelRepository.createHotel(entity);
  }
}
