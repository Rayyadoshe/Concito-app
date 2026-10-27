
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'saved_recipes_store.dart';

const _cream = Color(0xFFFBF7EF);
const _green = Color(0xFF165B45);
const _brown = Color(0xFF45291F);

class RecipesPage extends StatefulWidget {
const RecipesPage({super.key});

@override
State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
static const _favoritesKey = 'concito_favorite_recipe_ids_v1';
final TextEditingController _searchController = TextEditingController();
List<Map<String, dynamic>> recipes = [];
Set<String> favorites = {};
bool loading = true;
bool showFavoritesOnly = false;
String? error;

@override
void initState() {
super.initState();
_load();
SavedRecipesStore.instance.load();
}

Future<void> _load() async {
try {
final raw = await rootBundle.loadString('assets/recipes.json');
final decoded = (jsonDecode(raw) as List)
    .map((item) => Map<String, dynamic>.from(item as Map))
    .toList();
final prefs = await SharedPreferences.getInstance();
if (!mounted) return;
setState(() {
recipes = decoded;
favorites = prefs.getStringList(_favoritesKey)?.toSet() ?? {};
loading = false;
error = null;
});
} catch (e) {
if (!mounted) return;
setState(() {
loading = false;
error = 'Could not load recipes: $e';
});
}
}

String _recipeId(Map<String, dynamic> recipe) {
final explicitId = recipe['id'];
if (explicitId != null && explicitId.toString().isNotEmpty) {
return 'id:$explicitId';
}
// Recipe names are used as stable keys when no ID is available.
return 'name:${(recipe['name'] ?? '').toString().trim().toLowerCase()}';
}

Future<void> _toggleFavorite(Map<String, dynamic> recipe) async {
final id = _recipeId(recipe);
setState(() {
if (!favorites.add(id)) favorites.remove(id);
});
final prefs = await SharedPreferences.getInstance();
await prefs.setStringList(_favoritesKey, favorites.toList()..sort());
}

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return ValueListenableBuilder<List<Map<String, dynamic>>>(
valueListenable: SavedRecipesStore.instance.recipes,
builder: (context, savedRecipes, _) {
final allRecipes = [...savedRecipes, ...recipes];
final term = _searchController.text.trim().toLowerCase();
final visible = allRecipes.where((recipe) {
final matchesSearch =
(recipe['name'] ?? '').toString().toLowerCase().contains(term) ||
(recipe['description'] ?? '').toString().toLowerCase().contains(term);
return matchesSearch &&
(!showFavoritesOnly || favorites.contains(_recipeId(recipe)));
}).toList();

return Scaffold(
backgroundColor: _cream,
body: SafeArea(
child: Column(
children: [
Padding(
padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.fingerprint, color: Color(0xFF609B56), size: 33),
const SizedBox(width: 9),
Container(height: 34, width: 1, color: Colors.black26),
const SizedBox(width: 10),
const Text('CONCITO', style: TextStyle(
fontSize: 32, letterSpacing: 2.5,
fontWeight: FontWeight.w600, color: Color(0xFF1D1D1D),
)),
],
),
const SizedBox(height: 22),
Row(
children: [
Expanded(
child: Container(
height: 48,
decoration: BoxDecoration(
color: const Color(0xFFF4F1EA),
borderRadius: BorderRadius.circular(30),
border: Border.all(color: const Color(0xFFE4E0D7)),
),
child: TextField(
controller: _searchController,
onChanged: (_) => setState(() {}),
decoration: const InputDecoration(
hintText: 'Search',
prefixIcon: Icon(Icons.search, color: Colors.black87),
border: InputBorder.none,
contentPadding: EdgeInsets.symmetric(vertical: 13),
),
),
),
),
const SizedBox(width: 8),
_roundIconButton(
icon: Icons.close,
tooltip: 'Clear search and filters',
onTap: () => setState(() {
_searchController.clear();
showFavoritesOnly = false;
}),
),
const SizedBox(width: 6),
IconButton(
tooltip: showFavoritesOnly ? 'Show all recipes' : 'Show favorites only',
onPressed: () => setState(() => showFavoritesOnly = !showFavoritesOnly),
icon: Icon(Icons.filter_list,
color: showFavoritesOnly ? _green : Colors.black87,
size: 30),
),
],
),
const SizedBox(height: 21),
const Text('Recipes', style: TextStyle(
fontFamily: 'Georgia', fontSize: 34, color: _brown,
)),
const SizedBox(height: 17),
],
),
),
Expanded(
child: loading
? const Center(child: CircularProgressIndicator())
    : error != null
? Center(child: Padding(
padding: const EdgeInsets.all(20),
child: Text(error!, textAlign: TextAlign.center)))
    : visible.isEmpty
? Center(child: Text(showFavoritesOnly
? 'No favorite recipes yet.'
    : 'No recipes found.'))
    : ListView.builder(
padding: const EdgeInsets.fromLTRB(12, 0, 12, 22),
itemCount: visible.length,
itemBuilder: (context, index) {
final recipe = visible[index];
return _recipeCard(recipe);
},
),
),
],
),
),
);
},
);
}

