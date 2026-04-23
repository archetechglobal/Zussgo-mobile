// lib/features/home/widgets/traveler_card.dart

import 'package:flutter/material.dart';
import '../data/home_mock_data.dart';

class TravelerCard extends StatelessWidget {
  final TravelerPreview traveler;

  const TravelerCard({
    super.key,
    required this.traveler,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 84,
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: traveler.gradient,
              ),
            ),
            child: Text(
              traveler.score,
              style: const TextStyle(
                color: Color(0xFFF7B84E),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            traveler.name,
            style: const TextStyle(
              color: Color(0xFFEAF7F3),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            traveler.destination,
            style: const TextStyle(
              color: Color(0xFF6D8B86),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}