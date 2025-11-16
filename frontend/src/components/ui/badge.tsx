import * as React from 'react';
import { cn } from '@/lib/utils';

export interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  variant?: 'default' | 'secondary' | 'destructive' | 'outline';
}

const Badge = React.forwardRef<HTMLSpanElement, BadgeProps>(
  ({ className, variant = 'default', ...props }, ref) => {
    const baseStyles = 'inline-flex items-center justify-center rounded-full border px-2 py-0.5 text-xs font-medium transition-colors';
    
    const variants = {
      default: 'bg-[#667eea] text-white border-transparent',
      secondary: 'bg-gray-100 text-gray-700 border-transparent',
      destructive: 'bg-red-600 text-white border-transparent',
      outline: 'border-gray-300 text-gray-700 bg-transparent',
    };

    return (
      <span
        className={cn(baseStyles, variants[variant], className)}
        ref={ref}
        {...props}
      />
    );
  }
);

Badge.displayName = 'Badge';

export { Badge };

