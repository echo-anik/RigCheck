// Component Comparison Logic
// This file contains helper functions for the comparison page

import { Component } from '@/lib/api';

export interface ComparisonResult {
  specKey: string;
  specLabel: string;
  values: (string | number | null)[];
  highlight?: number[]; // Indices of best values
  unit?: string;
}

export function compareComponents(components: (Component | null)[]): ComparisonResult[] {
  if (components.every(c => c === null)) {
    return [];
  }

  // Get all unique spec keys from all components
  const allSpecKeys = new Set<string>();
  components.forEach(comp => {
    if (comp?.specs && typeof comp.specs === 'object') {
      Object.keys(comp.specs).forEach(key => {
        allSpecKeys.add(key);
      });
    }
  });

  const results: ComparisonResult[] = [];

  // Add basic info first
  results.push({
    specKey: 'name',
    specLabel: 'Name',
    values: components.map(c => c?.name || null),
  });

  results.push({
    specKey: 'brand',
    specLabel: 'Brand',
    values: components.map(c => c?.brand ? (typeof c.brand === 'string' ? c.brand : c.brand_obj?.brand_name || 'Unknown') : null),
  });

  results.push({
    specKey: 'price',
    specLabel: 'Price',
    values: components.map(c => c?.lowest_price_bdt || null),
    highlight: highlightBestPrice(components),
    unit: '৳',
  });

  // Add specs
  Array.from(allSpecKeys).sort().forEach(specKey => {
    const values = components.map(comp => {
      if (!comp?.specs || typeof comp.specs !== 'object') return null;
      const value = comp.specs[specKey];
      // Convert value to string or number
      if (value === null || value === undefined) return null;
      if (typeof value === 'string' || typeof value === 'number') return value;
      return String(value);
    });

    // Try to find best values for numeric specs
    const highlight = tryHighlightBestNumeric(values, specKey);

    results.push({
      specKey,
      specLabel: formatSpecLabel(specKey),
      values,
      highlight: highlight.length > 0 ? highlight : undefined,
    });
  });

  return results;
}

function formatSpecLabel(key: string): string {
  return key
    .replace(/_/g, ' ')
    .split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

function highlightBestPrice(components: (Component | null)[]): number[] {
  const prices = components.map(c => c?.lowest_price_bdt || null);
  const validPrices = prices.filter(p => p !== null) as number[];

  if (validPrices.length === 0) return [];

  const minPrice = Math.min(...validPrices);
  return prices
    .map((price, index) => (price === minPrice ? index : -1))
    .filter(i => i !== -1);
}

function tryHighlightBestNumeric(values: (string | number | null)[], specKey: string): number[] {
  // Try to convert values to numbers
  const numericValues = values.map(v => {
    if (v === null) return null;
    const num = parseFloat(String(v));
    return isNaN(num) ? null : num;
  });

  const validNumbers = numericValues.filter(n => n !== null) as number[];
  if (validNumbers.length === 0) return [];

  // Determine if higher or lower is better
  const higherIsBetter = isHigherBetter(specKey);
  const best = higherIsBetter
    ? Math.max(...validNumbers)
    : Math.min(...validNumbers);

  return numericValues
    .map((num, index) => (num === best ? index : -1))
    .filter(i => i !== -1);
}

function isHigherBetter(specKey: string): boolean {
  const lowerBetterKeys = [
    'tdp',
    'power',
    'latency',
    'cas',
    'price',
    'length',
    'height',
    'width',
  ];

  return !lowerBetterKeys.some(key => specKey.toLowerCase().includes(key));
}

export function getComparisonInsights(components: (Component | null)[]): string[] {
  const insights: string[] = [];

  // Price comparison
  const prices = components
    .map((c, i) => ({
      price: typeof c?.lowest_price_bdt === 'string' ? parseFloat(c.lowest_price_bdt) : (c?.lowest_price_bdt || 0),
      index: i,
      name: c?.name || ''
    }))
    .filter(p => p.price > 0)
    .sort((a, b) => a.price - b.price);

  if (prices.length > 1) {
    const cheapest = prices[0];
    const mostExpensive = prices[prices.length - 1];
    const priceDiff = mostExpensive.price - cheapest.price;
    const percentDiff = ((priceDiff / cheapest.price) * 100).toFixed(0);

    insights.push(
      `${cheapest.name} is ${percentDiff}% cheaper than ${mostExpensive.name} (৳${priceDiff.toLocaleString()} difference)`
    );
  }

  // Brand diversity
  const brands = new Set(
    components
      .map(c => {
        if (!c?.brand) return undefined;
        return typeof c.brand === 'string' ? c.brand : c.brand_obj?.brand_name;
      })
      .filter(b => b !== undefined && b !== null)
  );
  if (brands.size === components.length && components.length > 1) {
    insights.push('All components are from different brands');
  }

  return insights;
}
