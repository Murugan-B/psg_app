import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
      dotenv.env['SUPABASE_ANON_KEY'] ??
      '';

  static bool get isConfigured {
    final hasUrl = supabaseUrl.isNotEmpty && supabaseUrl.startsWith('http');
    final hasKey = supabasePublishableKey.isNotEmpty && supabasePublishableKey.length > 20;
    return hasUrl && hasKey;
  }
}
