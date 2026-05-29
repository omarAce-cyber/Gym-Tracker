import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class MealFormScreen extends ConsumerStatefulWidget {
  const MealFormScreen({super.key});

  @override
  ConsumerState<MealFormScreen> createState() => _MealFormScreenState();
}

class _MealFormScreenState extends ConsumerState<MealFormScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _proteinController.addListener(_recalculateCalories);
    _carbsController.addListener(_recalculateCalories);
    _fatController.addListener(_recalculateCalories);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _recalculateCalories() {
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final calories = (protein * 4) + (carbs * 4) + (fat * 9);
    _caloriesController.text = calories.toStringAsFixed(0);
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      final documents = await getApplicationDocumentsDirectory();
      final targetPath = p.join(documents.path, 'meal_${_uuid.v4()}${p.extension(file.path)}');
      final copied = await File(file.path).copy(targetPath);
      setState(() => _imagePath = copied.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر اختيار الصورة')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final user = await ref.read(currentUserProvider.future);
    await ref.read(nutritionRepositoryProvider).createMeal(
          MealModel(
            userId: user.id!,
            name: _nameController.text.trim(),
            imagePath: _imagePath,
            weightInGram: double.parse(_weightController.text),
            protein: double.parse(_proteinController.text),
            carbs: double.parse(_carbsController.text),
            fat: double.parse(_fatController.text),
            calories: double.parse(_caloriesController.text),
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          ),
        );
    ref.invalidate(mealsProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة وجبة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم الوجبة', border: OutlineInputBorder()),
              validator: (v) => (v?.trim().isNotEmpty ?? false) ? null : 'مطلوب',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'الوزن الأساسي (غرام)', border: OutlineInputBorder()),
              validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0 ? null : 'أدخل قيمة صحيحة',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _proteinController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'البروتين (غ)', border: OutlineInputBorder()),
              validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'أدخل قيمة صحيحة',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _carbsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'الكارب (غ)', border: OutlineInputBorder()),
              validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'أدخل قيمة صحيحة',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'الدهون (غ)', border: OutlineInputBorder()),
              validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'أدخل قيمة صحيحة',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _caloriesController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'السعرات (محسوبة تلقائيًا)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('اختيار صورة من المعرض'),
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(_imagePath!), height: 140, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
