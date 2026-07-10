import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;
  const SettingsScreen({super.key, required this.onThemeToggle, required this.isDarkMode});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _desktopMode = true;
  String _searchEngine = 'Google';
  String _homePage = 'https://www.google.com';

  @override void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _desktopMode = prefs.getBool('desktop_mode') ?? true;
      _searchEngine = prefs.getString('search_engine') ?? 'Google';
      _homePage = prefs.getString('home_page') ?? 'https://www.google.com';
    });
  }

  Future<void> _setDesktopMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('desktop_mode', value);
    setState(() => _desktopMode = value);
  }

  Future<void> _setSearchEngine(String engine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('search_engine', engine);
    setState(() => _searchEngine = engine);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 12), children: [
        _SectionHeader(title: 'Appearance'),
        Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: SwitchListTile(
          title: Text('Dark Mode', style: GoogleFonts.inter()),
          subtitle: Text('Switch between light and dark theme', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          value: widget.isDarkMode, onValueChanged: widget.onThemeToggle,
          secondary: Icon(widget.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: Theme.of(context).colorScheme.primary),
        )),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Browsing'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(children: [
            SwitchListTile(
              title: Text('Desktop Mode', style: GoogleFonts.inter()),
              subtitle: Text('Load desktop version of websites', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              value: _desktopMode, onValueChanged: _setDesktopMode,
              secondary: Icon(_desktopMode ? Icons.desktop_windows_rounded : Icons.phone_android_rounded, color: Theme.of(context).colorScheme.primary),
            ),
            const Divider(height: 1, indent: 72),
            ListTile(
              leading: const Icon(Icons.search_rounded, color: Color(0xFF4A90D9)),
              title: Text('Search Engine', style: GoogleFonts.inter()),
              subtitle: Text(_searchEngine, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _showSearchEnginePicker,
            ),
            const Divider(height: 1, indent: 72),
            ListTile(
              leading: const Icon(Icons.home_rounded, color: Color(0xFF4A90D9)),
              title: Text('Home Page', style: GoogleFonts.inter()),
              subtitle: Text(_homePage, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _showHomePageEditor,
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _SectionHeader(title: 'About'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF4A90D9)),
              title: Text('Fluent Browser', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text('Version 1.0.0 \· Built with Flutter', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ),
            const Divider(height: 1, indent: 72),
            ListTile(
              leading: const Icon(Icons.code_rounded, color: Color(0xFF4A90D9)),
              title: Text('Developer', style: GoogleFonts.inter()),
              subtitle: Text('Showab Ahammad', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ),
          ]),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  void _showSearchEnginePicker() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const SizedBox(height: 12), Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))), const SizedBox(height: 12), Text('Search Engine', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 8), ...['Google', 'Bing', 'DuckDuckGo', 'Yahoo'].map((e) => ListTile(leading: Icon(e == _searchEngine ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: e == _searchEngine ? Theme.of(ctx).colorScheme.primary : Colors.grey), title: Text(e, style: GoogleFonts.inter()), onTap: () { _setSearchEngine(e); Navigator.pop(ctx); })), const SizedBox(height: 16)])));
  }

  void _showHomePageEditor() {
    final ctrl = TextEditingController(text: _homePage);
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Home Page', style: GoogleFonts.inter()), content: TextField(controller: ctrl, decoration: InputDecoration(hintText: 'Enter URL', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.url), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), TextButton(onPressed: () async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('home_page', ctrl.text); setState(() => _homePage = ctrl.text); if (mounted) Navigator.pop(ctx); }, child: const Text('Save'))]));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary, letterSpacing: 0.5)));
  }
}