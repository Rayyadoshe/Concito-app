import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'saved_recipes_store.dart';

const _cream = Color(0xFFFBF7EF);
const _green = Color(0xFF165B45);
const _brown = Color(0xFF45291F);

class CreateRecipePage extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  final double totalEmissionsKg;

  const CreateRecipePage({
    super.key,
    required this.ingredients,
    required this.totalEmissionsKg,
  });

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _photo;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 700,
        maxHeight: 700,
        imageQuality: 50,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      if (bytes.lengthInBytes > 500000) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please choose a smaller photo (under 500 KB).'),
        ));
        return;
      }
      setState(() => _photo = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not access the photo: $e'),
      ));
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe name.')),
      );
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    final recipe = <String, dynamic>{
      'id': 'user_${DateTime.now().microsecondsSinceEpoch}',
      'name': name,
      'description': _descriptionController.text.trim(),
      'servings': 1,
      'prepTimeMinutes': null,
      'image': _photo == null ? '' : 'data:image/jpeg;base64,${base64Encode(_photo!)}',
      'ingredients': widget.ingredients,
      'instructions': <String>[],
      'totalEmissionsKg': widget.totalEmissionsKg,
      'emissionsPerServingKg': widget.totalEmissionsKg,
      'isUserRecipe': true,
    };
    try {
      await SavedRecipesStore.instance.add(recipe);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save recipe: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        title: const Text('Create recipe', style: TextStyle(color: _brown)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.fingerprint, color: Color(0xFF609B56), size: 34),
                SizedBox(width: 10),
                SizedBox(height: 36, child: VerticalDivider(color: Colors.black26)),
                SizedBox(width: 10),
                Text('CONCITO', style: TextStyle(
                  fontSize: 32, letterSpacing: 2.4, fontWeight: FontWeight.w600,
                )),
              ]),
              const SizedBox(height: 28),
              const Text('Create recipe', textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Georgia', fontSize: 29, color: _brown)),
              const SizedBox(height: 18),
              const _SectionLabel('Recipe name'),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                maxLength: 50,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g. Tomato pasta...',
                  counterText: '',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffix: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nameController,
                    builder: (_, value, __) => Text('${value.text.length}/50'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Add a photo (optional)'),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => _choosePhoto(ImageSource.gallery),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2DCCC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _brown, style: BorderStyle.solid),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _photo != null
                      ? Image.memory(_photo!, fit: BoxFit.cover)
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.image_outlined, size: 46, color: Colors.black87),
                    SizedBox(height: 8),
                    Text('Add a photo from your gallery'),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _choosePhoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take photo', style: TextStyle(fontSize: 12)),
                )),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _choosePhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Add from gallery', style: TextStyle(fontSize: 12)),
                )),
              ]),
              if (_photo != null)
                TextButton.icon(
                  onPressed: () => setState(() => _photo = null),
                  icon: const Icon(Icons.close),
                  label: const Text('Remove photo'),
                ),
              const SizedBox(height: 16),
              const _SectionLabel('Add description (optional)'),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLength: 500,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Write a short description...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(height: 44, child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _saving
                    ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save recipe'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(color: _green, fontSize: 21));
}
