/// Mock data for BoldKit Flutter app.
/// All data is local — no backend.
library;

// ─── Team members ──────────────────────────────────────────────────────────

class MockTeamMember {
  const MockTeamMember({
    required this.name,
    required this.role,
    required this.bio,
    required this.avatarInitials,
    required this.avatarColor,
  });

  final String name;
  final String role;
  final String bio;
  final String avatarInitials;
  final int avatarColor;
}

const mockTeam = [
  MockTeamMember(
    name: 'Alex Chen',
    role: 'CEO & Co-Founder',
    bio: 'Building products that matter. Ex-Google, Stanford CS.',
    avatarInitials: 'AC',
    avatarColor: 0xFFEE7171,
  ),
  MockTeamMember(
    name: 'Sarah Kim',
    role: 'Head of Design',
    bio: 'Neubrutalism enthusiast. Making the web bold again.',
    avatarInitials: 'SK',
    avatarColor: 0xFF3DC9B3,
  ),
  MockTeamMember(
    name: 'Marcus Rivera',
    role: 'Lead Engineer',
    bio: 'Full-stack wizard. Open source contributor.',
    avatarInitials: 'MR',
    avatarColor: 0xFFFFD849,
  ),
  MockTeamMember(
    name: 'Priya Patel',
    role: 'Product Manager',
    bio: 'Obsessed with user experience and data.',
    avatarInitials: 'PP',
    avatarColor: 0xFF7C3ADB,
  ),
  MockTeamMember(
    name: 'James Okonkwo',
    role: 'DevOps Lead',
    bio: 'Infrastructure at scale. Kubernetes aficionado.',
    avatarInitials: 'JO',
    avatarColor: 0xFFE44C8A,
  ),
  MockTeamMember(
    name: 'Luna Nakamura',
    role: 'Marketing Director',
    bio: 'Brand storyteller. Making noise in a quiet world.',
    avatarInitials: 'LN',
    avatarColor: 0xFF5EDBA0,
  ),
];

// ─── Testimonials ──────────────────────────────────────────────────────────

class MockTestimonial {
  const MockTestimonial({
    required this.quote,
    required this.author,
    required this.role,
    required this.company,
    required this.rating,
    required this.avatarInitials,
    required this.avatarColor,
  });

  final String quote;
  final String author;
  final String role;
  final String company;
  final int rating;
  final String avatarInitials;
  final int avatarColor;
}

const mockTestimonials = [
  MockTestimonial(
    quote:
        'BoldKit completely transformed how we think about UI. The neubrutalism aesthetic is bold, fresh, and our users love it.',
    author: 'Emma Thompson',
    role: 'Product Designer',
    company: 'Figma',
    rating: 5,
    avatarInitials: 'ET',
    avatarColor: 0xFFEE7171,
  ),
  MockTestimonial(
    quote:
        'Finally a component library that doesn\'t look like every other SaaS product. Our brand stands out now.',
    author: 'David Park',
    role: 'CTO',
    company: 'Vercel',
    rating: 5,
    avatarInitials: 'DP',
    avatarColor: 0xFF3DC9B3,
  ),
  MockTestimonial(
    quote:
        'The documentation is excellent and the components just work. Saved us weeks of design work.',
    author: 'Aria Santos',
    role: 'Frontend Lead',
    company: 'Stripe',
    rating: 5,
    avatarInitials: 'AS',
    avatarColor: 0xFFFFD849,
  ),
  MockTestimonial(
    quote:
        'We used BoldKit for our rebrand and the result was phenomenal. Clients are obsessed with the aesthetic.',
    author: 'Tom Bradley',
    role: 'Creative Director',
    company: 'Awwwards',
    rating: 5,
    avatarInitials: 'TB',
    avatarColor: 0xFF7C3ADB,
  ),
  MockTestimonial(
    quote:
        'The brutalist press animations on buttons alone are worth it. Feels so satisfying to use.',
    author: 'Nina Volkova',
    role: 'UX Engineer',
    company: 'Linear',
    rating: 5,
    avatarInitials: 'NV',
    avatarColor: 0xFFE44C8A,
  ),
  MockTestimonial(
    quote:
        'Dark mode support is flawless. Every token translates perfectly between modes.',
    author: 'Carlos Mendez',
    role: 'Full Stack Developer',
    company: 'Netlify',
    rating: 4,
    avatarInitials: 'CM',
    avatarColor: 0xFF5EDBA0,
  ),
];

