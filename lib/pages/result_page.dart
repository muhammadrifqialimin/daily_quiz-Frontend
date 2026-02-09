import 'package:flutter/material.dart';
import 'login_page.dart';

class ResultPage extends StatelessWidget {
  final String studentName;
  final int score;
  final int correct;
  final int total;

  const ResultPage({
    super.key,
    required this.studentName,
    required this.score,
    required this.correct,
    required this.total,
  });

  Map<String, dynamic> _getResultStyle() {
    if (score >= 95) {
      return {
        'message': "Selamat $studentName, kamu jagonya bidang ini! 🏆🔥",
        'icon': Icons.emoji_events,
        'color': Colors.amber,
      };
    } else if (score >= 80) {
      return {
        'message': "Wihh kerenn kamu $studentName! 😎👍",
        'icon': Icons.thumb_up_alt,
        'color': Colors.blue,
      };
    } else if (score >= 60) {
      return {
        'message': "Tidak apa apa setidaknya lulus. 😌👌",
        'icon': Icons.check_circle,
        'color': Colors.green,
      };
    } else if (score >= 40) {
      return {
        'message': "Ayoo nextnya pasti bisa! 💪🚀",
        'icon': Icons.trending_up,
        'color': Colors.orange,
      };
    } else if (score >= 20) {
      return {
        'message': "Serius nihh? 🧐❓",
        'icon': Icons.help_outline,
        'color': Colors.deepOrange,
      };
    } else {
      return {
        'message': "Udah nggk ketolong lagi ini... 💀🥀",
        'icon': Icons.sentiment_very_dissatisfied,
        'color': Colors.red,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Panggil fungsi gaya di sini
    final style = _getResultStyle();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400, // Lebarin dikit biar muat teks panjang
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. IKON DINAMIS (Berubah sesuai nilai)
                Icon(style['icon'], size: 80, color: style['color']),

                const SizedBox(height: 20),

                // 2. JUDUL
                const Text(
                  "Hasil Kuis",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // 3. PESAN PERSONAL (Dinamis)
                Text(
                  style['message'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const Divider(height: 40),

                const Text(
                  "Nilai Akhir",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                // 4. ANGKA NILAI (Warnanya ikut berubah)
                Text(
                  "$score",
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: style['color'], // Warna angka ikut status
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: style['color'].withOpacity(0.1), // Background tipis
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Benar $correct dari $total soal",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: style['color'],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("KELUAR"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
