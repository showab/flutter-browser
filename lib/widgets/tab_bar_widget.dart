import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tab_model.dart';

class TabBarWidget extends StatelessWidget {
  final List<BrowserTab> tabs;
  final int currentIndex;
  final Function(int) onTabSelected;
  final Function(int) onTabClosed;
  final VoidCallback onNewTab;

  const TabBarWidget({super.key, required this.tabs, required this.currentIndex, required this.onTabSelected, required this.onTabClosed, required this.onNewTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = index == currentIndex;
                return GestureDetector(
                  onTap: () => onTabSelected(index),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 160, minWidth: 100),
                    margin: EdgeInsets.only(left: 2, top: 4, bottom: 4),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tab.isLoading)
                          SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, value: tab.progress > 0 ? tab.progress : null, color: Theme.of(context).colorScheme.primary))
                        else
                          Icon(Icons.public_rounded, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _extractTitle(tab), overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        ),
                        SizedBox(width: 4),
                        if (tabs.length > 1)
                          GestureDetector(
                            onTap: () => onTabClosed(index),
                            child: Container(width: 20, height: 20, alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.close_rounded, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: onNewTab,
            child: Container(width: 38, height: 38, margin: EdgeInsets.symmetric(horizontal: 4), alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.add_rounded, size: 22, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
        ],
      ),
    );
  }

  String _extractTitle(BrowserTab tab) {
    if (tab.title != null && tab.title!.isNotEmpty) return tab.title!;
    try {
      final uri = Uri.parse(tab.currentUrl ?? tab.url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return tab.url.length > 25 ? '${tab.url.substring(0, 25)}...' : tab.url;
    }
  }
}
