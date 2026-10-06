import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _box = GetStorage();

  static const String tokenKey = 'auth_token';
  static const String candidateKey = 'candidate_data';

  static Future<void> saveToken(String token) async {
    await _box.write(tokenKey, token);
  }

  static String getToken() {
    return (_box.read(tokenKey) ?? '').toString();
  }

  static bool get isLoggedIn => getToken().isNotEmpty;

  static Future<void> saveCandidate(Map<String, dynamic> data) async {
    await _box.write(candidateKey, data);
  }

  static Map<String, dynamic>? getCandidate() {
    final data = _box.read(candidateKey);
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  static Future<void> clear() async {
    await _box.remove(tokenKey);
    await _box.remove(candidateKey);
  }
}