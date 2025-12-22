const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8002/api/v1';

const DEMO_IMAGES = Array.from({ length: 26 }, (_, i) => `/demo-images/image (${i + 1}).jpg`);

const pickDemoImage = (seed?: string | number | null) => {
  if (!seed || DEMO_IMAGES.length === 0) return undefined;
  const str = String(seed);
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = (hash * 31 + str.charCodeAt(i)) >>> 0;
  }
  const idx = hash % DEMO_IMAGES.length;
  return DEMO_IMAGES[idx];
};

export interface Component {
  // Primary identifier - API uses product_id as the main ID
  product_id: string;
  id?: string; // Alias for product_id for backward compatibility
  
  // Core fields from API
  category: string;
  brand: string;
  name: string; // This is the model field from API
  model?: string; // Alias for name for backward compatibility
  raw_name?: string; // Full product name from database
  
  // Specifications (JSON object)
  specs: Record<string, unknown>;
  
  // Pricing - API returns these as string decimals
  lowest_price_bdt?: string | number | null;
  highest_price_bdt?: string | number | null;
  lowest_price_usd?: number | null;
  
  // Images
  image_url?: string; // Legacy field
  image_urls?: string[]; // Array of image URLs
  primary_image_url?: string | null;
  
  // Additional metadata (may not be in simplified API)
  sku?: string;
  brand_id?: number;
  series?: string | null;
  price_last_updated?: string;
  availability_status?: string;
  stock_count?: number;
  view_count?: number;
  build_count?: number;
  popularity_score?: number;
  slug?: string;
  tags?: string | null;
  release_date?: string | null;
  discontinued_date?: string | null;
  featured?: boolean;
  is_verified?: number;
  data_version?: number;
  last_modified?: string;
  
  // Timestamps
  created_at?: string;
  updated_at?: string;
  
  // Prices array (when fetching single component)
  prices?: Array<{
    id: number;
    component_id: string;
    source: string;
    price_bdt: string;
    url: string;
    availability: string;
    last_updated: string;
  }>;
  
  // Brand object (if joined)
  brand_obj?: {
    id: number;
    brand_name: string;
    brand_slug: string;
    logo_url: string | null;
    website_url: string | null;
    country: string | null;
    is_active: boolean;
    created_at: string;
  };
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  meta: {
    current_page: number;
    total_pages: number;
    total_count: number;
    per_page: number;
  };
}

export interface Build {
  id: number;
  user_id: number;
  name: string; // Changed from build_name to name to match actual API responses
  description: string | null;
  use_case?: 'gaming' | 'workstation' | 'content_creation' | 'budget' | 'other' | null;
  budget_min_bdt?: number | null;
  budget_max_bdt?: number | null;
  total_price: number | string; // Was total_cost_bdt in DB
  total_tdp_w?: number | null;
  compatibility_status?: 'valid' | 'warnings' | 'errors';
  compatibility_issues?: Record<string, unknown>;
  visibility?: 'private' | 'public';
  share_token?: string;
  share_url?: string | null;
  share_id?: string | null;
  view_count?: number;
  like_count?: number;
  comment_count?: number;
  is_complete: boolean | number;
  sync_token?: string | null;
  last_synced_at?: string | null;
  created_at: string;
  updated_at: string;
  components: Component[];
  // Component IDs for build
  cpu_id?: string | null;
  motherboard_id?: string | null;
  gpu_id?: string | null;
  ram_id?: string | null;
  storage_id?: string | null;
  psu_id?: string | null;
  case_id?: string | null;
  cooler_id?: string | null;
  user?: {
    id: number;
    name: string;
    email: string;
    created_at?: string;
  };
}

export class ApiClient {
  private baseUrl: string;
  private token: string | null = null;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  setToken(token: string) {
    this.token = token;
  }

  /**
   * Normalize component data to ensure consistent structure
   * API returns product_id, but we want both product_id and id for compatibility
   */
  private normalizeComponent(component: Partial<Component>): Component {
    const productId = component.product_id || component.id || '';
    const name = component.name || component.model || '';
    const hasImages = (component.image_urls && component.image_urls.length > 0) || component.primary_image_url;
    const fallbackImage = hasImages ? undefined : pickDemoImage(productId || name);
    
    return {
      ...component,
      id: productId,
      product_id: productId,
      model: name,
      name: name,
      category: component.category || '',
      brand: component.brand || '',
      specs: component.specs || {},
      image_urls: component.image_urls && component.image_urls.length > 0
        ? component.image_urls
        : fallbackImage
          ? [fallbackImage]
          : [],
      primary_image_url: component.primary_image_url || fallbackImage,
      // Convert price strings to numbers for calculations
      lowest_price_bdt: component.lowest_price_bdt ? 
        (typeof component.lowest_price_bdt === 'string' ? parseFloat(component.lowest_price_bdt) : component.lowest_price_bdt) 
        : null,
      highest_price_bdt: component.highest_price_bdt ? 
        (typeof component.highest_price_bdt === 'string' ? parseFloat(component.highest_price_bdt) : component.highest_price_bdt) 
        : null,
    };
  }

