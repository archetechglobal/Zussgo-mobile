// lib/features/home/widgets/home_search_bar.dart

import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  static const surface = Color(0xFF0D1C1D);
  static const faint = Color(0xFF6D8B86);
  static const teal = Color(0xFF20C9B8);
  static const teal2 = Color(0xFF58DAD0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: teal.withOpacity(.22)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: faint, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Where are you headed?',
              style: TextStyle(
                color: faint,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: teal.withOpacity(.14),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: teal.withOpacity(.22)),
            ),
            child: const Text(
              'AI Match',
              style: TextStyle(
                color: teal2,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}