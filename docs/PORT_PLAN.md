# BoldKit → Flutter Port Plan

> **Design System**: BoldKit by Aniruddha Agarwal (MIT License)  
> **Source Repository**: https://github.com/ANIBIT14/boldkit  
> **Target**: `boldkit_flutter/` (Flutter + Dart 3, Null-Safe)

---

## 1. Design Language & Tokens

### Color Tokens (HSL → Flutter Hex)

| Token | Light (HSL) | Light Hex | Dark (HSL) | Dark Hex |
|---|---|---|---|---|
| `background` | `60 9% 98%` | `#FAFAF7` | `240 10% 10%` | `#181820` |
| `foreground` | `240 10% 10%` | `#181820` | `60 9% 98%` | `#FAFAF7` |
| `card` | `0 0% 100%` | `#FFFFFF` | `240 10% 14%` | `#21212D` |
| `card-foreground` | `240 10% 10%` | `#181820` | `60 9% 98%` | `#FAFAF7` |
| `primary` (coral) | `0 84% 71%` | `#EE7171` | `0 84% 71%` | `#EE7171` |
| `primary-foreground` | `240 10% 10%` | `#181820` | `240 10% 10%` | `#181820` |
| `secondary` (teal) | `174 62% 56%` | `#3DC9B3` | `174 62% 56%` | `#3DC9B3` |
| `secondary-foreground` | `240 10% 10%` | `#181820` | `240 10% 10%` | `#181820` |
| `accent` (yellow) | `49 100% 71%` | `#FFD849` | `49 100% 71%` | `#FFD849` |
| `accent-foreground` | `240 10% 10%` | `#181820` | `240 10% 10%` | `#181820` |
| `muted` | `60 5% 90%` | `#E6E6E0` | `240 10% 20%` | `#2E2E3D` |
| `muted-foreground` | `240 5% 38%` | `#5C5C6E` | `60 5% 65%` | `#A3A39A` |
| `destructive` | `0 84% 47%` | `#D92B2B` | `0 84% 47%` | `#D92B2B` |
| `destructive-foreground` | `0 0% 100%` | `#FFFFFF` | `0 0% 100%` | `#FFFFFF` |
| `success` | `152 69% 69%` | `#5EDBA0` | `152 69% 69%` | `#5EDBA0` |
| `warning` | `49 100% 60%` | `#FFCC1A` | `49 100% 60%` | `#FFCC1A` |
| `info` | `212 100% 73%` | `#75BBFF` | `212 100% 73%` | `#75BBFF` |
| `border` | `240 10% 10%` | `#181820` | `60 9% 98%` | `#FAFAF7` |
| `shadow-color` | `240 10% 10%` | `#181820` | `0 0% 0%` | `#000000` |

### Chart Colors
- `chart-1`: `#EE7171` (Coral)
- `chart-2`: `#3DC9B3` (Teal)
- `chart-3`: `#FFD849` (Yellow)
- `chart-4`: `#7C3ADB` (Purple)
- `chart-5`: `#E44C8A` (Magenta)

### Typography
- Primary UI: **Outfit** (`google_fonts`) — 700 / 900 bold uppercase styles
- Monospace / ASCII / Code: **DM Mono** (`google_fonts`)

### Neubrutalism Design Metrics
- **Border**: `3px` solid (`borderWidth`)
- **Shadow**: `4px 4px 0px` hard offset, `blurRadius: 0` (`shadowOffset`)
- **Radius**: `0px` (`BorderRadius.zero`)
- **Press Interaction**: On press, `translate(2px, 2px)` and shadow shrinks to 0.

---

## 2. Component Inventory & Flutter Mapping

