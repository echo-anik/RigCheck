#!/bin/bash
# Fix unused imports
sed -i "/import '..\/..\/..\/core\/constants\/app_strings.dart'/d" lib/presentation/screens/builder/builder_screen.dart
sed -i "/import '..\/..\/widgets\/component_card.dart'/d" lib/presentation/screens/builder/component_selection_bottom_sheet.dart
sed -i "/import 'builder_screen.dart'/d" lib/presentation/screens/builder/component_selection_bottom_sheet.dart
sed -i "/import '..\/..\/..\/data\/models\/component.dart'/d" lib/presentation/screens/favorites/favorites_screen.dart
sed -i "/import '..\/..\/..\/data\/models\/build.dart'/d" lib/presentation/screens/gallery/gallery_screen.dart
sed -i "/import '..\/..\/..\/core\/services\/local_storage_service.dart'/d" lib/presentation/screens/profile/settings_screen.dart
sed -i "/import '..\/..\/data\/repositories\/build_repository.dart'/d" lib/presentation/widgets/build_comments_sheet.dart
