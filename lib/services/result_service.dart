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
      final answersConverted = answers.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/submit-quiz'),
        body: jsonEncode({
          'student_id': studentId,
          'category': category,
          'answers': answersConverted,
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
