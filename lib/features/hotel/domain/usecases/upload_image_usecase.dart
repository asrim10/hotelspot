import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/hotel/data/repositories/hotel_repository.dart';
import 'package:hotelspot/features/hotel/domain/repositories/hotel_repository.dart';

final uploadImageProvider = Provider<UploadImageUsecase>((ref) {
  final hotelRepository = ref.watch(hotelRepositoryProvider);
  return UploadImageUsecase(hotelRepository: hotelRepository);
});

class UploadImageParams extends Equatable {
  final File image;

  const UploadImageParams({required this.image});

  @override
  List<Object?> get props => [image];
}

class UploadImageUsecase
    implements UsecaseWithParams<String, UploadImageParams> {
  final IHotelRepository _hotelRepository;

  UploadImageUsecase({required IHotelRepository hotelRepository})
    : _hotelRepository = hotelRepository;

  @override
  Future<Either<Failure, String>> call(UploadImageParams params) async {
    return await _hotelRepository.uploadImage(params.image);
  }
}
