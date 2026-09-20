import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';

void main() {
  // Test 1: Layar sempit menggunakan 1 kolom
  testWidgets(
    'Dashboard satu kolom di layar sempit',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const DashboardApp(),
      );

      // Memastikan terdapat 4 kartu
      final cards = find.byType(InfoCard);

      expect(
        cards,
        findsNWidgets(4),
      );

      // Lebar kartu pada layar sempit
      final width = tester.getSize(cards.first).width;

      expect(
        width,
        lessThan(700),
      );
    },
  );

  // Test 2: Layar lebar menggunakan 2 kolom
  testWidgets(
    'Dashboard dua kolom di layar lebar',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const DashboardApp(),
      );

      // Memastikan terdapat 4 kartu
      final cards = find.byType(InfoCard);

      expect(
        cards,
        findsNWidgets(4),
      );

      // Lebar kartu pada layar lebar
      final width = tester.getSize(cards.first).width;

      expect(
        width,
        greaterThan(500),
      );
    },
  );

  // Test 3: Dark mode switch
  testWidgets(
    'Dark mode switch dapat digunakan',
    (tester) async {
      await tester.pumpWidget(
        const DashboardApp(),
      );

      // Cari CupertinoSwitch
      final switchFinder =
          find.byType(CupertinoSwitch);

      // Pastikan switch tersedia
      expect(
        switchFinder,
        findsOneWidget,
      );

      // Ambil kondisi switch sebelum ditekan
      CupertinoSwitch darkSwitch =
          tester.widget<CupertinoSwitch>(
        switchFinder,
      );

      // Kondisi awal adalah Light Mode
      expect(
        darkSwitch.value,
        false,
      );

      // Tekan switch
      await tester.tap(switchFinder);

      // Tunggu aplikasi melakukan rebuild
      await tester.pump();

      // Ambil kembali switch setelah ditekan
      darkSwitch =
          tester.widget<CupertinoSwitch>(
        switchFinder,
      );

      // Setelah ditekan harus menjadi true
      expect(
        darkSwitch.value,
        true,
      );
    },
  );
}
