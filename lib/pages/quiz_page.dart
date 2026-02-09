import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import '../services/result_service.dart';
import 'login_page.dart';

class QuizPage extends StatefulWidget {
  final int studentId;
  final String studentName;
  final String category;

  const QuizPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.category,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Panggil service yang dibutuhkan
  final QuizService _quizService = QuizService();
  final ResultService _resultService = ResultService();

  late Future<List<Quiz>> _quizList;
  int _currentIndex = 0;
  final Map<int, String> _selectedAnswers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quizList = _quizService.getQuizzes(widget.category);
  }

  void _submitAnswers() async {
    setState(() => _isSubmitting = true);
    try {
      final result = await _resultService.submitQuiz(
        widget.studentId,
        widget.category,
        _selectedAnswers,
      );

      if (mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hasil Kuis 🎉", textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Hebat ${widget.studentName}!"),
                Text(
                  "${result['score']}",
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text("Benar ${result['correct']} dari ${result['total']} soal"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ),
                child: const Text("Keluar"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kuis ${widget.category}"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FutureBuilder<List<Quiz>>(
            future: _quizList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const CircularProgressIndicator();
              if (snapshot.hasError) return Text("Error: ${snapshot.error}");
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Text("Tidak ada soal.");

              final quizzes = snapshot.data!;
              final currentQuiz = quizzes[_currentIndex];
              final bool hasAnswered = _selectedAnswers.containsKey(
                currentQuiz.id,
              );
              final bool isLastQuestion = _currentIndex == quizzes.length - 1;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Soal ${_currentIndex + 1} / ${quizzes.length}"),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentQuiz.question,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 30),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 4,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              children: currentQuiz.options.entries.map((
                                entry,
                              ) {
                                final isSelected =
                                    _selectedAnswers[currentQuiz.id] ==
                                    entry.key;
                                return InkWell(
                                  onTap: () => setState(
                                    () => _selectedAnswers[currentQuiz.id] =
                                        entry.key,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue.shade100
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      "${entry.key.toUpperCase()}. ${entry.value}",
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: hasAnswered
                          ? () {
                              if (_currentIndex < quizzes.length - 1) {
                                setState(() => _currentIndex++);
                              } else {
                                _submitAnswers();
                              }
                            }
                          : null,
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isLastQuestion
                                  ? "SELESAI & LIHAT NILAI"
                                  : "LANJUT",
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
