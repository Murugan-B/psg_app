import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vishnu_mobile/core/theme/app_theme.dart';
import 'package:vishnu_mobile/core/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VishnuMobileApp(),
    ),
  );
}

class VishnuMobileApp extends ConsumerWidget {
  const VishnuMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Vishnu Mobile',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
