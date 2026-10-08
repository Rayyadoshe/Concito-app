
import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // Temporary data until we connect the real database.
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Red pepper',
      'category': 'Vegetables',
      'co2': 1.07,
      'image': 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=300',
    },
    {
      'name': 'Tomato',
      'category': 'Vegetables',
      'co2': 0.48,
      'image': 'https://images.unsplash.com/photo-1546470427-e5b89b618f96?w=300',
    },
    {
      'name': 'Squash',
      'category': 'Vegetables',
      'co2': 0.84,
      'image': 'https://images.unsplash.com/photo-1506806732259-39c2d0268443?w=300',
    },
    {
      'name': 'Aubergine',
      'category': 'Vegetables',
      'co2': 0.91,
      'image': 'https://images.unsplash.com/photo-1659261200833-ec8761558af7?w=300',
    },
    {
      'name': 'Cucumber',
      'category': 'Vegetables',
      'co2': 0.40,
      'image': 'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?w=300',
    },
    {
      'name': 'Apple',
      'category': 'Fruits',
      'co2': 0.50,
      'image': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=300',
    },
    {
      'name': 'Beef',
      'category': 'Meat',
      'co2': 30.00,
      'image': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300',
    },
  ];

  String searchQuery = '';
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Meat',
    'Dairy',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      final matchesSearch = product['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesCategory =
          selectedCategory == 'All' ||
              product['category'] == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF7),
        title: const Text(
          'EcoTracker',
          style: TextStyle(
            color: Color(0xFF14543F),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories.map((category) {
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: const Color(0xFF14543F),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Product cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return Card(
                  color: Colors.white,
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // Product image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            product['image'],
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 85,
                                height: 85,
                                color: const Color(0xFFEAF2ED),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Color(0xFF14543F),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Product information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product['category'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CO2 information
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              (product['co2'] as num)
                                  .toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF14543F),
                              ),
                            ),
                            const Text(
                              'kg CO₂-eq/kg',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),

                        const SizedBox(width: 5),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
