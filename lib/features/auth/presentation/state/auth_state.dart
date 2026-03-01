import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  registered,
  profileLoading,
  profileLoaded,
  profileUpdating,
  profileUpdated,
  error,
}

class AuthState {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;
  final int imageVersion;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
    this.imageVersion = 0,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    String? errorMessage,
    int? imageVersion,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: authEntity ?? this.authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
      imageVersion: imageVersion ?? this.imageVersion,
    );
  }
}
