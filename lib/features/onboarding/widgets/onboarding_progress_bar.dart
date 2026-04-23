import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingProgressBar extends StatelessWidget {
  final int total;
  final int current;

  const OnboardingProgressBar({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(total, (index) {
          final bool isActive = index == current;
          final bool isDone = index < current;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 4),
              height: 2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: (isActive || isDone)
                    ? AppColors.primary
                    : const Color(0x1AFFFFFF),
              ),
            ),
          );
        }),
      ),
    );
  }
}