  private normalizeBuild(build: Build): Build {
    const normalizedComponents = (build.components || []).map(c => this.normalizeComponent(c));
    return {
      ...build,
      components: normalizedComponents,
    };
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...options.headers,
    };

    // Auto-add token from localStorage if not already set
    if (!this.token && typeof window !== 'undefined') {
      const storedToken = localStorage.getItem('auth_token');
      if (storedToken) {
        this.token = storedToken;
      }
    }

    if (this.token) {
      (headers as Record<string, string>)['Authorization'] = `Bearer ${this.token}`;
    }

    console.log(`[API Request] ${options.method || 'GET'} ${this.baseUrl}${endpoint}`);

    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers,
    });

    if (!response.ok) {
      // Try to get error details from response body
      let errorDetails = '';
      try {
        const errorBody = await response.json();
        errorDetails = errorBody.message || errorBody.error || '';
      } catch {
        // Response body is not JSON
      }
      
      console.error(`[API Error] ${response.status} ${response.statusText} on ${endpoint}`, errorDetails);
      const errorMessage = `API Error: ${response.status} ${response.statusText}${errorDetails ? ` - ${errorDetails}` : ''}`;
      throw new Error(errorMessage);
    }

    return response.json();
  }

  // Components
  async getComponents(params: {
    category?: string;
    brand_id?: number;
    search?: string;
    min_price?: number;
    max_price?: number;
    featured?: boolean;
    sort_by?: string;
    sort_order?: 'asc' | 'desc';
    per_page?: number;
    page?: number;
  } = {}): Promise<PaginatedResponse<Component>> {
    const queryString = new URLSearchParams(
      Object.entries(params)
        .filter(([, value]) => value !== undefined)
        .map(([key, value]) => [key, String(value)])
    ).toString();

    const response = await this.request<PaginatedResponse<Component>>(
      `/components?${queryString}`
    );
    
    // Normalize all components in the response
    return {
      ...response,
      data: response.data.map(c => this.normalizeComponent(c))
    };
  }

  async getComponent(productId: string): Promise<{ success: boolean; data: Component }> {
    console.log(`[API] Fetching component: ${productId}`);
    try {
      const response = await this.request<{ success: boolean; data: Component }>(
        `/components/${productId}`
      );
      
      console.log(`[API] Component fetch successful for ${productId}:`, response);
      
      // Normalize the component data
      return {
        ...response,
        data: this.normalizeComponent(response.data)
      };
    } catch (error) {
      console.error(`[API] Failed to fetch component ${productId}:`, error);
      throw error;
    }
  }

  // Builds
  async getBuilds(params: {
    is_public?: boolean;
    featured?: boolean;
    per_page?: number;
    page?: number;
    search?: string;
    min_cost?: number;
    max_cost?: number;
    sort_by?: string;
    sort_order?: 'asc' | 'desc';
  } = {}): Promise<PaginatedResponse<Build>> {
    const queryString = new URLSearchParams(
      Object.entries(params)
        .filter(([, value]) => value !== undefined)
        .map(([key, value]) => [key, String(value)])
    ).toString();

    // Use /builds/public endpoint for public builds
    const endpoint = params.is_public !== false ? '/builds/public' : '/builds/my';
    
    const response = await this.request<PaginatedResponse<Build>>(
      `${endpoint}?${queryString}`
    );

    return {
      ...response,
      data: response.data.map(b => this.normalizeBuild(b)),
    };
  }

  async getBuild(id: number): Promise<{ success: boolean; data: Build }> {
    const response = await this.request<{ success: boolean; data: Build }>(
      `/builds/${id}`
    );

    return {
      ...response,
      data: this.normalizeBuild(response.data),
    };
  }

  async createBuild(data: {
    name: string;
    description?: string;
    total_price: number;
    is_public: boolean;
    cpu_id?: string | null;
    motherboard_id?: string | null;
    gpu_id?: string | null;
    ram_id?: string | null;
    storage_id?: string | null;
    psu_id?: string | null;
    case_id?: string | null;
    cooler_id?: string | null;
  }): Promise<{ success: boolean; data: Build }> {
    return this.request<{ success: boolean; data: Build }>('/builds', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async updateBuild(id: number, data: {
    name?: string;
    description?: string;
    total_price?: number;
    is_public?: boolean;
    cpu_id?: string | null;
    motherboard_id?: string | null;
    gpu_id?: string | null;
    ram_id?: string | null;
    storage_id?: string | null;
    psu_id?: string | null;
    case_id?: string | null;
    cooler_id?: string | null;
  }): Promise<{ success: boolean; data: Build }> {
    return this.request<{ success: boolean; data: Build }>(`/builds/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  // Compatibility Check
  async checkCompatibility(components: Record<string, string>): Promise<{
    success: boolean;
    data: {
      valid: boolean;
      warnings: string[];
      errors: string[];
      summary: {
        total_cost_bdt: number;
        total_tdp_w: number;
        recommended_psu_w: number;
      };
      compatibility_checks: Record<string, {
        pass: boolean;
        message: string;
        warning?: string;
      }>;
    };
  }> {
    return this.request('/builds/validate', {
      method: 'POST',
      body: JSON.stringify({ components }),
    });
  }
}

export const api = new ApiClient(API_BASE_URL);
