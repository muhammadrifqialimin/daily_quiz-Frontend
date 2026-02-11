import 'package:flutter/material.dart';
import '../services/student_service.dart';
import 'quiz_page.dart';
import 'profile_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final int studentId;
  final String studentName;
  final String className;

  const HomePage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.className,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StudentService _studentService = StudentService();
  late Future<List<dynamic>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _refreshSchedule();
  }

  void _refreshSchedule() {
    setState(() {
      _scheduleFuture = _studentService.getSchedules(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, ${widget.studentName}",
              style: const TextStyle(fontSize: 18),
            ),
            Text(widget.className, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Profil
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profil Saya',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(studentId: widget.studentId),
                ),
              );
            },
          ),
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshSchedule(),
        child: FutureBuilder<List<dynamic>>(
          future: _scheduleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Jika Jadwal Kosong
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Tidak ada jadwal ujian hari ini.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: _refreshSchedule,
                      child: const Text("Refresh"),
                    ),
                  ],
                ),
              );
            }

            final schedules = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final item = schedules[index];
                final String status =
                    item['status']; // active, upcoming, finished

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Mapel & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['subject'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildStatusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),

                        // Info Waktu
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${item['start_time']} - ${item['end_time']}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              item['date'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Tombol Aksi
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: status == 'active'
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizPage(
                                          studentId: widget.studentId,
                                          studentName: widget.studentName,
                                          category: item['subject'],
                                          endTime:
                                              item['full_end_time'], // Kirim Waktu Selesai (Hard Stop)
                                        ),
                                      ),
                                    );
                                  }
                                : null, // Tombol mati jika belum mulai/sudah lewat
                            style: ElevatedButton.styleFrom(
                              backgroundColor: status == 'active'
                                  ? Colors.blue
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(_getButtonLabel(status)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'active':
        color = Colors.green;
        text = "Sedang Berlangsung";
        break;
      case 'finished':
        color = Colors.red;
        text = "Selesai";
        break;
      default:
        color = Colors.orange;
        text = "Akan Datang";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getButtonLabel(String status) {
    if (status == 'active') return "KERJAKAN SEKARANG 🚀";
    if (status == 'finished') return "UJIAN DITUTUP";
    return "BELUM DIMULAI";
  }
}
