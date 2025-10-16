import '../models/history_item.dart';
import 'supabase_service.dart';

class HistoryService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<void> saveHistoryItem(HistoryItem item) async {
    await _supabaseService.saveHistoryItem(item);
  }

  Future<List<HistoryItem>> getHistory() async {
    return await _supabaseService.getHistory();
  }

  Future<void> clearHistory() async {
    await _supabaseService.clearHistory();
  }
}
