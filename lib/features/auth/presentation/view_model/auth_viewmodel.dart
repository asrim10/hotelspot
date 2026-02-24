import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:hotelspot/features/auth/domain/usecases/login_usecase.dart';
import 'package:hotelspot/features/auth/domain/usecases/register_usecase.dart';
import 'package:hotelspot/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:hotelspot/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetProfileUsecase _getProfileUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getProfileUsecase = ref.read(getProfileUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    String? phoneNumber,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(seconds: 2));

    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
    );
    final result = await _registerUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (isRegistered) => state = state.copyWith(
        status: isRegistered ? AuthStatus.registered : AuthStatus.error,
        errorMessage: isRegistered ? null : 'Registration failed',
      ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(seconds: 2));

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
    );
  }

  Future<void> getProfile() async {
    state = state.copyWith(status: AuthStatus.profileLoading);

    final result = await _getProfileUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.profileLoaded,
        authEntity: authEntity,
      ),
    );
  }

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? phoneNumber,
    File? image,
  }) async {
    state = state.copyWith(status: AuthStatus.profileUpdating);

    final result = await _updateProfileUsecase(
      UpdateProfileParams(
        fullName: fullName,
        username: username,
        phoneNumber: phoneNumber,
        image: image,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.profileUpdated,
        authEntity: authEntity,
        imageVersion: state.imageVersion + 1,
      ),
    );
  }
}
