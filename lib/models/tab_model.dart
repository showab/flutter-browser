import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserTab {
  String url;
  String? currentUrl;
  InAppWebViewController? webViewController;
  bool isLoading;
  bool canGoBack;
  bool canGoForward;
  double progress;
  String? title;

  BrowserTab({
    required this.url,
    this.currentUrl,
    this.webViewController,
    this.isLoading = false,
    this.canGoBack = false,
    this.canGoForward = false,
    this.progress = 0,
    this.title,
  });
}

enum DownloadStatus { downloading, completed, failed }

class DownloadItem {
  final String url;
  final String filename;
  final String path;
  double progress;
  DownloadStatus status;

  DownloadItem({
    required this.url,
    required this.filename,
    required this.path,
    required this.progress,
    required this.status,
  });
}