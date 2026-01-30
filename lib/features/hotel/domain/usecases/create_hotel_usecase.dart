import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';
import 'package:hotelspot/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:hotelspot/features/hotel/data/repositories/hotel_repository.dart';

class CreateHotelParams extends Equatable {
  final String hotelName;
  final String city;
  final String address;
  final double price;
  final String country;
  final int availableRooms;
  final double rating;
  final String? description;
  final String? imageUrl;

  const CreateHotelParams({
    required this.hotelName,
    required this.city,
    required this.price,
    required this.country,
    required this.address,
    required this.availableRooms,
    required this.rating,
    this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    hotelName,
    city,
    price,
    country,
    availableRooms,
    rating,
    address,
    description,
    imageUrl,
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
      hotelName: params.hotelName,
      address: params.address,
      city: params.city,
      country: params.country,
      price: params.price,
      availableRooms: params.availableRooms,
      rating: params.rating,
      description: params.description,
      imageUrl: params.imageUrl,
    );

    return _hotelRepository.createHotel(entity);
  }
}
