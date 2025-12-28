import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// AppColors removed - using theme
import '../../../core/services/build_templates_service.dart';
import '../../../data/models/build_template.dart';
import '../../widgets/template_card.dart';

/// Screen for selecting a build template
class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  final BuildTemplatesService _templatesService = BuildTemplatesService();
  BuildTemplate? _selectedTemplate;
  BuildTemplateCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = _selectedCategory == null
        ? _templatesService.getAllTemplates()
        : _templatesService.getTemplatesByCategory(_selectedCategory!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Build Template'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start with a Template',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a pre-configured template based on your needs, or skip to start from scratch',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Category filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    label: 'Gaming',
                    icon: Icons.sports_esports,
                    category: BuildTemplateCategory.gaming,
                    isSelected: _selectedCategory == BuildTemplateCategory.gaming,
                    onTap: () {
                      setState(() {
                        _selectedCategory = BuildTemplateCategory.gaming;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    label: 'Enthusiast',
                    icon: Icons.rocket_launch,
                    category: BuildTemplateCategory.enthusiast,
                    isSelected:
                        _selectedCategory == BuildTemplateCategory.enthusiast,
                    onTap: () {
                      setState(() {
                        _selectedCategory = BuildTemplateCategory.enthusiast;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    label: 'Workstation',
                    icon: Icons.work,
                    category: BuildTemplateCategory.workstation,
                    isSelected:
                        _selectedCategory == BuildTemplateCategory.workstation,
                    onTap: () {
                      setState(() {
                        _selectedCategory = BuildTemplateCategory.workstation;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    label: 'Office',
                    icon: Icons.business,
                    category: BuildTemplateCategory.office,
                    isSelected: _selectedCategory == BuildTemplateCategory.office,
                    onTap: () {
                      setState(() {
                        _selectedCategory = BuildTemplateCategory.office;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    label: 'Budget',
                    icon: Icons.savings,
                    category: BuildTemplateCategory.budget,
                    isSelected: _selectedCategory == BuildTemplateCategory.budget,
                    onTap: () {
                      setState(() {
                        _selectedCategory = BuildTemplateCategory.budget;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Templates list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TemplateCard(
                    template: template,
                    isSelected: _selectedTemplate?.id == template.id,
                    onTap: () {
                      setState(() {
                        _selectedTemplate = template;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Return null to indicate "start from scratch"
                        context.pop(null);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Start from Scratch'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedTemplate == null
                          ? null
                          : () {
                              // Return selected template
                              context.pop(_selectedTemplate);
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Use Template'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    IconData? icon,
    BuildTemplateCategory? category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
        ),
      ),
    );
  }
}
