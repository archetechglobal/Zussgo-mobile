import 'package:flutter_riverpod/flutter_riverpod.dart';

class _NavNotifier extends StateNotifier<int> {
  _NavNotifier() : super(0);
  void setIndex(int index) => state = index;
}

final bottomNavIndexProvider =
StateNotifierProvider<_NavNotifier, int>((_) => _NavNotifier());