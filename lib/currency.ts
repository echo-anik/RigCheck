/**
 * Currency conversion utilities
 * Default conversion rate: 1 USD = 125 BDT
 */

export const USD_TO_BDT_RATE = 125;

export function convertUSDtoBDT(usdPrice: number | null): number | null {
  if (!usdPrice || usdPrice <= 0) return null;
  return usdPrice * USD_TO_BDT_RATE;
}

export function convertBDTtoUSD(bdtPrice: number | null): number | null {
  if (!bdtPrice || bdtPrice <= 0) return null;
  return bdtPrice / USD_TO_BDT_RATE;
}

export function formatPriceBDT(price: number | string | null | undefined): string {
  if (price === null || price === undefined) {
    return 'N/A';
  }
  
  const numPrice = typeof price === 'string' ? parseFloat(price) : price;
  
  if (isNaN(numPrice) || numPrice <= 0) {
    return 'Price not available';
  }
  
  return `৳${numPrice.toLocaleString('en-BD', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
}

export function formatPriceUSD(price: number | null | undefined): string {
  if (!price || price <= 0) return 'Price not available';
  return `$${price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

export function formatPriceWithConversion(usdPrice: number | null): {
  usd: string;
  bdt: string;
  bdtValue: number | null;
} {
  const bdtValue = convertUSDtoBDT(usdPrice);
  return {
    usd: formatPriceUSD(usdPrice),
    bdt: formatPriceBDT(bdtValue),
    bdtValue,
  };
}
