import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationBarWidget extends StatelessWidget {
  final TextEditingController urlController;
  final FocusNode urlFocusNode;
  final bool isLoading;
  final bool isDesktopMode;
  final bool canGoBack;
  final bool canGoForward;
  final Function(String) onUrlSubmitted;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onRefresh;
  final VoidCallback onHome;
  final VoidCallback onDesktopModeToggle;
  final VoidCallback onBookmark;
  final VoidCallback onMenu;

  const NavigationBarWidget({
    super.key,
    required this.urlController,
    required this.urlFocusNode,
    required this.isLoading,
    required this.isDesktopMode,
    required this.canGoBack,
    required this.canGoForward,
    required this.onUrlSubmitted,
    required this.onBack,
    required this.onForward,
    required this.onRefresh,
    required this.onHome,
    required this.onDesktopModeToggle,
    required this.onBookmark,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _NavButton(icon: Icons.arrow_back_ios_rounded, onTap: canGoBack ? onBack : null, size: 18),
              SizedBox(width: 2),
              _NavButton(icon: Icons.arrow_forward_ios_rounded, onTap: canGoForward ? onForward : null, size: 18),
              SizedBox(width: 2),
              _NavButton(icon: isLoading ? Icons.close_rounded : Icons.refresh_rounded, onTap: onRefresh, size: 20),
              SizedBox(width: 2),
              _NavButton(icon: Icons.home_rounded, onTap: onHome, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: urlController,
                    focusNode: urlFocusNode,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search or enter URL',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: onDesktopModeToggle,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: isDesktopMode ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isDesktopMode ? Icons.desktop_windows_rounded : Icons.phone_android_rounded,
                                size: 18,
                                color: isDesktopMode ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onBookmark,
                            child: Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(Icons.bookmark_border_rounded, size: 18, color: Theme.of(context).textTheme.bodySmall?.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onSubmitted: onUrlSubmitted,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                  ),
                ),
              ),
              SizedBox(width: 8),
              _NavButton(icon: Icons.more_vert_rounded, onTap: onMenu, size: 22),
            ],
          ),
          if (isLoading)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(minHeight: 2, borderRadius: BorderRadius.circular(1), backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  const _NavButton({required this.icon, required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38, height: 38,
          alignment: Alignment.center,
          child: Icon(icon, size: size,
            color: onTap != null ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}