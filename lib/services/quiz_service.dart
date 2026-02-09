import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/quiz_model.dart';

class QuizService {
  Future<List<Quiz>> getQuizzes(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quizzes?category=$category'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];
        return data.map((e) => Quiz.fromJson(e)).toList();
      } else {
        throw Exception('Gagal ambil data');
      }
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }
}
