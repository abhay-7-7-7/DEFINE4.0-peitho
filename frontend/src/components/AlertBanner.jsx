import { Zap, Shield, Radio, Activity, Cpu, Lock, Sparkles, Clock } from 'lucide-react';
import { Marquee } from './ui/marquee';

export default function AlertBanner() {
  const items = [
    { text: 'AUTONOMOUS MULTI-AGENT ENGINE ACTIVE', icon: Zap },
    { text: '100% MARGIN FLOOR PROTECTION', icon: Shield },
    { text: 'LIVE ONLINE MEETING COPILOT ONLINE', icon: Radio },
    { text: 'REAL-TIME DEAL LIKELIHOOD GAUGE', icon: Activity },
    { text: 'DETERMINISTIC PRICING MATH (NON-LLM)', icon: Cpu },
    { text: 'INSTANT DEAL LOCK TRIGGER', icon: Lock },
    { text: '50+ LANGUAGES VIA GEMINI LIVE', icon: Sparkles },
    { text: '<180MS DECISION LATENCY', icon: Clock },
  ];

  return (
    <div className="w-full bg-neo-orange border-y-[3px] sm:border-y-[4px] border-neo-navy py-2.5 sm:py-3 overflow-hidden select-none relative z-20">
      <Marquee speed={28} pauseOnHover={true}>
        {items.map((item, idx) => {
          const Icon = item.icon;
          return (
            <div
              key={idx}
              className="inline-flex items-center gap-2 mx-4 text-xs sm:text-sm font-heading font-black text-neo-navy uppercase tracking-wider whitespace-nowrap"
            >
              <Icon className="w-4 h-4 text-neo-navy flex-shrink-0" />
              <span>{item.text}</span>
              <span className="text-neo-navy/40 font-mono ml-3 font-bold">★</span>
            </div>
          );
        })}
      </Marquee>
    </div>
  );
}
