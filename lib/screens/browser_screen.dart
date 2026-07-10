import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/user_agents.dart';
import '../widgets/tab_bar_widget.dart';
import '../widgets/navigation_bar_widget.dart';
import '../models/tab_model.dart';

class BrowserScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;
  const BrowserScreen({super.key, required this.onThemeToggle, required this.isDarkMode});
  @override State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<BrowserTab> _tabs = [];
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  bool _isDesktopMode = true;
  bool _isLoading = false;
  int _currentTabIndex = 0;
  final Dio _dio = Dio();

  @override void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTabIndex = _tabController.index);
        _updateUrlFromTab();
      }
    });
    _addNewTab('https://www.google.com');
    _loadDesktopMode();
  }

  Future<void> _loadDesktopMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDesktopMode = prefs.getBool('desktop_mode') ?? true);
  }

  Future<void> _toggleDesktopMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDesktopMode = !_isDesktopMode);
    await prefs.setBool('desktop_mode', _isDesktopMode);
    _tabs[_currentTabIndex].webViewController?.reload();
  }

  void _addNewTab([String url = 'https://www.google.com']) {
    final tab = BrowserTab(url: url);
    _tabs.add(tab);
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: _tabs.length - 1);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTabIndex = _tabController.index);
        _updateUrlFromTab();
      }
    });
    setState(() => _currentTabIndex = _tabs.length - 1);
    _urlController.text = url;
  }

  void _closeTab(int index) {
    if (_tabs.length == 1) return;
    setState(() {
      _tabs.removeAt(index);
      if (_currentTabIndex >= _tabs.length) _currentTabIndex = _tabs.length - 1;
    });
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: _currentTabIndex);
    _updateUrlFromTab();
  }

  void _updateUrlFromTab() {
    final tab = _tabs[_currentTabIndex];
    _urlController.text = tab.currentUrl ?? tab.url;
  }

  void _navigateToUrl(String input) {
    String url = input.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (!url.contains('.') || url.contains(' ')) {
        url = 'https://www.google.com/search?q=' + Uri.encodeComponent(url);
      } else {
        url = 'https://$url';
      }
    }
    _tabs[_currentTabIndex].url = url;
    _urlController.text = url;
    _tabs[_currentTabIndex].webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  Future<void> _downloadFile(String url, [String? filename]) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage permission required')));
      return;
    }
    final dir = await getExternalStorageDirectory();
    final name = filename ?? url.split('/').last.split('?').first;
    final savePath = '${dir!.path}/Downloads/$name';
    await _dio.download(url, savePath);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded: $name')));
  }

  @override void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NavigationBarWidget(
              urlController: _urlController, urlFocusNode: _urlFocusNode,
              isLoading: _isLoading, isDesktopMode: _isDesktopMode,
              canGoBack: _tabs.isNotEmpty && _tabs[_currentTabIndex].canGoBack,
              canGoForward: _tabs.isNotEmpty && _tabs[_currentTabIndex].canGoForward,
              onUrlSubmitted: _navigateToUrl,
              onBack: () => _tabs[_currentTabIndex].webViewController?.goBack(),
              onForward: () => _tabs[_currentTabIndex].webViewController?.goForward(),
              onRefresh: () => _tabs[_currentTabIndex].webViewController?.reload(),
              onHome: () => _navigateToUrl('https://www.google.com'),
              onDesktopModeToggle: _toggleDesktopMode,
              onBookmark: _addBookmark, onMenu: _showMenu,
            ),
            TabBarWidget(
              tabs: _tabs, currentIndex: _currentTabIndex,
              onTabSelected: (index) {
                setState(() => _currentTabIndex = index);
                _tabController.animateTo(index);
                _updateUrlFromTab();
              },
              onTabClosed: _closeTab, onNewTab: () => _addNewTab(),
            ),
            Expanded(
              child: _tabs.isEmpty
                  ? const Center(child: Text('No tabs open'))
                  : IndexedStack(index: _currentTabIndex, children: _tabs.map((t) => _buildWebView(t)).toList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(BrowserTab tab) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(tab.url)),
      initialSettings: InAppWebViewSettings(
        userAgent: _isDesktopMode ? UserAgents.desktop : UserAgents.mobile,
        javaScriptEnabled: true, domStorageEnabled: true,
        useWideViewPort: _isDesktopMode, loadWithOverviewMode: _isDesktopMode,
        supportZoom: true, builtInZoomControls: true, displayZoomControls: false,
        allowFileAccessFromFileURLs: true, allowUniversalAccessFromFileURLs: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW, useOnDownloadStart: true,
      ),
      onWebViewCreated: (controller) => tab.webViewController = controller,
      onLoadStart: (controller, url) {
        setState(() {
          _isLoading = true; tab.currentUrl = url?.toString(); tab.isLoading = true;
        });
        if (_tabs.indexOf(tab) == _currentTabIndex) _urlController.text = url?.toString() ?? tab.url;
      },
      onLoadStop: (controller, url) {
        setState(() { _isLoading = false; tab.currentUrl = url?.toString(); tab.isLoading = false; });
      },
      onProgressChanged: (controller, progress) => tab.progress = progress / 100,
      onDownloadStartRequest: (controller, req) => _downloadFile(req.url.toString(), req.suggestedFilename),
    );
  }

  void _addBookmark() {
    final tab = _tabs[_currentTabIndex];
    final url = tab.currentUrl ?? tab.url;
    _saveBookmark(url, url);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bookmarked: $url'), duration: const Duration(seconds: 2)));
  }

  Future<void> _saveBookmark(String title, String url) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    bookmarks.add('$title||$url');
    await prefs.setStringList('bookmarks', bookmarks);
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.bookmark_outline), title: const Text('Bookmarks'), onTap: () { Navigator.pop(ctx); Navigator.pushNamed(ctx, '/bookmarks'); }),
          ListTile(leading: const Icon(Icons.download_outlined), title: const Text('Downloads'), onTap: () { Navigator.pop(ctx); Navigator.pushNamed(ctx, '/downloads'); }),
          ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), onTap: () { Navigator.pop(ctx); Navigator.pushNamed(ctx, '/settings'); }),
          const Divider(),
          ListTile(
            leading: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: Text(widget.isDarkMode ? 'Light Mode' : 'Dark Mode'),
            onTap: () { widget.onThemeToggle(!widget.isDarkMode); Navigator.pop(ctx); },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}