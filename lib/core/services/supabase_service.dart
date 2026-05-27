// supabase_service.dart
// NOTE: Supabase is not used for auth in this prototype.
// All user data is stored locally via Hive.
// This file is kept for future cloud-sync functionality.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

// ── Safe Supabase client (returns null if not initialized) ─────────────────
SupabaseClient? _safeClient() {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  return _safeClient();
});

class SupabaseService {
  final SupabaseClient? _client;
  SupabaseService(this._client);

  bool get isAvailable => _client != null;

  // ── Auth (not used — app uses local auth) ─────────────────────────────────
  Future<AuthResponse?> signInWithEmail(String email, String password) async {
    if (!isAvailable) return null;
    return _client!.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse?> signUpWithEmail(String email, String password) async {
    if (!isAvailable) return null;
    return _client!.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    if (!isAvailable) return;
    await _client!.auth.signOut();
  }

  // ── Habits (cloud sync — future use) ──────────────────────────────────────
  Future<List<HabitModel>> fetchHabits(String userId) async {
    if (!isAvailable) return [];
    final data = await _client!
        .from('habits')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: true);
    return data.map((e) => HabitModel.fromJson(e)).toList();
  }

  Future<void> insertHabit(HabitModel habit) async {
    if (!isAvailable) return;
    await _client!.from('habits').insert(habit.toJson());
  }

  // ── Mood Logs ─────────────────────────────────────────────────────────────
  Future<List<MoodLogModel>> fetchLogs(String userId, {int limit = 30}) async {
    if (!isAvailable) return [];
    final data = await _client!
        .from('mood_logs')
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false)
        .limit(limit);
    return data.map((e) => MoodLogModel.fromJson(e)).toList();
  }

  Future<void> insertLog(MoodLogModel log) async {
    if (!isAvailable) return;
    await _client!.from('mood_logs').insert(log.toJson());
  }

  // ── Challenges ────────────────────────────────────────────────────────────
  Future<void> upsertChallenge(Map<String, dynamic> challenge) async {
    if (!isAvailable) return;
    await _client!.from('challenges').upsert(challenge);
  }

  // ── Saved Jar ─────────────────────────────────────────────────────────────
  Future<void> insertJarEntry(Map<String, dynamic> entry) async {
    if (!isAvailable) return;
    await _client!.from('saved_jar').insert(entry);
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(ref.watch(supabaseClientProvider));
});