// ─── FAQ ───────────────────────────────────────────────────────────────────

class MockFaq {
  const MockFaq({required this.question, required this.answer});
  final String question;
  final String answer;
}

const mockFaqs = [
  MockFaq(
    question: 'What is neubrutalism?',
    answer:
        'Neubrutalism is a web design trend that combines brutalism\'s raw, structural elements with modern aesthetics. It features bold borders, flat hard shadows, high-contrast colors, and intentionally clashing typography.',
  ),
  MockFaq(
    question: 'Is BoldKit free to use?',
    answer:
        'Yes! BoldKit is completely free and open source under the MIT license. You can use it in personal and commercial projects without restrictions.',
  ),
  MockFaq(
    question: 'How do I customize the colors?',
    answer:
        'Colors are defined as design tokens in BkTokens. Use the Theme Builder screen to preview changes live, then copy the generated token values into your BkTokens configuration.',
  ),
  MockFaq(
    question: 'Does it support dark mode?',
    answer:
        'Absolutely. Every component has full dark mode support. The theme automatically switches based on the system setting or can be toggled manually via the theme provider.',
  ),
  MockFaq(
    question: 'Can I use just some components?',
    answer:
        'Yes. Each Bk* widget is a standalone Flutter widget. Import only what you need — there are no mandatory peer dependencies beyond the core theme.',
  ),
  MockFaq(
    question: 'How do I add a new component?',
    answer:
        'Create a new file in lib/core/widgets/ following the Bk* naming convention. Use BkTokens.of(context) for design tokens. See CONTRIBUTING.md for the full guide.',
  ),
];

// ─── Pricing plans ─────────────────────────────────────────────────────────

class MockPricingPlan {
  const MockPricingPlan({
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    required this.ctaLabel,
    required this.highlighted,
    required this.badgeLabel,
  });

  final String name;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final String ctaLabel;
  final bool highlighted;
  final String? badgeLabel;
}

const mockPricingPlans = [
  MockPricingPlan(
    name: 'Starter',
    price: '\$0',
    period: '/month',
    description: 'Perfect for side projects and learning.',
    features: [
      'All core components',
      'MIT license',
      'Community support',
      '5 template blocks',
      'Light & dark mode',
    ],
    ctaLabel: 'Get Started Free',
    highlighted: false,
    badgeLabel: null,
  ),
  MockPricingPlan(
    name: 'Pro',
    price: '\$29',
    period: '/month',
    description: 'For teams building production apps.',
    features: [
      'Everything in Starter',
      'Priority support',
      'All template blocks',
      'Custom theme generator',
      'Figma kit',
      'Early access to new components',
    ],
    ctaLabel: 'Start Pro Trial',
    highlighted: true,
    badgeLabel: 'MOST POPULAR',
  ),
  MockPricingPlan(
    name: 'Enterprise',
    price: '\$99',
    period: '/month',
    description: 'Custom solutions for large organizations.',
    features: [
      'Everything in Pro',
      'Dedicated support',
      'Custom component development',
      'SLA guarantee',
      'Onboarding session',
      'Unlimited seats',
    ],
    ctaLabel: 'Contact Sales',
    highlighted: false,
    badgeLabel: null,
  ),
];

// ─── Stats ─────────────────────────────────────────────────────────────────

class MockStat {
  const MockStat(
      {required this.label, required this.value, required this.suffix});
  final String label;
  final String value;
  final String suffix;
}

const mockStats = [
  MockStat(label: 'Components', value: '75+', suffix: ''),
  MockStat(label: 'GitHub Stars', value: '2.8', suffix: 'K'),
  MockStat(label: 'Weekly Downloads', value: '12', suffix: 'K'),
  MockStat(label: 'Contributors', value: '48', suffix: ''),
];

// ─── Chart sample data ─────────────────────────────────────────────────────

class MockChartMonth {
  const MockChartMonth(
      {required this.month, required this.value, required this.value2});
  final String month;
  final double value;
  final double value2;
}

