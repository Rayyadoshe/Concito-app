
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'pages/main_navigation.dart';
import 'product_impact_groups.dart';

const _cream = Color(0xFFFCF7EF);
const _forest = Color(0xFF165B45);
const _brown = Color(0xFF40261E);

void main() => runApp(const EcoTrackerApp());

class EcoTrackerApp extends StatelessWidget {
const EcoTrackerApp({super.key});

@override
Widget build(BuildContext context) => MaterialApp(
title: 'EcoTracker',
debugShowCheckedModeBanner: false,
theme: ThemeData(
colorScheme: ColorScheme.fromSeed(seedColor: _forest),
scaffoldBackgroundColor: _cream,
useMaterial3: true,
),
home: const MainNavigation(),
);
}

class ProductPage extends StatefulWidget {
final ValueChanged<Map<String, dynamic>>? onAddToCalculator;
const ProductPage({super.key, this.onAddToCalculator});

@override
State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
final TextEditingController _searchController = TextEditingController();
List<Map<String, dynamic>> products = [];
String search = '';
String? selectedCategory;
bool loading = true;

@override
void initState() {
super.initState();
loadProducts();
}

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

Future<void> loadProducts() async {
try {
final raw = await rootBundle.loadString('assets/products.json');
final decoded = (jsonDecode(raw) as List)
    .map((item) => Map<String, dynamic>.from(item as Map))
    .toList();
if (mounted) setState(() { products = decoded; loading = false; });
} catch (e) {
if (!mounted) return;
setState(() => loading = false);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Could not load products: $e')),
);
}
}

void _reset() {
_searchController.clear();
setState(() { search = ''; selectedCategory = null; });
}

// Fixed category-specific photographs. Images require an internet connection.
// If a photo cannot load, a matching icon is shown instead.
String _categoryPhoto(String name) {
final c = name.toLowerCase();
if (c.contains('beverage')) return 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600&fit=crop';
if (c.contains('bread') || c.contains('bakery')) return 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&fit=crop';
if (c.contains('candy') || c.contains('sugar')) return 'https://images.unsplash.com/photo-1499195333224-3ce974eecb47?w=600&fit=crop';
if (c.contains('cereal') || c.contains('grain') || c.contains('pulse')) return 'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=600&fit=crop';
if (c.contains('fruit') && c.contains('vegetable')) return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&fit=crop';
if (c.contains('fruit')) return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&fit=crop';
if (c.contains('vegetable')) return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&fit=crop';
if (c.contains('meat') || c.contains('poultry')) return 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&fit=crop';
if (c.contains('milk') || c.contains('egg')) return 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=600&fit=crop';
if (c.contains('oil') || c.contains('fat')) return 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=600&fit=crop';
if (c.contains('seafood') || c.contains('fish')) return 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&fit=crop';
if (c.contains('seasoning') || c.contains('spice')) return 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=600&fit=crop';
if (c.contains('prepared')) return 'https://images.unsplash.com/photo-1547592180-85f173990554?w=600&fit=crop';
return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&fit=crop';
}

IconData _categoryIcon(String name) {
final c = name.toLowerCase();
if (c.contains('beverage')) return Icons.local_drink;
if (c.contains('bread') || c.contains('bakery')) return Icons.bakery_dining;
if (c.contains('candy') || c.contains('sugar')) return Icons.cake;
if (c.contains('grain') || c.contains('cereal')) return Icons.grass;
if (c.contains('fruit')) return Icons.apple;
if (c.contains('vegetable')) return Icons.eco;
if (c.contains('meat') || c.contains('poultry')) return Icons.restaurant;
if (c.contains('milk') || c.contains('egg')) return Icons.egg;
if (c.contains('oil') || c.contains('fat')) return Icons.water_drop;
if (c.contains('fish') || c.contains('seafood')) return Icons.set_meal;
return Icons.restaurant_menu;
}

