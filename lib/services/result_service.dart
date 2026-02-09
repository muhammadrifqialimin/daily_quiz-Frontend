import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class ResultService {
  Future<Map<String, dynamic>> submitQuiz(
    int studentId,
    String category,
    Map<int, String> answers,
  ) async {
    try {
      // 🛠️ PERBAIKAN UTAMA DI SINI 🛠️
      // Kita konversi Key (ID Soal) dari int ke String.
      // Dari {1: "a"} menjadi {"1": "a"} supaya JSON mau terima.
      final answersConverted = answers.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/submit-quiz'),
        body: jsonEncode({
          'student_id': studentId,
          'category': category,
          'answers': answersConverted, // <--- Kirim yang sudah dikonversi
        }),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal Submit: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