const mockMonthlyData = [
  MockChartMonth(month: 'JAN', value: 65, value2: 40),
  MockChartMonth(month: 'FEB', value: 78, value2: 55),
  MockChartMonth(month: 'MAR', value: 90, value2: 70),
  MockChartMonth(month: 'APR', value: 81, value2: 62),
  MockChartMonth(month: 'MAY', value: 56, value2: 48),
  MockChartMonth(month: 'JUN', value: 95, value2: 83),
  MockChartMonth(month: 'JUL', value: 110, value2: 91),
  MockChartMonth(month: 'AUG', value: 98, value2: 79),
  MockChartMonth(month: 'SEP', value: 120, value2: 95),
  MockChartMonth(month: 'OCT', value: 88, value2: 72),
  MockChartMonth(month: 'NOV', value: 132, value2: 108),
  MockChartMonth(month: 'DEC', value: 145, value2: 120),
];

// ─── Invoice ───────────────────────────────────────────────────────────────

class MockInvoiceItem {
  const MockInvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  final String description;
  final int quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;
}

const mockInvoiceItems = [
  MockInvoiceItem(
      description: 'UI Component Library — BoldKit Pro License',
      quantity: 1,
      unitPrice: 299.00),
  MockInvoiceItem(
      description: 'Custom Theme Development', quantity: 3, unitPrice: 150.00),
  MockInvoiceItem(
      description: 'Figma Design Kit', quantity: 1, unitPrice: 49.00),
  MockInvoiceItem(
      description: 'Priority Support (3 months)',
      quantity: 3,
      unitPrice: 30.00),
];

// ─── Components catalog data ────────────────────────────────────────────────

class MockComponentInfo {
  const MockComponentInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
}

