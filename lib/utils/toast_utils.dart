import 'package:flutter/material.dart';

class ToastUtils {
  static void show(BuildContext context, String message, {IconData icon = Icons.check_circle, Color iconColor = const Color(0xFF0D9488)}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: const Color(0xFF282A2E), // Dark gray pill background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 50, left: 40, right: 40),
        elevation: 10,
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      )
    );
  }
}
