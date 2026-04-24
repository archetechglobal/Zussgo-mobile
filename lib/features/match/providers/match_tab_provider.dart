import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MatchTab { discover, requests }

class MatchTabNotifier extends StateNotifier<MatchTab> {
  MatchTabNotifier() : super(MatchTab.discover);

  void showDiscover() => state = MatchTab.discover;
  void showRequests() => state = MatchTab.requests;
}

final matchTabProvider =
StateNotifierProvider<MatchTabNotifier, MatchTab>(
      (_) => MatchTabNotifier(),
);