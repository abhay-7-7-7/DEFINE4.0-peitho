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
- **Core**: `BkButton` (8 variants, 5 sizes, loading state, icon support, brutalist push effect), `BkCard`, `BkLayeredCard` (multi-layered stacked paper effect), `BkStatCard`, `BkBadge` (8 variants), `BkSticker` (rotated labels, stamps, sticky notes), `BkMarquee` (scrolling ticker with reduced-motion support), `BkAvatar`, `BkSeparator`, `BkKbd`.
- **Forms**: `BkInput`, `BkTextarea`, `BkCheckbox` (square CustomPainter checkmark), `BkRadioGroup`, `BkSwitch` (rectangular track, square thumb), `BkSlider`, `BkOtpInput` (6-digit auto-advancing), `BkCombobox`, `BkTagInput`.
- **Overlays & Feedback**: `showBkDialog`, `showBkAlertDialog`, `showBkBottomSheet`, `showBkSideSheet`, `BkToastManager` (queued snackbar replacement), `BkAlert` (4 severity tiers), `BkProgress` (determinate & indeterminate linear indicator), `BkSkeleton` (shimmer loading placeholder), `BkSpinner` (5 animation variants: ring, dots, bars, blocks, brutal), `BkTooltip`.
- **Navigation & Layout**: `BkTabs` (solid color active fill), `BkAccordion` (single & multi-expandable), `BkStepper` (horizontal & vertical multi-step indicator), `BkPagination`, `BkDataTable`.
- **Charts**: `BkBarChart`, `BkLineChart`, `BkPieChart`, `BkDonutChart`, `BkRadarChart`, `BkGaugeChart`, `BkSparkline` styled with brutalist borders and shadows via `fl_chart` and `CustomPainter`.
- **Decorative**:
  - **30+ CustomPainter SVG Shapes**: Triangle, Diamond, Pentagon, Hexagon, Octagon, Cross, Arrow, Chevron, Blob, Cloud, Splash, Leaf, Flower, Heart, Star, Moon, Sun, Lightning, Rocket, Planet, Cosmic Ring, Infinity, Spiral, Fractal, Mobius, Wave, Gear, Cog, Circuit, Target, Shield, Bracket.
  - **17 Animated ASCII Shapes**: Torus, Donut, Sphere, Cube, Helix, Trefoil Knot, Geodesic Dome, Saturn, Hyperboloid, DNA, Spiral, Rose, Wave, Vortex, Pulse, Matrix, Grid with customizable charsets, speed, and multicolor palette.
  - **Parametric Math Curves**: `BkMathCurveLoader`, `BkMathCurveProgress` with Rose, Lissajous, Spirograph, Butterfly, Cardioid, Epitrochoid curves.
  - **Canvas Shaders**: `BkCanvasEffect` with Mesh Gradient, Aurora, Plasma, Halftone, Truchet, Flow Field, CRT scanlines, and Metaballs.

### 2. Complete Application Screens (`lib/features/`)
1. **Home**: Bold hero header, marquee ticker, stat cards, feature grid, shapes showcase, CTA.
2. **Components Catalog**: Searchable, filterable catalog of all 75+ components with detail views featuring live interactive demos, variant/size selectors, and collapsible Dart code usage snippets.
3. **Charts**: Showcase of Bar, Line, Area, Pie, Donut, Gauge, and Sparkline visualizations with realistic mock data.
4. **Shapes Gallery & Shape Builder**: 30+ categorized shape gallery with a dedicated interactive Shape Builder to customize size, stroke width, fill, colors, and animations with instant Dart code generation.
5. **ASCII & Effects Studio**: Multi-tab live studio for animated ASCII art, parametric math curves, and procedural canvas shaders.
6. **Production Blocks**:
   - **Auth**: Login, Sign Up, Forgot Password, and 6-digit OTP verification.
   - **Error & Status**: Brutalist 404 Not Found, 500 Server Error, and Maintenance / System Status page.
   - **Settings**: Account Settings with Profile, Notification Toggles, and Billing tabs.
   - **Onboarding**: 4-step interactive onboarding flow with horizontal Stepper.
   - **Invoice**: Professional printable invoice with line items, tax calculations, and status badges.
   - **Marketing**: Testimonials grid, Pricing tiers with annual toggle, Team directory, Searchable FAQ accordion, and Contact form.
7. **Theme Builder**: Live editor for primary/secondary/accent colors, border width, and shadow offset that updates the app preview live and exports token code.
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
│   │   │   ├── bk_theme.dart       # ThemeData builder (Material 3 disabled)
│   │   │   └── bk_tokens.dart      # Design token ThemeExtension (light & dark mode)
│   │   └── widgets/                # The complete Bk* component library
│   │       ├── bk_widgets.dart     # Barrel export file
│   │       ├── bk_button.dart
│   │       ├── bk_card.dart
│   │       ├── bk_input.dart
│   │       ├── bk_shapes.dart
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
│   │   │   ├── auth/
│   │   │   ├── error/
│   │   │   ├── marketing/
│   │   │   ├── onboarding/
│   │   │   ├── invoice/
│   │   │   └── settings/
│   │   └── settings/
│   └── main.dart
├── test/
│   └── widget_test.dart            # Unit and widget tests
├── docs/
│   └── PORT_PLAN.md                # Mapping and port manifesto
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+ and Dart 3.0+

### Installation & Run

```bash
# 1. Navigate to the project directory
cd boldkit_flutter

# 2. Install dependencies
flutter pub get

# 3. Run the app on your preferred target
flutter run -d chrome    # Web
flutter run -d android   # Android emulator or device
flutter run -d ios       # iOS simulator
```

### Running Tests
```bash
flutter test
```

---

## 🛠️ How to Add a New Component

1. Create a new file in `lib/core/widgets/bk_<name>.dart`.
2. Access tokens using `final t = BkTokens.of(context);`.
3. Adhere to design rules:
   - Border: `Border.all(color: t.border, width: t.borderWidth)`
   - Shadow: `BoxShadow(color: t.shadowColor, offset: Offset(t.shadowOffset, t.shadowOffset), blurRadius: 0)`
   - Radius: strictly `BorderRadius.zero`
   - Typography: `GoogleFonts.outfit()` with bold weights and uppercase labels
4. Export the new widget from `lib/core/widgets/bk_widgets.dart`.
5. Register it in `lib/data/mock_data.dart` to automatically list it in the searchable Components catalog!

---

## 📐 Engineering Decisions & Porting Notes

- **Typography**: Configured via `google_fonts` package using `GoogleFonts.outfit()` for UI text and `GoogleFonts.dmMono()` for code, monospace, and ASCII renders.
- **Button Sizing API**: Standardized default button sizing with `BkButtonSize.defaultSize = BkButtonSize.md` and added unified icon sizing handling across all screen call sites.
- **Badge API**: Standardized `label:` parameter across all `BkBadge` variants.
- **Responsive Architecture**: All screens and components are engineered for flexible rendering across mobile (360px), tablet (768px), and desktop (1280px+) with wrapping rows, flex layouts, and scrollable containers to ensure zero layout overflows (yellow/black stripe free).
- **Automated Verification**: Comprehensive test suite under `test/` verifying individual widget behavior (`widget_test.dart`) and multi-viewport rendering integrity across all 24 app screens in both Light and Dark themes (`responsive_render_test.dart`).

---

## ⚖️ License and Credit

BoldKit is open source under the **MIT License**.

> **Design system ported from [BoldKit](https://github.com/ANIBIT14/boldkit) by Aniruddha Agarwal.**  
> Original React & Vue implementation Copyright (c) 2025 BoldKit.
