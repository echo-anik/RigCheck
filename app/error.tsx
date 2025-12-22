'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import { Home, RefreshCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('Application error:', error);
  }, [error]);

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
      <div className="text-center max-w-2xl">
        <div className="mb-8">
          <h1 className="text-9xl font-bold text-red-500 mb-4">500</h1>
          <h2 className="text-3xl font-bold mb-4">Something Went Wrong</h2>
          <p className="text-muted-foreground text-lg mb-4">
            We encountered an unexpected error while processing your request.
            Our team has been notified and is working to fix the issue.
          </p>
          {error.digest && (
            <p className="text-sm text-muted-foreground font-mono bg-gray-100 p-2 rounded">
              Error ID: {error.digest}
            </p>
          )}
        </div>

        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Button size="lg" onClick={reset}>
            <RefreshCcw className="h-5 w-5 mr-2" />
            Try Again
          </Button>
          <Button size="lg" variant="outline" asChild>
            <Link href="/">
              <Home className="h-5 w-5 mr-2" />
              Back to Home
            </Link>
          </Button>
        </div>

        <div className="mt-12 pt-8 border-t">
          <h3 className="font-semibold mb-4">Need Help?</h3>
          <p className="text-sm text-muted-foreground mb-4">
            If this problem persists, please contact our support team with the error ID above.
          </p>
          <div className="flex flex-wrap gap-4 justify-center text-sm">
            <Link href="/components" className="text-primary hover:underline">
              Browse Components
            </Link>
            <Link href="/builds" className="text-primary hover:underline">
              Build Gallery
            </Link>
            <Link href="/builder" className="text-primary hover:underline">
              PC Builder
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
