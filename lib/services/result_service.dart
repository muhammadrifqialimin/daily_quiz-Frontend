import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class ResultService {
  Future<Map<String, dynamic>> submitQuiz(
    int studentId,
    String category,
    Map<int, String> answers,
  ) async {
    Map<String, String> formattedAnswers = answers.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    final url = Uri.parse('${ApiConfig.baseUrl}/submit-quiz');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'student_id': studentId,
          'category': category,
          'answers': formattedAnswers,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'score': data['score'],
          'correct': data['correct'],
          'total': data['total'],
        };
      } else {
        throw Exception(data['message'] ?? 'Gagal mengirim jawaban');
      }
    } catch (e) {
      throw Exception('Error connection: $e');
    }
  }
}
