# RigCheck App - Implementation Roadmap
## Bringing Mobile App to Feature Parity with Web Version

**Last Updated:** 2025-12-21
**Status:** 🔴 In Progress

---

## Overview
This document tracks all changes needed to bring the rigcheck_app (Flutter mobile) to feature parity with the rigcheck-web (Next.js) version. Changes are organized by priority and implementation status.

---

## 🔴 CRITICAL PRIORITY (Week 1-2)

### 1. Build Templates System
**Status:** ✅ Complete
**Files to Create/Update:**
- [x] `lib/core/services/build_templates_service.dart`
- [x] `lib/data/models/build_template.dart`
- [x] `lib/presentation/screens/builder/template_selection_screen.dart`
- [x] `lib/presentation/widgets/template_card.dart`

**Description:**
- Port 8 pre-configured templates from web version
- Template categories: Gaming Beast, High-End Gaming, Mid-Range Gaming, Budget Gaming, Professional Workstation, Mid-Range Workstation, Office Professional, Basic Office
- Budget ranges: ৳25,000 - ৳400,000
- Component recommendation algorithm based on template specs
- Template matching with compatibility validation

**Web Reference:**
- `rigcheck-web/lib/build-templates.ts`
- `rigcheck-web/components/builder/TemplateSelector.tsx`

**Implementation Notes:**
- ✅ Created BuildTemplate model with all 8 templates
- ✅ Implemented BuildTemplatesService with component matching algorithm
- ✅ Created TemplateCard widget with category color coding
- ✅ Created TemplateSelectionScreen with category filtering
- ✅ Integrated template selection into BuilderScreen
- ✅ Added template recommendations display when selecting components
- ✅ Updated app routing with /builder/templates route

---

### 2. Wishlist Feature
**Status:** ✅ Complete
**Files to Create/Update:**
- [x] `lib/core/services/wishlist_service.dart`
- [x] `lib/data/repositories/wishlist_repository.dart`
- [x] `lib/data/models/wishlist_item.dart`
- [x] `lib/presentation/providers/wishlist_provider.dart`
- [x] `lib/presentation/screens/wishlist/wishlist_screen.dart`
- [x] `lib/presentation/widgets/wishlist_button.dart`
- [x] Update `lib/presentation/screens/components/component_detail_screen.dart`
- [x] Update `lib/routes/app_router.dart`

**Description:**
- Save components and builds to wishlist
- Persistent storage with Hive
- Total value calculation
- Quick add/remove from component cards
- Wishlist badge counter in navigation
- Context-based state management

**Web Reference:**
- `rigcheck-web/lib/wishlist-context.tsx`
- `rigcheck-web/app/wishlist/page.tsx`

---

### 3. Component Comparison Tool
**Status:** ✅ Complete
**Files to Create/Update:**
- [x] `lib/presentation/screens/compare/compare_screen.dart`
- [x] `lib/presentation/widgets/comparison_table.dart`
- [x] `lib/presentation/widgets/comparison_selector.dart`
- [x] `lib/core/services/comparison_service.dart`
- [x] Update component cards to add "Add to Compare" button

**Description:**
- Side-by-side comparison of 2-4 components
- Category-specific comparisons (CPU vs CPU, GPU vs GPU)
- Dynamic specification table generation
- Price comparison with currency toggle
- Highlight differences in specs
- Modal-based component selection

**Web Reference:**
- `rigcheck-web/app/compare/page.tsx`
- `rigcheck-web/components/compare/ComparisonTable.tsx`

---

### 4. Build Wizard Step-by-Step Flow
**Status:** ✅ Complete
**Files to Create/Update:**
- [x] Update `lib/presentation/screens/builder/builder_screen.dart`
- [x] `lib/presentation/widgets/builder/wizard_progress_indicator.dart`
- [x] `lib/presentation/widgets/builder/step_indicator.dart`
- [x] `lib/presentation/widgets/builder/compatibility_hint.dart`

**Description:**
- 8-step guided process with visual progress
- Step indicators (CPU → Motherboard → RAM → GPU → Storage → PSU → Case → Cooler)
- Required/optional indicators for each step
- Real-time compatibility hints during selection
- Smart component filtering (e.g., motherboards filtered by CPU socket)
- Visual feedback for each step completion
- Navigation between steps

**Web Reference:**
- `rigcheck-web/components/builder/BuildWizard.tsx`
- `rigcheck-web/components/builder/StepIndicator.tsx`