Widget _brandHeader() => Padding(
padding: const EdgeInsets.only(top: 17, bottom: 18),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
SvgPicture.asset('assets/images/concitologo.svg',
width: 36, height: 36),
const SizedBox(width: 12),
Container(width: 1, height: 35, color: const Color(0xFFD2CBC2)),
const SizedBox(width: 12),
const Text('CONCITO',
style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600,
letterSpacing: 2.5, color: Color(0xFF1F1E1C))),
],
),
);

Widget _searchBar() => Row(
children: [
Expanded(
child: Container(
decoration: BoxDecoration(
color: const Color(0xFFF7F4EF),
borderRadius: BorderRadius.circular(30),
border: Border.all(color: const Color(0xFFD8D2C9)),
),
child: TextField(
controller: _searchController,
onChanged: (value) => setState(() => search = value),
decoration: const InputDecoration(
hintText: 'Search',
prefixIcon: Icon(Icons.search, color: Color(0xFF222222)),
border: InputBorder.none,
contentPadding: EdgeInsets.symmetric(vertical: 14),
),
),
),
),
const SizedBox(width: 8),
IconButton.outlined(
tooltip: selectedCategory != null ? 'Back to categories' : 'Clear search',
onPressed: _reset,
icon: Icon(selectedCategory != null ? Icons.arrow_back : Icons.close),
style: IconButton.styleFrom(
backgroundColor: const Color(0xFFF7F4EF),
side: const BorderSide(color: Color(0xFFD8D2C9)),
minimumSize: const Size(48, 48),
),
),
],
);

Color _impactColor(Map<String, dynamic> product) {
switch (productImpactById[(product['idRa'] ?? '').toString()]) {
case 'Green':
return const Color(0xFFD7F2D6);
case 'Yellow':
return const Color(0xFFFFF29B);
case 'Red':
return const Color(0xFFFF918B);
default:
return const Color(0xFFE9E7E2);
}
}

String _impactLabel(Map<String, dynamic> product) =>
productImpactById[(product['idRa'] ?? '').toString()] ?? 'Unclassified';

Widget _productCard(Map<String, dynamic> product) {
final name = (product['name'] ?? '').toString();
final category = (product['category'] ?? '').toString();
final impact = _impactLabel(product);
final emissions = product['totalEmissions'];
return Padding(
padding: const EdgeInsets.only(bottom: 12),
child: Material(
color: _impactColor(product),
elevation: 3,
shadowColor: Colors.black26,
borderRadius: BorderRadius.circular(19),
clipBehavior: Clip.antiAlias,
child: InkWell(
onTap: () => Navigator.push(
context,
MaterialPageRoute(builder: (_) => ProductDetails(
product: product, onAddToCalculator: widget.onAddToCalculator)),
),
child: SizedBox(
height: 91,
child: Padding(
padding: const EdgeInsets.all(10),
child: Row(
children: [
ClipRRect(
borderRadius: BorderRadius.circular(13),
child: Container(
height: 70,
width: 78,
color: Colors.white,
child: Image.network(
_categoryPhoto(category),
fit: BoxFit.cover,
errorBuilder: (_, __, ___) => Icon(
_categoryIcon(category), color: _forest, size: 35,
),
),
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(name.toUpperCase(),
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: _forest, fontSize: 12.5,
fontWeight: FontWeight.w500, height: 1.25,
),
),
Text(category,
maxLines: 1, overflow: TextOverflow.ellipsis,
style: const TextStyle(fontSize: 12, color: _brown),
),
],
),
),
const SizedBox(width: 5),
SizedBox(
width: 72,
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
emissions is num ? emissions.toStringAsFixed(2) : 'N/A',
style: const TextStyle(
fontSize: 21, color: _forest,
fontWeight: FontWeight.w600,
),
),
const Text('kg CO₂-eq/kg',
textAlign: TextAlign.center,
style: TextStyle(fontSize: 9, color: _brown),
),
Text(impact,
style: const TextStyle(fontSize: 9, color: _brown),
),
],
),
),
const Icon(Icons.chevron_right, color: Colors.black, size: 26),
],
),
),
),
),
),
);
}

