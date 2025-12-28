import '../../data/models/component.dart';

/// Budget warning level thresholds
enum BudgetWarningLevel {
  safe, // Below 75%
  approaching, // 75% - 90%
  near, // 90% - 100%
  atLimit, // Exactly at 100%
  over, // Over 100%
}

/// Budget warning with threshold information
class BudgetWarning {
  final BudgetWarningLevel level;
  final String message;
  final double currentAmount;
  final double budgetLimit;
  final double percentageUsed;

  BudgetWarning({
    required this.level,
    required this.message,
    required this.currentAmount,
    required this.budgetLimit,
    required this.percentageUsed,
  });

  bool get isOverBudget => level == BudgetWarningLevel.over;
  bool get isAtLimit => level == BudgetWarningLevel.atLimit;
  bool get needsAttention =>
      level == BudgetWarningLevel.near ||
      level == BudgetWarningLevel.atLimit ||
      level == BudgetWarningLevel.over;
}

/// Cost breakdown by component category
class CategoryCostBreakdown {
  final String category;
  final String categoryName;
  final double cost;
  final double percentage;
  final Component? component;

  CategoryCostBreakdown({
    required this.category,
    required this.categoryName,
    required this.cost,
    required this.percentage,
    this.component,
  });
}

/// Price comparison suggestion
class PriceComparison {
  final String category;
  final Component currentComponent;
  final double potentialSavings;
  final String suggestion;

  PriceComparison({
    required this.category,
    required this.currentComponent,
    required this.potentialSavings,
    required this.suggestion,
  });
}

/// Budget tracking and analysis service
class BudgetService {
  /// Get budget warning level based on current spending
  BudgetWarning getBudgetWarning({
    required double currentCost,
    required double budgetLimit,
  }) {
    if (budgetLimit <= 0) {
      return BudgetWarning(
        level: BudgetWarningLevel.safe,
        message: 'No budget limit set',
        currentAmount: currentCost,
        budgetLimit: budgetLimit,
        percentageUsed: 0,
      );
    }

    final percentageUsed = (currentCost / budgetLimit) * 100;

    BudgetWarningLevel level;
    String message;

    if (currentCost > budgetLimit) {
      level = BudgetWarningLevel.over;
      final overAmount = currentCost - budgetLimit;
      message =
          'Over budget by ৳${overAmount.toStringAsFixed(0)} (${percentageUsed.toStringAsFixed(1)}%)';
    } else if (currentCost == budgetLimit) {
      level = BudgetWarningLevel.atLimit;
      message = 'At budget limit (100%)';
    } else if (percentageUsed >= 90) {
      level = BudgetWarningLevel.near;
      final remaining = budgetLimit - currentCost;
      message =
          'Near budget limit (${percentageUsed.toStringAsFixed(1)}%). ৳${remaining.toStringAsFixed(0)} remaining';
    } else if (percentageUsed >= 75) {
      level = BudgetWarningLevel.approaching;
      final remaining = budgetLimit - currentCost;
      message =
          'Approaching budget limit (${percentageUsed.toStringAsFixed(1)}%). ৳${remaining.toStringAsFixed(0)} remaining';
    } else {
      level = BudgetWarningLevel.safe;
      final remaining = budgetLimit - currentCost;
      message =
          '৳${remaining.toStringAsFixed(0)} remaining (${percentageUsed.toStringAsFixed(1)}% used)';
    }

    return BudgetWarning(
      level: level,
      message: message,
      currentAmount: currentCost,
      budgetLimit: budgetLimit,
      percentageUsed: percentageUsed,
    );
  }

  /// Get cost breakdown by component category
  List<CategoryCostBreakdown> getCostBreakdown(
    Map<String, Component> components,
    double totalCost,
  ) {
    final breakdown = <CategoryCostBreakdown>[];

    // Category name mapping
    final categoryNames = {
      'cpu': 'CPU',
      'motherboard': 'Motherboard',
      'video-card': 'GPU',
      'memory': 'RAM',
      'internal-hard-drive': 'Storage',
      'power-supply': 'PSU',
      'case': 'Case',
      'cpu-cooler': 'CPU Cooler',
    };

    for (final entry in components.entries) {
      final category = entry.key;
      final component = entry.value;
      final cost = component.priceBdt ?? 0;
      final percentage = totalCost > 0 ? (cost / totalCost) * 100 : 0.0;

      breakdown.add(CategoryCostBreakdown(
        category: category,
        categoryName: categoryNames[category] ?? category,
        cost: cost,
        percentage: percentage.toDouble(),
        component: component,
      ));
    }

    // Sort by cost (descending)
    breakdown.sort((a, b) => b.cost.compareTo(a.cost));

    return breakdown;
  }