---

## 🟡 HIGH PRIORITY (Week 3-4)

### 5. Build Export Enhancements
**Status:** ⚠️ Partial (basic export exists)
**Files to Create/Update:**
- [ ] Update `lib/core/services/build_export_service.dart`
- [ ] Add HTML export functionality
- [ ] Add CSV/Excel export functionality
- [ ] Add professional formatting
- [ ] Add share as image functionality

**Description:**
- Export builds to HTML/PDF with professional formatting
- Export to CSV/Excel for spreadsheet analysis
- Share as image (screenshot of build summary)
- Include compatibility status in exports
- Timestamp and branding
- Multiple export format options in share dialog

**Web Reference:**
- `rigcheck-web/lib/export-build.ts`

---

### 6. Advanced Search & Filters
**Status:** ⚠️ Partial (basic search exists)
**Files to Create/Update:**
- [ ] Update `lib/presentation/screens/components/search_screen.dart`
- [ ] `lib/presentation/widgets/filters/price_range_slider.dart`
- [ ] `lib/presentation/widgets/filters/brand_filter.dart`
- [ ] `lib/presentation/widgets/filters/category_filter.dart`
- [ ] Update `lib/data/repositories/component_repository.dart` for advanced filters

**Description:**
- Full-page advanced search
- Price range slider (min/max)
- Brand checkboxes (multiple selection)
- Category filters with counts
- Availability status filters
- Sort options (relevance, price low-high, price high-low, newest, rating)
- Filter persistence across sessions
- Clear all filters button

**Web Reference:**
- `rigcheck-web/app/search/page.tsx`
- `rigcheck-web/components/filters/FilterModal.tsx`

---

### 7. Public Build Gallery/Feed
**Status:** ❌ Missing
**Files to Create/Update:**
- [ ] `lib/presentation/screens/feed/public_builds_screen.dart`
- [ ] `lib/presentation/widgets/build_card.dart` (enhanced version)
- [ ] Update `lib/data/repositories/build_repository.dart`
- [ ] Add `lib/presentation/providers/public_builds_provider.dart`

**Description:**
- Browse community builds (public builds feed)
- Filter by use case (All, Gaming, Workstation, Budget)
- Featured builds section
- Build statistics (views, likes, comments)
- Search builds
- Pagination
- Pull-to-refresh
- Build detail view with social stats

**Web Reference:**
- `rigcheck-web/app/builds/page.tsx`
- `rigcheck-web/app/feed/page.tsx`

**API Endpoint:**
- `GET /api/v1/builds/public`

---

### 8. Currency Toggle (USD/BDT)
**Status:** ✅ Complete
**Files to Create/Update:**
- [x] `lib/core/utils/currency_utils.dart`
- [x] Update `lib/presentation/providers/user_preferences_provider.dart` (currency preference exists)
- [x] Update all price display widgets
- [x] Add currency toggle in settings
- [x] Add currency selector in component/build views

**Description:**
- Toggle between USD and BDT display
- Conversion rate configuration (1 USD = 120 BDT)
- Formatted price display functions
- Persistent currency preference
- Real-time currency switching without API calls
- Currency indicator in UI

**Web Reference:**
- `rigcheck-web/lib/currency.ts`

---

## 🟢 MEDIUM PRIORITY (Week 5-6)

### 9. Build Sharing Enhancements
**Status:** ⚠️ Partial (basic share exists)
**Files to Create/Update:**
- [ ] Update `lib/presentation/widgets/build_share_dialog.dart`
- [ ] `lib/core/services/share_service.dart` (enhance)
- [ ] Add QR code generation
- [ ] Add shareable link generation

**Description:**
- Public/private visibility toggle
- Generate shareable links with tokens
- QR code generation for quick sharing
- Social media share intents (WhatsApp, Facebook, Twitter)
- Copy link to clipboard
- Share build as image

**Web Reference:**
- `rigcheck-web/components/builder/ShareBuildDialog.tsx`

**API Endpoint:**
- `POST /api/v1/shared-builds`
- `GET /api/v1/shared-builds/{shareToken}`

**New Dependencies:**
- `qr_flutter: ^4.1.0`

---

### 10. Bottom Sheet UX for Component Selection
**Status:** ❌ Missing
**Files to Create/Update:**
- [ ] Update builder flow to use bottom sheets
- [ ] `lib/presentation/widgets/builder/component_selection_sheet.dart`
- [ ] Keep build context visible while selecting

