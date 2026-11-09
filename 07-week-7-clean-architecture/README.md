
# Laporan Perbandingan Campus Notif

Dokumen ini membandingkan aplikasi `campus_notif` pada minggu ke-6
(`06-week-6-authentication-security-fcm`) dengan versi minggu ke-7
(`07-week-7-clean-architecture/campus_notif`).

## Ringkasan

Versi minggu ke-6 sudah memiliki fitur autentikasi, notifikasi lokal, dan
Firebase Cloud Messaging (FCM), tetapi kode masih dikelompokkan terutama
berdasarkan jenis file. Versi minggu ke-7 mempertahankan fungsi aplikasi dan
memisahkan kode ke lapisan `data`, `domain`, dan `presentation`. Perubahan
utamanya adalah struktur dan arah dependensi, bukan penambahan fitur pengguna.
Dengan susunan baru, perubahan pada tampilan, aturan bisnis, atau cara
penyimpanan dapat dikerjakan pada bagian yang lebih sesuai tanpa menempatkan
semua tanggung jawab dalam file yang sama.

## Perbandingan

| Area | Minggu ke-6 | Minggu ke-7 (Clean Architecture) |
|---|---|---|
| Struktur UI dan state | `pages/` dan `providers/` berada langsung di bawah `lib/`. | UI dan provider berada di `presentation/pages/` dan `presentation/providers/`. |
| Logika bisnis | Aturan login dan operasi notifikasi dipanggil langsung melalui repository/store dari provider. | Operasi bisnis tersedia sebagai use case pada `domain/usecases/`, misalnya `Login`, `LoadNotifications`, dan `RemoveNotification`. |
| Kontrak repository | `AuthRepository` berupa implementasi konkret; kontrak notification repository belum tersedia sebagai lapisan domain. | Kontrak `AuthRepository` dan `NotificationRepository` didefinisikan di domain, sedangkan implementasi berada di `data/repositories/`. |
| Penyimpanan dan model | Model notifikasi dan penyimpanan SharedPreferences digabung dalam `data/notification_store.dart`; penyimpanan token ada di `data/token_store.dart`. | Entity notifikasi berada di domain; model serialisasi, local data source, dan token store dipisahkan di `data/models/` dan `data/datasources/`. |
| Push notification | Layanan push berada di `messaging/push_service.dart`. | Layanan push dipindahkan ke `data/services/push_service.dart` dan memakai local data source untuk penyimpanan pesan latar. |
| Dependency | Provider berinteraksi langsung dengan store/repository konkret. | UI/provider memanggil use case; implementasi data memenuhi kontrak domain. `main.dart` tetap menjadi titik komposisi aplikasi. |
| Dependensi paket | Flutter, Riverpod, GoRouter, Firebase, secure storage, dan SharedPreferences. | Paket utama yang dibandingkan tetap sama; perubahan ini tidak memerlukan dependensi baru. |

Alur utama versi minggu ke-7:

```text
presentation -> domain use case -> domain repository contract
                                      ^
                                      |
data repository implementation -> data source / external service
```

Sebagai contoh, saat pengguna login, halaman login mengirim email dan kata sandi
ke provider. Provider menjalankan use case `Login`, lalu use case menggunakan
kontrak `AuthRepository`. Implementasi di data memvalidasi kredensial simulasi
dan menyimpan token melalui `TokenStore`. Dengan alur ini, halaman tidak perlu
mengetahui detail penyimpanan token.

Alur notifikasi menggunakan pola serupa. Provider menjalankan use case untuk
memuat, menambah, menghapus, atau membersihkan notifikasi. Implementasi
repository meneruskan operasi tersebut ke local data source yang mengelola
serialisasi JSON dan SharedPreferences. Entity notifikasi di domain berisi data
yang dibutuhkan aplikasi tanpa harus bergantung pada format JSON.

Domain tidak mengimpor Flutter atau pustaka penyimpanan. Batas ini mengurangi
ketergantungan logika bisnis pada UI dan teknologi penyimpanan, serta
memungkinkan use case diuji menggunakan repository palsu. Jika sumber data
berubah di kemudian hari, misalnya dari SharedPreferences ke API, perubahan
utama dapat dibatasi pada data source dan implementasi repository selama
kontrak domain tetap sama. Di sisi lain, versi minggu ke-7 memiliki lebih
banyak file dan lapisan yang perlu dipahami; untuk fitur sederhana, pemisahan
ini dapat terasa lebih panjang dibanding pemanggilan langsung.

## Dampak pada perilaku

Rute login, beranda, daftar notifikasi, penyimpanan notifikasi lokal, serta
integrasi FCM dipertahankan. Penambahan use case dan pemindahan file tidak
dimaksudkan untuk mengubah alur yang terlihat oleh pengguna.

Perubahan yang terlihat terutama berada di dalam kode: file dipindahkan,
provider menggunakan use case, dan repository memiliki kontrak yang jelas.
Pemisahan ini memberikan tempat yang lebih konsisten untuk menambahkan aturan
baru, misalnya kebijakan validasi login atau penyaringan notifikasi, sekaligus
memudahkan pengujian fungsi tersebut secara terpisah dari widget.

Implementasi autentikasi masih berupa simulasi lokal (validasi email/password
dan token buatan), bukan autentikasi ke backend. Karena itu, struktur Clean
Architecture ini memperbaiki pemisahan tanggung jawab, tetapi tidak dengan
sendirinya menambah keamanan autentikasi atau layanan server.

## Verifikasi versi minggu ke-7

- `flutter test`: lulus (1 widget test).
- `dart format --output=none --set-exit-if-changed lib test`: tidak ada file
  yang perlu diformat.
- `flutter analyze`: tidak menemukan error, tetapi keluar dengan dua info
  deprecated API FCM (`getToken` dan `onTokenRefresh`) di layanan push.
- Hot restart aplikasi Flutter: berhasil.

Test widget mencatat error inisialisasi plugin notifikasi lokal di lingkungan
test yang tidak memiliki platform plugin, tetapi test tetap lulus. Hal itu bukan
verifikasi perilaku notifikasi pada perangkat nyata.
Analyzer hanya melaporkan dua info deprecated API, bukan error kompilasi.
Pengujian perangkat nyata masih diperlukan untuk memastikan izin, penerimaan
FCM, suara, dan interaksi notifikasi bekerja sesuai harapan pada platform target.

## Kesimpulan

Versi minggu ke-7 merupakan peningkatan pada kualitas struktur, bukan perubahan
besar pada fitur. Pemisahan `presentation`, `domain`, dan `data` membuat alur
tanggung jawab lebih jelas, membatasi ketergantungan antarbagian, serta
menyiapkan aplikasi agar lebih mudah diuji dan dikembangkan. Fitur utama
aplikasi dan paket dependensinya tetap dipertahankan.

Sebagai konsekuensinya, perubahan sederhana dapat melibatkan beberapa file dan
perlu dipahami melalui alur use case serta kontrak repository. Untuk proyek ini,
manfaat struktur tersebut menjadi berguna ketika fitur dan sumber data
bertambah. Tahap pengembangan berikutnya sebaiknya menambah unit test untuk
use case dan repository, memperbarui API FCM yang deprecated, serta menguji
notifikasi pada perangkat nyata. Secara keseluruhan, versi Clean Architecture
memberikan fondasi yang lebih teratur untuk pengembangan Campus Notif
selanjutnya, tetapi tidak dengan sendirinya mengubah simulasi autentikasi
menjadi autentikasi backend atau menggantikan kebutuhan pengujian.
