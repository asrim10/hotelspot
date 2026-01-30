import 'package:equatable/equatable.dart';
import 'package:hotelspot/features/hotel/domain/entities/hotel_entity.dart';

enum HotelStatus { initial, loading, loaded, error, created, updated, deleted }

class HotelState extends Equatable {
  final HotelStatus status;
  final String? errorMessage;
  final HotelEntity? selectedHotel;
  final List<HotelEntity> hotels;
  //store image name temp
  final String? uploadImageName;

  const HotelState({
    this.status = HotelStatus.initial,
    this.errorMessage,
    this.selectedHotel,
    this.hotels = const [],
    this.uploadImageName,
  });

  HotelState copyWith({
    HotelStatus? status,
    String? errorMessage,
    HotelEntity? selectedHotel,
    List<HotelEntity>? hotels,
    String? uploadImageName,
  }) {
    return HotelState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedHotel: selectedHotel ?? this.selectedHotel,
      hotels: hotels ?? this.hotels,
      uploadImageName: uploadImageName ?? this.uploadImageName,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    selectedHotel,
    hotels,
    uploadImageName,
  ];
}
