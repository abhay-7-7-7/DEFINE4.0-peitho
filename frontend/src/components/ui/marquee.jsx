import * as React from 'react'
import { cn } from '@/lib/utils'

export function Marquee({
  className,
  reverse = false,
  pauseOnHover = false,
  children,
  speed = 30,
  ...props
}) {
  return (
    <div
      className={cn(
        'group flex overflow-hidden p-2 [--gap:1rem] [gap:var(--gap)] select-none',
        className
      )}
      {...props}
    >
      <div
        className={cn(
          'flex shrink-0 justify-around [gap:var(--gap)] animate-marquee',
          reverse && '[animation-direction:reverse]',
          pauseOnHover && 'group-hover:[animation-play-state:paused]'
        )}
        style={{ animationDuration: `${speed}s` }}
      >
        {children}
      </div>
      <div
        className={cn(
          'flex shrink-0 justify-around [gap:var(--gap)] animate-marquee',
          reverse && '[animation-direction:reverse]',
          pauseOnHover && 'group-hover:[animation-play-state:paused]'
        )}
        style={{ animationDuration: `${speed}s` }}
        aria-hidden="true"
      >
        {children}
      </div>
    </div>
  )
}
