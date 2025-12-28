import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/compatibility_service.dart';
import '../../../core/services/budget_service.dart';
import '../../../core/services/build_templates_service.dart';
import '../../../data/models/build.dart';
import '../../../data/models/component.dart';
import '../../../data/models/build_template.dart';
import '../../providers/build_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/active_build_provider.dart';
import '../../widgets/web_inspired_component_card.dart';
import '../../widgets/warning_dialog.dart';
import '../../widgets/compatibility_status_card.dart';
import '../../widgets/tdp_calculator_widget.dart';
import '../../widgets/compatibility_details_modal.dart';
import '../../widgets/builder/wizard_progress_indicator.dart';
import '../../widgets/builder/step_indicator.dart';
import '../../widgets/builder/compatibility_hint.dart';
import 'template_selection_screen.dart';
import 'component_selection_screen.dart';

// Compatibility Service Provider
final compatibilityServiceProvider = Provider<CompatibilityService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CompatibilityService(apiClient);
});

// Budget Service Provider
final budgetServiceProvider = Provider<BudgetService>((ref) {
  return BudgetService();
});

// Build Templates Service Provider
final buildTemplatesServiceProvider = Provider<BuildTemplatesService>((ref) {
  return BuildTemplatesService();
});

class BuilderScreen extends ConsumerStatefulWidget {
  final Build? existingBuild;
  final Component? initialComponent;
  final String? initialCategory;

  const BuilderScreen({
    super.key,
    this.existingBuild,
    this.initialComponent,
    this.initialCategory,
  });

  @override
  ConsumerState<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends ConsumerState<BuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  late Build _currentBuild;
  bool _isPublic = false;
  double _budgetLimit = 0;
  LocalCompatibilityResult? _compatibilityResult;
  BudgetWarning? _budgetWarning;
  BuildTemplate? _selectedTemplate;

  // Wizard mode state
  bool _useWizardMode = true;
  int _currentWizardStep = 0;
  final Set<String> _completedSteps = {};

  final List<Map<String, dynamic>> _categories = [
    {'id': 'cpu', 'name': 'CPU', 'icon': Icons.memory, 'required': true},
    {
      'id': 'motherboard',
      'name': 'Motherboard',
      'icon': Icons.developer_board,
      'required': true
    },
    {
      'id': 'video-card',
      'name': 'GPU',
      'icon': Icons.videogame_asset,
      'required': false
    },
    {'id': 'memory', 'name': 'RAM', 'icon': Icons.sd_storage, 'required': true},
    {
      'id': 'internal-hard-drive',
      'name': 'Storage',
      'icon': Icons.storage,
      'required': true
    },
    {
      'id': 'power-supply',
      'name': 'PSU',
      'icon': Icons.power,
      'required': true
    },
    {'id': 'case', 'name': 'Case', 'icon': Icons.computer, 'required': false},
    {
      'id': 'cpu-cooler',
      'name': 'Cooler',
      'icon': Icons.ac_unit,
      'required': false
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with empty build first to prevent LateInitializationError
    _currentBuild = Build(
      name: '',
      description: '',
      components: {},
      totalCost: 0,
      totalTdp: 0,
    );

    // Then check if there's an active build or load existing build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeState = ref.read(activeBuildProvider);
      
      // If there's an active build and we're not explicitly editing a different build, use it
      if (activeState.hasActiveBuild && 
          widget.existingBuild == null && 
          widget.initialComponent == null) {
        setState(() {
          _currentBuild = activeState.activeBuild!;
          _nameController.text = _currentBuild.name;
          _descriptionController.text = _currentBuild.description ?? '';
          _isPublic = _currentBuild.visibility == 'public';
          _runCompatibilityCheck();
        });
      } else {
        // Initialize new or existing build
        if (widget.existingBuild != null) {
          setState(() {
            _currentBuild = widget.existingBuild!;
            _nameController.text = _currentBuild.name;
            _descriptionController.text = _currentBuild.description ?? '';
            _isPublic = _currentBuild.visibility == 'public';
          });
        } else {
          // Start active build session
          ref.read(activeBuildProvider.notifier).startBuild(
            _currentBuild,
            isEdit: false,
          );
        }

        // Add initial component if provided
        if (widget.initialComponent != null && widget.initialCategory != null) {
          _addComponent(widget.initialCategory!, widget.initialComponent!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.initialComponent!.name} added to build'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _runCompatibilityCheck();
      }
    });
  }