Widget _categoryTile(String name) => InkWell(
onTap: () {
_searchController.clear();
setState(() { selectedCategory = name; search = ''; });
},
borderRadius: BorderRadius.circular(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
AspectRatio(
aspectRatio: 1.23,
child: ClipRRect(
borderRadius: BorderRadius.circular(20),
child: Image.network(
_categoryPhoto(name),
fit: BoxFit.cover,
errorBuilder: (_, __, ___) => Container(
color: const Color(0xFFEAE6DC),
alignment: Alignment.center,
child: Icon(_categoryIcon(name), size: 54, color: _forest),
),
),
),
),
const SizedBox(height: 8),
Text(name.toUpperCase(),
maxLines: 3,
overflow: TextOverflow.ellipsis,
style: const TextStyle(fontSize: 14, height: 1.28,
fontWeight: FontWeight.w500, color: Colors.black)),
],
),
);

@override
Widget build(BuildContext context) {
final categories = products
    .map((p) => (p['category'] ?? '').toString())
    .where((c) => c.isNotEmpty)
    .toSet().toList()..sort();
final searching = search.trim().isNotEmpty;
final showProducts = selectedCategory != null || searching;
final visible = products.where((p) {
final categoryMatch = selectedCategory == null || p['category'] == selectedCategory;
final searchMatch = (p['name'] ?? '').toString().toLowerCase()
    .contains(search.trim().toLowerCase());
return categoryMatch && searchMatch;
}).toList();

return Scaffold(
backgroundColor: _cream,
body: SafeArea(
child: Column(
children: [
Padding(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: Column(
children: [_brandHeader(), _searchBar()],
),
),
const SizedBox(height: 8),
Expanded(
child: loading
? const Center(child: CircularProgressIndicator())
    : !showProducts
? Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
const Padding(
padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
child: Text('Product Categories',
style: TextStyle(fontFamily: 'Georgia',
fontSize: 29, fontWeight: FontWeight.w600,
color: _brown)),
),
Expanded(
child: GridView.builder(
padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 20,
mainAxisSpacing: 22,
childAspectRatio: 0.83,
),
itemCount: categories.length,
itemBuilder: (context, index) => _categoryTile(categories[index]),
),
),
],
)
    : Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
child: Center(child: Text((selectedCategory ?? 'Search results').toUpperCase(),
style: const TextStyle(fontFamily: 'Georgia',
fontSize: 27, color: _forest))),
),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: Text('${visible.length} products',
style: const TextStyle(color: Colors.black54)),
),
const SizedBox(height: 8),
Expanded(
child: visible.isEmpty
? const Center(child: Text('No products found.'))
    : ListView.builder(
padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
itemCount: visible.length,
itemBuilder: (context, index) =>
_productCard(visible[index]),
),
),
const Padding(
padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
child: Text(
'Card colors reflect estimated typical cooking portions, not 1 kg. '
'Gray means emissions data needs verification. '
'These are provisional categories, not official CONCITO ratings.',
textAlign: TextAlign.center,
style: TextStyle(fontSize: 10, color: Colors.black54),
),
),
],
),
),
],
),
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
final ValueChanged<Map<String, dynamic>>? onAddToCalculator;
const ProductDetails({super.key, required this.product, this.onAddToCalculator});

String get _group => productImpactById[(product['idRa'] ?? '').toString()] ?? 'Unclassified';
Color get _groupColor => switch (_group) {
'Red' => const Color(0xFFFF4949),
'Yellow' => const Color(0xFFFFDB65),
'Green' => const Color(0xFF8BD9A4),
_ => const Color(0xFFD3D1CD),
};
String get _groupText => switch (_group) {
'Red' => 'High', 'Yellow' => 'Medium', 'Green' => 'Low', _ => 'Unknown',
};

String _display(dynamic value) {
if (value is num && value.isFinite) return value.toStringAsFixed(2);
return 'N/A';
}

IconData _icon(String category) {
final c = category.toLowerCase();
if (c.contains('fruit')) return Icons.apple;
if (c.contains('vegetable')) return Icons.eco;
if (c.contains('meat')) return Icons.restaurant;
if (c.contains('bread')) return Icons.bakery_dining;
if (c.contains('milk') || c.contains('egg')) return Icons.egg;
return Icons.restaurant_menu;
}

