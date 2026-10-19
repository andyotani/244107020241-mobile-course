# AI Prompt Challenge — Offline Notes

## 1. Prompt yang Digunakan

Aplikasi Flutter Offline Notes memiliki fitur CRUD catatan, preferensi tema, dan pengelolaan data secara offline-first. Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk kebutuhan penyimpanan aplikasi tersebut.

Gunakan kriteria berikut:
- Kompleksitas query.
- Kebutuhan relasi.
- Reaktivitas (stream).
- Type-safety.
- Ukuran boilerplate.
- Kemudahan testing.

Berikan rekomendasi teknologi untuk menyimpan preferensi dan catatan dalam satu tabel perbandingan. Tunjukkan rancangan tabel yang sesuai untuk aplikasi dengan lebih dari 1.000 catatan dan jelaskan trade-off setiap pilihan.

## 2. Ringkasan Rekomendasi AI

Hasil analisis menunjukkan bahwa pemilihan teknologi penyimpanan perlu disesuaikan dengan jenis data dan kebutuhan aplikasi.

SharedPreferences sesuai untuk menyimpan preferensi sederhana, seperti tema terang dan gelap. Hive dapat digunakan untuk menyimpan objek lokal, tetapi pengelolaan query relasional lebih terbatas dibandingkan SQLite. sqflite menyediakan akses ke database SQLite menggunakan query SQL sehingga sesuai untuk operasi CRUD, pengurutan catatan, dan pengelolaan status sinkronisasi.

Drift juga menggunakan SQLite, tetapi menyediakan fitur tambahan berupa query bertipe, stream reaktif, dan kode hasil generator. Fitur tersebut bermanfaat untuk aplikasi yang lebih kompleks, tetapi membutuhkan konfigurasi tambahan.

## 3. Hasil Perbandingan

Perbandingan lengkap tersedia pada `docs/perbandingan-storage.md`.

Berdasarkan kebutuhan aplikasi Week 5, SharedPreferences dipilih untuk preferensi tema, sedangkan sqflite dipilih untuk menyimpan catatan. Pemilihan ini mempertimbangkan kesesuaian dengan implementasi aplikasi, kebutuhan CRUD, dan pengelolaan status sinkronisasi melalui kolom `dirty`.

## 4. Verifikasi Rekomendasi

- [x] Preferensi tema menggunakan SharedPreferences.
- [x] Catatan dikelola menggunakan SQLite melalui sqflite.
- [x] Model catatan memiliki atribut judul, isi, waktu pembaruan, dan status `dirty`.
- [x] Rekomendasi mempertimbangkan query, relasi, reaktivitas, type-safety, boilerplate, dan testing.
- [x] Keputusan akhir mempertimbangkan kebutuhan serta struktur proyek Week 5.

Catatan: Perbandingan Hive dan Drift dilakukan sebagai evaluasi desain. Paket alternatif tersebut tidak diklaim sudah diinstal atau diuji dalam aplikasi.

## 5. Keputusan Akhir

**Preferensi:** SharedPreferences, karena pengaturan tema merupakan data sederhana yang tidak membutuhkan query database.

**Catatan:** sqflite (SQLite), karena mendukung CRUD, pengurutan berdasarkan `updated_at`, dan penyimpanan status sinkronisasi melalui `dirty`.

**Alasan tidak memilih Hive:** kebutuhan aplikasi lebih sesuai dengan query SQL dan struktur data relasional yang disediakan SQLite.

**Alasan tidak memilih Drift saat ini:** fitur query reaktif dan type-safety tambahan bermanfaat, tetapi konfigurasi serta code generation belum diperlukan untuk kebutuhan praktikum ini.

**Kesimpulan:** Kombinasi SharedPreferences dan sqflite merupakan pilihan yang sesuai dengan implementasi Week 5. SharedPreferences menangani preferensi sederhana, sedangkan SQLite mengelola catatan lokal agar tetap dapat diakses tanpa koneksi internet.