  @override
  void dispose() {
    // End active build session when leaving the screen
    ref.read(activeBuildProvider.notifier).endBuild();
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _addComponent(String category, Component component, {bool autoProgress = false}) {
    setState(() {
      _currentBuild = _currentBuild.addComponent(category, component);
      _completedSteps.add(category);
      _runCompatibilityCheck();
      _updateBudgetWarning();

      // Update active build provider
      ref.read(activeBuildProvider.notifier).updateBuild(_currentBuild);
    });

    // Auto-progress to next step in wizard mode if requested
    if (autoProgress && _useWizardMode) {
      // Find the current step index and verify we can progress
      final currentStepCategory = buildSteps[_currentWizardStep].category;
      if (currentStepCategory == category && _currentWizardStep < buildSteps.length - 1) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _goToNextStep();
          }
        });
      }
    }
  }

  void _removeComponent(String category) {
    setState(() {
      _currentBuild = _currentBuild.removeComponent(category);
      _completedSteps.remove(category);
      _runCompatibilityCheck();
      _updateBudgetWarning();

      // Update active build provider
      ref.read(activeBuildProvider.notifier).updateBuild(_currentBuild);
    });
  }

  void _runCompatibilityCheck() {
    final compatibilityService = ref.read(compatibilityServiceProvider);
    _compatibilityResult =
        compatibilityService.validateBuildLocally(_currentBuild.components);
  }

  /// Safely parse numeric value from specs
  int? _parseNumericValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));
    }
    return null;
  }

  void _updateBudgetWarning() {
    if (_budgetLimit > 0) {
      final budgetService = ref.read(budgetServiceProvider);
      _budgetWarning = budgetService.getBudgetWarning(
        currentCost: _currentBuild.totalCost,
        budgetLimit: _budgetLimit,
      );
    }
  }

  void _setBudgetLimit(String value) {
    setState(() {
      _budgetLimit = double.tryParse(value) ?? 0;
      _updateBudgetWarning();
    });
  }

  /// Maps UI category names to API category names
  /// API expects: cpu, motherboard, gpu, ram, storage, psu, case, cooler
  String _mapCategoryToApi(String uiCategory) {
    const categoryMapping = {
      'cpu': 'cpu',
      'motherboard': 'motherboard',
      'video-card': 'gpu',
      'gpu': 'gpu',
      'memory': 'ram',
      'ram': 'ram',
      'storage': 'storage',
      'internal-hard-drive': 'storage',
      'ssd': 'storage',
      'hdd': 'storage',
      'nvme': 'storage',
      'power-supply': 'psu',
      'psu': 'psu',
      'case': 'case',
      'cooler': 'cooler',
      'cpu-cooler': 'cooler',
      'fan': 'cooler',
      'liquid-cooler': 'cooler',
      'air-cooler': 'cooler',
    };
    
    return categoryMapping[uiCategory] ?? uiCategory.toLowerCase();
  }

  List<Map<String, dynamic>> _getMissingRequiredCategories() {
    return _categories
        .where((cat) => cat['required'] == true)
        .where((cat) => !_currentBuild.components.containsKey(cat['id']))
        .toList();
  }

  bool _isStepAccessible(int index) {
    if (index <= _currentWizardStep) {
      return true;
    }

    for (var i = 0; i < index; i++) {
      final step = buildSteps[i];
      if (step.required && _currentBuild.components[step.category] == null) {
        return false;
      }
    }

    return true;
  }

  void _showLockedStepMessage(int index) {
    final missingRequired = _getMissingRequiredCategories();
    if (missingRequired.isEmpty) {
      return;
    }

    final upcomingStep = buildSteps[index];
    final blockingSteps = missingRequired
        .where((cat) {
          final catIndex = buildSteps.indexWhere((step) => step.category == cat['id']);
          return catIndex >= 0 && catIndex < index;
        })
        .toList();

    if (!mounted || blockingSteps.isEmpty) {
      return;
    }

    final names = blockingSteps
        .map((cat) => cat['name'] as String)
        .join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add $names before configuring ${upcomingStep.label}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _selectTemplate() async {
    final result = await Navigator.of(context).push<BuildTemplate?>(
      MaterialPageRoute(
        builder: (context) => const TemplateSelectionScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedTemplate = result;
        // Update build name with template name if current name is empty
        if (_nameController.text.isEmpty) {
          _nameController.text = result.name;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template "${result.name}" selected'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Clear',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _selectedTemplate = null;
              });
            },
          ),
        ),
      );
    }
  }

  // Wizard navigation methods
  void _handleStepTap(int stepIndex) {
    if (!_isStepAccessible(stepIndex)) {
      _showLockedStepMessage(stepIndex);
      return;
    }

    setState(() {
      _currentWizardStep = stepIndex;
    });
  }

  void _goToPreviousStep() {
    if (_currentWizardStep > 0) {
      setState(() {
        _currentWizardStep--;
      });
    }
  }

  void _goToNextStep() {
    if (_currentWizardStep < buildSteps.length - 1) {
      final nextStepIndex = _currentWizardStep + 1;
      if (!_isStepAccessible(nextStepIndex)) {
        _showLockedStepMessage(nextStepIndex);
        return;
      }

      setState(() {
        _currentWizardStep = nextStepIndex;
      });
      
      // Log for debugging
      print('Advanced to step $_currentWizardStep: ${buildSteps[_currentWizardStep].label}');
    }
  }

  bool _canProceedToNextStep() {
    final currentStep = buildSteps[_currentWizardStep];
    if (currentStep.required && _currentBuild.components[currentStep.category] == null) {
      return false;
    }

    if (_currentWizardStep == buildSteps.length - 1) {
      return _getMissingRequiredCategories().isEmpty;
    }

    final nextStepIndex = _currentWizardStep + 1;
    return _isStepAccessible(nextStepIndex);
  }

  String? _getCompatibilityHintForStep(BuildStepModel step) {
    switch (step.category) {
      case 'motherboard':
        final cpu = _currentBuild.components['cpu'];
        return CompatibilityHintGenerator.getMotherboardHint(cpu?.specs);

      case 'memory':
        final motherboard = _currentBuild.components['motherboard'];
        return CompatibilityHintGenerator.getMemoryHint(motherboard?.specs);

      case 'video-card':
        final pcCase = _currentBuild.components['case'];
        final motherboard = _currentBuild.components['motherboard'];
        return CompatibilityHintGenerator.getGpuHint(pcCase?.specs, motherboard?.specs);

      case 'power-supply':
        return CompatibilityHintGenerator.getPsuHint(
          _compatibilityResult?.totalTdp ?? 0,
          _compatibilityResult?.recommendedPsuWattage,
        );

      case 'case':
        final motherboard = _currentBuild.components['motherboard'];
        return CompatibilityHintGenerator.getCaseHint(motherboard?.specs);

      case 'cpu-cooler':
        final cpu = _currentBuild.components['cpu'];
        final pcCase = _currentBuild.components['case'];
        return CompatibilityHintGenerator.getCoolerHint(cpu?.specs, pcCase?.specs);

      case 'internal-hard-drive':
        final motherboard = _currentBuild.components['motherboard'];
        return CompatibilityHintGenerator.getStorageHint(motherboard?.specs);

      default:
        return null;
    }
  }

  Future<void> _saveBuild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if at least one component is added
    if (_currentBuild.components.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one component to your build'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if all required components are added
    final missingRequired = _getMissingRequiredCategories();

    if (missingRequired.isNotEmpty) {
      final missingNames = missingRequired
          .map((cat) => cat['name'] as String)
          .join(', ');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Missing required components: $missingNames'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    // Run final compatibility check
    _runCompatibilityCheck();

    // Show warning dialog if there are compatibility issues
    if (_compatibilityResult != null && _compatibilityResult!.issues.isNotEmpty) {
      final proceed = await CompatibilityWarningDialog.show(
        context,
        issues: _compatibilityResult!.issues,
        onProceed: () {
          // Will proceed with save after dialog closes
        },
        onFixIssues: () {
          // User wants to review/fix issues - stay on screen
        },
      );

      // If user didn't proceed (closed dialog or chose to fix), return
      if (proceed != true && _compatibilityResult!.hasErrors) {
        return;
      }
    }

    final buildName = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    // Build components array for API
    final componentsForApi = _currentBuild.components.entries.map((entry) {
      final category = _mapCategoryToApi(entry.key);
      final component = entry.value;
      return {
        'component_id': component.productId,
        'category': category,
        'quantity': 1, // Default to 1, can be extended for multi-quantity
        'price_at_selection_bdt': component.priceBdt ?? 0,
      };
    }).toList();

    final bool success;

    if (widget.existingBuild != null) {
      // Update existing build
      success = await ref.read(buildProvider.notifier).updateBuild(
        id: widget.existingBuild!.id!,
        buildName: buildName,
        description: description.isEmpty ? null : description,
        useCase: null, // Add use case if available in UI
        budgetMaxBdt: _budgetLimit > 0 ? _budgetLimit : null,
        visibility: _isPublic ? 'public' : 'private',
        components: componentsForApi,
      );
    } else {
      // Create new build
      success = await ref.read(buildProvider.notifier).createBuild(
        buildName: buildName,
        description: description.isEmpty ? null : description,
        useCase: 'other', // Default use case
        budgetMaxBdt: _budgetLimit > 0 ? _budgetLimit : 0,
        visibility: _isPublic ? 'public' : 'private',
        components: componentsForApi,
      );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingBuild != null
                  ? 'Build updated successfully'
                  : 'Build created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(buildProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to save build'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildState = ref.watch(buildProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingBuild != null ? 'Edit Build' : 'Create Build',
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 1,
        actions: [
          if (widget.existingBuild == null)
            IconButton(
              icon: Icon(_useWizardMode ? Icons.view_list : Icons.auto_awesome),
              tooltip: _useWizardMode ? 'Switch to List View' : 'Switch to Wizard View',
              onPressed: () {
                setState(() {
                  _useWizardMode = !_useWizardMode;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: buildState.isLoading ? null : _saveBuild,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Build Info Section
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Build Name',
                      hintText: 'My Gaming PC',
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a build name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Describe your build...',
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Budget Limit (Optional)',
                      hintText: '\$1250',
                      filled: true,
                      fillColor: surfaceColor,
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: _setBudgetLimit,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Make Public'),
                    subtitle: const Text('Share with the community'),
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Template Selection Button
                  if (widget.existingBuild == null)
                    OutlinedButton.icon(
                      onPressed: _selectTemplate,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        _selectedTemplate == null
                            ? 'Choose a Template'
                            : 'Template: ${_selectedTemplate!.name}',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        side: BorderSide(
                          color: _selectedTemplate == null
                              ? Theme.of(context).colorScheme.primary
                              : Colors.green,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Budget Progress Bar
            if (_budgetLimit > 0) _buildBudgetProgressBar(),

            // Compatibility Status Card
            if (_currentBuild.components.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: CompatibilityStatusCard(
                  compatibilityResult: _compatibilityResult,
                  onViewDetails: _compatibilityResult != null
                      ? () {
                          CompatibilityDetailsModal.show(
                            context,
                            compatibilityResult: _compatibilityResult!,
                            components: _currentBuild.components,
                            totalTdp: _compatibilityResult!.totalTdp,
                            recommendedPsu:
                                _compatibilityResult!.recommendedPsuWattage,
                          );
                        }
                      : null,
                ),
              ),

            // TDP Calculator Widget
            if (_currentBuild.components.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TdpCalculatorWidget(
                  totalTdp: _compatibilityResult?.totalTdp ?? 0,
                  recommendedPsuWattage:
                      _compatibilityResult?.recommendedPsuWattage ?? 500,
                  selectedPsuWattage:
                      _parseNumericValue(
                        _currentBuild.components['power-supply']?.specs?['wattage']
                      ),
                  showDetails: true,
                ),
              ),

            // Stats Summary
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.inventory_2,
                    label: 'Components',
                    value: '${_currentBuild.components.length}',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _buildStatItem(
                    icon: Icons.shopping_cart,
                    label: 'Total Cost',
                    value: '৳${_currentBuild.totalCost.toStringAsFixed(0)}',
                    color: Colors.green,
                  ),
                  _buildStatItem(
                    icon: Icons.flash_on,
                    label: 'Est. TDP',
                    value: '${_currentBuild.totalTdp ?? 0}W',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Component Selection - Wizard or List Mode
            if (_useWizardMode && widget.existingBuild == null)
              Expanded(
                child: _buildWizardView(),
              )
            else ...[
              // Component Selection Header with Add Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Build Components',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Component Selection - List Mode
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final categoryId = category['id'] as String;
                    final component = _currentBuild.components[categoryId];

                    return _buildCategoryCard(
                      categoryId: categoryId,
                      name: category['name'] as String,
                      icon: category['icon'] as IconData,
                      isRequired: category['required'] as bool,
                      selectedComponent: component,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: !_useWizardMode ? FloatingActionButton.extended(
        onPressed: _showComponentSelectionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Component'),
        tooltip: 'Add a component to your build',
      ) : null,
    );
  }

  void _showComponentSelectionDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Component Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return ListTile(
                leading: Icon(category['icon'] as IconData),
                title: Text(category['name'] as String),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  
                  final categoryId = category['id'] as String;
                  final categoryName = category['name'] as String;
                  final selectedComponent = _currentBuild.components[categoryId];

                  // Store context before async operations
                  final scaffoldContext = this.context;

                  // Show template recommendations if template is selected
                  if (_selectedTemplate != null && mounted) {
                    final recommendations = _selectedTemplate!
                        .recommendations
                        .getForCategory(categoryId);
                    if (recommendations.isNotEmpty) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Recommended: ${recommendations.take(3).join(", ")}',
                          ),
                          backgroundColor: Theme.of(scaffoldContext).colorScheme.primary,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }

                  if (mounted) {
                    final result = await Navigator.of(scaffoldContext).push<Component>(
                      MaterialPageRoute(
                        builder: (context) => ComponentSelectionScreen(
                          category: categoryId,
                          categoryName: categoryName,
                          currentComponent: selectedComponent,
                          currentBuild: _currentBuild,
                        ),
                      ),
                    );

                    if (result != null && mounted) {
                      _addComponent(categoryId, result);
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildWizardView() {
    final currentStep = buildSteps[_currentWizardStep];
    final selectedComponent = _currentBuild.components[currentStep.category];
    final compatibilityHint = _getCompatibilityHintForStep(currentStep);
    final isLastStep = _currentWizardStep == buildSteps.length - 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Indicator
          WizardProgressIndicator(
            currentStep: _currentWizardStep,
            totalSteps: buildSteps.length,
            completedCount: _currentBuild.components.length,
          ),

          // Step Indicators
          StepIndicator(
            currentStep: _currentWizardStep,
            completedSteps: _completedSteps,
            onStepTap: _handleStepTap,
            isStepEnabled: (index) => _isStepAccessible(index),
          ),

          const SizedBox(height: 16),

          // Current Step Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(currentStep.icon, size: 32, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                currentStep.label,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              if (currentStep.required) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Required',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentStep.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Compatibility Hint
          if (compatibilityHint != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CompatibilityHint(
                message: compatibilityHint,
                type: CompatibilityHintType.info,
              ),
            ),

          // Selected Component Display
          if (selectedComponent != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Selected Component',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _removeComponent(currentStep.category),
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  WebInspiredComponentCard(
                    component: selectedComponent,
                  ),
                ],
              ),
            )
          else
            // Select Component Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push<Component>(
                    MaterialPageRoute(
                      builder: (context) => ComponentSelectionScreen(
                        category: currentStep.category,
                        categoryName: currentStep.label,
                        currentComponent: selectedComponent,
                        currentBuild: _currentBuild,
                      ),
                    ),
                  );

                  if (result != null) {
                    _addComponent(currentStep.category, result, autoProgress: true);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${result.name} added to build'),
                          backgroundColor: Colors.green,
                          duration: const Duration(milliseconds: 1500),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
                label: Text('Select ${currentStep.label}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Previous Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentWizardStep > 0 ? _goToPreviousStep : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: _currentWizardStep > 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Next/Complete Button
                Expanded(
                  flex: isLastStep ? 2 : 1,
                  child: ElevatedButton.icon(
                    onPressed: !_canProceedToNextStep()
                        ? null
                        : (isLastStep ? () => _saveBuild() : _goToNextStep),
                    icon: Icon(isLastStep ? Icons.save : Icons.chevron_right),
                    label: Text(isLastStep ? 'Save Build' : 'Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastStep ? Colors.green : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      disabledBackgroundColor: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Skip Optional Component Button
          if (!currentStep.required && selectedComponent == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton(
                onPressed: _goToNextStep,
                child: const Text('Skip Optional Component'),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final labelStyle = Theme.of(context).textTheme.bodySmall;

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: labelStyle?.copyWith(
              fontSize: 12,
            )),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String categoryId,
    required String name,
    required IconData icon,
    required bool isRequired,
    Component? selectedComponent,
  }) {
    // Check if this category has compatibility issues
    Color? borderColor;
    if (_compatibilityResult != null && selectedComponent != null) {
      final categoryIssues = _compatibilityResult!.issues
          .where((issue) => _isCategoryRelatedToIssue(categoryId, issue.category))
          .toList();

      if (categoryIssues.any((issue) => issue.isError)) {
        borderColor = Theme.of(context).colorScheme.error;
      } else if (categoryIssues.any((issue) => issue.isWarning)) {
        borderColor = Colors.orange;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              icon,
              color: borderColor ?? Theme.of(context).colorScheme.primary,
            ),
            title: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: borderColor,
                  ),
                ),
                if (isRequired)
                  const Text(
                    ' *',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (borderColor != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    borderColor == Theme.of(context).colorScheme.error
                        ? Icons.error
                        : Icons.warning_amber,
                    color: borderColor,
                    size: 20,
                  ),
                ],
              ],
            ),
            trailing: selectedComponent != null
                ? IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                    onPressed: () => _removeComponent(categoryId),
                  )
                : null,
          ),
          if (selectedComponent != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: WebInspiredComponentCard(component: selectedComponent),
            ),
        ],
      ),
    );
  }

  bool _isCategoryRelatedToIssue(String categoryId, String issueCategory) {
    // Map issue categories to component categories
    final categoryMapping = {
      'socket': ['cpu', 'motherboard'],
      'memory': ['memory', 'motherboard'],
      'power': ['power-supply'],
      'form_factor': ['case', 'motherboard'],
      'clearance': ['case', 'video-card'],
      'cooler': ['cpu-cooler', 'cpu', 'case'],
      'storage': ['internal-hard-drive', 'motherboard'],
    };

    final relatedCategories = categoryMapping[issueCategory] ?? [];
    return relatedCategories.contains(categoryId);
  }

  Widget _buildBudgetProgressBar() {
    if (_budgetWarning == null) return const SizedBox.shrink();

    final percentage = _budgetWarning!.percentageUsed.clamp(0.0, 100.0);
    Color progressColor;

    switch (_budgetWarning!.level) {
      case BudgetWarningLevel.over:
        progressColor = Theme.of(context).colorScheme.error;
        break;
      case BudgetWarningLevel.atLimit:
        progressColor = Theme.of(context).colorScheme.error;
        break;
      case BudgetWarningLevel.near:
        progressColor = Colors.orange;
        break;
      case BudgetWarningLevel.approaching:
        progressColor = Colors.orange.withOpacity(0.7);
        break;
      case BudgetWarningLevel.safe:
        progressColor = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: progressColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
              Text(
                _budgetWarning!.message,
                style: TextStyle(
                  fontSize: 12,
                  color: progressColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

}
