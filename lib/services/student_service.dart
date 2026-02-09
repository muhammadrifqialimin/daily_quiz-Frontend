import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class StudentService {
  Future<Map<String, dynamic>> login(String name, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        body: jsonEncode({'name': name, 'password': password}),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login Gagal: Nama atau Password salah');
      }
    } catch (e) {
      throw Exception('Error Login: $e');
    }
  }
}
