import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/error/failures.dart';
import 'package:hotelspot/core/usecases/app_usecase.dart';
import 'package:hotelspot/features/auth/data/repositories/auth_repository.dart';
import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';
import 'package:hotelspot/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileParams extends Equatable {
  final String? fullName;
  final String? username;
  final String? phoneNumber;
  final File? image;

  const UpdateProfileParams({
    this.fullName,
    this.username,
    this.phoneNumber,
    this.image,
  });

  @override
  List<Object?> get props => [fullName, username, phoneNumber, image];
}

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  return UpdateProfileUsecase(authRepository: ref.read(authRepositoryProvider));
});

class UpdateProfileUsecase
    implements UsecaseWithParams<AuthEntity, UpdateProfileParams> {
  final IAuthRepository _authRepository;

  UpdateProfileUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateProfileParams params) {
    return _authRepository.updateProfile(
      fullName: params.fullName,
      username: params.username,
      phoneNumber: params.phoneNumber,
      image: params.image,
    );
  }
}
