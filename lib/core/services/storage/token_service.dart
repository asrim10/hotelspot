import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

//provider
final tokenServiceProvider = Provider<TokenService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TokenService(prefs: prefs);
});

class TokenService {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';

  TokenService({required SharedPreferences prefs}) : _prefs = prefs;

  //save token: secure storage
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  //get token

  //remove token
}
