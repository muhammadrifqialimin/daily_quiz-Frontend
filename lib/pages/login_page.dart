import 'package:flutter/material.dart';
import '../services/student_service.dart';
import 'quiz_page.dart';
import 'result_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Panggil Service yang baru dibuat tadi
  final StudentService _studentService = StudentService();

  bool _isLoading = false;
  String _errorMessage = '';

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final result = await _studentService.login(
        _nameController.text,
        _passwordController.text,
      );

      // PERUBAHAN DI SINI:
      // Struktur data sekarang: result['data']['student'] dan result['data']['has_completed']
      final dataResponse = result['data'];
      final student = dataResponse['student'];
      final bool hasCompleted = dataResponse['has_completed'];

      if (mounted) {
        if (hasCompleted) {
          // SKENARIO A: SUDAH MENGERJAKAN -> KE HALAMAN NILAI
          final resultData = dataResponse['result'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                studentName: student['name'],
                score: resultData['score'],
                correct: resultData['total_correct'],
                total: resultData['total_questions'],
              ),
            ),
          );
        } else {
          // SKENARIO B: BELUM MENGERJAKAN -> KE HALAMAN KUIS
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPage(
                studentId: student['id'],
                studentName: student['name'],
                category: student['category'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Card(
          elevation: 5,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Login Siswa",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Nama",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("MASUK"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
