import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
      ),
      body: const Center(
        child: Text('Daftar pengumuman kampus'),
      ),
    );
  }
}