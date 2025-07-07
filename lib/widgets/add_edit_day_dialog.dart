// lib/widgets/add_edit_day_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/daily_plan.dart';
import '../providers/plan_provider.dart';

class AddEditDayDialog extends StatefulWidget {
  // Nhận vào một DailyPlan có sẵn nếu là chế độ Sửa
  final DailyPlan? dailyPlan;

  const AddEditDayDialog({super.key, this.dailyPlan});

  @override
  State<AddEditDayDialog> createState() => _AddEditDayDialogState();
}

class _AddEditDayDialogState extends State<AddEditDayDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _selectedDate;

  bool get isEditing => widget.dailyPlan != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.dailyPlan?.title ?? '');
    _selectedDate = widget.dailyPlan?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<PlanProvider>();
      if (isEditing) {
        // TODO: Implement update logic in provider
      } else {
        provider.addDailyPlan(_selectedDate, _titleController.text);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Sửa ngày' : 'Thêm ngày mới'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề cho ngày *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Chọn ngày'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Lưu' : 'Thêm'),
        ),
      ],
    );
  }
}