import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SavedRecipesStore {
  SavedRecipesStore._();

  static final SavedRecipesStore instance = SavedRecipesStore._();

  final ValueNotifier<List<Map<String, dynamic>>> recipes =
  ValueNotifier<List<Map<String, dynamic>>>([]);

  String? _loadedUserId;

  Future<void> load() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      recipes.value = [];
      _loadedUserId = null;
      return;
    }

    if (_loadedUserId == user.uid) return;

    // Clear recipes from any previously logged-in user.
    recipes.value = [];
    _loadedUserId = null;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recipes')
        .get();

    // Don't display another user's recipes if the account changed
    // while the request was running.
    if (FirebaseAuth.instance.currentUser?.uid != user.uid) return;

    recipes.value = snapshot.docs.map((doc) {
      return Map<String, dynamic>.from(doc.data());
    }).toList();

    _loadedUserId = user.uid;
  }

  Future<void> add(Map<String, dynamic> recipe) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please log in to save a recipe.');
    }

    await load();

    final recipeData = Map<String, dynamic>.from(recipe);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recipes')
        .add(recipeData);

    // Only update the current user's displayed recipes.
    if (FirebaseAuth.instance.currentUser?.uid == user.uid) {
      recipes.value = [...recipes.value, recipeData];
    }
  }
}