Widget _roundIconButton({
required IconData icon,
required String tooltip,
required VoidCallback onTap,
}) {
return Container(
width: 46,
height: 46,
decoration: BoxDecoration(
border: Border.all(color: const Color(0xFFE4E0D7)),
borderRadius: BorderRadius.circular(28),
),
child: IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onTap),
);
}

Widget _recipeCard(Map<String, dynamic> recipe) {
final name = (recipe['name'] ?? '').toString();
final imagePath = (recipe['image'] ?? '').toString();
final isFavorite = favorites.contains(_recipeId(recipe));

return Container(
margin: const EdgeInsets.only(bottom: 12),
decoration: BoxDecoration(
color: _cream,
borderRadius: BorderRadius.circular(23),
border: Border.all(color: const Color(0xFFECE6DD)),
boxShadow: const [BoxShadow(
color: Color(0x26000000), blurRadius: 6, offset: Offset(0, 3),
)],
),
child: InkWell(
borderRadius: BorderRadius.circular(23),
onTap: () => Navigator.push(context, MaterialPageRoute(
builder: (_) => RecipeDetailsPage(
recipe: recipe,
isFavorite: isFavorite,
onToggleFavorite: () => _toggleFavorite(recipe),
),
)),
child: Padding(
padding: const EdgeInsets.all(9),
child: SizedBox(
height: 119,
child: Row(
children: [
ClipRRect(
borderRadius: BorderRadius.circular(19),
child: SizedBox(
width: 116,
height: 119,
child: imagePath.isEmpty
? const Icon(Icons.restaurant, size: 44, color: _green)
    : recipeImage(imagePath, fit: BoxFit.cover,
errorBuilder: (_, __, ___) => const Center(
child: Icon(Icons.restaurant, size: 44, color: _green))),
),
),
const SizedBox(width: 11),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(child: Padding(
padding: const EdgeInsets.only(top: 4),
child: Text(name.toUpperCase(),
maxLines: 2, overflow: TextOverflow.ellipsis,
style: const TextStyle(fontSize: 15, height: 1.2,
color: _green, fontWeight: FontWeight.w500)),
)),
const Text('Per serving',
style: TextStyle(fontSize: 13, color: _brown)),
Text('${_formatKgShort(recipe['emissionsPerServingKg'])} kg CO₂e',
style: const TextStyle(fontSize: 19, color: _green,
fontWeight: FontWeight.w700)),
const SizedBox(height: 3),
],
),
),
SizedBox(
width: 35,
child: Column(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
IconButton(
padding: EdgeInsets.zero,
constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
tooltip: isFavorite ? 'Remove from favorites' : 'Save to favorites',
onPressed: () => _toggleFavorite(recipe),
icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
size: 26,
color: isFavorite ? const Color(0xFFFF641C) : Colors.black),
),
const Padding(
padding: EdgeInsets.only(bottom: 6),
child: Icon(Icons.arrow_forward, size: 23),
),
],
),
),
],
),
),
),
),
);
}
}

String _formatKg(dynamic value) {
if (value is num) return value.toStringAsFixed(3);
return 'N/A';
}

String _formatKgShort(dynamic value) {
if (value is num) return value.toStringAsFixed(1);
return 'N/A';
}

