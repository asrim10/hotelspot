import 'package:equatable/equatable.dart';
import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  registered,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: authEntity ?? this.authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, authEntity, errorMessage];
}