**Description:**
- Replace full-screen component selection with draggable bottom sheets
- Show build summary at top while selecting components
- Draggable scrollable sheets
- Dismiss on swipe down
- Better UX for quick component swapping

---

### 11. Toast Notifications
**Status:** ⚠️ Partial (uses SnackBars)
**Files to Create/Update:**
- [ ] Add `fluttertoast` dependency
- [ ] Create `lib/core/utils/toast_utils.dart`
- [ ] Replace SnackBars with Toasts throughout app
- [ ] Standardize success/error/warning/info styles

**Description:**
- Replace SnackBars with Toast notifications
- Consistent styling (success, error, warning, info)
- Non-blocking notifications
- Auto-dismiss with configurable duration
- Position control (top, center, bottom)

**New Dependencies:**
- `fluttertoast: ^8.2.4`

**Web Reference:**
- Uses `sonner` for toast notifications

---

### 12. Static Content Pages
**Status:** ❌ Missing
**Files to Create/Update:**
- [ ] `lib/presentation/screens/static/about_screen.dart`
- [ ] `lib/presentation/screens/static/privacy_screen.dart`
- [ ] `lib/presentation/screens/static/terms_screen.dart`
- [ ] `lib/presentation/screens/static/faq_screen.dart`
- [ ] `lib/presentation/screens/static/contact_screen.dart`
- [ ] Update settings screen to link to these pages

**Description:**
- About RigCheck page
- Privacy Policy
- Terms of Service
- FAQ/Help section
- Contact/Support page
- Legal compliance

**Web Reference:**
- `rigcheck-web/app/about/page.tsx`
- `rigcheck-web/app/privacy/page.tsx`
- `rigcheck-web/app/terms/page.tsx`
- `rigcheck-web/app/faq/page.tsx`
- `rigcheck-web/app/contact/page.tsx`

---

## 🔵 LOW PRIORITY (Week 7+)

### 13. Admin Panel Expansion
**Status:** ⚠️ Partial (basic admin dashboard exists)
**Files to Create/Update:**
- [ ] `lib/presentation/screens/admin/user_management_screen.dart`
- [ ] `lib/presentation/screens/admin/content_moderation_screen.dart`
- [ ] `lib/presentation/screens/admin/builds_management_screen.dart`
- [ ] Enhance `lib/presentation/screens/admin/admin_dashboard_screen.dart`

**Description:**
- User management UI (view, edit, suspend users)
- Content moderation (posts, builds, comments)
- Enhanced analytics dashboard
- System settings

**Web Reference:**
- `rigcheck-web/app/admin/*` (multiple admin pages)

---

### 14. Advanced Analytics Integration
**Status:** ❌ Missing
**Files to Create/Update:**
- [ ] Integrate analytics library
- [ ] Track user behavior events
- [ ] Popular component tracking
- [ ] Build creation analytics
- [ ] Conversion tracking

**Description:**
- User behavior tracking
- Popular components/builds analytics
- Conversion funnel tracking
- A/B testing capabilities
- Error tracking (Sentry or similar)

---

### 15. Offline Mode Enhancements
**Status:** ⚠️ Partial (basic offline exists)
**Files to Create/Update:**
- [ ] Enhance `lib/core/services/local_storage_service.dart`
- [ ] Enhance `lib/core/services/sync_manager.dart`
- [ ] Better caching strategy
- [ ] Offline build creation with sync queue

**Description:**
- Better caching strategy for components
- Complete offline build creation
- Sync queue improvements with conflict resolution
- Offline indicator in UI
- Background sync optimization

---

## 🔧 CONFIGURATION UPDATES

### API Constants
**Status:** ❌ Needs Update
**File:** `lib/core/constants/api_constants.dart`

