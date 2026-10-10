import * as React from 'react'
import { cn } from '@/lib/utils'

const Progress = React.forwardRef(({ className, value, variant = 'smooth', max = 100, indicatorClassName, ...props }, ref) => {
  const safeMax = max > 0 ? max : 100
  const clampedValue = Math.max(0, Math.min(safeMax, value ?? 0))
  const percent = (clampedValue / safeMax) * 100

  return (
    <div
      ref={ref}
      role="progressbar"
      aria-valuemin={0}
      aria-valuemax={safeMax}
      aria-valuenow={clampedValue}
      className={cn(
        'relative h-4 w-full overflow-hidden border-3 border-foreground bg-muted shadow-[3px_3px_0px_hsl(var(--shadow-color))]',
        className
      )}
      {...props}
    >
      <div
        className={cn(
          'h-full w-full flex-1 bg-primary transition-all duration-300 ease-out',
          indicatorClassName
        )}
        style={{ transform: `translateX(-${100 - percent}%)` }}
      />
    </div>
  )
})
Progress.displayName = 'Progress'

export { Progress }