class RecipeDetailsPage extends StatefulWidget {
final Map<String, dynamic> recipe;
final bool isFavorite;
final VoidCallback? onToggleFavorite;

const RecipeDetailsPage({
super.key,
required this.recipe,
this.isFavorite = false,
this.onToggleFavorite,
});

@override
State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
bool ingredientsExpanded = true;
bool instructionsExpanded = true;
late bool isFavorite;

@override
void initState() {
super.initState();
isFavorite = widget.isFavorite;
}

Widget _brand() => Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
SvgPicture.asset('assets/images/concitologo.svg',
width: 30, height: 30),
const SizedBox(width: 9),
Container(height: 30, width: 1, color: const Color(0xFFCDC7BD)),
const SizedBox(width: 9),
const Text('CONCITO', style: TextStyle(
color: Color(0xFF1D1D1D), fontSize: 29,
fontWeight: FontWeight.w600, letterSpacing: 2.2)),
],
);

String _quantity(dynamic grams) {
if (grams == null) return '—';
if (grams is num) return '${grams.toStringAsFixed(grams % 1 == 0 ? 0 : 1)} g';
return grams.toString();
}

String _ingredientName(dynamic ingredient) {
if (ingredient is Map) {
return (ingredient['productName'] ?? ingredient['name'] ?? 'Ingredient').toString();
}
return ingredient.toString();
}

Widget _sectionHeader(String title, bool expanded, VoidCallback toggle) =>
InkWell(
onTap: toggle,
child: Padding(
padding: const EdgeInsets.symmetric(vertical: 12),
child: Row(children: [
Expanded(child: Text(title, style: const TextStyle(
color: _green, fontSize: 21, fontWeight: FontWeight.w500))),
Icon(expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
color: Colors.black87),
]),
),
);

