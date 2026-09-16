import 'package:flutter/material.dart';

void showComingSoonSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: const [
          Icon(Icons.construction, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Text(
            'This feature is coming soon!',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F172A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ),
  );
}
