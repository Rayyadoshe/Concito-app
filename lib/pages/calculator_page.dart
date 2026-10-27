

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'create_recipe_page.dart';
import '../calculator_product_selection.dart';


// Provisional ingredient-impact thresholds, based on the entered grams.
// These are prototype labels, not official Concito categories.
String impactGroup(double emissionsPerKg, double grams) {
if (!emissionsPerKg.isFinite || emissionsPerKg <= 0 || grams <= 0) {
return 'Unclassified';
}
final impact = emissionsPerKg * grams / 1000;
if (impact > 0.50) return 'Red';
if (impact > 0.15) return 'Yellow';
return 'Green';
}

Color impactColor(String group) {
switch (group) {
case 'Red': return const Color(0xFFB42318);
case 'Yellow': return const Color(0xFF936200);
case 'Green': return const Color(0xFF247A45);
default: return const Color(0xFF64748B);
}
}

Color impactBackground(String group) {
switch (group) {
case 'Red': return const Color(0xFFFFEBE9);
case 'Yellow': return const Color(0xFFFFF4D2);
case 'Green': return const Color(0xFFE3F2E7);
default: return const Color(0xFFEDF0F3);
}
}

// Suggestions curated by dish type from the existing products.json.
// These are culinary ideas, NOT verified nutritional equivalents.
const Map<String, List<String>> lowerEmissionSwaps = {
"Beef, fillet, defatted, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Beef, T-bone steak, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Average beef": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Veal, medium fat, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Roastbeef, sliced": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Beef, topside, cap off, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Beef, rump, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pulled beef": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Kebab": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Beef, low fat": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Beef, mince, 5-10% fat, raw": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Sausage, beef salami": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Beef, mince, 10-15% fat, raw": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Beef, mince, 15-20% fat, raw": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Lamb, leg, unspecified , raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Lamb, meat, average values, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Minced lamb": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Chili con carne, ready meals": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Turtle, fake, average values, ready meals": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Veal and pork, mince, 15-20% fat, raw": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Minced meat, spaghetti sauce type, average values, ready meals": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Potato hotchpotch, beef, ready meals": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Meat balls, average values": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Meat balls, canned": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Meat balls, frozen": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Potato hotchpotch, mixed meat, ready meals": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Lasagne, beef, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Cod, liver, canned": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Prawn, giant tiger, aquaculture, boiled, frozen": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Shrimps, canned": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Crab claws, meat, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Shrimps, boiled, shell removed": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Shrimp, boiled, in brine": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Bream, raw": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Pork, tenderloin, trimmed, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Burbot, raw": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Whitefish, raw": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Minced chicken": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Charr, raw": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Lobster, canned": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Bacon, frying, raw": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Chicken, breast, flesh and skin, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pepperoni": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Sausage, salami": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Chorizo, sliced": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Spring rolls, beef, ready meals": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Chicken, grilled, fast food": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Chicken, breast, boiled, sliced": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Turkey, flesh only, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pork, loin, lean, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Turkey, mince, 5-10% fat, raw": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Chicken nuggets, deepfried, ready meals": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Herring, pickled, canned": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Turkey, breast, boiled/smoked, sliced": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pork in curry sauce, frozen, ready meals": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pulled pork": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pork, collar, defatted, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Average pork": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pork, ham, topside (M. Semimembranosus), lean, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pork, collar with rind, raw": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pizza with meat, tomato and cheese, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Pork, liver paste, Danish": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Cod, roe, canned": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Crab, boiled": ["Tofu, soy bean curd", "Chickpeas, canned", "Oyster mushroom"],
"Pork, ham, boiled, sliced": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pork, saddle, smoked, boiled": ["Tofu, soy bean curd", "Vegan pulled beans", "Black beans", "Chickpeas, canned"],
"Pizza with meat and seafood, tomato and cheese, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Rice noodles": ["Pasta, raw", "Bulgur, parboiled, raw"],
"Pizza with seafood, tomato and cheese, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Spring rolls, chicken, ready meals": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Spring roll, deepfried, ready meals": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Spring roll, frozen, ready meals": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Spring rolls, vegetables, ready meals": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Pizza with salami, tomato and cheese, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Pancakes, ready meals": ["Oats, rolled, not enriched"],
"Pizza Romana, frozen, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Meatballs in curry with rice and curry sauce, ready meals": ["Vegan pulled beans", "Tofu, soy bean curd", "Vegan balls, soy based", "Black beans"],
"Pizza with broccoli, frozen, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Pizza with vegetables, fruit, tomato and cheese, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Pizza with tuna, frozen, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Pizza Napolitana, frozen, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Pizza with tomato and cheese, ready meals": ["Pizza dough", "Pizzasauce", "Mushroom, raw", "Tofu, soy bean curd"],
"Sushi, ready meals": ["Tofu, soy bean curd", "Cucumber, raw", "Carrot, raw"],
"Leek pie with bacon, ready meals": ["Pizza dough", "Mushroom, raw"],
"Lasagne, vegan, ready meals": ["Pizza dough", "Mushroom, raw"],
"Lasagne, vegetarian, ready meals": ["Pizza dough", "Mushroom, raw"],
};

