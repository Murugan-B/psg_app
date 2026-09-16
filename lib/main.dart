import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:psg_app/core/router/app_router.dart';
import 'package:psg_app/core/auth/auth_gate.dart';
import 'package:psg_app/core/theme/app_theme.dart';

import 'package:psg_app/core/config/env.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isSupabaseInitialized = false;

  try {
    await dotenv.load(fileName: ".env");
    debugPrint('.env loaded successfully.');
  } catch (e) {
    debugPrint('.env file not found or could not be loaded.');
  }

  debugPrint('SUPABASE_URL: ${dotenv.env['SUPABASE_URL']?.isNotEmpty == true ? 'configured' : 'missing'}');
  debugPrint('SUPABASE_ANON_KEY: ${dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty == true ? 'configured' : 'missing'}');

  if (Env.isConfigured) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabasePublishableKey,
      );
      isSupabaseInitialized = true;
    } catch (e) {
      debugPrint('Supabase Initialization Failed: $e');
    }
  }

  runApp(ProviderScope(
    child: isSupabaseInitialized
        ? const VishnuMobileApp()
        : const InitializationErrorApp(),
  ));
}

class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Configuration Error',
                  style: AppTheme.lightTheme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to connect to the application services.\nPlease provide valid SUPABASE_URL and SUPABASE_ANON_KEY environment variables.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Retry requires full restart if we don't hot-reload
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VishnuMobileApp extends StatelessWidget {
  const VishnuMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PSG App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AuthGate(child: child!);
      },
    );
  }
}
