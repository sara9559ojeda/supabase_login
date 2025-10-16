import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/history_service.dart';
import '../services/export_service.dart';
import '../models/history_item.dart';
import 'history_screen.dart';

class WritingScreen extends StatefulWidget {
  final GeminiService geminiService;

  const WritingScreen({super.key, required this.geminiService});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final TextEditingController _textController = TextEditingController();
  String _tone = 'formal';
  int _alternatives = 1;
  String _result = '';
  bool _isLoading = false;
  String? _error;

  final List<String> _tones = ['formal', 'casual', 'persuasive'];

  Future<void> _improveWriting() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final improved = await widget.geminiService.improveWriting(
        _textController.text,
        _tone,
        alternatives: _alternatives,
      );
      setState(() {
        _result = improved;
        _isLoading = false;
      });

      // Save to history
      final historyItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'writing',
        input: _textController.text,
        output: improved,
        timestamp: DateTime.now(),
        options: {'tone': _tone, 'alternatives': _alternatives},
      );
      final historyService = HistoryService();
      await historyService.saveHistoryItem(historyItem);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Input Text',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Paste your draft here',
                        border: OutlineInputBorder(),
                        hintText: 'Enter the text you want to improve...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Options',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.mood, size: 20),
                        const SizedBox(width: 8),
                        const Text('Tone:'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _tone,
                            isExpanded: true,
                            items: _tones.map((tone) {
                              return DropdownMenuItem(value: tone, child: Text(tone));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _tone = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.library_books, size: 20),
                        const SizedBox(width: 8),
                        const Text('Alternatives:'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<int>(
                            value: _alternatives,
                            isExpanded: true,
                            items: [1, 2, 3].map((num) {
                              return DropdownMenuItem(value: num, child: Text(num.toString()));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _alternatives = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _improveWriting,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Improve Writing'),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_result.isNotEmpty)
              Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.purple.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Improved Text',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            onSelected: (format) async {
                              try {
                                final exportService = ExportService();
                                final fileName = 'writing_${DateTime.now().millisecondsSinceEpoch}';
                                final url = await exportService.exportToFile(_result, fileName, format);
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_result),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