String _categoryPhoto(String category) {
final c = category.toLowerCase();
if (c.contains('fruit')) return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=700&fit=crop';
if (c.contains('vegetable')) return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=700&fit=crop';
if (c.contains('meat')) return 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=700&fit=crop';
if (c.contains('bread')) return 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=700&fit=crop';
if (c.contains('beverage')) return 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=700&fit=crop';
return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&fit=crop';
}

@override
Widget build(BuildContext context) {
final name = (product['name'] ?? '').toString();
final category = (product['category'] ?? '').toString();
final fields = <String, String>{
'Agriculture': 'agriculture',
'iLUC': 'iluc',
'Food processing': 'foodProcessing',
'Packaging': 'packaging',
'Transport': 'transport',
'Retail': 'retail',
};
return Scaffold(
backgroundColor: _cream,
body: SafeArea(
child: ListView(
padding: const EdgeInsets.fromLTRB(26, 16, 26, 35),
children: [
Row(mainAxisAlignment: MainAxisAlignment.center, children: [
SvgPicture.asset('assets/images/concitologo.svg', width: 30, height: 30),
const SizedBox(width: 10),
Container(width: 1, height: 32, color: const Color(0xFFD2CBC2)),
const SizedBox(width: 10),
const Text('CONCITO', style: TextStyle(fontSize: 29, letterSpacing: 2.2,
fontWeight: FontWeight.w600, color: Colors.black87)),
]),
const SizedBox(height: 22),
Align(alignment: Alignment.centerLeft, child: TextButton.icon(
onPressed: () => Navigator.pop(context),
icon: const Icon(Icons.arrow_back_ios_new, size: 16),
label: const Text('Back'),
style: TextButton.styleFrom(foregroundColor: _brown,
padding: EdgeInsets.zero),
)),
const SizedBox(height: 14),
Text(name, style: const TextStyle(fontFamily: 'Georgia', fontSize: 25,
color: _brown)),
Text(category, style: const TextStyle(color: _forest, fontSize: 17)),
const SizedBox(height: 10),
Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
Expanded(flex: 3, child: ClipRRect(
borderRadius: BorderRadius.circular(24),
child: AspectRatio(aspectRatio: 1.12, child: Container(
color: Colors.white,
child: Image.network(_categoryPhoto(category), fit: BoxFit.cover,
errorBuilder: (_, __, ___) => Center(child: Icon(_icon(category),
size: 70, color: _forest))),
)),
)),
const SizedBox(width: 8),
Expanded(flex: 1, child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
child: Text(_display(product['totalEmissions']),
style: const TextStyle(fontSize: 29, color: Colors.black))),
const Text('kg CO₂e / kg', style: TextStyle(fontSize: 10)),
const SizedBox(height: 9),
Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 5),
color: _groupColor, child: Text(_groupText,
textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
],
)),
]),
const SizedBox(height: 28),
Center(child: ElevatedButton.icon(
onPressed: onAddToCalculator == null ? null : () {
onAddToCalculator!(product);
Navigator.pop(context);
},
icon: const Icon(Icons.add, size: 20),
label: const Text('Add to calculator'),
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFFFFBE6B),
foregroundColor: Colors.black,
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
),
)),
const SizedBox(height: 46),
const Text('OVERVIEW', style: TextStyle(color: _forest, fontSize: 23)),
const SizedBox(height: 7),
for (final entry in fields.entries)
Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
child: Column(children: [
Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
Text(entry.key, style: const TextStyle(color: Colors.black54, fontSize: 12)),
Text(_display(product[entry.value]),
style: const TextStyle(color: Colors.black54, fontSize: 12)),
]),
const SizedBox(height: 5),
const Divider(height: 1, thickness: 0.7, color: Colors.black54),
]),
),
const SizedBox(height: 15),
const Text('Overview values are kg CO₂-eq per kg. Impact color is based on an estimated typical portion; it is not an official CONCITO rating.',
style: TextStyle(color: Colors.black54, fontSize: 11)),
],
),
),
);
}
}

