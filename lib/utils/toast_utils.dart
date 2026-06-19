import 'package:flutter/material.dart';

class ToastUtils {
  static void show(BuildContext context, String message, {
    IconData icon = Icons.check_circle, 
    Color iconColor = const Color(0xFF0D9488), 
    Duration duration = const Duration(seconds: 2), 
    Color bgColor = Colors.white
  }) {
    // Get overlay state safely
    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return;
    
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        message, 
                        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
