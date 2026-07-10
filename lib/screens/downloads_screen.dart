import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});
  @override State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<FileSystemEntity> _files = [];
  bool _loading = true;

  @override void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    setState(() => _loading = true);
    try {
      final dir = await getExternalStorageDirectory();
      final downloadDir = Directory('${dir!.path}/Downloads');
      if (await downloadDir.exists()) {
        final files = downloadDir.listSync();
        files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        setState(() => _files = files);
      } else {
        setState(() => _files = []);
      }
    } catch (e) {
      setState(() => _files = []);
    }
    setState(() => _loading = false);
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    try {
      await file.delete();
      _loadDownloads();
    } catch (_) {}
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'mp4': case 'mkv': case 'avi': return Icons.videocam_rounded;
      case 'mp3': return Icons.music_note_rounded;
      case 'jpg': case 'jpeg': case 'png': case 'gif': return Icons.image_rounded;
      case 'apk': return Icons.android_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadDownloads)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.download_rounded, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), Text('No downloads yet', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey))]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _files.length,
                  itemBuilder: (ctx, i) {
                    final f = _files[i];
                    final stat = f.statSync();
                    final name = f.path.split('/').last;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(_fileIcon(name), color: Theme.of(ctx).colorScheme.primary)),
                        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                        subtitle: Text('${_formatBytes(stat.size)}', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20), onPressed: () => _deleteFile(f)),
                      ),
                    );
                  },
                ),
    );
  }
}