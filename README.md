# BoldKit Flutter ⚡

> **A production-quality Neubrutalism UI library for Flutter & Dart 3.**  
> Design system ported from [BoldKit by Aniruddha Agarwal](https://github.com/ANIBIT14/boldkit) (MIT License).

---

## 🎨 Neubrutalism Design Language

- **Borders**: 3px solid near-black borders (`#181820` light, `#FAFAF7` dark).
- **Shadows**: Hard-offset `4px 4px 0px` shadows with zero blur.
- **Border Radius**: 0px everywhere — strictly rectangular/sharp geometry.
- **Typography**: Bold, high-contrast, uppercase styling powered by Google Fonts `Outfit` (UI) and `DM Mono` (code/ASCII).
- **Interactions**: On press, interactive elements translate 2px toward their shadow while the shadow shrinks, creating the signature brutalist tactile "push" effect. On desktop/web, elements lift slightly on hover.
- **Color Palette**: High-contrast flat tones:
  - **Primary**: Coral Red (`#EE7171`)
  - **Secondary**: Teal (`#3DC9B3`)
  - **Accent**: Yellow (`#FFD849`)
  - **Destructive**: Crimson (`#D92B2B`)
  - **Success**: Mint Green (`#5EDBA0`)
  - **Warning**: Amber (`#FFCC1A`)
  - **Info**: Sky Blue (`#75BBFF`)

---

## 📦 What Was Built

### 1. Component Library (`lib/core/widgets/`, prefixed `Bk`)
- **Core**: `BkButton` (9 variants, 5 sizes, loading state, icon support, brutalist push effect), `BkCard`, `BkLayeredCard` (multi-layered stacked paper effect), `BkStatCard`, `BkBadge` (8 variants), `BkSticker` (rotated labels, stamps, sticky notes), `BkMarquee` (scrolling ticker with velocity reactivity), `BkAvatar`, `BkSeparator`, `BkKbd`.
- **Forms & Inputs**: `BkInput`, `BkTextarea`, `BkCheckbox` (square CustomPainter checkmark), `BkRadioGroup`, `BkSwitch` (rectangular track, square thumb), `BkSlider` (tactile slider with numeric readout and responsive label), `BkSelect` (modal bottom sheet dropdown), `BkRating` (tactile 5-star rating with bounce physics and score display), `BkOtpInput` (6-digit auto-advancing), `BkCombobox`, `BkTagInput`.
- **Overlays, Feedback & Navigation**: `showBkDialog`, `showBkAlertDialog`, `showBkBottomSheet`, `showBkSideSheet`, `BkToastManager` (queued overlay toasts with manual and timed dismiss), `BkAlert` (4 severity tiers), `BkProgress`, `BkSkeleton`, `BkSpinner`, `BkTooltip`, `BkPopover`, `BkDropdownMenu`, `BkCollapsible`, `BkBreadcrumb`, `BkCarousel`, `BkCommandPalette` (instant keyboard search and navigation across all app sections).
- **Navigation & Layout**: `BkTabs` (solid color active fill), `BkAccordion` (single & multi-expandable), `BkStepper` (horizontal & vertical multi-step indicator), `BkPagination`, `BkDataTable` (sortable, searchable, selectable, paginated brutalist table), `BkTimeline`, `BkTreeView`, `BkReveal` (staggered entrance fade/slide/rotate physics).
- **Charts**: `BkBarChart`, `BkLineChart`, `BkAreaChart`, `BkPieChart`, `BkDonutChart`, `BkRadarChart`, `BkGaugeChart`, `BkRadialBarChart`, `BkSparkline` with dynamic time-ranges (7D, 30D, 90D, 1Y) and interactive series filtering.
- **Decorative**:
  - **30+ CustomPainter SVG Shapes**: Triangle, Diamond, Pentagon, Hexagon, Octagon, Cross, Arrow, Chevron, Blob, Cloud, Splash, Leaf, Flower, Heart, Star, Moon, Sun, Lightning, Rocket, Planet, Cosmic Ring, Infinity, Spiral, Fractal, Mobius, Wave, Gear, Cog, Circuit, Target, Shield, Bracket.
  - **17 Animated ASCII Shapes**: Torus, Donut, Sphere, Cube, Helix, Trefoil Knot, Geodesic Dome, Saturn, Hyperboloid, DNA, Spiral, Rose, Wave, Vortex, Pulse, Matrix, Grid with customizable charsets, speed, and multicolor palette.
  - **Parametric Math Curves**: `BkMathCurveLoader`, `BkMathCurveProgress` with Rose, Lissajous, Spirograph, Butterfly, Cardioid, Epitrochoid curves.
  - **Canvas Shaders**: `BkCanvasEffect` with Mesh Gradient, Aurora, Plasma, Halftone, Truchet, Flow Field, CRT scanlines, and Metaballs.

### 2. Complete Application Screens (`lib/features/`)
1. **Home**: Live animated hero headline, marquee ticker, stat counters that count up on scroll, feature cards with flip/tap details, live interactive playground (button variant/size tester & quick theme swapper), and CTA.
2. **Components Catalog**: Searchable, categorized catalog of all components with detail views featuring live interactive demos, variant/size selectors, copyable Dart snippets, and persistent favorites.
3. **Charts Showcase**: Bar, Line, Area, Pie, Donut, Radial, Gauge, and Sparkline visualizations with interactive time-range filters, series toggles, and live randomized data triggers.
4. **Shapes Gallery & Shape Builder Studio**: 30+ categorized shape gallery with a dedicated interactive Shape Builder featuring 2D touch drag/pan physics, live sliders for size/stroke/rotation, color picker, animation toggles, and instant Dart code export.
5. **ASCII & Effects Studio**: Multi-tab live studio for animated ASCII art, parametric math curves, and procedural canvas shaders with interactive controls for resolution, rotation speed, and progress.
6. **Production Blocks**:
   - **Auth**: Login, Sign Up (with live 4-tier brutalist password strength meter), Forgot Password, and 6-digit OTP verification.
   - **Error & Status**: Brutalist 404 Not Found, 500 Server Error, and Maintenance / System Status page.
   - **Settings**: Account Settings with Profile, Notification Toggles, Billing, and Theme mode options.
   - **Onboarding**: 4-step interactive onboarding flow with smooth step transitions and progress tracking.
   - **Invoice**: Dynamic interactive invoice with live item addition/removal, quantity steppers, and instant subtotal, 15% tax, and total recalculation.
   - **Marketing**: Testimonials grid, Pricing tiers with monthly/annual toggle, Team directory with tap-to-inspect profile modals, Searchable FAQ accordion, and Contact form with validation.
7. **Theme Builder**: Live theme customizer for primary, secondary, and accent colors, border width, and shadow offset that dynamically injects tokens app-wide via Riverpod and exports Dart configuration code.
8. **Settings & About**: Light / Dark / System theme switcher with persistence, credits, and MIT license disclosure.

---

## 🏗️ Architecture

```
boldkit_flutter/
├── lib/
│   ├── core/
│   │   ├── router.dart             # go_router configuration with shell navigation
│   │   ├── shell_scaffold.dart     # Responsive brutalist bottom navigation scaffold
│   │   ├── theme/
│   │   │   ├── bk_theme.dart       # ThemeData builder (light & dark)
│   │   │   ├── bk_tokens.dart      # Design token ThemeExtension & context.bk getter
│   │   │   └── bk_motion.dart      # Brutalist spring curves, press timings, haptics
│   │   └── widgets/                # The complete Bk* component library
│   │       ├── bk_widgets.dart     # Barrel export file
│   │       ├── bk_button.dart
│   │       ├── bk_card.dart
│   │       ├── bk_input.dart
│   │       ├── bk_select.dart
│   │       ├── bk_slider.dart
│   │       ├── bk_rating.dart
│   │       ├── bk_data_table.dart
│   │       ├── bk_command_palette.dart
│   │       └── ...
│   ├── data/
│   │   └── mock_data.dart          # Local mock data models & collections (no backend)
│   ├── features/
│   │   ├── home/
│   │   ├── components/
│   │   ├── charts/
│   │   ├── shapes/
│   │   ├── ascii_effects/
│   │   ├── theme_builder/
│   │   ├── blocks/
│   │   └── settings/
│   └── main.dart
├── test/
│   ├── widget_test.dart            # Unit and widget tests (BkButton, BkInput, BkSelect, BkSlider, BkRating, BkDataTable, BkCommandPalette, Theme persistence)
│   └── responsive_render_test.dart # 20 test matrices across 5 viewports (320px to 1280px), light/dark, 1.0x & 1.3x text scales
├── docs/
│   └── PORT_PLAN.md                # Mapping and port inventory
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+ and Dart 3.0+
- Android Studio or VS Code

### Opening in Android Studio
> [!IMPORTANT]
> **Open `boldkit_flutter` directly in Android Studio**, NOT the outer parent folder.
> Android Studio expects `pubspec.yaml`, `lib/`, and `android/` directly in the project root to correctly configure the Flutter SDK and device runners.

```
Path to open: D:\boltkit ui\boldkit_flutter
```

### Installation & Run

```bash
# 1. Navigate to the project directory
cd boldkit_flutter

# 2. Install dependencies
flutter pub get

# 3. Run the app on your preferred target
flutter run -d chrome    # Web
flutter run -d android   # Android emulator or physical device (e.g., CPH2767)
```

### Running Tests
```bash
flutter test
```
All 29 tests pass with 0 errors and 0 warnings:
- 9 Unit & Widget Tests: `BkButton`, `BkInput`, `BkBadge`, `BkSelect`, `BkSlider`, `BkRating`, `BkDataTable`, `BkCommandPalette`, and Riverpod `themeModeProvider` persistence.
- 20 Responsive Layout Tests: Zero render overflow across 320x640, 360x800, 412x915, 768x1024, and 1280x800 viewports at 1.0x and 1.3x text scales in both Light and Dark themes.

---

## 📐 Engineering Decisions & Porting Notes

- **Strict Neubrutalism**: 3px solid borders, hard `4px 4px 0px` offset shadow with 0 blur, strictly `BorderRadius.zero` everywhere, high-contrast flat color palette, and bold uppercase Outfit and DM Mono typography.
- **Theme Architecture**: Single source of truth via Riverpod `themeModeProvider` (`ThemeMode.light` / `ThemeMode.dark` / `ThemeMode.system`) backed by `shared_preferences`. Preloaded before `runApp` to eliminate theme flash on launch. Full token exposure through `BkTokens` ThemeExtension and `context.bk` extension getter. Live dynamic overrides through `customThemeTokensProvider`.
- **Dynamic Micro-Interactions**: Interactive hero typewriter headline cycling across dynamic keywords, real-time animated ASCII geometric projections with ticker synchronization, and brutalist tactile press translations (2px offset reduction with 0 blur).
- **Responsive Architecture**: All 24 screens and 75+ components are engineered for flexible rendering across compact mobile (`320x640`), standard mobile (`360x800`, `412x915`), tablet (`768x1024`), and desktop (`1280x800`) viewports with text scales up to `1.3x`. Eliminates hardcoded heights and double-nested card padding, ensuring 0 layout overflows.
- **Offline / Local Data**: Completely self-contained with no external backend requirement. All mocks, settings, themes, and states operate in-memory or through local device preferences.

---

## ⚖️ License and Credit

BoldKit is open source under the **MIT License**.

> **Design system ported from [BoldKit](https://github.com/ANIBIT14/boldkit) by Aniruddha Agarwal.**  
> Original React & Vue implementation Copyright (c) 2025 BoldKit.

