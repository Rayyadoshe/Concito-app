import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedRecipesStore {
  SavedRecipesStore._();
  static final SavedRecipesStore instance = SavedRecipesStore._();
  static const _key = 'eco_tracker_saved_recipes_v1';

  final ValueNotifier<List<Map<String, dynamic>>> recipes =
  ValueNotifier<List<Map<String, dynamic>>>([]);
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        recipes.value = (jsonDecode(raw) as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } catch (_) {
        recipes.value = [];
      }
    }
    _loaded = true;
  }

  Future<void> add(Map<String, dynamic> recipe) async {
    await load();
    final updated = [...recipes.value, recipe];
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(_key, jsonEncode(updated));
    if (!saved) throw Exception('Could not save recipe on this device.');
    recipes.value = updated;
  }
}