| React/Vue Component | Flutter Component (`lib/core/widgets/`) | Implementation Status |
|---|---|---|
| `Button` | `BkButton` (8 variants, 5 sizes, loading, push effect) | Complete |
| `Card` | `BkCard`, `BkCardHeader`, `BkCardContent`, etc. | Complete |
| `LayeredCard` | `BkLayeredCard` (1-3 offset layers) | Complete |
| `StatCard` | `BkStatCard` (KPI + trend + progress) | Complete |
| `Badge` | `BkBadge` (8 variants) | Complete |
| `Sticker`, `Stamp`, `StickyNote` | `BkSticker`, `BkStamp`, `BkStickyNote` | Complete |
| `Marquee` | `BkMarquee` (ticker tape + reduced-motion) | Complete |
| `Input`, `Textarea` | `BkInput`, `BkTextarea` (3px border, label) | Complete |
| `InputOtp` | `BkOtpInput` (6 boxes auto-focus) | Complete |
| `Checkbox` | `BkCheckbox` (square CustomPainter check) | Complete |
| `RadioGroup` | `BkRadioGroup` | Complete |
| `Switch` | `BkSwitch` (rectangular track, square thumb) | Complete |
| `Dialog`, `AlertDialog` | `showBkDialog`, `showBkAlertDialog` | Complete |
| `Drawer`, `Sheet` | `showBkBottomSheet`, `showBkSideSheet` | Complete |
| `Sonner` (toast) | `BkToastManager` (queued overlay) | Complete |
| `Alert` | `BkAlert` (4 severities) | Complete |
| `Progress` | `BkProgress` (determinate & indeterminate) | Complete |
| `Skeleton` | `BkSkeleton` (shimmer animation) | Complete |
| `Spinner` | `BkSpinner` (ring, dots, bars, blocks, brutal) | Complete |
| `Tooltip` | `BkTooltip` (hard shadow, square styling) | Complete |
| `Tabs` | `BkTabs` (solid color active fill) | Complete |
| `Accordion` | `BkAccordion` (single & multi-expand) | Complete |
| `Stepper` | `BkStepper` (horizontal & vertical) | Complete |
| `Pagination` | `BkPagination` (1 2 3 ... N) | Complete |
| `Charts` (all types) | `BkBarChart`, `BkLineChart`, `BkPieChart`, `BkGaugeChart`, `BkSparkline` | Complete |
| `Shapes` (30+ SVG) | `BkShape` (CustomPainter paths) | Complete |
| `AsciiShapes` (17) | `BkAsciiShape` (animated math grid engine) | Complete |
| `MathCurves` | `BkMathCurveLoader`, `BkMathCurveProgress` | Complete |
| `CanvasEffects` | `BkCanvasEffect` (8 shaders via CustomPainter + Ticker) | Complete |

---

## 3. Screen Routing Map

| Route | Feature / Screen | File Path |
|---|---|---|
| `/` | Home Screen | `lib/features/home/home_screen.dart` |
| `/components` | Components Catalog | `lib/features/components/components_screen.dart` |
| `/components/:id` | Component Detail & Live Demo | `lib/features/components/component_detail_screen.dart` |
| `/charts` | Charts Showcase | `lib/features/charts/charts_screen.dart` |
| `/shapes` | 30+ Shapes Gallery | `lib/features/shapes/shapes_screen.dart` |
| `/shapes/builder` | Interactive Shape Builder | `lib/features/shapes/shape_builder_screen.dart` |
| `/ascii` | ASCII Art, Math Curves & Shaders | `lib/features/ascii_effects/ascii_effects_screen.dart` |
| `/theme-builder` | Live Theme Token Editor | `lib/features/theme_builder/theme_builder_screen.dart` |
| `/settings` | Settings & About | `lib/features/settings/settings_about_screen.dart` |
| `/blocks/login` | Login Form Block | `lib/features/blocks/auth/login_screen.dart` |
| `/blocks/signup` | Signup Form Block | `lib/features/blocks/auth/signup_screen.dart` |
| `/blocks/forgot-password` | Forgot Password Block | `lib/features/blocks/auth/forgot_password_screen.dart` |
| `/blocks/otp` | OTP Verification Block | `lib/features/blocks/auth/otp_screen.dart` |
| `/blocks/404` | 404 Not Found Block | `lib/features/blocks/error/error_404_screen.dart` |
| `/blocks/500` | 500 Server Error Block | `lib/features/blocks/error/error_500_screen.dart` |
| `/blocks/maintenance` | Maintenance Block | `lib/features/blocks/error/maintenance_screen.dart` |
| `/blocks/settings` | Account Settings Block | `lib/features/blocks/settings/settings_screen.dart` |
| `/blocks/onboarding` | Multi-step Onboarding Block | `lib/features/blocks/onboarding/onboarding_screen.dart` |
| `/blocks/invoice` | Printable Invoice Block | `lib/features/blocks/invoice/invoice_screen.dart` |
| `/blocks/testimonials` | Marketing Testimonials Block | `lib/features/blocks/marketing/testimonials_screen.dart` |
| `/blocks/pricing` | Pricing Plans Block | `lib/features/blocks/marketing/pricing_screen.dart` |
| `/blocks/team` | Team Directory Block | `lib/features/blocks/marketing/team_screen.dart` |
| `/blocks/faq` | Searchable FAQ Block | `lib/features/blocks/marketing/faq_screen.dart` |
| `/blocks/contact` | Contact Form Block | `lib/features/blocks/marketing/contact_screen.dart` |
