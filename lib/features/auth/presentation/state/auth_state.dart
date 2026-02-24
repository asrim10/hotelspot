import 'package:equatable/equatable.dart';
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

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;
  final int imageVersion; // incremented on every successful profile update

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

  @override
  List<Object?> get props => [status, authEntity, errorMessage, imageVersion];
}
