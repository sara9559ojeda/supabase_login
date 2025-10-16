import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/exported_file.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<ExportedFile> _files = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabaseService = SupabaseService();
      final fileNames = await supabaseService.getUserFiles();

      final files = <ExportedFile>[];
      for (final fileName in fileNames) {
        final url = await supabaseService.getFileUrl(fileName);
        files.add(ExportedFile(
          name: fileName,
          url: url,
          // Note: Supabase storage doesn't provide creation date or size in list
          // We could store this metadata in a separate table if needed
        ));
      }

      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(ExportedFile file) async {
    try {
      final supabaseService = SupabaseService();
      final fileBytes = await supabaseService.downloadFile(file.name);

      // For web, we'll open the file in a new tab
      // For mobile, we could save to downloads folder
      if (await canLaunchUrl(Uri.parse(file.url))) {
        await launchUrl(Uri.parse(file.url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el archivo')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar: $e')),
      );
    }
  }

  Future<void> _deleteFile(ExportedFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: Text('¿Estás seguro de que quieres eliminar "${file.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final supabaseService = SupabaseService();
      await supabaseService.deleteFile(file.name);

      setState(() {
        _files.remove(file);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Archivos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFiles,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _files.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No tienes archivos exportados',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Crea un resumen o mejora un texto y expórtalo',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              file.fileType == 'PDF' ? Icons.picture_as_pdf : Icons.text_snippet,
                              color: file.fileType == 'PDF' ? Colors.red : Colors.blue,
                              size: 32,
                            ),
                            title: Text(file.displayName),
                            subtitle: Text('${file.fileType} • ${file.createdAt?.toString() ?? 'Fecha desconocida'}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () => _downloadFile(file),
                                  tooltip: 'Descargar',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteFile(file),
                                  tooltip: 'Eliminar',
                                ),
                              ],
                            ),
                            onTap: () => _downloadFile(file),
                          ),
                        );
                      },
                    ),
    );
  }
}
