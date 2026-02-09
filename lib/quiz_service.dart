import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quiz_model.dart';

class QuizService {
  final String baseUrl = 'http://127.0.0.1:8000/api/v1/quizzes';

  Future<List<Quiz>> getQuizzes() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];

        return data.map((e) => Quiz.fromJson(e)).toList();
      } else {
        throw Exception('gagal ambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Koneksi Error: $e');
    }
  }
}
