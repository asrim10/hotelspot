import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? batchId;
  final String username;
  final String? password;
  final String? profilePicture;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.batchId,
    required this.username,
    this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    password,
    username,
    profilePicture,
  ];
}
