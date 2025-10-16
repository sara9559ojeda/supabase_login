import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/history_item.dart';

class SupabaseService {
  static final SupabaseClient supabase = Supabase.instance.client;

  // Authentication methods
  Future<AuthResponse> signUp(String email, String password) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  // History methods
  Future<void> saveHistoryItem(HistoryItem item) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await supabase.from('history').insert({
      'user_id': userId,
      'id': item.id,
      'type': item.type,
      'input': item.input,
      'output': item.output,
      'timestamp': item.timestamp.toIso8601String(),
      'options': item.options,
    });
  }

  Future<List<HistoryItem>> getHistory() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('history')
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false);

    return response.map((json) => HistoryItem.fromJson(json)).toList();
  }

  Future<void> clearHistory() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await supabase.from('history').delete().eq('user_id', userId);
  }

  // Storage methods
  Future<String> uploadFile(String fileName, List<int> fileBytes, String contentType) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final filePath = '$userId/$fileName';
    await supabase.storage.from('exports').uploadBinary(
      filePath,
      Uint8List.fromList(fileBytes),
      fileOptions: FileOptions(contentType: contentType),
    );

    return supabase.storage.from('exports').getPublicUrl(filePath);
  }

  Future<List<String>> getUserFiles() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final files = await supabase.storage.from('exports').list(path: userId);
    return files.map((file) => file.name).toList();
  }

  Future<String> getFileUrl(String fileName) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final filePath = '$userId/$fileName';
    return supabase.storage.from('exports').getPublicUrl(filePath);
  }

  Future<void> deleteFile(String fileName) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final filePath = '$userId/$fileName';
    await supabase.storage.from('exports').remove([filePath]);
  }

  Future<Uint8List> downloadFile(String fileName) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final filePath = '$userId/$fileName';
    final response = await supabase.storage.from('exports').download(filePath);
    return response;
  }
}
