import 'package:hotelspot/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<bool> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthHiveModel> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getUserById(String authId);
}
