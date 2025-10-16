import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';
import '../services/export_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final historyService = HistoryService();
    final history = await historyService.getHistory();
    setState(() {
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: _history.isEmpty
          ? const Center(child: Text('No history yet'))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(item.type == 'summary' ? 'Summary' : 'Writing'),
                    subtitle: Text(item.timestamp.toString()),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(item.type == 'summary' ? 'Summary Details' : 'Writing Details'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Input:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(item.input),
                                const SizedBox(height: 16),
                                const Text('Output:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(item.output),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (format) async {
                                try {
                                  final exportService = ExportService();
                                  final fileName = '${item.type}_${DateTime.now().millisecondsSinceEpoch}';
                                  final url = await exportService.exportToFile(item.output, fileName, format);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('File exported successfully! URL: $url')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Export failed: $e')),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
                                const PopupMenuItem(value: 'txt', child: Text('Export as TXT')),
                              ],
                              child: const Text('Export'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
