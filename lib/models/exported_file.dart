class ExportedFile {
  final String name;
  final String url;
  final DateTime? createdAt;
  final int? size;

  ExportedFile({
    required this.name,
    required this.url,
    this.createdAt,
    this.size,
  });

  String get fileType => name.toLowerCase().endsWith('.pdf') ? 'PDF' : 'TXT';

  String get displayName => name.replaceAll('.pdf', '').replaceAll('.txt', '');
}
