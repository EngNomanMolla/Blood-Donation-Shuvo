import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider authProvider;

  AuthRepository(this.authProvider);

  Future<http.Response> sendCode(String phone) async {
    return await authProvider.sendCode(phone);
  }

  Future<http.Response> verifyCode(String phone, String code, {String? fcmToken}) async {
    return await authProvider.verifyCode(phone, code, fcmToken: fcmToken);
  }
}
