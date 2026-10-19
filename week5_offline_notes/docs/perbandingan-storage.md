# Perbandingan Teknologi Penyimpanan Data

## 1. Tujuan

Perbandingan ini bertujuan menentukan teknologi penyimpanan yang sesuai untuk aplikasi Flutter Offline Notes. Penilaian dilakukan berdasarkan kompleksitas query, kebutuhan relasi, reaktivitas, type-safety, ukuran boilerplate, dan kemudahan testing. Hasil perbandingan digunakan untuk menjelaskan alasan pemilihan teknologi yang diterapkan pada Praktikum Week 5.

## 2. Tabel Perbandingan

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Sangat sederhana, berbasis key-value | Sederhana, berbasis objek | Mendukung SQL, filter, sorting, dan agregasi | Mendukung query SQL melalui API Dart bertipe |
| Kebutuhan relasi | Tidak mendukung relasi tabel | Relasi perlu dikelola sendiri | Mendukung tabel, foreign key, dan JOIN | Mendukung relasi dan JOIN |
| Reaktivitas (stream) | Tidak menyediakan stream query bawaan | Dapat mendengarkan perubahan box melalui mekanisme yang tersedia | Tidak menyediakan stream query bawaan | Mendukung stream perubahan query melalui `watch()` |
| Type-safety | Terbatas pada tipe nilai preferensi | Menggunakan model dan adapter untuk objek | Mapping hasil query ke model Dart umumnya dilakukan manual | Mendukung query dan model bertipe melalui code generation |
| Ukuran boilerplate | Sangat sedikit | Memerlukan model atau adapter untuk objek tertentu | Memerlukan SQL dan mapping model | Memerlukan konfigurasi dan code generation |
| Kemudahan testing | Mudah untuk preferensi sederhana | Dapat diuji menggunakan penyimpanan sementara | Dapat diuji menggunakan database sementara atau repository palsu | Dapat diuji menggunakan database sementara dan DAO |
| Kesesuaian untuk preferensi | Sangat cocok | Bisa digunakan, tetapi relatif berlebihan | Bisa digunakan, tetapi lebih kompleks | Bisa digunakan, tetapi berlebihan untuk kebutuhan sederhana |
| Kesesuaian untuk 1.000+ catatan | Tidak disarankan sebagai penyimpanan utama koleksi catatan | Memungkinkan, tetapi query kompleks perlu pengelolaan tambahan | Cocok untuk CRUD, pencarian, dan pengurutan | Cocok untuk query kompleks dan data reaktif |

## 3. Rekomendasi Teknologi

### A. SharedPreferences untuk preferensi pengguna

SharedPreferences digunakan untuk menyimpan preferensi sederhana, seperti tema terang atau gelap. Data tersebut berbentuk pasangan key-value dan tidak memerlukan query kompleks. Oleh karena itu, SharedPreferences sesuai dengan kebutuhan pengaturan aplikasi pada Week 5.

### B. SQLite melalui sqflite untuk catatan

sqflite digunakan untuk mengakses database SQLite yang menyimpan catatan secara lokal. Teknologi ini mendukung operasi CRUD, query berdasarkan ID, pengurutan berdasarkan waktu pembaruan, dan penyimpanan status sinkronisasi melalui kolom `dirty`.

SQLite juga memungkinkan catatan tetap diakses ketika perangkat tidak terhubung ke internet. Hal ini sesuai dengan pendekatan offline-first yang diterapkan pada aplikasi.

### C. Drift sebagai alternatif pengembangan lanjutan

Drift dapat dipertimbangkan jika aplikasi membutuhkan query yang lebih kompleks, stream perubahan data secara otomatis, dan type-safety yang lebih kuat. Namun, Drift memerlukan konfigurasi serta code generation sehingga menambah kompleksitas dibandingkan penggunaan sqflite secara langsung.

### D. Hive sebagai alternatif penyimpanan berbasis objek

