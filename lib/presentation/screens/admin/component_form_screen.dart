import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/component.dart';
import 'admin_dashboard_screen.dart';

class ComponentFormScreen extends ConsumerStatefulWidget {
  final Component? component;

  const ComponentFormScreen({super.key, this.component});

  @override
  ConsumerState<ComponentFormScreen> createState() => _ComponentFormScreenState();
}

class _ComponentFormScreenState extends ConsumerState<ComponentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _productIdController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

  String _selectedCategory = 'cpu';
  String _availabilityStatus = 'in_stock';
  bool _isFeatured = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'cpu',
    'gpu',
    'ram',
    'storage',
    'motherboard',
    'psu',
    'case',
    'cooler',
  ];

  final List<String> _availabilityOptions = [
    'in_stock',
    'out_of_stock',
    'pre_order',
    'discontinued',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.component?.name ?? '');
    _brandController = TextEditingController(text: widget.component?.brand ?? '');
    _productIdController = TextEditingController(text: widget.component?.productId ?? '');
    _priceController = TextEditingController(
      text: widget.component?.priceBdt?.toStringAsFixed(0) ?? '',
    );
    _imageUrlController = TextEditingController(text: widget.component?.imageUrl ?? '');

    if (widget.component != null) {
      _selectedCategory = widget.component!.category;
      _availabilityStatus = widget.component!.availabilityStatus ?? 'in_stock';
      _isFeatured = widget.component!.featured ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _productIdController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.component != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Component' : 'Add Component'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Component Name *',
                  hintText: 'e.g., AMD Ryzen 9 7950X',
                  prefixIcon: const Icon(Icons.label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter component name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Product ID Field
              TextFormField(
                controller: _productIdController,
                decoration: InputDecoration(
                  labelText: 'Product ID / SKU *',
                  hintText: 'e.g., amd-ryzen-9-7950x',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product ID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Brand Field
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Brand *',
                  hintText: 'e.g., AMD, Intel, NVIDIA',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter brand name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),

              const SizedBox(height: 16),

              // Price Field
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Price (BDT) *',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: '৳ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Availability Status Dropdown
              DropdownButtonFormField<String>(
                value: _availabilityStatus,
                decoration: InputDecoration(
                  labelText: 'Availability Status',
                  prefixIcon: const Icon(Icons.inventory),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _availabilityOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_formatStatus(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _availabilityStatus = value!);
                },
              ),

              const SizedBox(height: 16),

              // Image URL Field
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: const Icon(Icons.image),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Featured Toggle
              Card(
                elevation: 2,
                child: SwitchListTile(
                  title: const Text('Featured Component'),
                  subtitle: const Text('Show in featured section'),
                  value: _isFeatured,
                  onChanged: (value) {
                    setState(() => _isFeatured = value);
                  },
                  secondary: const Icon(Icons.star),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'Update Component' : 'Create Component',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              if (isEditing) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(adminRepositoryProvider);

      final componentData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'product_id': _productIdController.text.trim(),
        'brand_name': _brandController.text.trim(),
        'category': _selectedCategory,
        'lowest_price_bdt': double.parse(_priceController.text.trim()),
        'availability_status': _availabilityStatus,
        'featured': _isFeatured,
      };

      if (_imageUrlController.text.trim().isNotEmpty) {
        componentData['primary_image_url'] = _imageUrlController.text.trim();
      }

      if (isEditing) {
        // Update existing component
        await repository.updateComponent(widget.component!.id, componentData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Component updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        // Create new component
        await repository.createComponent(componentData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Component created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${isEditing ? 'update' : 'create'} component: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
