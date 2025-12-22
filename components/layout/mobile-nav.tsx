'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import { X, Home, Package, Hammer, LayoutGrid, GitCompare, User, LogOut, Heart, Search } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { useAuth } from '@/lib/auth-context';
import { useWishlist } from '@/lib/wishlist-context';

interface MobileNavProps {
  isOpen: boolean;
  onClose: () => void;
  onOpenLogin: () => void;
}

export function MobileNav({ isOpen, onClose, onOpenLogin }: MobileNavProps) {
  const { user, logout, isAuthenticated } = useAuth();
  const { items, hydrated } = useWishlist();

  // Prevent body scroll when drawer is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [isOpen]);

  const handleLinkClick = () => {
    onClose();
  };

  const handleLogout = async () => {
    const { toast } = await import('sonner');
    await logout();
    toast.success('Logged out successfully');
    onClose();
  };

  return (
    <>
      {/* Overlay */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 md:hidden"
          onClick={onClose}
        />
      )}

      {/* Drawer */}
      <div
        className={`fixed top-0 left-0 h-full w-80 bg-background z-50 transform transition-transform duration-300 ease-in-out md:hidden ${
          isOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-center justify-between p-4 border-b">
            <div className="flex items-center space-x-2">
              <div className="h-8 w-8 rounded bg-primary flex items-center justify-center">
                <span className="text-primary-foreground font-bold text-lg">RC</span>
              </div>
              <span className="font-bold text-xl">RigCheck</span>
            </div>
            <Button variant="ghost" size="icon" onClick={onClose}>
              <X className="h-5 w-5" />
            </Button>
          </div>

          {/* User Section */}
          <div className="p-4 border-b bg-gray-50">
            {isAuthenticated && user ? (
              <div className="space-y-2">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-full bg-primary flex items-center justify-center">
                    <span className="text-primary-foreground font-medium">
                      {user.name.charAt(0).toUpperCase()}
                    </span>
                  </div>
                  <div>
                    <p className="font-medium">{user.name}</p>
                    <p className="text-sm text-muted-foreground">{user.email}</p>
                  </div>
                </div>
              </div>
            ) : (
              <Button
                onClick={() => {
                  onClose();
                  onOpenLogin();
                }}
                className="w-full"
              >
                Sign In
              </Button>
            )}
          </div>

          {/* Navigation Links */}
          <nav className="flex-1 overflow-y-auto py-4">
            <div className="space-y-1 px-2">
              <Link
                href="/"
                onClick={handleLinkClick}
                className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <Home className="h-5 w-5 text-muted-foreground" />
                <span className="font-medium">Home</span>
              </Link>

              <Link
                href="/components"
                onClick={handleLinkClick}
                className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <Package className="h-5 w-5 text-muted-foreground" />
                <span className="font-medium">Browse Components</span>
              </Link>

              <Link
                href="/builds"
                onClick={handleLinkClick}
                className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <LayoutGrid className="h-5 w-5 text-muted-foreground" />
                <span className="font-medium">Build Gallery</span>
              </Link>

              <Link
                href="/builder"
                onClick={handleLinkClick}
                className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <Hammer className="h-5 w-5 text-muted-foreground" />
                <span className="font-medium">PC Builder</span>
              </Link>

              <Link
                href="/compare"
                onClick={handleLinkClick}
                className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <GitCompare className="h-5 w-5 text-muted-foreground" />
                <span className="font-medium">Compare</span>
              </Link>

              <Link
                href="/search"
                onClick={handleLinkClick}
                className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <Search className="h-5 w-5 text-muted-foreground" />
                <span className="font-medium">Search</span>
              </Link>

              <Link
                href="/wishlist"
                onClick={handleLinkClick}
                className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <Heart className="h-5 w-5 text-muted-foreground" />
                <span className="font-medium">Wishlist</span>
                {hydrated && items.length > 0 && (
                  <Badge className="ml-auto">{items.length}</Badge>
                )}
              </Link>

              {isAuthenticated && (
                <>
                  <div className="h-px bg-gray-200 my-2" />
                  
                  <Link
                    href="/profile"
                    onClick={handleLinkClick}
                    className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors"
                  >
                    <User className="h-5 w-5 text-muted-foreground" />
                    <span className="font-medium">Profile</span>
                  </Link>

                  <button
                    onClick={handleLogout}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors text-left"
                  >
                    <LogOut className="h-5 w-5 text-muted-foreground" />
                    <span className="font-medium">Sign Out</span>
                  </button>
                </>
              )}
            </div>
          </nav>

          {/* Footer */}
          <div className="p-4 border-t text-center text-sm text-muted-foreground">
            <p>&copy; 2025 RigCheck. All rights reserved.</p>
          </div>
        </div>
      </div>
    </>
  );
}
