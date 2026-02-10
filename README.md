# 📱 Daily Quiz App (Frontend UI)

Frontend aplikasi **Daily Quiz**. Dibangun menggunakan **Flutter** untuk memberikan pengalaman pengguna yang interaktif, responsif, dan real-time.

Project ini berfungsi sebagai "wajah" antarmuka yang menghubungkan siswa dengan sistem penilaian dan bank soal dari server backend (Laravel).

## 🚀 Fitur Utama

- **User Authentication:** Sistem login siswa yang terintegrasi langsung dengan validasi database backend.
- **Interactive Quiz:** Antarmuka pengerjaan soal yang dinamis dengan dukungan berbagai tipe soal.
- **Smart Result System:** Menampilkan skor, jumlah benar/salah, dan pesan motivasi (emoji) secara otomatis setelah submit.
- **Anti-Cheat Logic:** Mencegah siswa mengerjakan ulang kuis yang sama pada hari yang sama.

## 🛠️ Teknologi yang Digunakan

- **Framework:** Flutter SDK (Dart)
- **Networking:** HTTP Package
- **Configuration:** Flutter Dotenv (.env)
- **Architecture:** Clean UI & Service Repository Pattern

## 📦 Cara Install & Menjalankan (Localhost)

Ikuti langkah ini jika ingin menjalankan project di komputer kamu:

1.  **Clone Repository**

    ```bash
    git clone [https://github.com/muhammadrifqialimin/daily-quiz-frontend.git](https://github.com/muhammadrifqialimin/daily-quiz-frontend.git)
    cd daily-quiz-frontend
    ```

2.  **Install Dependencies**
    Pastikan kamu sudah menginstall Flutter SDK.

    ```bash
    flutter pub get
    ```

3.  **Setup Environment**
    Buat file `.env` baru di folder root project.

    ```bash
    # Buat file baru bernama .env
    # Isi dengan URL Backend lokal kamu:
    BASE_URL=[http://127.0.0.1:8000/api/v1](http://127.0.0.1:8000/api/v1)
    ```

4.  **Konfigurasi Aset**
    Pastikan file `.env` sudah terdaftar di `pubspec.yaml`.

    ```yaml
    flutter:
      assets:
        - .env
    ```

5.  **Jalankan Aplikasi**
    Jalankan via Chrome untuk tampilan Web.

    ```bash
    flutter run -d chrome
    ```

## 🔌 Integrasi API

Aplikasi ini terhubung dengan Backend melalui endpoint berikut:

### 1. Login Siswa

- **URL:** `POST /api/v1/login`
- **Fungsi:** Memvalidasi kredensial nama & password serta mengecek status pengerjaan hari ini.
- **Payload:**
  ```json
  {
    "name": "Rifqi",
    "password": "123"
  }
  ```

### 2. Ambil Daftar Soal

- **URL:** `GET /api/v1/quizzes`
- **Fungsi:** Mengambil daftar soal aktif harian berdasarkan kategori.
- **Response:**
  ```json
  {
      "status": true,
      "data": [ ...list soal... ]
  }
  ```

### 3. Kirim Jawaban (Submit)

- **URL:** `POST /api/v1/submit-quiz`
- **Fungsi:** Mengirim jawaban siswa untuk dinilai oleh server.
- **Body:**
  ```json
  {
    "student_id": 1,
    "answers": { "1": "A", "2": "C" }
  }
  ```

---

Dibuat oleh **[Muhammad Rifqi Alimin]**.
