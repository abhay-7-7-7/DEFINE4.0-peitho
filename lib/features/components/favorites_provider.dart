import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final notifier = FavoritesNotifier();
  notifier.load();
  return notifier;
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(const {});

  static const _key = 'bk_favorite_components';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      state = list.toSet();
    } catch (_) {
      // Fallback
    }
  }

  Future<void> toggleFavorite(String componentId) async {
    final next = Set<String>.from(state);
    if (next.contains(componentId)) {
      next.remove(componentId);
    } else {
      next.add(componentId);
    }
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, next.toList());
    } catch (_) {}
  }

  bool isFavorite(String componentId) => state.contains(componentId);
}
