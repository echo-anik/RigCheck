import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/build.dart';
import '../../data/models/component.dart';

/// State for the active build being created/edited
class ActiveBuildState {
  final Build? activeBuild;
  final bool isBuilding;
  final String? buildMode; // 'create' or 'edit'

  ActiveBuildState({
    this.activeBuild,
    this.isBuilding = false,
    this.buildMode,
  });

  ActiveBuildState copyWith({
    Build? activeBuild,
    bool? isBuilding,
    String? buildMode,
    bool clearBuild = false,
  }) {
    return ActiveBuildState(
      activeBuild: clearBuild ? null : (activeBuild ?? this.activeBuild),
      isBuilding: isBuilding ?? this.isBuilding,
      buildMode: clearBuild ? null : (buildMode ?? this.buildMode),
    );
  }

  bool get hasActiveBuild => activeBuild != null && isBuilding;
}

/// Notifier for managing the active build state
class ActiveBuildNotifier extends StateNotifier<ActiveBuildState> {
  ActiveBuildNotifier() : super(ActiveBuildState());

  /// Start a new build or edit an existing one
  void startBuild(Build build, {bool isEdit = false}) {
    state = ActiveBuildState(
      activeBuild: build,
      isBuilding: true,
      buildMode: isEdit ? 'edit' : 'create',
    );
  }

  /// Update the entire build
  void updateBuild(Build build) {
    if (!state.isBuilding) return;
    state = state.copyWith(activeBuild: build);
  }

  /// Add a component to the active build
  void addComponent(String category, Component component) {
    if (!state.hasActiveBuild) return;

    final updatedBuild = state.activeBuild!.addComponent(category, component);
    state = state.copyWith(activeBuild: updatedBuild);
  }

  /// Remove a component from the active build
  void removeComponent(String category) {
    if (!state.hasActiveBuild) return;

    final updatedBuild = state.activeBuild!.removeComponent(category);
    state = state.copyWith(activeBuild: updatedBuild);
  }

  /// Replace a component in a specific category
  void replaceComponent(String category, Component component) {
    if (!state.hasActiveBuild) return;

    // Remove old component and add new one
    final build = state.activeBuild!.removeComponent(category);
    final updatedBuild = build.addComponent(category, component);
    state = state.copyWith(activeBuild: updatedBuild);
  }

  /// Check if a component is in the active build
  bool hasComponent(String category) {
    if (!state.hasActiveBuild) return false;
    return state.activeBuild!.components.containsKey(category);
  }

  /// Get the component in a specific category
  Component? getComponent(String category) {
    if (!state.hasActiveBuild) return null;
    return state.activeBuild!.components[category];
  }

  /// End the build session (after save or cancel)
  void endBuild() {
    state = ActiveBuildState(activeBuild: null, isBuilding: false);
  }

  /// Cancel the build session without saving
  void cancelBuild() {
    endBuild();
  }
}

/// Provider for active build state
final activeBuildProvider = StateNotifierProvider<ActiveBuildNotifier, ActiveBuildState>((ref) {
  return ActiveBuildNotifier();
});
