import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String username;
  final String? password;
  final String? confirmPassword;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    password,
    username,
    confirmPassword,
  ];
}
