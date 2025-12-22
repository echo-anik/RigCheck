'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface WishlistItem {
  id: string;
  type: 'component' | 'build';
}

interface WishlistContextType {
  items: WishlistItem[];
  addToWishlist: (id: string, type: 'component' | 'build') => void;
  removeFromWishlist: (id: string, type: 'component' | 'build') => void;
  isInWishlist: (id: string, type: 'component' | 'build') => boolean;
  clearWishlist: () => void;
  hydrated: boolean;
}

const WishlistContext = createContext<WishlistContextType | undefined>(undefined);

export function WishlistProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<WishlistItem[]>([]);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    try {
      const saved = localStorage.getItem('wishlist');
      if (saved) {
        const parsed = JSON.parse(saved) as WishlistItem[];
        setItems(parsed);
      }
    } catch (error) {
      console.error('Failed to load wishlist:', error);
    } finally {
      setHydrated(true);
    }
  }, []);

  useEffect(() => {
    if (!hydrated) return;
    // Save wishlist to localStorage whenever it changes after hydration
    localStorage.setItem('wishlist', JSON.stringify(items));
  }, [items, hydrated]);

  const addToWishlist = (id: string, type: 'component' | 'build') => {
    setItems((prev) => {
      const exists = prev.some((item) => item.id === id && item.type === type);
      if (exists) return prev;
      return [...prev, { id, type }];
    });
  };

  const removeFromWishlist = (id: string, type: 'component' | 'build') => {
    setItems((prev) => prev.filter((item) => !(item.id === id && item.type === type)));
  };

  const isInWishlist = (id: string, type: 'component' | 'build') => {
    return items.some((item) => item.id === id && item.type === type);
  };

  const clearWishlist = () => {
    setItems([]);
  };

  return (
    <WishlistContext.Provider
      value={{
        items,
        addToWishlist,
        removeFromWishlist,
        isInWishlist,
        clearWishlist,
        hydrated,
      }}
    >
      {children}
    </WishlistContext.Provider>
  );
}

export function useWishlist() {
  const context = useContext(WishlistContext);
  if (context === undefined) {
    throw new Error('useWishlist must be used within a WishlistProvider');
  }
  return context;
}
