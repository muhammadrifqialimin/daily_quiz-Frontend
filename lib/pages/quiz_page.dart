import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import '../services/result_service.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final int studentId;
  final String studentName;
  final String category;
  final String
  endTime; // Menerima Waktu Selesai (Format: "2026-02-10 10:30:00")

  const QuizPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.category,
    required this.endTime,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Services
  final QuizService _quizService = QuizService();
  final ResultService _resultService = ResultService();

  // State Variables
  late Future<List<Quiz>> _quizList;
  int _currentIndex = 0;
  final Map<int, String> _selectedAnswers = {};
  bool _isSubmitting = false;

  // Timer Variables
  Timer? _timer;
  String _timeLeftString = "Memuat waktu...";
  late DateTime _endDateTime;

  @override
  void initState() {
    super.initState();
    _quizList = _quizService.getQuizzes(widget.category);

    // 1. Parsing Waktu Selesai
    try {
      _endDateTime = DateTime.parse(widget.endTime);
      // 2. Mulai Timer
      _startTimer();
    } catch (e) {
      debugPrint("Error parsing date: $e");
      _timeLeftString = "Error Waktu";
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Matikan timer saat widget dihancurkan
    super.dispose();
  }

  // --- LOGIC TIMER ---
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = _endDateTime.difference(now);

      if (difference.isNegative) {
        // WAKTU HABIS -> Paksa Submit
        timer.cancel();
        _forceSubmit();
      } else {
        // Update UI
        if (mounted) {
          setState(() {
            _timeLeftString = _formatDuration(difference);
          });
        }
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // --- LOGIC SUBMIT ---
  void _forceSubmit() {
    if (_isSubmitting) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Waktu Habis! Jawaban otomatis dikirim."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
    _submitAnswers();
  }

  void _submitAnswers() async {
    _timer?.cancel(); // Stop timer agar tidak double submit
    setState(() => _isSubmitting = true);

    try {
      final result = await _resultService.submitQuiz(
        widget.studentId,
        widget.category,
        _selectedAnswers,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              studentId: widget.studentId,
              studentName: widget.studentName,
              score: result['score'],
              correct: result['correct'],
              total: result['total'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal mengirim jawaban: $e")));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hilangkan tombol Back default
        backgroundColor: Colors.blue.shade100,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kuis ${widget.category}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  "Jangan keluar aplikasi!",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    _timeLeftString,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FutureBuilder<List<Quiz>>(
            future: _quizList,
            builder: (context, snapshot) {
              // 1. Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // 2. Error
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              // 3. Kosong
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("Tidak ada soal untuk kategori ini."),
                );
              }

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
                    // Indikator Soal
                    Text(
                      "Soal ${_currentIndex + 1} dari ${quizzes.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // KARTU SOAL
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentQuiz.question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 30),

                            // OPSI JAWABAN (A, B, C, D)
                            ...currentQuiz.options.entries.map((entry) {
                              final isSelected =
                                  _selectedAnswers[currentQuiz.id] == entry.key;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade50
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: RadioListTile<String>(
                                  title: Text(
                                    "${entry.key.toUpperCase()}. ${entry.value}",
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.blue.shade900
                                          : Colors.black,
                                    ),
                                  ),
                                  value: entry.key,
                                  groupValue: _selectedAnswers[currentQuiz.id],
                                  activeColor: Colors.blue,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedAnswers[currentQuiz.id] = val
                                          .toString();
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL NAVIGASI
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              if (isLastQuestion) {
                                // Konfirmasi sebelum submit manual
                                _showSubmitConfirmation();
                              } else {
                                setState(() => _currentIndex++);
                              }
                            },
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isLastQuestion
                                  ? "SELESAI & KIRIM JAWABAN"
                                  : "SELANJUTNYA",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    if (!isLastQuestion && _currentIndex > 0)
                      TextButton(
                        onPressed: () {
                          setState(() => _currentIndex--);
                        },
                        child: const Text("Kembali ke soal sebelumnya"),
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

  // Dialog Konfirmasi Manual
  void _showSubmitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Kirim Jawaban?"),
        content: const Text(
          "Pastikan kamu sudah menjawab semua soal. Waktu akan berhenti setelah kamu mengirim.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitAnswers();
            },
            child: const Text("Ya, Kirim"),
          ),
        ],
      ),
    );
  }
}