class CalculatorPage extends StatefulWidget {
const CalculatorPage({super.key});

@override
State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
List<Map<String, dynamic>> products = [];
bool loading = true;
Map<String, dynamic>? selectedProduct;
final List<Map<String, dynamic>> mealIngredients = [];
final TextEditingController gramsController = TextEditingController();
double? calculatedEmissions;

double get totalMealEmissions => mealIngredients.fold<double>(
0,
(total, item) => total + (item['emissions'] as num).toDouble(),
);

@override
void initState() {
super.initState();
calculatorProductSelection.addListener(_receiveProduct);
loadProducts();
WidgetsBinding.instance.addPostFrameCallback((_) => _receiveProduct());
}

Future<void> loadProducts() async {
try {
final raw = await rootBundle.loadString('assets/products.json');
final decoded = (jsonDecode(raw) as List)
    .cast<Map<String, dynamic>>();
if (!mounted) return;
setState(() {
products = decoded;
loading = false;
});
} catch (e) {
if (!mounted) return;
setState(() => loading = false);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Could not load products: $e')),
);
}
}

void _receiveProduct() {
final product = calculatorProductSelection.value;
if (product == null || !mounted) return;
calculatorProductSelection.value = null;
setState(() {
selectedProduct = product;
gramsController.clear();
calculatedEmissions = null;
});
}

Future<void> selectIngredient() async {
if (loading) return;
final result = await showSearch<Map<String, dynamic>?>(
context: context,
delegate: IngredientSearchDelegate(products),
);
if (!mounted || result == null) return;
setState(() {
selectedProduct = result;
gramsController.clear();
calculatedEmissions = null;
});
}

void calculateEmissions() {
if (selectedProduct == null) return;
final grams = double.tryParse(
gramsController.text.trim().replaceAll(',', '.'),
);
final emissions = selectedProduct!['totalEmissions'];
if (grams == null ||
!grams.isFinite ||
grams <= 0 ||
emissions is! num ||
!emissions.toDouble().isFinite ||
emissions.toDouble() <= 0) {
setState(() => calculatedEmissions = null);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Enter a valid quantity and select a product with emissions data.',
),
),
);
return;
}
setState(() {
calculatedEmissions = (grams / 1000) * emissions.toDouble();
});
}

void addIngredientToMeal() {
if (selectedProduct == null || calculatedEmissions == null) return;
final grams = double.tryParse(
gramsController.text.trim().replaceAll(',', '.'),
);
if (grams == null || !grams.isFinite || grams <= 0) return;
setState(() {
mealIngredients.add({
'product': selectedProduct,
'grams': grams,
'emissions': calculatedEmissions,
});
selectedProduct = null;
calculatedEmissions = null;
gramsController.clear();
});
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Ingredient added to meal!')),
);
}

Future<void> saveMealAsRecipe() async {
if (mealIngredients.isEmpty) return;
final ingredients = mealIngredients.map((item) {
final product = item['product'] as Map<String, dynamic>;
return <String, dynamic>{
'productId': (product['id'] ?? '').toString(),
'productName': (product['name'] ?? '').toString(),
'grams': item['grams'],
'emissionsKg': item['emissions'],
};
}).toList();

final saved = await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (_) => CreateRecipePage(
ingredients: ingredients,
totalEmissionsKg: totalMealEmissions,
),
),
);
if (!mounted) return;
if (saved == true) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Recipe saved! Find it in Recipes.')),
);
}
}