**Changes Needed:**
```dart
class ApiConstants {
  // Use environment variables instead of hardcoded
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8002/api/v1',
  );

  // Add new endpoints
  static const String publicBuilds = '/builds/public';
  static const String sharedBuilds = '/shared-builds';
  static const String buildTemplates = '/build-templates';

  // Timeout configuration
  static const Duration connectTimeout = Duration(seconds: 30); // Match web (30s)
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

---

### Environment Files
**Status:** ❌ Needs Update
**File:** `.env.production`

**Changes Needed:**
```bash
# Add missing configurations
API_BASE_URL=https://api.rigcheck.com/api/v1
ENABLE_WISHLIST=true
ENABLE_COMPARISON=true
ENABLE_BUILD_TEMPLATES=true
ENABLE_SOCIAL_SHARING=true
USD_TO_BDT_RATE=120
DEFAULT_CURRENCY=BDT
```

---

### Dependencies
**Status:** ❌ Needs Update
**File:** `pubspec.yaml`

**New Dependencies to Add:**
```yaml
dependencies:
  # Toast notifications
  fluttertoast: ^8.2.4

  # QR code generation
  qr_flutter: ^4.1.0

  # PDF generation enhancement
  pdf: ^3.10.8

  # CSV export
  csv: ^6.0.0

  # Enhanced image handling (already included but verify version)
  # image_picker: ^1.1.2
```

---

## 📊 PROGRESS TRACKING

### Overall Status
- **Total Tasks:** 18
- **Completed:** 5
- **In Progress:** 0
- **Missing:** 13

### By Priority
- **Critical (1-4):** 4/4 ✅
- **High (5-8):** 1/4 ✅
- **Medium (9-12):** 0/4 ✅
- **Low (13-15):** 0/3 ✅
- **Configuration:** 0/3 ✅

---

## 🎯 SPRINT PLAN

### Sprint 1 (Week 1-2): Core Features
**Goal:** Implement critical missing features
- [ ] Build Templates System
- [x] Wishlist Feature
- [ ] Component Comparison
- [ ] Build Wizard Flow

**Expected Outcome:** Major feature gaps closed

---

### Sprint 2 (Week 3-4): Enhanced Builder
**Goal:** Improve builder UX and exports
- [ ] Build Export Enhancements
- [ ] Advanced Search & Filters
- [ ] Public Build Gallery
- [ ] Currency Toggle

**Expected Outcome:** Feature parity with web builder

---

### Sprint 3 (Week 5-6): Community & Polish
**Goal:** Community features and UX polish
- [ ] Build Sharing Enhancements
- [ ] Bottom Sheet UX
- [ ] Toast Notifications
- [ ] Static Content Pages

**Expected Outcome:** Production-ready polish

---

### Sprint 4 (Week 7+): Advanced Features
**Goal:** Advanced features and optimization
- [ ] Admin Panel Expansion
- [ ] Advanced Analytics
- [ ] Offline Mode Enhancements

**Expected Outcome:** Advanced capabilities

---

## 📝 NOTES

### Key Differences Between Web and Mobile
1. **Web uses localStorage, Mobile uses SharedPreferences/Hive**
2. **Web uses fetch API, Mobile uses Dio**
3. **Web uses Next.js routing, Mobile uses GoRouter**
4. **Web has environment-based config, Mobile needs to implement**
5. **Mobile has better offline support already**
6. **Mobile has social features (posts, follow) that web lacks**

### Feature Parity Status
- **Mobile Ahead:** Social posts, follow system, offline-first architecture
- **Web Ahead:** Build templates, wishlist, comparison, wizard UX, currency toggle
- **Equal:** Core builder, compatibility checking, authentication

### Recommendations
1. **Priority 1:** Build Templates (biggest differentiator)
2. **Quick Win:** Wishlist (high value, moderate effort)
3. **UX Focus:** Build Wizard (better first-time experience)
4. **Power User:** Comparison Tool (enthusiast feature)

---

## 🔗 REFERENCE FILES

### Web Version Files to Reference
- `rigcheck-web/lib/build-templates.ts` - Templates logic
- `rigcheck-web/lib/wishlist-context.tsx` - Wishlist management
- `rigcheck-web/lib/export-build.ts` - Export functionality
- `rigcheck-web/lib/currency.ts` - Currency conversion
- `rigcheck-web/components/builder/BuildWizard.tsx` - Wizard UI
- `rigcheck-web/app/compare/page.tsx` - Comparison tool
- `rigcheck-web/app/feed/page.tsx` - Public builds feed

### Mobile Version Files to Update
- `lib/presentation/screens/builder/builder_screen.dart` - Main builder
- `lib/core/services/compatibility_service.dart` - Compatibility logic
- `lib/data/repositories/build_repository.dart` - Build operations
- `lib/data/repositories/component_repository.dart` - Component operations
- `lib/core/constants/api_constants.dart` - API configuration

---

**Last Updated:** 2025-12-21
**Next Review:** After Sprint 1 completion
