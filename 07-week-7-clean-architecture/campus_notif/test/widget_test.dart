import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campus_notif/main.dart';
import 'package:campus_notif/data/datasources/token_store.dart';
import 'package:campus_notif/presentation/providers/auth_provider.dart';

// Token store khusus pengujian
class FakeTokenStore extends TokenStore {
  @override
  Future<String?> readAccess() async {
    return null;
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> save({required String access, required String refresh}) async {}
}

void main() {
  testWidgets('Campus Notif menampilkan halaman login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(FakeTokenStore())],
        child: const CampusNotifApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Campus Notif'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
