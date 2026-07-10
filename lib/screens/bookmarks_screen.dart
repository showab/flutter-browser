import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<_Bookmark> _bookmarks = [];

  @override void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      _bookmarks = raw.map((entry) {
        final parts = entry.split('||');
        return _Bookmark(
          title: parts.isNotEmpty ? parts[0] : '',
          url: parts.length > 1 ? parts[1] : parts[0],
        );
      }).toList();
    });
  }

  Future<void> _deleteBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarks.removeAt(index);
    final raw = _bookmarks.map((b) => '${b.title}||${b.url}').toList();
    await prefs.setStringList('bookmarks', raw);
    setState(() {});
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))),
      body: _bookmarks.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('No bookmarks yet', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _bookmarks.length,
              itemBuilder: (ctx, i) {
                final b = _bookmarks[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.bookmark_rounded, color: Theme.of(ctx).colorScheme.primary, size: 20)),
                    title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    subtitle: Text(b.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20), onPressed: () => _deleteBookmark(i)),
                    onTap: () => Navigator.pop(ctx, b.url),
                  ),
                );
              },
            ),
    );
  }
}

class _Bookmark {
  final String title;
  final String url;
  _Bookmark({required this.title, required this.url});
}