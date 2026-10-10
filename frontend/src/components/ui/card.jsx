import * as React from 'react'
import { cn } from '@/lib/utils'

const Card = React.forwardRef(({ className, interactive, role = 'article', ...props }, ref) => (
  <div
    ref={ref}
    role={role}
    className={cn(
      'bg-card text-card-foreground border-3 border-foreground shadow-[4px_4px_0px_hsl(var(--shadow-color))]',
      interactive && 'cursor-pointer hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_hsl(var(--shadow-color))] active:translate-x-[4px] active:translate-y-[4px] active:shadow-none transition-all duration-150',
      className
    )}
    {...props}
  />
))
Card.displayName = 'Card'

const CardHeader = React.forwardRef(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('flex flex-col space-y-1.5 p-5 sm:p-6 border-b-3 border-foreground', className)}
    {...props}
  />
))
CardHeader.displayName = 'CardHeader'

const CardTitle = React.forwardRef(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn('text-lg sm:text-xl font-heading font-black uppercase tracking-wide leading-none text-foreground', className)}
    {...props}
  />
))
CardTitle.displayName = 'CardTitle'

const CardDescription = React.forwardRef(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('text-xs sm:text-sm text-muted-foreground font-body', className)}
    {...props}
  />
))
CardDescription.displayName = 'CardDescription'

const CardContent = React.forwardRef(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('p-5 sm:p-6', className)} {...props} />
))
CardContent.displayName = 'CardContent'

const CardFooter = React.forwardRef(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('flex items-center p-4 sm:p-6 border-t-3 border-foreground bg-muted/30', className)}
    {...props}
  />
))
CardFooter.displayName = 'CardFooter'

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent }
