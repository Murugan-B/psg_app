import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/core/providers/supabase_provider.dart';

final roleProvider = FutureProvider<String?>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return null;

  try {
    final response = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();
    return response['role'] as String?;
  } catch (e) {
    return null;
  }
});
