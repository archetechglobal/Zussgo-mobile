import 'package:flutter/material.dart';

class HomeInfoTray extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? badgeCount;
  final VoidCallback? onTap;

  const HomeInfoTray({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeCount,
    this.onTap,
  });

  static const gold = Color(0xFFF7B84E);
  static const goldSoft = Color.fromRGBO(247, 184, 78, 0.14);
  static const goldBorder = Color.fromRGBO(247, 184, 78, 0.20);
  static const text = Color(0xFFEDF7F4);
  static const faint = Color(0xFF6A8882);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.024),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(.044)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: goldSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: goldBorder),
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                color: gold,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: faint,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeCount != null) ...[
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Color(0xFF041818),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: faint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}