const mockComponents = [
  // Core
  MockComponentInfo(
      id: 'button',
      name: 'Button',
      description: 'Brutalist button with push animation and 8 variants.',
      category: 'Core',
      tags: ['interactive', 'form', 'action']),
  MockComponentInfo(
      id: 'card',
      name: 'Card',
      description:
          'Container with hard shadow and optional interactive press effect.',
      category: 'Core',
      tags: ['layout', 'container']),
  MockComponentInfo(
      id: 'layered-card',
      name: 'Layered Card',
      description: 'Stacked paper effect with 1-3 offset layers.',
      category: 'Core',
      tags: ['layout', 'decorative']),
  MockComponentInfo(
      id: 'badge',
      name: 'Badge',
      description: 'Compact inline label with 8 color variants.',
      category: 'Core',
      tags: ['label', 'status']),
  MockComponentInfo(
      id: 'sticker',
      name: 'Sticker',
      description: 'Rotated label, stamp, and sticky note widgets.',
      category: 'Core',
      tags: ['decorative', 'label']),
  MockComponentInfo(
      id: 'avatar',
      name: 'Avatar',
      description: 'Square user avatar with initials fallback.',
      category: 'Core',
      tags: ['user', 'identity']),
  MockComponentInfo(
      id: 'stat-card',
      name: 'Stat Card',
      description: 'KPI card with trend indicator and progress bar.',
      category: 'Core',
      tags: ['dashboard', 'data']),
  MockComponentInfo(
      id: 'marquee',
      name: 'Marquee',
      description: 'Continuously scrolling ticker tape.',
      category: 'Core',
      tags: ['animation', 'scroll']),
  MockComponentInfo(
      id: 'separator',
      name: 'Separator',
      description: '3px divider line.',
      category: 'Core',
      tags: ['layout']),
  MockComponentInfo(
      id: 'kbd',
      name: 'Kbd',
      description: 'Keyboard key label.',
      category: 'Core',
      tags: ['code', 'label']),
  // Form
  MockComponentInfo(
      id: 'input',
      name: 'Input',
      description: 'Text input with brutalist border styling.',
      category: 'Form',
      tags: ['form', 'text']),
  MockComponentInfo(
      id: 'textarea',
      name: 'Textarea',
      description: 'Multi-line text input.',
      category: 'Form',
      tags: ['form', 'text']),
  MockComponentInfo(
      id: 'checkbox',
      name: 'Checkbox',
      description: 'Square checkbox with custom painter.',
      category: 'Form',
      tags: ['form', 'selection']),
  MockComponentInfo(
      id: 'radio',
      name: 'Radio Group',
      description: 'Square radio button group.',
      category: 'Form',
      tags: ['form', 'selection']),
  MockComponentInfo(
      id: 'select',
      name: 'Select',
      description: 'Bottom sheet picker.',
      category: 'Form',
      tags: ['form', 'dropdown']),
  MockComponentInfo(
      id: 'switch',
      name: 'Switch',
      description: 'Rectangular toggle switch.',
      category: 'Form',
      tags: ['form', 'toggle']),
  MockComponentInfo(
      id: 'slider',
      name: 'Slider',
      description: 'Range slider with brutalist thumb.',
      category: 'Form',
      tags: ['form', 'range']),
  MockComponentInfo(
      id: 'otp-input',
      name: 'OTP Input',
      description: '6-digit one-time password input.',
      category: 'Form',
      tags: ['form', 'auth']),
  MockComponentInfo(
      id: 'tag-input',
      name: 'Tag Input',
      description: 'Multi-value input with removable tags.',
      category: 'Form',
      tags: ['form', 'multi']),
  MockComponentInfo(
      id: 'rating',
      name: 'Rating',
      description: 'Half-star rating widget.',
      category: 'Form',
      tags: ['form', 'feedback']),
  MockComponentInfo(
      id: 'combobox',
      name: 'Combobox',
      description: 'Searchable dropdown.',
      category: 'Form',
      tags: ['form', 'search']),
  // Overlay
  MockComponentInfo(
      id: 'dialog',
      name: 'Dialog',
      description: 'Brutalist modal dialog.',
      category: 'Overlay',
      tags: ['modal', 'feedback']),
  MockComponentInfo(
      id: 'alert-dialog',
      name: 'Alert Dialog',
      description: 'Confirmation dialog with actions.',
      category: 'Overlay',
      tags: ['modal', 'confirm']),
  MockComponentInfo(
      id: 'bottom-sheet',
      name: 'Bottom Sheet',
      description: 'Slides up from bottom.',
      category: 'Overlay',
      tags: ['modal', 'panel']),
  MockComponentInfo(
      id: 'toast',
      name: 'Toast',
      description: 'Queued notification overlay.',
      category: 'Overlay',
      tags: ['notification', 'feedback']),
  MockComponentInfo(
      id: 'alert',
      name: 'Alert',
      description: 'Inline alert with 4 severity levels.',
      category: 'Overlay',
      tags: ['notification', 'feedback']),
  MockComponentInfo(
      id: 'progress',
      name: 'Progress',
      description: 'Linear progress with brutalist border.',
      category: 'Overlay',
      tags: ['loading', 'feedback']),
  MockComponentInfo(
      id: 'skeleton',
      name: 'Skeleton',
      description: 'Shimmer loading placeholder.',
      category: 'Overlay',
      tags: ['loading', 'placeholder']),
  MockComponentInfo(
      id: 'spinner',
      name: 'Spinner',
      description: '5 animation variants of loading spinner.',
      category: 'Overlay',
      tags: ['loading', 'animation']),
  MockComponentInfo(
      id: 'tooltip',
      name: 'Tooltip',
      description: 'Brutalist tooltip with square arrow.',
      category: 'Overlay',
      tags: ['help', 'ui']),
  // Navigation
  MockComponentInfo(
      id: 'tabs',
      name: 'Tabs',
      description: 'Tab bar with solid active indicator.',
      category: 'Navigation',
      tags: ['navigation', 'layout']),
  MockComponentInfo(
      id: 'accordion',
      name: 'Accordion',
      description: 'Collapsible content sections.',
      category: 'Navigation',
      tags: ['layout', 'content']),
  MockComponentInfo(
      id: 'stepper',
      name: 'Stepper',
      description: 'Multi-step progress indicator.',
      category: 'Navigation',
      tags: ['navigation', 'form']),
  MockComponentInfo(
      id: 'breadcrumb',
      name: 'Breadcrumb',
      description: 'Location path breadcrumbs.',
      category: 'Navigation',
      tags: ['navigation']),
  MockComponentInfo(
      id: 'pagination',
      name: 'Pagination',
      description: 'Page number navigation.',
      category: 'Navigation',
      tags: ['navigation', 'data']),
  MockComponentInfo(
      id: 'timeline',
      name: 'Timeline',
      description: 'Vertical timeline with connecting lines.',
      category: 'Navigation',
      tags: ['layout', 'content']),
  MockComponentInfo(
      id: 'carousel',
      name: 'Carousel',
      description: 'Swipeable card carousel.',
      category: 'Navigation',
      tags: ['layout', 'gallery']),
  MockComponentInfo(
      id: 'data-table',
      name: 'Data Table',
      description: 'Sortable, filterable data table.',
      category: 'Navigation',
      tags: ['data', 'table']),
];
