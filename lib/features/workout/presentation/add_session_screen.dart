import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/utils/date_utils.dart';
import 'package:gym_tracker/features/workout/data/models/workout_session_model.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

class AddSessionScreen extends ConsumerStatefulWidget {
  const AddSessionScreen({super.key, required this.userId, this.session});

  final int userId;
  final WorkoutSessionModel? session;

  @override
  ConsumerState<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends ConsumerState<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late final TextEditingController _notesController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _selectedDate = s != null ? AppDateUtils.parseDate(s.date) : DateTime.now();
    _notesController = TextEditingController(text: s?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repo = ref.read(workoutRepositoryProvider);
    final session = WorkoutSessionModel(
      id: widget.session?.id,
      userId: widget.userId,
      date: AppDateUtils.formatDate(_selectedDate),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (widget.session == null) {
      await repo.createWorkoutSession(session);
    } else {
      await repo.updateWorkoutSession(session);
    }

    ref.invalidate(workoutSessionsProvider);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session == null ? 'إضافة جلسة' : 'تعديل الجلسة'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('تاريخ الجلسة'),
              subtitle: Text(AppDateUtils.formatDate(_selectedDate)),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('تغيير'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              textDirection: TextDirection.rtl,
              maxLines: 3,
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
