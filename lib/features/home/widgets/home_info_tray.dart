import 'package:flutter/material.dart';
import '../data/home_mock_data.dart';

class HomeInfoTray extends StatelessWidget {
  final HomeTrayData tray;

  const HomeInfoTray({
    super.key,
    required this.tray,
  });

  static const text = Color(0xFFEAF7F3);
  static const faint = Color(0xFF6A8882);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.024),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.045)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tray.iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: tray.iconColor.withOpacity(.18),
              ),
            ),
            child: Icon(
              tray.icon,
              size: 17,
              color: tray.iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tray.title,
                  style: const TextStyle(
                    color: text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tray.subtitle,
                  style: const TextStyle(
                    color: faint,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (tray.badge != null) ...[
            Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7B84E),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Text(
                  tray.badge!,
                  style: const TextStyle(
                    color: Color(0xFF041818),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: faint.withOpacity(.95),
            size: 18,
          ),
        ],
      ),
    );
  }
}