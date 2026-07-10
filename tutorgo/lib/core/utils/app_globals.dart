import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// App-wide navigator key so services (e.g. the notification poller) can show
/// UI (in-app banners) without a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Shows a transient top banner (real-time in-app popup) for a message or
/// reminder — works on every platform, including Windows desktop.
void showInAppBanner(String title, String body,
    {IconData icon = LucideIcons.messageCircle, VoidCallback? onTap}) {
  final overlay = navigatorKey.currentState?.overlay;
  final context = navigatorKey.currentContext;
  if (overlay == null || context == null) return;

  final theme = Theme.of(context);
  late OverlayEntry entry;
  bool removed = false;
  void remove() {
    if (removed) return;
    removed = true;
    try {
      entry.remove();
    } catch (_) {}
  }

  entry = OverlayEntry(
    builder: (ctx) {
      return Positioned(
        top: MediaQuery.of(ctx).padding.top + 12,
        left: 12,
        right: 12,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: onTap == null
                ? null
                : () {
                    remove();
                    onTap();
                  },
            child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Icon(icon,
                      color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (body.isNotEmpty)
                        Text(body,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 4), remove);
}