@override
Widget build(BuildContext context) {
final recipe = widget.recipe;
final ingredients = recipe['ingredients'] as List? ?? [];
final instructions = recipe['instructions'] as List? ?? [];
final imagePath = (recipe['image'] ?? '').toString();
final servings = recipe['servings'];
final total = recipe['totalEmissionsKg'];
final perServing = recipe['emissionsPerServingKg'];
final description = (recipe['description'] ?? '').toString();

return Scaffold(
backgroundColor: _cream,
body: SafeArea(
child: Column(children: [
Padding(
padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
child: _brand(),
),
const SizedBox(height: 13),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20),
child: Row(children: [
TextButton.icon(
onPressed: () => Navigator.pop(context),
icon: const Icon(Icons.arrow_back_ios_new, size: 17),
label: const Text('Back'),
style: TextButton.styleFrom(foregroundColor: _brown,
padding: EdgeInsets.zero),
),
const Spacer(),
IconButton(
tooltip: isFavorite ? 'Remove from favorites' : 'Save to favorites',
onPressed: widget.onToggleFavorite == null ? null : () {
widget.onToggleFavorite!();
setState(() => isFavorite = !isFavorite);
},
icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
size: 30,
color: isFavorite ? const Color(0xFFFF641C) : Colors.black),
),
]),
),
Expanded(child: ListView(
padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
children: [
Text((recipe['name'] ?? '').toString(),
textAlign: TextAlign.center,
style: const TextStyle(fontFamily: 'Georgia', fontSize: 26,
color: _brown)),
const SizedBox(height: 20),
Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
Expanded(flex: 3, child: ClipRRect(
borderRadius: BorderRadius.circular(20),
child: SizedBox(height: 155, child: imagePath.isEmpty
? Container(color: const Color(0xFFEAE5DA),
child: const Icon(Icons.restaurant, size: 48, color: _green))
    : recipeImage(imagePath, fit: BoxFit.cover,
width: double.infinity, height: 155,
errorBuilder: (_, __, ___) => Container(
color: const Color(0xFFEAE5DA),
child: const Icon(Icons.restaurant, size: 48, color: _green))))),
),
const SizedBox(width: 12),
Expanded(flex: 2, child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
if (recipe['prepTimeMinutes'] != null) ...[
Row(children: [
const Icon(Icons.access_time, size: 20),
const SizedBox(width: 7),
Flexible(child: Text('${recipe['prepTimeMinutes']} min',
style: const TextStyle(fontSize: 13))),
]),
const SizedBox(height: 10),
],
if (servings != null) Row(children: [
const Icon(Icons.people, size: 20),
const SizedBox(width: 7),
Flexible(child: Text('$servings servings',
style: const TextStyle(fontSize: 13))),
]),
],
)),
]),
if (description.isNotEmpty) ...[
const SizedBox(height: 12),
Text(description, style: const TextStyle(color: _brown, fontSize: 13)),
],
const SizedBox(height: 16),
_sectionHeader('INGREDIENTS', ingredientsExpanded,
() => setState(() => ingredientsExpanded = !ingredientsExpanded)),
if (ingredientsExpanded) ...[
Row(children: const [
Expanded(flex: 5, child: SizedBox()),
Expanded(flex: 2, child: Text('Amount',
style: TextStyle(fontSize: 10, color: _green))),
Expanded(flex: 3, child: Text('Estimated kg CO₂',
style: TextStyle(fontSize: 10, color: _green))),
]),
const SizedBox(height: 5),
if (ingredients.isEmpty)
const Text('No ingredients were recorded for this recipe.',
style: TextStyle(fontSize: 13)),
for (final item in ingredients)
Padding(
padding: const EdgeInsets.symmetric(vertical: 3),
child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
Expanded(flex: 5, child: Text(_ingredientName(item),
style: const TextStyle(fontSize: 12,
fontWeight: FontWeight.w600))),
Expanded(flex: 2, child: Text(
item is Map ? _quantity(item['grams'] ?? item['amount']) : '—',
style: const TextStyle(fontSize: 12))),
Expanded(flex: 3, child: Text(
item is Map ? _formatKg(item['emissionsKg']) : 'N/A',
style: const TextStyle(fontSize: 12))),
]),
),
const SizedBox(height: 9),
Row(children: [
const Expanded(flex: 5, child: Text('TOTAL',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
Expanded(flex: 2, child: Text(
servings == null ? '—' : '$servings servings',
style: const TextStyle(fontSize: 11))),
Expanded(flex: 3, child: Text(
total is num ? '${_formatKg(total)} kg CO₂e' : 'N/A',
style: const TextStyle(color: _green, fontSize: 12,
decoration: TextDecoration.underline))),
]),
if (perServing is num) Padding(
padding: const EdgeInsets.only(top: 7),
child: Text('${_formatKg(perServing)} kg CO₂e per serving',
textAlign: TextAlign.right,
style: const TextStyle(color: _green, fontSize: 12)),
),
],
const SizedBox(height: 20),
_sectionHeader('INSTRUCTIONS', instructionsExpanded,
() => setState(() => instructionsExpanded = !instructionsExpanded)),
if (instructionsExpanded) ...[
if (instructions.isEmpty)
const Text('No instructions have been added for this recipe.',
style: TextStyle(fontSize: 13)),
for (var i = 0; i < instructions.length; i++)
Padding(
padding: const EdgeInsets.only(bottom: 6),
child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
SizedBox(width: 25, child: Text('${i + 1}.',
style: const TextStyle(fontSize: 13))),
Expanded(child: Text(instructions[i].toString(),
style: const TextStyle(fontSize: 13, height: 1.35))),
]),
),
],
const SizedBox(height: 20),
const Text('Emissions are estimates based on listed ingredients; '
'cooking energy and unlisted seasonings are excluded.',
style: TextStyle(fontSize: 10, color: Colors.black54)),
],
)),
]),
),
);
}
}

// Displays both bundled recipe photos and photos chosen in Create Recipe.
Widget recipeImage(String path, {BoxFit fit = BoxFit.cover,
double? height, double? width, ImageErrorWidgetBuilder? errorBuilder}) {
if (path.startsWith('data:image/') && path.contains('base64,')) {
try {
final Uint8List bytes = base64Decode(path.split('base64,').last);
return Image.memory(bytes, fit: fit, height: height, width: width,
errorBuilder: errorBuilder);
} catch (_) {
return const Center(child: Icon(Icons.restaurant, size: 44));
}
}
return Image.asset(path, fit: fit, height: height, width: width,
errorBuilder: errorBuilder);
}