Hive dapat digunakan untuk menyimpan objek lokal dengan pendekatan berbasis box. Teknologi ini cocok untuk kebutuhan yang sederhana, tetapi query kompleks dan relasi antardata memerlukan pengelolaan tambahan. Untuk aplikasi Week 5, SQLite lebih sesuai dengan kebutuhan data catatan yang terstruktur.

## 4. Rancangan Tabel untuk 1.000+ Catatan

Berikut contoh rancangan tabel SQLite yang disesuaikan dengan atribut model catatan pada proyek Week 5.

### Tabel `notes`

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
```

Keterangan:
- `id`: identitas unik setiap catatan.
- `title`: judul catatan.
- `body`: isi catatan.
- `updated_at`: waktu terakhir catatan diperbarui dalam format ISO 8601.
- `dirty`: status sinkronisasi; nilai 1 berarti belum tersinkronisasi dan 0 berarti sudah tersinkronisasi.

Indeks berikut dapat ditambahkan apabila pengurutan berdasarkan waktu pembaruan sering digunakan:

```sql
CREATE INDEX idx_notes_updated_at
ON notes(updated_at DESC);
```

Indeks tersebut merupakan rekomendasi optimasi untuk query pengurutan, bukan klaim bahwa indeks sudah diterapkan dalam database proyek.

### Penyimpanan cache posts

Aplikasi Week 5 juga mengambil data posts dari server dan menyimpannya agar dapat digunakan ketika offline. Bentuk tabel cache perlu mengikuti implementasi `PostRepository` dan `db.dart` yang digunakan dalam proyek. Jika cache disimpan sebagai payload JSON, salah satu rancangan yang dapat digunakan adalah:

```sql
CREATE TABLE cached_posts (
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  cached_at TEXT NOT NULL
);
```

Rancangan ini merupakan contoh alternatif, bukan pernyataan bahwa struktur tabel tersebut sudah digunakan oleh aplikasi.

## 5. Trade-off Setiap Pilihan

### SharedPreferences

**Kelebihan:** implementasi sederhana dan cocok untuk preferensi seperti tema aplikasi.

**Kekurangan:** tidak dirancang untuk koleksi catatan yang membutuhkan query, pengurutan, dan relasi.

### Hive

**Kelebihan:** penyimpanan objek lokal relatif sederhana dan mendukung mekanisme pemantauan perubahan box.

**Kekurangan:** pengelolaan query kompleks, filtering, sorting, dan relasi tidak sefleksibel SQLite.

### sqflite

**Kelebihan:** mendukung SQL, CRUD, transaksi, indeks, dan relasi. Teknologi ini juga sesuai dengan repository catatan yang sudah digunakan dalam proyek Week 5.

**Kekurangan:** mapping hasil query ke model Dart dan pembaruan state UI perlu dikelola secara manual.

### Drift

**Kelebihan:** menyediakan query bertipe, stream reaktif, dan dukungan pengelolaan skema yang lebih terstruktur.

**Kekurangan:** memerlukan konfigurasi awal, code generation, dan pemahaman tambahan.

## 6. Keputusan Akhir

Kombinasi SharedPreferences dan sqflite dipilih untuk aplikasi Offline Notes Week 5.

SharedPreferences digunakan untuk menyimpan preferensi tema karena datanya sederhana. Sementara itu, sqflite digunakan untuk menyimpan catatan dan mendukung operasi CRUD, pengurutan berdasarkan `updated_at`, serta pengelolaan status sinkronisasi melalui `dirty`.

Hive dan Drift tetap menjadi alternatif yang dapat dipertimbangkan apabila kebutuhan aplikasi berkembang. Namun, untuk praktikum ini, penggunaan teknologi yang sudah diterapkan lebih sesuai karena memenuhi kebutuhan utama tanpa menambah kompleksitas implementasi yang belum diperlukan.
