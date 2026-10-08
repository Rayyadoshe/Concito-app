
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(const EcoTrackerApp());

class EcoTrackerApp extends StatelessWidget {
  const EcoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF165B45),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF7),
        useMaterial3: true,
      ),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> products = [];
  String search = '';
  String category = 'All';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final raw = await rootBundle.loadString('assets/products.json');
      final decoded =
      (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

      if (mounted) {
        setState(() {
          products = decoded;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load products: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      ...{
        for (final p in products)
          (p['category'] ?? '').toString()
      }..remove(''),
    ];

    categories.sort(
          (a, b) => a == 'All'
          ? -1
          : b == 'All'
          ? 1
          : a.compareTo(b),
    );

    final visible = products.where((p) {
      final matchesCategory =
          category == 'All' || p['category'] == category;

      final matchesSearch = (p['name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(search.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoTracker'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search for products...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) {
                setState(() => search = v);
              },
            ),
          ),

          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final c in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) {
                        setState(() => category = c);
                      },
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${visible.length} products',
                style:
                Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final p = visible[i];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  color: Colors.white,
                  child: ListTile(
                    // Concito logo as the product fallback image
                    leading: Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F2EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/concitologo.svg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),

                    title: Text(
                      (p['name'] ?? '').toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    subtitle: Text(
                      (p['category'] ?? '').toString(),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            Text(
                              _value(p['totalEmissions']),
                              style: const TextStyle(
                                color: Color(0xFF165B45),
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const Text(
                              'kg CO₂-eq/kg',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right),
                      ],
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetails(product: p),
                        ),
                      );
                    },
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

String _value(dynamic v) {
  if (v == null) return 'Not available';
  if (v is num) return v.toStringAsFixed(2);
  return v.toString();
}

class ProductDetails extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetails({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final fields = <String, String>{
      'Agriculture (kg CO₂-eq/kg)': 'agriculture',
      'iLUC (kg CO₂-eq/kg)': 'iluc',
      'Food processing (kg CO₂-eq/kg)': 'foodProcessing',
      'Packaging (kg CO₂-eq/kg)': 'packaging',
      'Transport (kg CO₂-eq/kg)': 'transport',
      'Retail (kg CO₂-eq/kg)': 'retail',
      'Energy (kJ/100 g)': 'energy',
      'Fat (g/100 g)': 'fat',
      'Carbohydrate (g/100 g)': 'carbohydrate',
      'Protein (g/100 g)': 'protein',
      'Dataset ID': 'idRa',
      'Food ID': 'idFood',
      'Packaging ID': 'idPack',
      'Retail ID': 'idRetail',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            (product['name'] ?? '').toString(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 6),

          Text(
            (product['category'] ?? '').toString(),
          ),

          const SizedBox(height: 18),

          Card(
            color: const Color(0xFFE6F2EB),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Text('Total emissions'),
                  Text(
                    _value(product['totalEmissions']),
                    style: const TextStyle(
                      fontSize: 34,
                      color: Color(0xFF165B45),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('kg CO₂-eq/kg'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Additional information',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          ...fields.entries.map((entry) {
            final value = product[entry.value];

            final displayValue = value is num
                ? _value(value)
                : (value?.toString().isNotEmpty == true
                ? value.toString()
                : 'Not available');

            return ListTile(
              dense: true,
              title: Text(entry.key),
              trailing: Text(displayValue),
            );
          }),
        ],
      ),
    );
  }
}
