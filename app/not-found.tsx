import Link from 'next/link';
import { Home, Search } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function NotFound() {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
      <div className="text-center max-w-2xl">
        <div className="mb-8">
          <h1 className="text-9xl font-bold text-primary mb-4">404</h1>
          <h2 className="text-3xl font-bold mb-4">Page Not Found</h2>
          <p className="text-muted-foreground text-lg mb-8">
            Sorry, we couldn&apos;t find the page you&apos;re looking for. 
            The component or build you&apos;re searching for might have been moved or deleted.
          </p>
        </div>

        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Button size="lg" asChild>
            <Link href="/">
              <Home className="h-5 w-5 mr-2" />
              Back to Home
            </Link>
          </Button>
          <Button size="lg" variant="outline" asChild>
            <Link href="/search">
              <Search className="h-5 w-5 mr-2" />
              Search Components
            </Link>
          </Button>
        </div>

        <div className="mt-12 pt-8 border-t">
          <h3 className="font-semibold mb-4">Popular Pages</h3>
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
            <Link href="/compare" className="text-primary hover:underline">
              Compare
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
