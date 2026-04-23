// lib/features/home/providers/home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePageIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final homePageIndexProvider =
NotifierProvider<HomePageIndexNotifier, int>(HomePageIndexNotifier.new);