Future<void> showSwaps(int index) async {
final item = mealIngredients[index];
final original = item['product'] as Map<String, dynamic>;
final name = original['name'].toString();
final grams = (item['grams'] as num).toDouble();
final originalImpact = (item['emissions'] as num).toDouble();
final candidateNames = lowerEmissionSwaps[name] ?? const <String>[];
final candidates = candidateNames
    .map((candidateName) {
for (final product in products) {
if (product['name'] == candidateName) return product;
}
return null;
})
    .whereType<Map<String, dynamic>>()
    .where((candidate) => candidate['totalEmissions'] is num &&
(candidate['totalEmissions'] as num).toDouble() > 0 &&
(candidate['totalEmissions'] as num).toDouble() * grams / 1000 < originalImpact)
    .toList();
if (!mounted) return;
final selected = await showModalBottomSheet<Map<String, dynamic>>(
context: context,
isScrollControlled: true,
showDragHandle: true,
builder: (context) => SafeArea(
child: Padding(
padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Lower-emission alternatives',
style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
Text('For $name · ${grams.toStringAsFixed(0)} g'),
const SizedBox(height: 8),
const Text('Suggestions are culinary alternatives, not nutritionally equivalent. '
'The same grams are used for comparison; adjust the amount after swapping.'),
const SizedBox(height: 12),
if (candidates.isEmpty)
const Padding(
padding: EdgeInsets.symmetric(vertical: 20),
child: Text('No suitable alternative is available yet for this product.'),
),
...candidates.map((candidate) {
final impact = (candidate['totalEmissions'] as num).toDouble() * grams / 1000;
return ListTile(
contentPadding: EdgeInsets.zero,
title: Text(candidate['name'].toString()),
subtitle: Text('${impact.toStringAsFixed(3)} kg CO₂-eq for ${grams.toStringAsFixed(0)} g'),
trailing: const Icon(Icons.swap_horiz),
onTap: () => Navigator.pop(context, candidate),
);
}),
],
),
),
),
);
if (!mounted || selected == null || index >= mealIngredients.length) return;
final newImpact = (selected['totalEmissions'] as num).toDouble() * grams / 1000;
setState(() {
mealIngredients[index] = {
'product': selected,
'grams': grams,
'emissions': newImpact,
};
});
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Swapped ingredient. Estimated reduction: '
'${(originalImpact - newImpact).toStringAsFixed(3)} kg CO₂-eq.')),
);
}

Widget impactCard(double impact, double grams, double perKg) {
final group = impactGroup(perKg, grams);
return Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
decoration: BoxDecoration(
color: impactBackground(group),
borderRadius: BorderRadius.circular(12),
),
child: Row(mainAxisSize: MainAxisSize.min, children: [
Icon(Icons.circle, size: 12, color: impactColor(group)),
const SizedBox(width: 8),
Text('$group impact · ${impact.toStringAsFixed(3)} kg CO₂-eq',
style: TextStyle(color: impactColor(group), fontWeight: FontWeight.w600)),
]),
);
}

void removeIngredient(int index) {
setState(() => mealIngredients.removeAt(index));
}

