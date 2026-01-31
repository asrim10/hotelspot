import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/hotel/domain/usecases/create_hotel_usecase.dart';
import 'package:hotelspot/features/hotel/domain/usecases/get_all_hotel_usecase.dart';
import 'package:hotelspot/features/hotel/domain/usecases/upload_image_usecase.dart';
import 'package:hotelspot/features/hotel/presentation/state/hotel_state.dart';

final hotelViewmodelProvider = NotifierProvider<HotelViewmodel, HotelState>(
  HotelViewmodel.new,
);

class HotelViewmodel extends Notifier<HotelState> {
  late final CreateHotelUsecase _createhotelUsecase;
  late final UploadImageUsecase _uploadImageUsecase;
  late final GetAllHotelsUsecase _getAllHotelsUsecase;

  @override
  HotelState build() {
    _createhotelUsecase = ref.read(createHotelUsecaseProvider);
    _uploadImageUsecase = ref.read(uploadImageProvider);
    _getAllHotelsUsecase = ref.read(getAllHotelsUsecaseProvider);
    return const HotelState();
  }

  Future<void> createHotel({
    required String hotelName,
    required String address,
    required String country,
    required String city,
    required int availableRooms,
    required double price,
    required double rating,
    String? description,
    String? imageUrl,
  }) async {
    state = state.copyWith(status: HotelStatus.loading);

    final result = await _createhotelUsecase(
      CreateHotelParams(
        hotelName: hotelName,
        city: city,
        address: address,
        country: country,
        availableRooms: availableRooms,
        price: price,
        rating: rating,
        description: description,
        imageUrl: imageUrl,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: HotelStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(status: HotelStatus.created),
    );
  }

  // Get all hotels
  Future<void> getAllHotels() async {
    state = state.copyWith(status: HotelStatus.loading);

    final result = await _getAllHotelsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: HotelStatus.error,
        errorMessage: failure.message,
      ),
      (hotels) =>
          state = state.copyWith(status: HotelStatus.loaded, hotels: hotels),
    );
  }

  // Upload image
  Future<void> uploadImage(File image) async {
    state = state.copyWith(status: HotelStatus.loading);
    final result = await _uploadImageUsecase(UploadImageParams(image: image));
    result.fold(
      (failure) {
        state = state.copyWith(
          status: HotelStatus.error,
          errorMessage: failure.message,
        );
      },
      (imageName) {
        state = state.copyWith(
          status: HotelStatus.loaded,
          uploadImageName: imageName,
        );
      },
    );
  }
}
