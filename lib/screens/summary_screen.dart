import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/history_service.dart';
import '../services/export_service.dart';
import '../models/history_item.dart';
import 'history_screen.dart';

class SummaryScreen extends StatefulWidget {
  final GeminiService geminiService;

  const SummaryScreen({super.key, required this.geminiService});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController _textController = TextEditingController();
  String _detailLevel = 'medium';
  String? _language;
  String _result = '';
  bool _isLoading = false;
  String? _error;

  final List<String> _detailLevels = ['brief', 'medium', 'complete'];
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  Future<void> _generateSummary() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await widget.geminiService.generateSummary(
        _textController.text,
        _detailLevel,
        language: _language != 'English' ? _language : null,
      );
      setState(() {
        _result = summary;
        _isLoading = false;
      });

      // Save to history
      final historyItem = HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'summary',
        input: _textController.text,
        output: summary,
        timestamp: DateTime.now(),
        options: {'detailLevel': _detailLevel, 'language': _language},
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
        title: const Text('Document Summary'),
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
                        Icon(Icons.article, color: Colors.blue.shade700),
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
                        labelText: 'Paste your document text here',
                        border: OutlineInputBorder(),
                        hintText: 'Enter the text you want to summarize...',
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
                        Icon(Icons.settings, color: Colors.green.shade700),
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
                        const Icon(Icons.details, size: 20),
                        const SizedBox(width: 8),
                        const Text('Detail Level:'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _detailLevel,
                            isExpanded: true,
                            items: _detailLevels.map((level) {
                              return DropdownMenuItem(value: level, child: Text(level));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _detailLevel = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.translate, size: 20),
                        const SizedBox(width: 8),
                        const Text('Translate to:'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _language,
                            hint: const Text('None'),
                            isExpanded: true,
                            items: _languages.map((lang) {
                              return DropdownMenuItem(value: lang, child: Text(lang));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _language = value;
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
                onPressed: _isLoading ? null : _generateSummary,
                icon: const Icon(Icons.summarize),
                label: const Text('Generate Summary'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                          Icon(Icons.description, color: Colors.purple.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Summary',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            onSelected: (format) async {
                              try {
                                final exportService = ExportService();
                                final fileName = 'summary_${DateTime.now().millisecondsSinceEpoch}';
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
