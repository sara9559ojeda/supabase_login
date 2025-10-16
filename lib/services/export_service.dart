import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'supabase_service.dart';

class ExportService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<String> exportToFile(String content, String fileName, String format) async {
    List<int> fileBytes;
    String contentType;

    if (format == 'pdf') {
      fileBytes = await _generatePdf(content);
      contentType = 'application/pdf';
      fileName = '$fileName.pdf';
    } else {
      fileBytes = content.codeUnits;
      contentType = 'text/plain';
      fileName = '$fileName.txt';
    }

    return await _supabaseService.uploadFile(fileName, fileBytes, contentType);
  }

  Future<List<int>> _generatePdf(String content) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('AI Assistant Export', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text(content, style: const pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  Future<String> downloadFile(String fileName) async {
    return await _supabaseService.getFileUrl(fileName);
  }

  Future<List<String>> getUserFiles() async {
    return await _supabaseService.getUserFiles();
  }
}
