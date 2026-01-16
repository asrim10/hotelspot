import 'package:hotelspot/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String username;
  final String? password;
  final String? confirmPassword;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.confirmPassword,
  });

  // to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      "email": email,
      "username": username,
      "password": password,
      "confirmPassword": confirmPassword,
    };
  }

  //from Json
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json["_id"] as String,
      fullName: json['fullName'] as String,
      email: json["email"] as String,
      username: json["username"] as String,
    );
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      username: username,
    );
  }

  //from Entity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
