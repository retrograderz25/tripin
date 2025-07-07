// lib/widgets/add_location_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plan_provider.dart';
import '../models/location_item.dart';

class AddLocationForm extends StatefulWidget {
  final LocationItem? existingLocation;
  const AddLocationForm({super.key, this.existingLocation});

  @override
  State<AddLocationForm> createState() => _AddLocationFormState();
}

class _AddLocationFormState extends State<AddLocationForm> {
  // A GlobalKey to identify our form and help with validation.
  final _formKey = GlobalKey<FormState>();

  // Controllers to read the text from the input fields.
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _urlController = TextEditingController();
  final _costController = TextEditingController();

  // A variable to hold the selected category.
  ItemCategory _selectedCategory = ItemCategory.sightseeing;

  @override
  void initState() {
    super.initState();
    // Nếu có dữ liệu sửa (chế độ Edit)
    if (widget.existingLocation != null) {
      final location = widget.existingLocation!;
      // Điền dữ liệu cũ vào các controller
      _nameController.text = location.name;
      _addressController.text = location.address;
      _urlController.text = location.referenceUrl;
      _costController.text = location.estimatedCost.toString();
      _selectedCategory = location.category;
    }
  }

  // Clean up the controllers when the widget is disposed.
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _urlController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submitData() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final provider = Provider.of<PlanProvider>(context, listen: false);
    final enteredCost = double.tryParse(_costController.text) ?? 0.0;

    // Kiểm tra xem đây là chế độ Sửa hay Thêm mới
    if (widget.existingLocation != null) {
      // --- LOGIC CẬP NHẬT ---
      final updatedLocation = LocationItem(
        id: widget.existingLocation!.id, // Dùng lại ID cũ
        name: _nameController.text,
        address: _addressController.text,
        category: _selectedCategory,
        referenceUrl: _urlController.text,
        estimatedCost: enteredCost,
      );
      provider.updateLocation(updatedLocation);
    } else {
      // --- LOGIC THÊM MỚI (như cũ) ---
      final newLocation = LocationItem(
        id: DateTime.now().toIso8601String(),
        name: _nameController.text,
        address: _addressController.text,
        category: _selectedCategory,
        referenceUrl: _urlController.text,
        estimatedCost: enteredCost,
      );
      provider.addLocation(newLocation);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingLocation != null;

    // We wrap our form in a Padding to avoid the keyboard covering the inputs.
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        // This makes sure the form is above the on-screen keyboard.
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  isEditing ? 'Sửa địa điểm' : 'Thêm địa điểm mới',
                  style: Theme.of(context).textTheme.headlineSmall
              ),
              const SizedBox(height: 20),

              // Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên địa điểm *'),
                // This is our validation logic.
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên địa điểm.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Address Input
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
              ),
              const SizedBox(height: 12),

              // Category Dropdown
              DropdownButtonFormField<ItemCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Phân loại'),
                items: ItemCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Reference URL Input
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Link tham khảo (Google Maps, etc.)'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              // Estimated Cost Input
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Chi phí ước tính (VNĐ)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.lightBlueAccent,
                ),
                  child: Text(isEditing ? 'Lưu thay đổi' : 'Lưu địa điểm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}