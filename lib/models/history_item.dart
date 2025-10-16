class HistoryItem {
  final String id;
  final String type; // 'summary' or 'writing'
  final String input;
  final String output;
  final DateTime timestamp;
  final Map<String, dynamic> options; // detail level, tone, etc.

  HistoryItem({
    required this.id,
    required this.type,
    required this.input,
    required this.output,
    required this.timestamp,
    required this.options,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'input': input,
        'output': output,
        'timestamp': timestamp.toIso8601String(),
        'options': options,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'],
        type: json['type'],
        input: json['input'],
        output: json['output'],
        timestamp: DateTime.parse(json['timestamp']),
        options: json['options'],
      );
}