@override
void dispose() {
calculatorProductSelection.removeListener(_receiveProduct);
gramsController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Meal Calculator'),
centerTitle: true,
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Calculate your meal emissions',
style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
),
const SizedBox(height: 12),
const Text(
'Add ingredients and their quantities to '
'calculate the carbon footprint of your meal.',
style: TextStyle(fontSize: 16),
),
const SizedBox(height: 30),
const Center(
child: Icon(
Icons.restaurant_menu,
size: 80,
color: Color(0xFF165B45),
),
),
const SizedBox(height: 24),
ElevatedButton.icon(
onPressed: loading ? null : selectIngredient,
icon: const Icon(Icons.add),
label: const Text('Add ingredient'),
),
const SizedBox(height: 20),
if (selectedProduct != null)
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Selected: ${selectedProduct!['name']}',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 20),
TextField(
controller: gramsController,
keyboardType: const TextInputType.numberWithOptions(
decimal: true,
),
decoration: const InputDecoration(
labelText: 'Quantity in grams',
hintText: 'e.g. 250',
border: OutlineInputBorder(),
suffixText: 'g',
),
onChanged: (_) {
setState(() => calculatedEmissions = null);
},
),
const SizedBox(height: 16),
ElevatedButton(
onPressed: calculateEmissions,
child: const Text('Calculate CO₂'),
),
if (calculatedEmissions != null) ...[
const SizedBox(height: 24),
Text(
'Ingredient emissions: '
'${calculatedEmissions!.toStringAsFixed(3)} kg CO₂-eq',
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Color(0xFF165B45),
),
),
const SizedBox(height: 12),
impactCard(
calculatedEmissions!,
double.tryParse(gramsController.text.trim().replaceAll(',', '.')) ?? 0,
(selectedProduct!['totalEmissions'] as num).toDouble(),
),
const SizedBox(height: 16),
ElevatedButton.icon(
onPressed: addIngredientToMeal,
icon: const Icon(Icons.add_circle_outline),
label: const Text('Add to meal'),
),
],
],
),
const SizedBox(height: 28),
Text(
'Your Meal',
style: Theme.of(context).textTheme.titleLarge?.copyWith(
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
if (mealIngredients.isEmpty)
const Text('Your meal is currently empty.')
else ...[
for (int index = 0; index < mealIngredients.length; index++)
Builder(builder: (context) {
final item = mealIngredients[index];
final product = item['product'] as Map<String, dynamic>;
final grams = (item['grams'] as num).toDouble();
final emissions = (item['emissions'] as num).toDouble();
final perKg = (product['totalEmissions'] as num).toDouble();
final group = impactGroup(perKg, grams);
return Card(
color: Colors.white,
margin: const EdgeInsets.only(bottom: 10),
child: Padding(
padding: const EdgeInsets.all(12),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(children: [
Expanded(child: Text(product['name'].toString(),
style: const TextStyle(fontWeight: FontWeight.w600))),
IconButton(
tooltip: 'Remove ingredient',
icon: const Icon(Icons.delete_outline),
onPressed: () => removeIngredient(index),
),
]),
Text('${grams.toStringAsFixed(0)} g'),
const SizedBox(height: 8),
impactCard(emissions, grams, perKg),
if (group == 'Red') ...[
const SizedBox(height: 8),
OutlinedButton.icon(
onPressed: () => showSwaps(index),
icon: const Icon(Icons.swap_horiz),
label: const Text('Swap'),
),
],
],
),
),
);
}),
const SizedBox(height: 12),
SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
onPressed: saveMealAsRecipe,
icon: const Icon(Icons.bookmark_add_outlined),
label: const Text('Save as Recipe'),
),
),
const SizedBox(height: 12),
Card(
color: const Color(0xFFE6F2EB),
child: Padding(
padding: const EdgeInsets.all(18),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Total meal emissions',
style: TextStyle(fontWeight: FontWeight.w600),
),
const SizedBox(height: 8),
Text(
'${totalMealEmissions.toStringAsFixed(3)} kg CO₂-eq',
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Color(0xFF165B45),
),
),
],
),
),
),
],
],
),
),
);
}
}

class IngredientSearchDelegate
extends SearchDelegate<Map<String, dynamic>?> {
final List<Map<String, dynamic>> products;

IngredientSearchDelegate(this.products);

@override
List<Widget> buildActions(BuildContext context) {
return [
IconButton(
icon: const Icon(Icons.clear),
onPressed: () => query = '',
),
];
}

@override
Widget buildLeading(BuildContext context) {
return IconButton(
icon: const Icon(Icons.arrow_back),
onPressed: () => close(context, null),
);
}

@override
Widget buildResults(BuildContext context) => buildProductList();

@override
Widget buildSuggestions(BuildContext context) => buildProductList();

Widget buildProductList() {
final filtered = products.where((product) {
final name = (product['name'] ?? '').toString().toLowerCase();
return name.contains(query.toLowerCase());
}).toList();

return ListView.builder(
itemCount: filtered.length,
itemBuilder: (context, index) {
final product = filtered[index];
return ListTile(
title: Text((product['name'] ?? '').toString()),
subtitle: Text((product['category'] ?? '').toString()),
trailing: const Icon(Icons.add_circle_outline),
onTap: () => close(context, product),
);
},
);
}
}
