
import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  final String id;

  const AnnouncementPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
      ),
      body: Center(
        child: Text(
          'Pengumuman dengan ID: $id',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
