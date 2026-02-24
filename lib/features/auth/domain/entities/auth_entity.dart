import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String username;
  final String? password;
  final String? confirmPassword;
  final String? imageUrl;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.confirmPassword,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    password,
    username,
    confirmPassword,
    imageUrl,
  ];
}
