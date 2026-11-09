import 'package:flutter/material.dart';

class AnnouncementDetailPage extends StatelessWidget {
  final String id;

  const AnnouncementDetailPage({
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
        child: Text('ID Pengumuman: $id'),
      ),
    );
  }
}