  /// Get price comparison suggestions for potential savings
  /// This is a simplified version - in production, you might fetch alternative components
  List<PriceComparison> getPriceComparisonSuggestions(
    Map<String, Component> components,
    double budgetLimit,
    double currentCost,
  ) {
    final suggestions = <PriceComparison>[];

    // Only suggest if over budget or near limit
    if (currentCost <= budgetLimit * 0.9) {
      return suggestions;
    }

    // Sort components by cost to find expensive ones
    final sortedComponents = components.entries.toList()
      ..sort((a, b) =>
          (b.value.priceBdt ?? 0).compareTo(a.value.priceBdt ?? 0));

    // Suggest alternatives for the most expensive components
    for (var i = 0; i < sortedComponents.length && i < 3; i++) {
      final entry = sortedComponents[i];
      final component = entry.value;
      final cost = component.priceBdt ?? 0;

      if (cost == 0) continue;

      // Estimate potential savings (10-20% for similar spec alternatives)
      final potentialSavings = cost * 0.15;

      String suggestion;
      if (entry.key == 'cpu') {
        suggestion =
            'Consider a similar CPU with slightly lower clock speed for potential savings';
      } else if (entry.key == 'video-card') {
        suggestion =
            'Look for previous generation GPUs with similar performance at lower cost';
      } else if (entry.key == 'motherboard') {
        suggestion =
            'Consider a motherboard with fewer features but same socket compatibility';
      } else if (entry.key == 'memory') {
        suggestion =
            'Look for RAM with similar speed from different brands for better pricing';
      } else if (entry.key == 'internal-hard-drive') {
        suggestion =
            'Consider mixing SSD for OS and HDD for storage to reduce costs';
      } else {
        suggestion =
            'Compare prices across different brands for similar specifications';
      }

      suggestions.add(PriceComparison(
        category: entry.key,
        currentComponent: component,
        potentialSavings: potentialSavings,
        suggestion: suggestion,
      ));
    }

    return suggestions;
  }

  /// Calculate how much budget is remaining for a specific category
  double getRemainingBudgetForCategory({
    required String category,
    required double totalBudget,
    required double currentTotalCost,
    required Map<String, Component> components,
  }) {
    if (totalBudget <= 0) return 0;

    final remaining = totalBudget - currentTotalCost;
    if (remaining <= 0) return 0;

    // If category already has a component, return 0
    if (components.containsKey(category)) {
      return 0;
    }

    // Estimate typical budget allocation percentages
    final categoryBudgetPercentages = {
      'cpu': 0.20, // 20% of total budget
      'video-card': 0.30, // 30% of total budget
      'motherboard': 0.15, // 15% of total budget
      'memory': 0.10, // 10% of total budget
      'internal-hard-drive': 0.10, // 10% of total budget
      'power-supply': 0.08, // 8% of total budget
      'case': 0.05, // 5% of total budget
      'cpu-cooler': 0.02, // 2% of total budget
    };

    final categoryPercentage = categoryBudgetPercentages[category] ?? 0.05;
    final suggestedBudget = totalBudget * categoryPercentage;

    // Return the lesser of suggested budget or remaining budget
    return suggestedBudget < remaining ? suggestedBudget : remaining;
  }

  /// Get a summary of budget status
  Map<String, dynamic> getBudgetSummary({
    required double currentCost,
    required double budgetLimit,
    required Map<String, Component> components,
  }) {
    final warning = getBudgetWarning(
      currentCost: currentCost,
      budgetLimit: budgetLimit,
    );

    final breakdown = getCostBreakdown(components, currentCost);
    final suggestions = getPriceComparisonSuggestions(
      components,
      budgetLimit,
      currentCost,
    );

    return {
      'warning': warning,
      'breakdown': breakdown,
      'suggestions': suggestions,
      'totalCost': currentCost,
      'budgetLimit': budgetLimit,
      'remaining': budgetLimit - currentCost,
      'percentageUsed': warning.percentageUsed,
    };
  }

  /// Get recommended budget allocations for each category
  Map<String, double> getRecommendedBudgetAllocations(double totalBudget) {
    return {
      'cpu': totalBudget * 0.20,
      'video-card': totalBudget * 0.30,
      'motherboard': totalBudget * 0.15,
      'memory': totalBudget * 0.10,
      'internal-hard-drive': totalBudget * 0.10,
      'power-supply': totalBudget * 0.08,
      'case': totalBudget * 0.05,
      'cpu-cooler': totalBudget * 0.02,
    };
  }
}
