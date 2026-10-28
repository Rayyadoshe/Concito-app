import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'recipes_page.dart';
import 'login_page.dart';


class HomePage extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const HomePage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _cream = Color(0xFFFCF7EF);
  static const _forest = Color(0xFF165B45);
  static const _brown = Color(0xFF40261E);

  List<Map<String, dynamic>> recommendedRecipes = [];
  bool loadingRecipes = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final raw = await rootBundle.loadString('assets/recipes.json');

      final decoded = (jsonDecode(raw) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      if (!mounted) return;

      setState(() {
        recommendedRecipes = decoded.take(5).toList();
        loadingRecipes = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loadingRecipes = false;
      });
    }
  }

  void _openRecipe(Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailsPage(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 30),
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
                _buildSearchBar(),
                const SizedBox(height: 18),
                _buildCalculatorCard(),
                const SizedBox(height: 18),
                _buildNavigationCards(),
                const SizedBox(height: 28),
                _buildRecommendedRecipes(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/concitologo.svg',
            height: 42,
            alignment: Alignment.centerLeft,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Every meal has\nan impact.\n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: 'Know yours',
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 27,
                    color: _brown,
                    height: 1.2,
                  ),
                ),
              ),

              Container(
                width: 135,
                height: 135,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFDCE8DE),
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 65,
                  color: _forest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => widget.onNavigate(1),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: _cream,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _brown),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.search, color: _brown),
            ],
          ),
        ),
      ),
    );
  }

  // CALCULATOR CARD
  Widget _buildCalculatorCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => widget.onNavigate(2),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF2EDE2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADING AND LEAF
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      "What's on\nyour plate?",
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 26,
                        height: 1.15,
                        color: _brown,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.eco,
                    size: 55,
                    color: Color(0xFF9CBF91),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // DESCRIPTION
              const Text(
                'Calculate your meal emissions',
                style: TextStyle(
                  fontSize: 12,
                  color: _brown,
                ),
              ),

              const SizedBox(height: 20),

              // BUTTON
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2DBC9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Calculate meal',
                        style: TextStyle(
                          fontSize: 12,
                          color: _brown,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: _brown,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // THREE NAVIGATION CARDS
  Widget _buildNavigationCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _navigationCard(
              title: 'Browse\nProducts',
              color: const Color(0xFFFFD9A0),
              icon: Icons.shopping_basket_outlined,
              onTap: () => widget.onNavigate(1),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _navigationCard(
              title: 'Find\nRecipes',
              color: const Color(0xFFB4D2A3),
              icon: Icons.restaurant_menu,
              onTap: () => widget.onNavigate(3),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _navigationCard(
              title: 'Explore\nthe Data',
              color: const Color(0xFFBBC7D4),
              icon: Icons.bar_chart,
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // Open My Account to see CO₂ statistics
                  widget.onNavigate(4);
                } else {
                  // Open Login if the user is not logged in
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationCard({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 135,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const Spacer(),

            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                icon,
                size: 38,
                color: _forest,
              ),
            ),

            const Icon(
              Icons.arrow_circle_right_outlined,
              size: 22,
              color: _brown,
            ),
          ],
        ),
      ),
    );
  }

  // RECOMMENDED RECIPES
  Widget _buildRecommendedRecipes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Recommended recipes',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 25,
                    color: _brown,
                  ),
                ),
              ),

              TextButton(
                onPressed: () => widget.onNavigate(3),
                child: const Text(
                  'See all',
                  style: TextStyle(color: _forest),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        if (loadingRecipes)
          const Center(child: CircularProgressIndicator())
        else if (recommendedRecipes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No recipes available.'),
          )
        else
          SizedBox(
            height: 205,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recommendedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = recommendedRecipes[index];

                final name = (recipe['name'] ?? '').toString();
                final image = (recipe['image'] ?? '').toString();

                final emissions = recipe['emissionsPerServingKg'];

                return GestureDetector(
                  onTap: () => _openRecipe(recipe),
                  child: Container(
                    width: 165,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE0D9CF),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: SizedBox(
                            height: 125,
                            width: double.infinity,
                            child: image.isEmpty
                                ? const Icon(
                              Icons.restaurant,
                              size: 50,
                              color: _forest,
                            )
                                : recipeImage(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(
                                Icons.restaurant,
                                size: 50,
                                color: _forest,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _brown,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                emissions is num
                                    ? '${emissions.toStringAsFixed(2)} kg CO₂e'
                                    : 'N/A',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _forest,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}