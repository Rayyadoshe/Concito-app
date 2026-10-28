import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'my_recipes_page.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'edit_profile_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static const _cream = Color(0xFFFCF7EF);
  static const _forest = Color(0xFF165B45);
  static const _brown = Color(0xFF40261E);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your account.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.hasError) {
              return const Center(
                child: Text('Could not load your profile.'),
              );
            }

            if (!profileSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final data = profileSnapshot.data!.data() ?? {};

            final name =
            (data['name'] ?? user.displayName ?? 'User').toString();

            final email =
            (data['email'] ?? user.email ?? '').toString();

            final phone = (data['phone'] ?? '').toString();

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('meals')
                  .snapshots(),
              builder: (context, mealsSnapshot) {
                if (mealsSnapshot.hasError) {
                  return const Center(
                    child: Text('Could not load your meal statistics.'),
                  );
                }

                if (!mealsSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final meals = mealsSnapshot.data!.docs;

                // Calculate total emissions.
                double totalEmissions = 0;

                for (final meal in meals) {
                  final emissions = meal.data()['totalEmissionsKg'];

                  if (emissions is num) {
                    totalEmissions += emissions.toDouble();
                  }
                }

                final totalMeals = meals.length;

                // Sort meals by date, newest first.
                final sortedMeals = [...meals];

                sortedMeals.sort((a, b) {
                  final aDate = a.data()['createdAt'];
                  final bDate = b.data()['createdAt'];

                  final aTime = aDate is Timestamp
                      ? aDate.toDate()
                      : DateTime.fromMillisecondsSinceEpoch(0);

                  final bTime = bDate is Timestamp
                      ? bDate.toDate()
                      : DateTime.fromMillisecondsSinceEpoch(0);

                  return bTime.compareTo(aTime);
                });

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      children: [
                        // CONCITO LOGO
                        SvgPicture.asset(
                          'assets/images/concitologo.svg',
                          height: 38,
                        ),

                        const SizedBox(height: 12),



                        const SizedBox(height: 24),

                        const Text(
                          'My Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 34,
                            color: _brown,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // PROFILE PICTURE
                        Builder(
                          builder: (context) {
                            Uint8List? imageBytes;

                            final savedImage = data['profileImage'];

                            if (savedImage is String && savedImage.isNotEmpty) {
                              try {
                                imageBytes = base64Decode(savedImage);
                              } catch (_) {
                                imageBytes = null;
                              }
                            }

                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFDCE8DE),
                              backgroundImage: imageBytes != null
                                  ? MemoryImage(imageBytes)
                                  : null,
                              child: imageBytes == null
                                  ? const Icon(
                                Icons.person,
                                size: 60,
                                color: _forest,
                              )
                                  : null,
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: _brown,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),

                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            phone,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        Center(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfilePage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Profile'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _forest,
                              side: const BorderSide(color: _forest),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // MY RECIPES
                        // MY RECIPES
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('recipes')
                              .snapshots(),
                          builder: (context, recipeSnapshot) {
                            if (recipeSnapshot.hasError) {
                              return _infoCard(
                                icon: Icons.menu_book_outlined,
                                title: 'My Recipes',
                                value: 'Unavailable',
                              );
                            }

                            final recipeCount = recipeSnapshot.data?.docs.length ?? 0;

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyRecipesPage(),
                                  ),
                                );
                              },
                              child: _infoCard(
                                icon: Icons.menu_book_outlined,
                                title: 'My Recipes',
                                value: recipeSnapshot.hasData
                                    ? '$recipeCount saved  →'
                                    : 'Loading...',
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // TOTAL CO2 EMISSIONS
                        _infoCard(
                          icon: Icons.eco_outlined,
                          title: 'Total CO₂ Emissions',
                          value:
                          '${totalEmissions.toStringAsFixed(2)} kg',
                        ),

                        const SizedBox(height: 16),

                        // TOTAL MEALS TRACKED
                        _infoCard(
                          icon: Icons.restaurant_outlined,
                          title: 'Meals Tracked',
                          value: '$totalMeals meals',
                        ),

                        const SizedBox(height: 32),

                        // STATISTICS SECTION
                        const Text(
                          'My CO₂ Statistics',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 26,
                            color: _brown,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Your estimated food-related emissions '
                              'over the last 7 days.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 20),

                        _statisticsChart(meals),

                        const SizedBox(height: 32),

                        // RECENT MEALS
                        const Text(
                          'Recent Meals',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 26,
                            color: _brown,
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (sortedMeals.isEmpty)
                          const Text(
                            'No meals tracked yet. '
                                'Visit the calculator to track your first meal!',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          )
                        else
                          ...sortedMeals.take(5).map((meal) {
                            final mealData = meal.data();

                            final mealName =
                            (mealData['name'] ?? 'Tracked Meal')
                                .toString();

                            final emissions =
                            mealData['totalEmissionsKg'];

                            final emissionsValue = emissions is num
                                ? emissions.toDouble()
                                : 0.0;

                            final timestamp = mealData['createdAt'];

                            String date = 'Date unavailable';

                            if (timestamp is Timestamp) {
                              final d = timestamp.toDate();

                              date =
                              '${d.day}/${d.month}/${d.year}';
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE0D9CF),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.restaurant_menu,
                                    color: _forest,
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mealName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _brown,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          date,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${emissionsValue.toStringAsFixed(2)} kg',
                                        style: const TextStyle(
                                          color: _forest,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      IconButton(
                                        tooltip: 'Delete meal',
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 22,
                                        ),
                                        onPressed: () async {
                                          final shouldDelete = await showDialog<bool>(
                                            context: context,
                                            builder: (dialogContext) => AlertDialog(
                                              title: const Text('Delete Meal'),
                                              content: const Text(
                                                'Are you sure you want to delete this meal? '
                                                    'Its CO₂ emissions will be removed from your statistics.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(dialogContext, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(dialogContext, true),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (shouldDelete != true || !context.mounted) return;

                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user.uid)
                                                .collection('meals')
                                                .doc(meal.id)
                                                .delete();

                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Meal deleted successfully!'),
                                                backgroundColor: _forest,
                                              ),
                                            );
                                          } catch (e) {
                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Could not delete meal: $e'),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 38),

                        // LOG OUT
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _forest,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // INFORMATION CARD
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0D9CF),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _forest,
            size: 30,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                color: _brown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // CO2 STATISTICS CHART
  Widget _statisticsChart(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> meals,
      ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final List<double> dailyEmissions =
    List.filled(7, 0.0);

    // Calculate emissions for each of the last 7 days.
    for (final meal in meals) {
      final data = meal.data();

      final timestamp = data['createdAt'];
      final emissions = data['totalEmissionsKg'];

      if (timestamp is! Timestamp || emissions is! num) {
        continue;
      }

      final date = timestamp.toDate();

      final mealDay = DateTime(
        date.year,
        date.month,
        date.day,
      );

      final difference = today.difference(mealDay).inDays;

      if (difference >= 0 && difference < 7) {
        dailyEmissions[6 - difference] +=
            emissions.toDouble();
      }
    }

    double maxEmissions = 0;

    for (final value in dailyEmissions) {
      if (value > maxEmissions) {
        maxEmissions = value;
      }
    }

    final dayLabels = List.generate(7, (index) {
      final date = today.subtract(
        Duration(days: 6 - index),
      );

      return '${date.day}/${date.month}';
    });

    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Last 7 Days',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _brown,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final emissions = dailyEmissions[index];

                final heightFactor = maxEmissions > 0
                    ? emissions / maxEmissions
                    : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          emissions.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            color: _brown,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          height: 115 * heightFactor,
                          decoration: BoxDecoration(
                            color: _forest,
                            borderRadius:
                            BorderRadius.circular(5),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          dayLabels[index],
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          const Center(
            child: Text(
              'Estimated emissions (kg CO₂e)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}