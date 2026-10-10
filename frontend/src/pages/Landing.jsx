import { useState, useId } from 'react';
import { Link } from 'react-router-dom';
import { 
  TrendingUp, 
  IndianRupee, 
  BarChart3, 
  MessageSquare, 
  Cpu, 
  Zap, 
  Target, 
  ArrowRight, 
  Shield, 
  Radio, 
  CheckCircle2, 
  Sliders, 
  Sparkles, 
  Clock, 
  Lock, 
  Scale, 
  RefreshCw, 
  Play, 
  Layers, 
  ChevronRight,
  AlertCircle,
  HelpCircle,
  Activity,
  Bot,
  Flame,
  Award
} from 'lucide-react';
import Layout from '../components/Layout';
import AlertBanner from '../components/AlertBanner';
import { useI18n } from '../context/I18nContext';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../components/ui/card';
import { Badge } from '../components/ui/badge';
import { StatCard } from '../components/ui/stat-card';
import { Progress } from '../components/ui/progress';
import { Marquee } from '../components/ui/marquee';

export default function Landing() {
  const { t } = useI18n();

  // Interactive Live Simulation State
  const [selectedMode, setSelectedMode] = useState('MAX_PROFIT'); // MAX_PROFIT | BALANCED | CLEAR_INVENTORY
  const [activeRound, setActiveRound] = useState(2); // 1, 2, 3
  const [showLockedModal, setShowLockedModal] = useState(false);

  // Strategy profiles data for interactive demonstration
  const strategyData = {
    MAX_PROFIT: {
      name: 'Max Profit',
      tagline: 'Conservative concessions • Prioritizes margin over volume',
      targetPrice: 1200,
      floorPrice: 920,
      costPrice: 800,
      rounds: [
        {
          round: 1,
          buyerOffer: 850,
          buyerText: "We need 20 units fast, but ₹1,200 is too steep. Can you do ₹850 right now?",
          posture: 'Price-Sensitive • High Urgency',
          pricingMath: { counter: 1140, profit: 340, margin: '29.8%', floorOk: true },
          agentPitch: "We can guarantee 24hr priority dispatch and full 2-year warranty at ₹1,140.",
          dealLikelihood: 38,
          trend: '+8 pts',
          isLockable: false
        },
        {
          round: 2,
          buyerOffer: 980,
          buyerText: "₹1,140 is over our budget. What if we meet in the middle at ₹980?",
          posture: 'Budget Testing • Moderate Concession',
          pricingMath: { counter: 1060, profit: 260, margin: '24.5%', floorOk: true },
          agentPitch: "At ₹1,060 we can include expedited freight and dedicated account onboarding.",
          dealLikelihood: 72,
          trend: '+34 pts',
          isLockable: false
        },
        {
          round: 3,
          buyerOffer: 1040,
          buyerText: "If you can do ₹1,040, I have immediate sign-off authority to wire payment today.",
          posture: 'Ready to Close • Target Margin Met',
          pricingMath: { counter: 1040, profit: 240, margin: '23.1%', floorOk: true, accepted: true },
          agentPitch: "Deal agreed at ₹1,040. Target profit margin of 23.1% secured. Ready to lock.",
          dealLikelihood: 94,
          trend: '+22 pts',
          isLockable: true
        }
      ]
    },
    BALANCED: {
      name: 'Balanced',
      tagline: 'Progressive concessions • Standard commercial curve',
      targetPrice: 1200,
      floorPrice: 860,
      costPrice: 800,
      rounds: [
        {
          round: 1,
          buyerOffer: 850,
          buyerText: "Can we do ₹850 for a batch of 20 units?",
          posture: 'Initial Anchor • High Interest',
          pricingMath: { counter: 1090, profit: 290, margin: '26.6%', floorOk: true },
          agentPitch: "Our volume pricing tier lands at ₹1,090 with comprehensive SLA coverage.",
          dealLikelihood: 45,
          trend: '+12 pts',
          isLockable: false
        },
        {
          round: 2,
          buyerOffer: 950,
          buyerText: "Could you come down to ₹950? We'll commit to a quarterly recurring contract.",
          posture: 'High Value • Relationship Potential',
          pricingMath: { counter: 1010, profit: 210, margin: '20.8%', floorOk: true },
          agentPitch: "At ₹1,010 we'll lock in recurring tier discounts and waived setup fees.",
          dealLikelihood: 81,
          trend: '+36 pts',
          isLockable: false
        },
        {
          round: 3,
          buyerOffer: 990,
          buyerText: "₹990 is our final approved figure. Can you shake on that?",
          posture: 'Closing Stage • Acceptable Margin',
          pricingMath: { counter: 990, profit: 190, margin: '19.2%', floorOk: true, accepted: true },
          agentPitch: "Accepted at ₹990. Concession curve satisfied, profit floor strictly defended.",
          dealLikelihood: 96,
          trend: '+15 pts',
          isLockable: true
        }
      ]
    },
    CLEAR_INVENTORY: {
      name: 'Clear Inventory',
      tagline: 'Volume acceleration • Flexible down to break-even floor',
      targetPrice: 1200,
      floorPrice: 810,
      costPrice: 800,
      rounds: [
        {
          round: 1,
          buyerOffer: 850,
          buyerText: "We take entire warehouse excess if price is right. ₹850 per unit?",
          posture: 'Bulk Buyer • High Clearance Velocity',
          pricingMath: { counter: 960, profit: 160, margin: '16.7%', floorOk: true },
          agentPitch: "For the entire lot, we can release inventory at ₹960 per unit immediately.",
          dealLikelihood: 58,
          trend: '+25 pts',
          isLockable: false
        },
        {
          round: 2,
          buyerOffer: 890,
          buyerText: "We can wire 100% upfront today for ₹890 all-inclusive.",
          posture: 'Cash Available • Immediate Clearance',
          pricingMath: { counter: 910, profit: 110, margin: '12.1%', floorOk: true },
          agentPitch: "At ₹910 we include palletization and immediate freight release.",
          dealLikelihood: 88,
          trend: '+30 pts',
          isLockable: true
        },
        {
          round: 3,
          buyerOffer: 900,
          buyerText: "Split difference at ₹900 and generate the purchase order now.",
          posture: 'Fast Turnover • Above ₹810 Floor',
          pricingMath: { counter: 900, profit: 100, margin: '11.1%', floorOk: true, accepted: true },
          agentPitch: "Deal locked at ₹900. Inventory cleared at +₹100 unit profit above cost.",
          dealLikelihood: 98,
          trend: '+10 pts',
          isLockable: true
        }
      ]
    }
  };

  const currentStrategy = strategyData[selectedMode];
  const currentSim = currentStrategy.rounds[activeRound - 1];

  const marqueeBadges = [
    { label: 'AI NEGOTIATION ENGINE ONLINE', icon: Zap, color: 'bg-neo-orange text-neo-navy' },
    { label: '100% MARGIN FLOOR PROTECTION', icon: Shield, color: 'bg-neo-teal text-neo-cream' },
    { label: 'LIVE MEETING DUAL-AUDIO COPILOT', icon: Radio, color: 'bg-neo-orange text-neo-navy' },
    { label: 'REAL-TIME DEAL LIKELIHOOD GAUGE', icon: Activity, color: 'bg-neo-navy text-neo-cream' },
    { label: 'DETERMINISTIC PRICING MATH (NON-LLM)', icon: Cpu, color: 'bg-neo-teal text-neo-cream' },
    { label: 'INSTANT DEAL LOCK TRIGGER', icon: Lock, color: 'bg-neo-orange text-neo-navy' },
    { label: '50+ LANGUAGES VIA GEMINI LIVE', icon: Sparkles, color: 'bg-neo-navy text-neo-cream' },
    { label: '<180MS DECISION LATENCY', icon: Clock, color: 'bg-neo-teal text-neo-cream' },
  ];

  const corePillars = [
    {
      title: 'Profit > Deal Closure',
      description: 'The engine protects seller margins with an iron hand. If a buyer stays below your absolute floor, Peitho walks away. Zero compromise.',
      icon: Shield,
      badge: 'CORE DIRECTIVE',
      badgeColor: 'bg-neo-orange text-neo-navy'
    },
    {
      title: 'Constraints > Intelligence',
      description: 'Hard business logic overrides language model suggestions — always. An LLM can never override your margin rules or offer unauthorized discounts.',
      icon: Lock,
      badge: 'DETERMINISTIC VETO',
      badgeColor: 'bg-neo-teal text-neo-cream'
    },
    {
      title: 'Rules > Language Models',
      description: 'LLMs generate conversational persuasive dialogue. Pure deterministic mathematics decides all numbers, concessions, and pricing curves.',
      icon: Cpu,
      badge: 'SEPARATION OF CONCERNS',
      badgeColor: 'bg-neo-navy text-neo-cream'
    },
    {
      title: 'Triple-Fallback Resilience',
      description: 'Zero runtime dependency failures. If primary LLM calls fail, heuristic mathematical algorithms take over; if heuristics fail, safety templates close the deal.',
      icon: Layers,
      badge: '100% UPTIME DESIGN',
      badgeColor: 'bg-neo-orange text-neo-navy'
    }
  ];

  const platformFeatures = [
    {
      title: 'Online Meeting Assistant',
      tag: 'LIVE SALES COPILOT',
      description: 'Real-time copilot for any online meeting (Google Meet, Zoom, Teams). Dual-channel audio capture, live deal scoring, and instant deal lock.',
      path: '/meet-assistant',
      ctaText: 'Launch Meeting Assistant',
      icon: Radio,
      badgeVariant: 'accent',
      stats: 'Dual Audio • Likelihood Meter • One-Click Lock'
    },
    {
      title: 'Auto-Negotiation Bot',
      tag: '24/7 AUTONOMOUS SELLER',
      description: 'Multi-round conversational negotiation bot. Automatically extracts buyer offers and executes mathematical concession curves.',
      path: '/jury',
      secondaryPath: '/chat',
      ctaText: 'View Negotiation Bot',
      secondaryText: 'Try Sandbox',
      icon: Bot,
      badgeVariant: 'default',
      stats: 'Multi-Round • Smart Offer Extraction'
    },
    {
      title: 'Product Catalog & Margins',
      tag: 'MARGIN GOVERNANCE',
      description: 'Define unit costs, target prices, and guaranteed floors per SKU with inventory-weighted concession rules.',
      path: '/products',
      ctaText: 'Manage Product Catalog',
      icon: Target,
      badgeVariant: 'secondary',
      stats: 'Per-SKU Cost, Target, Floor • CSV Bulk Import'
    },
    {
      title: 'Business Intelligence & Simulation',
      tag: 'PROFIT & SCENARIO ANALYTICS',
      description: 'Post-negotiation profit analytics, retained margins, and what-if counterfactual pricing simulations.',
      path: '/authority',
      ctaText: 'Open Analytics Engine',
      icon: BarChart3,
      badgeVariant: 'default',
      stats: 'What-If Simulator • Margin Funnels • Win/Loss Stats'
    }
  ];

  return (
    <Layout>
      {/* 1. TOP LIVE SYSTEM TICKER MARQUEE */}
      <div className="bg-neo-navy border-b-[3px] border-neo-navy text-neo-cream py-2.5 overflow-hidden">
        <Marquee speed={26} pauseOnHover={true}>
          {marqueeBadges.map((badge, idx) => {
            const Icon = badge.icon;
            return (
              <div
                key={idx}
                className="inline-flex items-center gap-2 mx-3 px-3 py-1 border-[2px] border-neo-cream text-xs font-heading font-black uppercase tracking-wider bg-neo-navy text-neo-cream shadow-[2px_2px_0px_#FFECD1]"
              >
                <Icon className="w-3.5 h-3.5 text-neo-orange animate-pulse" />
                <span>{badge.label}</span>
              </div>
            );
          })}
        </Marquee>
      </div>

      {/* 2. HERO SECTION */}
      <section className="relative overflow-hidden bg-neo-cream border-b-[4px] border-neo-navy pt-8 pb-12 sm:pt-12 sm:pb-16 lg:pt-14 lg:pb-16">
        {/* Subtle Background Decorative Neubrutalist Shapes (Confined to corners, zero content overlap) */}
        <div className="absolute inset-0 pointer-events-none opacity-15 overflow-hidden">
          <div className="absolute top-8 left-6 w-32 h-32 border-[4px] border-neo-navy rotate-12"></div>
          <div className="absolute top-20 right-8 w-24 h-24 border-[4px] border-neo-teal -rotate-12"></div>
        </div>

        <div className="container mx-auto px-4 max-w-7xl relative z-10">
          <div className="grid lg:grid-cols-12 gap-8 lg:gap-10 items-start">
            
            {/* Left Hero Column: Headline & Action */}
            <div className="lg:col-span-6 space-y-5 sm:space-y-6">
              
              {/* Status Badge */}
              <div className="inline-flex items-center gap-2 px-3 py-1.5 border-[3px] border-neo-navy bg-neo-orange text-neo-navy font-heading font-black text-xs uppercase tracking-wider shadow-[3px_3px_0px_#001524] animate-pulse-badge">
                <span className="w-2 h-2 rounded-full bg-neo-navy animate-ping"></span>
                <span>AUTONOMOUS NEGOTIATION ENGINE • REAL-TIME COPILOT</span>
              </div>

              {/* Main Headline with generous line-height to prevent ascender clipping */}
              <div className="space-y-1.5 pt-0.5">
                <h1 className="text-3xl sm:text-5xl lg:text-6xl xl:text-7xl font-heading font-black text-neo-navy uppercase leading-[1.08] tracking-tight">
                  PEI<span className="text-neo-orange">THO</span>
                </h1>
                <p className="text-xl sm:text-2xl lg:text-3xl font-heading font-bold text-neo-teal tracking-tight leading-snug">
                  Deterministic AI Negotiation With Guaranteed Margin Floors.
                </p>
              </div>

              {/* Description */}
              <p className="text-sm sm:text-base lg:text-lg text-neo-navy/80 leading-relaxed font-medium">
                A profit-aware autonomous negotiation engine. Define your costs and non-negotiable floor prices; Peitho negotiates on your behalf in <strong>live online meetings</strong> or <strong>24/7 web chat</strong> — mathematically guaranteeing you never sell at a loss.
              </p>

              {/* Key Value Prop Pills */}
              <div className="flex flex-wrap gap-2 pt-0.5">
                <span className="px-2.5 py-1 text-xs font-mono font-bold border-2 border-neo-navy bg-white shadow-[2px_2px_0px_#001524]">
                  🛡️ 100% Floor Protection
                </span>
                <span className="px-2.5 py-1 text-xs font-mono font-bold border-2 border-neo-navy bg-white shadow-[2px_2px_0px_#001524]">
                  🎙️ Any Online Meeting
                </span>
                <span className="px-2.5 py-1 text-xs font-mono font-bold border-2 border-neo-navy bg-white shadow-[2px_2px_0px_#001524]">
                  ⚡ 3-Agent Architecture
                </span>
                <span className="px-2.5 py-1 text-xs font-mono font-bold border-2 border-neo-navy bg-white shadow-[2px_2px_0px_#001524]">
                  🔒 Instant Deal Lock
                </span>
              </div>

              {/* Action Buttons - Fully responsive with clean wrapping */}
              <div className="flex flex-wrap items-center gap-2.5 sm:gap-3 pt-1">
                <Link to="/meet-assistant" className="w-full sm:w-auto">
                  <Button 
                    size="lg" 
                    className="w-full sm:w-auto bg-neo-orange hover:bg-neo-orange text-neo-navy font-heading font-black text-sm sm:text-base px-5 sm:px-6 py-5 sm:py-6 border-[3px] border-neo-navy shadow-[4px_4px_0px_#001524] hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_#001524] transition-all"
                  >
                    <Radio className="w-4 h-4 sm:w-5 sm:h-5 mr-2 text-neo-navy animate-pulse" />
                    Launch Meeting Assistant
                    <ArrowRight className="w-4 h-4 ml-1.5" />
                  </Button>
                </Link>

                <Link to="/chat" className="w-full sm:w-auto">
                  <Button 
                    size="lg" 
                    variant="outline"
                    className="w-full sm:w-auto bg-white hover:bg-neo-cream text-neo-navy font-heading font-bold text-sm sm:text-base px-5 sm:px-6 py-5 sm:py-6 border-[3px] border-neo-navy shadow-[4px_4px_0px_#001524] hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_#001524] transition-all"
                  >
                    <MessageSquare className="w-4 h-4 sm:w-5 sm:h-5 mr-2 text-neo-teal" />
                    Test Sandbox
                  </Button>
                </Link>

                <Link to="/wallet" className="w-full sm:w-auto">
                  <Button 
                    size="lg" 
                    variant="ghost"
                    className="w-full sm:w-auto bg-neo-cream hover:bg-white text-neo-navy font-heading font-bold text-xs uppercase px-4 py-5 sm:py-6 border-[2px] border-neo-navy shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] transition-all"
                  >
                    API Docs →
                  </Button>
                </Link>
              </div>

              {/* Trust Metric Microbar */}
              <div className="pt-2 border-t-2 border-neo-navy/20 flex flex-wrap items-center gap-4 sm:gap-6 text-xs font-mono font-bold text-neo-navy/70">
                <div className="flex items-center gap-1.5">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                  <span>Zero Price Violations</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                  <span>Dual Mic & Browser Audio</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                  <span>Triple-Fallback Redundancy</span>
                </div>
              </div>
            </div>

            {/* Right Hero Column: Interactive Live Multi-Agent Simulation Card */}
            <div className="lg:col-span-6 w-full">
              {/* Main Interactive Neubrutalist Container with crisp, self-contained shadow */}
              <Card className="bg-white border-[3px] sm:border-[4px] border-neo-navy shadow-[6px_6px_0px_#001524] sm:shadow-[8px_8px_0px_#001524] p-0 overflow-hidden">
                
                {/* Card Header Bar with Status Ticker */}
                <div className="bg-neo-navy text-neo-cream p-3.5 sm:p-4 border-b-[3px] border-neo-navy flex items-center justify-between flex-wrap gap-2">
                  <div className="flex items-center gap-2">
                    <div className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-ping"></div>
                    <span className="font-heading font-black text-xs sm:text-sm uppercase tracking-wider text-neo-cream">
                      LIVE AGENT PIPELINE SIMULATOR
                    </span>
                  </div>
                  <div className="flex items-center gap-2 text-[11px] font-mono bg-neo-teal/30 px-2 py-0.5 border border-neo-teal">
                    <span>COST: ₹{currentStrategy.costPrice}</span>
                    <span>•</span>
                    <span className="text-neo-orange font-bold">FLOOR: ₹{currentStrategy.floorPrice}</span>
                  </div>
                </div>

                <div className="p-4 sm:p-5 space-y-3.5 sm:space-y-4">
                  
                  {/* Strategy Mode Switcher Tabs */}
                  <div>
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-1 mb-2">
                      <label className="text-[11px] font-heading font-black uppercase text-neo-navy/70 tracking-wider">
                        1. Select Strategy Mode:
                      </label>
                      <span className="text-[10px] font-mono font-bold text-neo-teal bg-neo-teal/10 px-2 py-0.5 border border-neo-teal/30 truncate">
                        {currentStrategy.tagline}
                      </span>
                    </div>
                    <div className="grid grid-cols-3 gap-2">
                      {['MAX_PROFIT', 'BALANCED', 'CLEAR_INVENTORY'].map((mode) => (
                        <button
                          key={mode}
                          onClick={() => setSelectedMode(mode)}
                          className={`
                            py-2 px-1 text-[11px] sm:text-xs font-heading font-black uppercase border-[2.5px] border-neo-navy transition-all
                            ${selectedMode === mode
                              ? 'bg-neo-orange text-neo-navy shadow-[2px_2px_0px_#001524] translate-x-[-1px] translate-y-[-1px]'
                              : 'bg-neo-cream text-neo-navy/70 hover:bg-white hover:text-neo-navy'
                            }
                          `}
                        >
                          {mode.replace('_', ' ')}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Round Stepper */}
                  <div className="flex items-center justify-between bg-neo-cream p-2 sm:p-2.5 border-[2px] border-neo-navy">
                    <span className="text-xs font-heading font-bold text-neo-navy uppercase">
                      Negotiation Turn:
                    </span>
                    <div className="flex items-center gap-1.5">
                      {[1, 2, 3].map((r) => (
                        <button
                          key={r}
                          onClick={() => setActiveRound(r)}
                          className={`
                            w-7 h-7 sm:w-8 sm:h-8 font-heading font-black text-xs border-[2px] border-neo-navy transition-all
                            ${activeRound === r
                              ? 'bg-neo-teal text-neo-cream shadow-[2px_2px_0px_#001524]'
                              : 'bg-white text-neo-navy hover:bg-neo-orange'
                            }
                          `}
                        >
                          R{r}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Step A: Buyer Utterance */}
                  <div className="bg-neo-cream/50 border-[2px] border-neo-navy p-3 space-y-1">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] sm:text-[11px] font-mono font-black uppercase text-neo-maroon flex items-center gap-1.5">
                        <MessageSquare className="w-3.5 h-3.5" />
                        Buyer Utterance (Round {currentSim.round})
                      </span>
                      <span className="px-1.5 py-0.2 text-[10px] font-mono font-black border border-neo-maroon bg-rose-100 text-rose-900">
                        OFFER: ₹{currentSim.buyerOffer}
                      </span>
                    </div>
                    <p className="text-xs sm:text-sm font-medium text-neo-navy italic">
                      "{currentSim.buyerText}"
                    </p>
                  </div>

                  {/* Step B: 3-Agent Real-Time Analysis Grid */}
                  <div className="space-y-2">
                    <div className="text-[10px] sm:text-[11px] font-heading font-black uppercase text-neo-navy/70 tracking-wider">
                      2. 3-Agent Internal Reasoning:
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                      {/* Agent 1: Context Analysis */}
                      <div className="p-2.5 border-[2px] border-neo-navy bg-white">
                        <div className="flex items-center gap-1.5 font-heading font-black text-neo-teal mb-0.5">
                          <Target className="w-3.5 h-3.5" />
                          <span>Context Agent</span>
                        </div>
                        <p className="text-[11px] font-mono text-neo-navy/80">
                          Posture: <strong className="text-neo-navy">{currentSim.posture}</strong>
                        </p>
                      </div>

                      {/* Agent 2: Pricing Strategy (Strict Math) */}
                      <div className="p-2.5 border-[2px] border-neo-navy bg-white">
                        <div className="flex items-center gap-1.5 font-heading font-black text-neo-orange mb-0.5">
                          <Cpu className="w-3.5 h-3.5" />
                          <span>Pricing Agent (Math)</span>
                        </div>
                        <p className="text-[11px] font-mono text-neo-navy/80">
                          Counter: <strong className="text-neo-navy">₹{currentSim.pricingMath.counter}</strong> ({currentSim.pricingMath.margin})
                        </p>
                      </div>
                    </div>

                    {/* Agent 3: Conversation Agent + Safety Validator */}
                    <div className="p-2.5 border-[2px] border-neo-navy bg-neo-teal/5">
                      <div className="flex items-center justify-between mb-1">
                        <div className="flex items-center gap-1.5 font-heading font-black text-neo-navy text-xs">
                          <Bot className="w-3.5 h-3.5 text-neo-teal" />
                          <span>Conversation Agent + LLM Safety Validator</span>
                        </div>
                        <span className="text-[9px] sm:text-[10px] font-mono font-black px-1.5 py-0.2 bg-emerald-100 text-emerald-800 border border-emerald-500">
                          ✓ ZERO HALLUCINATION VETO
                        </span>
                      </div>
                      <p className="text-xs font-medium text-neo-navy leading-snug">
                        "{currentSim.agentPitch}"
                      </p>
                    </div>
                  </div>

                  {/* Step C: Live Deal Likelihood Gauge */}
                  <div className="pt-2 border-t-[2px] border-neo-navy/15 space-y-1.5">
                    <div className="flex items-center justify-between text-xs font-heading font-bold">
                      <span className="flex items-center gap-1.5 text-neo-navy">
                        <Activity className="w-3.5 h-3.5 text-neo-orange animate-pulse" />
                        Live Deal Likelihood Estimate:
                      </span>
                      <div className="flex items-center gap-2 font-mono">
                        <span className="text-sm sm:text-base font-black text-neo-navy">
                          {currentSim.dealLikelihood} / 100
                        </span>
                        <span className="text-[11px] font-bold px-1.5 py-0.2 bg-emerald-100 text-emerald-800 border border-emerald-400">
                          {currentSim.trend}
                        </span>
                      </div>
                    </div>
                    <Progress value={currentSim.dealLikelihood} className="h-2.5 sm:h-3 border-[2px] border-neo-navy" />
                  </div>

                  {/* Interactive "Lock Deal" Feature Trigger */}
                  {currentSim.isLockable ? (
                    <div className="p-3 bg-neo-orange border-[3px] border-neo-navy shadow-[3px_3px_0px_#001524] flex items-center justify-between flex-wrap gap-2">
                      <div className="flex items-center gap-2">
                        <Lock className="w-4 h-4 sm:w-5 sm:h-5 text-neo-navy flex-shrink-0" />
                        <div>
                          <p className="font-heading font-black text-xs uppercase text-neo-navy">
                            Buyer Target Reached! Deal Lock Available
                          </p>
                          <p className="text-[11px] text-neo-navy/80 font-medium">
                            Profit margin locked at {currentSim.pricingMath.margin} (₹{currentSim.pricingMath.profit} profit)
                          </p>
                        </div>
                      </div>
                      <Button
                        onClick={() => setShowLockedModal(true)}
                        className="bg-neo-navy hover:bg-neo-navy text-neo-cream font-heading font-black text-xs px-3.5 py-2 border-[2px] border-neo-cream shadow-[2px_2px_0px_#001524]"
                      >
                        Lock Deal Now
                      </Button>
                    </div>
                  ) : (
                    <div className="flex items-center justify-between text-xs text-neo-navy/60 font-mono pt-0.5">
                      <span>Concession curve active • Round {currentSim.round} of 3</span>
                      <button 
                        onClick={() => setActiveRound((prev) => (prev < 3 ? prev + 1 : 1))}
                        className="text-neo-teal font-bold hover:underline flex items-center gap-1"
                      >
                        Advance turn <ChevronRight className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  )}

                </div>
              </Card>
            </div>

          </div>
        </div>
      </section>

      {/* 3. ALERT BANNER / LIVE ENGINE STATUS TICKER (Dedicated Full-Width Row, Impossible to Overlap) */}
      <AlertBanner />

      {/* 4. HARD NUMBERS & STATS BENTO ROW */}
      <section className="bg-neo-navy border-b-[4px] border-neo-navy py-12 text-neo-cream">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center mb-8">
            <span className="inline-block px-3 py-1 bg-neo-orange text-neo-navy text-xs font-heading font-black uppercase tracking-wider border-[2px] border-neo-cream mb-2">
              AUDITABLE PERFORMANCE METRICS
            </span>
            <h2 className="text-2xl sm:text-4xl font-heading font-black uppercase tracking-tight text-neo-cream">
              Engineered For Margin Defense At Scale
            </h2>
          </div>

          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
            <div className="p-6 bg-neo-cream text-neo-navy border-[3px] border-neo-navy shadow-[4px_4px_0px_#FF7D00]">
              <div className="text-4xl sm:text-5xl font-heading font-black text-neo-orange mb-1">
                100%
              </div>
              <div className="font-heading font-black uppercase text-sm mb-1 text-neo-navy">
                Floor Margin Defense
              </div>
              <p className="text-xs text-neo-navy/70 leading-relaxed">
                Zero pricing rule breaches. Mathematical veto strictly prevents any counter-offer below floor.
              </p>
            </div>

            <div className="p-6 bg-neo-cream text-neo-navy border-[3px] border-neo-navy shadow-[4px_4px_0px_#15616D]">
              <div className="text-4xl sm:text-5xl font-heading font-black text-neo-teal mb-1">
                3 + 1
              </div>
              <div className="font-heading font-black uppercase text-sm mb-1 text-neo-navy">
                Agent Architecture
              </div>
              <p className="text-xs text-neo-navy/70 leading-relaxed">
                Context Agent + Pricing Strategy Math + Conversation Agent + Real-Time Safety Validator.
              </p>
            </div>

            <div className="p-6 bg-neo-cream text-neo-navy border-[3px] border-neo-navy shadow-[4px_4px_0px_#FF7D00]">
              <div className="text-4xl sm:text-5xl font-heading font-black text-neo-orange mb-1">
                &lt;180ms
              </div>
              <div className="font-heading font-black uppercase text-sm mb-1 text-neo-navy">
                Decision Latency
              </div>
              <p className="text-xs text-neo-navy/70 leading-relaxed">
                Instant deterministic pricing rule computation without conversational wait times.
              </p>
            </div>

            <div className="p-6 bg-neo-cream text-neo-navy border-[3px] border-neo-navy shadow-[4px_4px_0px_#15616D]">
              <div className="text-4xl sm:text-5xl font-heading font-black text-neo-teal mb-1">
                50+
              </div>
              <div className="font-heading font-black uppercase text-sm mb-1 text-neo-navy">
                Live Languages
              </div>
              <p className="text-xs text-neo-navy/70 leading-relaxed">
                Full multilingual capability with live Gemini 2.5 Flash Lite translation and RTL support.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* 4. CORE PLATFORM CAPABILITIES (BENTO CARDS) */}
      <section className="py-16 lg:py-24 bg-neo-cream border-b-[4px] border-neo-navy">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="max-w-3xl mb-12">
            <span className="inline-block px-3 py-1 bg-neo-teal text-neo-cream text-xs font-heading font-black uppercase tracking-wider border-[2px] border-neo-navy mb-3">
              COMPLETE NEGOTIATION SUITE
            </span>
            <h2 className="text-3xl sm:text-5xl font-heading font-black text-neo-navy uppercase leading-tight tracking-tight">
              One Engine. Four Powerful Ways To Close Deals.
            </h2>
            <p className="text-base sm:text-lg text-neo-navy/70 font-medium mt-3">
              Whether conducting live sales calls across Google Meet, Zoom, or Teams, or managing automated 24/7 web inquiries, Peitho has you covered.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-8">
            {platformFeatures.map((feat) => {
              const Icon = feat.icon;
              return (
                <Card 
                  key={feat.title}
                  className="bg-white border-[4px] border-neo-navy shadow-[6px_6px_0px_#001524] hover:translate-x-[-2px] hover:translate-y-[-2px] hover:shadow-[8px_8px_0px_#001524] transition-all flex flex-col justify-between"
                >
                  <CardHeader className="p-6 pb-4">
                    <div className="flex items-center justify-between mb-4">
                      <div className="w-14 h-14 bg-neo-orange border-[3px] border-neo-navy flex items-center justify-center shadow-[3px_3px_0px_#001524]">
                        <Icon className="w-7 h-7 text-neo-navy" />
                      </div>
                      <Badge variant="outline" className="border-2 border-neo-navy font-mono text-xs uppercase px-2.5 py-1 bg-neo-cream font-bold">
                        {feat.tag}
                      </Badge>
                    </div>

                    <CardTitle className="text-2xl font-heading font-black text-neo-navy uppercase">
                      {feat.title}
                    </CardTitle>
                    <CardDescription className="text-sm font-medium text-neo-navy/70 mt-2 leading-relaxed">
                      {feat.description}
                    </CardDescription>
                  </CardHeader>

                  <CardContent className="p-6 pt-0 space-y-4">
                    <div className="p-2.5 bg-neo-cream/80 border-[2px] border-neo-navy font-mono text-xs text-neo-navy font-bold">
                      ⚡ {feat.stats}
                    </div>

                    <div className="flex items-center gap-3 pt-2">
                      <Link to={feat.path} className="flex-1">
                        <Button 
                          className="w-full bg-neo-navy hover:bg-neo-navy text-neo-cream font-heading font-black uppercase text-xs sm:text-sm py-5 border-[2px] border-neo-navy shadow-[3px_3px_0px_#FF7D00] hover:translate-x-[1px] hover:translate-y-[1px]"
                        >
                          {feat.ctaText}
                          <ArrowRight className="w-4 h-4 ml-2" />
                        </Button>
                      </Link>

                      {feat.secondaryPath && (
                        <Link to={feat.secondaryPath}>
                          <Button 
                            variant="outline"
                            className="bg-white hover:bg-neo-cream text-neo-navy font-heading font-bold uppercase text-xs sm:text-sm py-5 border-[2px] border-neo-navy shadow-[3px_3px_0px_#001524]"
                          >
                            {feat.secondaryText}
                          </Button>
                        </Link>
                      )}
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </div>
      </section>

      {/* 5. MULTI-AGENT ARCHITECTURE BREAKDOWN */}
      <section className="py-16 lg:py-24 bg-neo-teal border-b-[4px] border-neo-navy text-neo-cream">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="inline-block px-3 py-1 bg-neo-orange text-neo-navy text-xs font-heading font-black uppercase tracking-wider border-[2px] border-neo-cream mb-3">
              UNDER THE HOOD
            </span>
            <h2 className="text-3xl sm:text-5xl font-heading font-black uppercase leading-tight tracking-tight text-neo-cream">
              The 3-Agent Decision Pipeline
            </h2>
            <p className="text-base sm:text-lg text-neo-cream/80 font-medium mt-3">
              Why traditional chatbots fail: they ask an LLM to generate prices. LLMs hallucinate numbers and give away margins.
              Peitho decouples language from deterministic pricing logic.
            </p>
          </div>

          <div className="grid md:grid-cols-4 gap-6">
            {/* Step 1 */}
            <div className="bg-neo-navy border-[3px] border-neo-cream p-6 shadow-[5px_5px_0px_#FF7D00] flex flex-col justify-between">
              <div>
                <div className="w-10 h-10 bg-neo-orange text-neo-navy font-heading font-black text-lg flex items-center justify-center border-2 border-neo-cream mb-4">
                  01
                </div>
                <h3 className="text-xl font-heading font-black uppercase mb-2 text-neo-orange">
                  Offer Extraction
                </h3>
                <p className="text-xs sm:text-sm text-neo-cream/80 leading-relaxed font-medium">
                  Free-text buyer messages are parsed using LLM intent extraction with strict regex fallbacks to isolate numerical offers, unit requests, and urgency.
                </p>
              </div>
              <div className="mt-4 pt-3 border-t border-neo-cream/20 text-[11px] font-mono text-neo-cream/60">
                Input: Raw Buyer Utterance
              </div>
            </div>

            {/* Step 2 */}
            <div className="bg-neo-navy border-[3px] border-neo-cream p-6 shadow-[5px_5px_0px_#FF7D00] flex flex-col justify-between">
              <div>
                <div className="w-10 h-10 bg-neo-orange text-neo-navy font-heading font-black text-lg flex items-center justify-center border-2 border-neo-cream mb-4">
                  02
                </div>
                <h3 className="text-xl font-heading font-black uppercase mb-2 text-neo-orange">
                  Context Agent
                </h3>
                <p className="text-xs sm:text-sm text-neo-cream/80 leading-relaxed font-medium">
                  Analyzes psychological posture: urgency rating, buyer aggression, relationship value, and concession budgets across rounds.
                </p>
              </div>
              <div className="mt-4 pt-3 border-t border-neo-cream/20 text-[11px] font-mono text-neo-cream/60">
                Output: Strategic Posture Profile
              </div>
            </div>

            {/* Step 3 */}
            <div className="bg-neo-navy border-[3px] border-neo-cream p-6 shadow-[5px_5px_0px_#FF7D00] flex flex-col justify-between">
              <div>
                <div className="w-10 h-10 bg-neo-orange text-neo-navy font-heading font-black text-lg flex items-center justify-center border-2 border-neo-cream mb-4">
                  03
                </div>
                <h3 className="text-xl font-heading font-black uppercase mb-2 text-neo-orange">
                  Pricing Agent (Rule Math)
                </h3>
                <p className="text-xs sm:text-sm text-neo-cream/80 leading-relaxed font-medium">
                  <strong>Strictly non-LLM.</strong> Mathematical engine computes counter-offers, round concession curves, and enforces the non-negotiable floor price.
                </p>
              </div>
              <div className="mt-4 pt-3 border-t border-neo-cream/20 text-[11px] font-mono text-neo-cream/60">
                Output: Exact Numeric Counter (₹)
              </div>
            </div>

            {/* Step 4 */}
            <div className="bg-neo-navy border-[3px] border-neo-cream p-6 shadow-[5px_5px_0px_#FF7D00] flex flex-col justify-between">
              <div>
                <div className="w-10 h-10 bg-neo-orange text-neo-navy font-heading font-black text-lg flex items-center justify-center border-2 border-neo-cream mb-4">
                  04
                </div>
                <h3 className="text-xl font-heading font-black uppercase mb-2 text-neo-orange">
                  Conv Agent + Safety Veto
                </h3>
                <p className="text-xs sm:text-sm text-neo-cream/80 leading-relaxed font-medium">
                  Generates natural persuasive response wrapping the computed price. Safety validator inspects output to ensure zero price deviation before transmission.
                </p>
              </div>
              <div className="mt-4 pt-3 border-t border-neo-cream/20 text-[11px] font-mono text-neo-cream/60">
                Output: Audited, Validated Dialogue
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 6. CORE PHILOSOPHY / THE 4 PILLARS */}
      <section className="py-16 lg:py-24 bg-neo-cream border-b-[4px] border-neo-navy">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="inline-block px-3 py-1 bg-neo-orange text-neo-navy text-xs font-heading font-black uppercase tracking-wider border-[2px] border-neo-navy mb-3">
              OUR IRONCLAD PHILOSOPHY
            </span>
            <h2 className="text-3xl sm:text-5xl font-heading font-black text-neo-navy uppercase leading-tight tracking-tight">
              Rules Beat Intelligence. Every Time.
            </h2>
            <p className="text-base sm:text-lg text-neo-navy/70 font-medium mt-3">
              "If there is ever a trade-off between closing a deal and protecting seller constraints, seller constraints win."
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            {corePillars.map((pillar) => {
              const Icon = pillar.icon;
              return (
                <div 
                  key={pillar.title}
                  className="bg-white border-[3px] border-neo-navy p-6 shadow-[5px_5px_0px_#001524] space-y-3"
                >
                  <div className="flex items-center justify-between">
                    <div className="w-12 h-12 bg-neo-cream border-[2px] border-neo-navy flex items-center justify-center">
                      <Icon className="w-6 h-6 text-neo-navy" />
                    </div>
                    <span className={`px-2.5 py-1 text-[10px] font-mono font-black border-[2px] border-neo-navy ${pillar.badgeColor}`}>
                      {pillar.badge}
                    </span>
                  </div>

                  <h3 className="text-xl font-heading font-black text-neo-navy uppercase">
                    {pillar.title}
                  </h3>
                  <p className="text-sm font-medium text-neo-navy/70 leading-relaxed">
                    {pillar.description}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* 7. HOW IT WORKS TIMELINE */}
      <section className="py-16 lg:py-24 bg-neo-navy border-b-[4px] border-neo-navy text-neo-cream">
        <div className="container mx-auto px-4 max-w-6xl">
          <div className="text-center mb-16">
            <span className="inline-block px-3 py-1 bg-neo-orange text-neo-navy text-xs font-heading font-black uppercase tracking-wider border-[2px] border-neo-cream mb-3">
              GETTING STARTED
            </span>
            <h2 className="text-3xl sm:text-5xl font-heading font-black uppercase tracking-tight text-neo-cream">
              Four Steps To Smarter Negotiation
            </h2>
          </div>

          <div className="grid md:grid-cols-4 gap-6">
            {[
              {
                step: '01',
                title: 'Set Your Constraints',
                desc: 'Upload or input your SKU cost price, target sales price, and minimum floor margin. These rules are locked in stone.'
              },
              {
                step: '02',
                title: 'Select Operating Mode',
                desc: 'Choose MAX_PROFIT for high-demand margin defense, BALANCED for standard commerce, or CLEAR_INVENTORY for volume turnover.'
              },
              {
                step: '03',
                title: 'Engage Negotiations',
                desc: 'Turn on Meeting Assistant on your online sales calls, or embed the autonomous chat bot widget on your web storefront.'
              },
              {
                step: '04',
                title: 'Lock Deal & Audit',
                desc: 'When buyer reaches target, trigger the Lock Deal popup. Receive immediate profit telemetry and full transaction audit records.'
              }
            ].map((st) => (
              <div 
                key={st.step}
                className="bg-neo-cream text-neo-navy border-[3px] border-neo-cream p-6 shadow-[5px_5px_0px_#FF7D00] flex flex-col justify-between"
              >
                <div>
                  <div className="text-3xl font-heading font-black text-neo-orange mb-3">
                    {st.step}
                  </div>
                  <h3 className="text-lg font-heading font-black uppercase mb-2 text-neo-navy">
                    {st.title}
                  </h3>
                  <p className="text-xs sm:text-sm text-neo-navy/70 font-medium leading-relaxed">
                    {st.desc}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 8. HIGH-ENERGY NEUBRUTALIST CTA BANNER */}
      <section className="py-16 lg:py-20 bg-neo-orange border-b-[4px] border-neo-navy">
        <div className="container mx-auto px-4 max-w-5xl text-center space-y-6">
          <div className="inline-block px-4 py-1.5 bg-neo-navy text-neo-cream font-heading font-black text-xs uppercase tracking-wider border-[2px] border-neo-navy shadow-[3px_3px_0px_#FFFFFF]">
            READY TO DEFEND YOUR REVENUE?
          </div>

          <h2 className="text-4xl sm:text-6xl font-heading font-black text-neo-navy uppercase tracking-tight leading-tight">
            Stop Guessing Prices.<br />Let Peitho Lock In Your Target Margins.
          </h2>

          <p className="text-lg sm:text-xl font-medium text-neo-navy/80 max-w-2xl mx-auto">
            Experience the multi-agent difference today. Test the autonomous negotiator or launch the live meeting sales assistant.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
            <Link to="/meet-assistant">
              <Button 
                size="lg"
                className="bg-neo-navy hover:bg-neo-navy text-neo-cream font-heading font-black text-base px-8 py-6 border-[3px] border-neo-navy shadow-[4px_4px_0px_#FFFFFF] hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_#FFFFFF] transition-all"
              >
                <Radio className="w-5 h-5 mr-2 text-neo-orange animate-pulse" />
                Launch Meeting Assistant
              </Button>
            </Link>

            <Link to="/chat">
              <Button 
                size="lg"
                className="bg-white hover:bg-neo-cream text-neo-navy font-heading font-black text-base px-8 py-6 border-[3px] border-neo-navy shadow-[4px_4px_0px_#001524] hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_#001524] transition-all"
              >
                <MessageSquare className="w-5 h-5 mr-2 text-neo-teal" />
                Test Chat Sandbox
              </Button>
            </Link>

            <Link to="/jury">
              <Button 
                size="lg"
                variant="outline"
                className="bg-neo-teal hover:bg-neo-teal text-neo-cream font-heading font-black text-base px-8 py-6 border-[3px] border-neo-navy shadow-[4px_4px_0px_#001524] hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_#001524] transition-all"
              >
                Seller Dashboard
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* 9. INTERACTIVE LOCK DEAL DEMO MODAL */}
      {showLockedModal && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div 
            className="absolute inset-0 bg-neo-navy/70 backdrop-blur-sm"
            onClick={() => setShowLockedModal(false)}
          />
          <div className="relative bg-neo-cream border-[4px] border-neo-navy shadow-[8px_8px_0px_#001524] p-6 sm:p-8 max-w-md w-full animate-fade-in">
            <div className="text-center space-y-4">
              <div className="w-16 h-16 bg-neo-orange border-[3px] border-neo-navy flex items-center justify-center mx-auto shadow-[3px_3px_0px_#001524]">
                <CheckCircle2 className="w-8 h-8 text-neo-navy" />
              </div>

              <div>
                <Badge variant="accent" className="mb-2 font-mono text-xs">
                  DEAL LOCKED • PROFIT GUARANTEED
                </Badge>
                <h3 className="text-2xl font-heading font-black text-neo-navy uppercase">
                  Deal Successfully Locked!
                </h3>
                <p className="text-xs sm:text-sm text-neo-navy/70 font-medium mt-1">
                  Agreement confirmed within target pricing boundary. Audit record dispatched to seller ledger.
                </p>
              </div>

              <div className="bg-white border-[2px] border-neo-navy p-4 space-y-2 text-left font-mono text-xs">
                <div className="flex justify-between border-b pb-1">
                  <span className="text-neo-navy/60">Strategy Mode:</span>
                  <span className="font-bold text-neo-navy">{selectedMode}</span>
                </div>
                <div className="flex justify-between border-b pb-1">
                  <span className="text-neo-navy/60">Agreed Price:</span>
                  <span className="font-black text-neo-orange">₹{currentSim.pricingMath.counter}</span>
                </div>
                <div className="flex justify-between border-b pb-1">
                  <span className="text-neo-navy/60">Protected Profit:</span>
                  <span className="font-bold text-emerald-700">+₹{currentSim.pricingMath.profit} ({currentSim.pricingMath.margin})</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-neo-navy/60">Floor Defended:</span>
                  <span className="font-bold text-neo-teal">₹{currentStrategy.floorPrice} (Zero Violation)</span>
                </div>
              </div>

              <div className="flex gap-3 pt-2">
                <Button 
                  onClick={() => setShowLockedModal(false)}
                  className="w-full bg-neo-navy text-neo-cream font-heading font-black text-xs uppercase py-3 border-[2px] border-neo-navy shadow-[2px_2px_0px_#001524]"
                >
                  Close Demo
                </Button>
                <Link to="/meet-assistant" className="w-full">
                  <Button 
                    className="w-full bg-neo-orange text-neo-navy font-heading font-black text-xs uppercase py-3 border-[2px] border-neo-navy shadow-[2px_2px_0px_#001524]"
                  >
                    Open Live Copilot
                  </Button>
                </Link>
              </div>
            </div>
          </div>
        </div>
      )}

    </Layout>
  );
}
