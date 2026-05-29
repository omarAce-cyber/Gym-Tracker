import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/features/profile/data/models/user_model.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, this.user});

  final UserModel? user;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  String _goal = 'BuildMuscle';
  bool _saving = false;

  static const _goalOptions = [
    ('BuildMuscle', 'بناء العضلات'),
    ('LoseWeight', 'خسارة الوزن'),
    ('Maintain', 'الحفاظ على الوزن'),
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u?.name ?? '');
    _weightController = TextEditingController(
      text: u?.weight != null ? u!.weight.toString() : '',
    );
    _heightController = TextEditingController(
      text: u?.height != null ? u!.height.toString() : '',
    );
    _goal = u?.goal ?? 'BuildMuscle';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repo = ref.read(profileRepositoryProvider);
    final now = DateTime.now().toIso8601String();
    final double? weight = _weightController.text.isEmpty
        ? null
        : double.tryParse(_weightController.text);
    final double? height = _heightController.text.isEmpty
        ? null
        : double.tryParse(_heightController.text);

    final user = UserModel(
      id: widget.user?.id,
      name: _nameController.text.trim(),
      weight: weight,
      height: height,
      goal: _goal,
      createdAt: widget.user?.createdAt ?? now,
    );

    if (widget.user == null) {
      await repo.createUser(user);
    } else {
      await repo.updateUser(user);
    }

    ref.invalidate(usersProvider);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'إنشاء ملف شخصي' : 'تعديل الملف الشخصي'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textDirection: TextDirection.rtl,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'الوزن (كجم)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                if (double.tryParse(value) == null) return 'أدخل رقمًا صحيحًا';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'الطول (سم)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                if (double.tryParse(value) == null) return 'أدخل رقمًا صحيحًا';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _goal,
              decoration: const InputDecoration(
                labelText: 'الهدف',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: _goalOptions
                  .map(
                    (option) => DropdownMenuItem(
                      value: option.$1,
                      child: Text(option.$2),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _goal = value);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
