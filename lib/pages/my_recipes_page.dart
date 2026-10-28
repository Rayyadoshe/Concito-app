import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'recipes_page.dart';

class MyRecipesPage extends StatelessWidget {
  const MyRecipesPage({super.key});

  static const _cream = Color(0xFFFCF7EF);
  static const _forest = Color(0xFF165B45);
  static const _brown = Color(0xFF40261E);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in first.')),
      );
    }

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text('My Recipes'),
        backgroundColor: _cream,
        foregroundColor: _brown,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('recipes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load your recipes.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final recipes = snapshot.data!.docs;

          if (recipes.isEmpty) {
            return const Center(
              child: Text(
                'You have not saved any recipes yet.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index].data();

              final name = (recipe['name'] ?? 'Untitled Recipe')
                  .toString();

              final emissions = recipe['emissionsPerServingKg'];

              final emissionsText = emissions is num
                  ? '${emissions.toStringAsFixed(2)} kg CO₂e'
                  : 'N/A';

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.restaurant_menu,
                    color: _forest,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: _brown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(emissionsText),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailsPage(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}