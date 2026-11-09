
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/push_service.dart';
import 'router_provider.dart';

final pushServiceProvider = Provider<PushService>((ref) {

  final router = ref.watch(routerProvider);

  final service = PushService(
    router: router,
  );

  ref.onDispose(service.dispose);

  return service;
});
