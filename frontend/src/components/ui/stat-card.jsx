import * as React from 'react'
import { Card, CardContent } from './card'
import { cn } from '@/lib/utils'

export function StatCard({
  title,
  value,
  description,
  icon: Icon,
  trend,
  trendValue,
  variant = 'default',
  className,
  ...props
}) {
  const variantStyles = {
    default: 'bg-card text-card-foreground',
    primary: 'bg-primary/10 border-primary',
    secondary: 'bg-secondary/10 border-secondary',
    accent: 'bg-accent/20 border-accent',
  }

  return (
    <Card
      className={cn(
        'relative overflow-hidden',
        variantStyles[variant] || variantStyles.default,
        className
      )}
      {...props}
    >
      <CardContent className="p-5">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs font-heading font-black uppercase tracking-wider text-muted-foreground">
            {title}
          </span>
          {Icon && (
            <div className="p-2 border-2 border-foreground bg-primary/20 shadow-[2px_2px_0px_hsl(var(--shadow-color))]">
              <Icon className="w-4 h-4 text-foreground" />
            </div>
          )}
        </div>
        <div className="text-2xl sm:text-3xl font-heading font-black text-foreground tracking-tight">
          {value}
        </div>
        {(description || trendValue) && (
          <div className="flex items-center gap-2 mt-2 text-xs font-medium text-muted-foreground">
            {trendValue && (
              <span
                className={cn(
                  'font-bold px-1.5 py-0.2 border border-foreground/30',
                  trend === 'up' && 'bg-emerald-100 text-emerald-800',
                  trend === 'down' && 'bg-rose-100 text-rose-800',
                  trend === 'flat' && 'bg-gray-100 text-gray-800'
                )}
              >
                {trendValue}
              </span>
            )}
            {description && <span>{description}</span>}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
