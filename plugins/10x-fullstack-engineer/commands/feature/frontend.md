# Frontend Layer Operation

Implement frontend layer only: components, state management, API integration, and tests for a feature.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'frontend' operation name)

Expected format: `description:"UI functionality needed" [framework:"react|vue|angular"] [state:"redux|zustand|context"] [tests:"unit|integration|e2e"]`

## Workflow

### 1. Understand Frontend Requirements

Clarify:
- What UI components are needed?
- What user interactions are supported?
- What state management is required?
- What API endpoints to consume?
- What responsive/accessibility requirements?

### 2. Analyze Existing Frontend Structure

```bash
# Find frontend framework
cat package.json | grep -E "(react|vue|angular|svelte)"

# Find component structure
find . -path "*/components/*" -o -path "*/src/app/*"

# Find state management
cat package.json | grep -E "(redux|zustand|mobx|pinia|ngrx)"
```

### 3. Implement Components

#### Component Structure Example (React + TypeScript)

```typescript
// features/products/components/ProductCard.tsx
import React from 'react';
import { Product } from '../types';

interface ProductCardProps {
  product: Product;
  onAddToCart?: (productId: string) => void;
  onViewDetails?: (productId: string) => void;
}

export const ProductCard: React.FC<ProductCardProps> = ({
  product,
  onAddToCart,
  onViewDetails,
}) => {
  const [imageError, setImageError] = React.useState(false);

  const handleAddToCart = () => {
    if (onAddToCart) {
      onAddToCart(product.id);
    }
  };

  const handleViewDetails = () => {
    if (onViewDetails) {
      onViewDetails(product.id);
    }
  };

  return (
    <div className="product-card" role="article" aria-label={`Product: ${product.name}`}>
      <div className="product-card__image-container">
        {!imageError && product.images[0] ? (
          <img
            src={product.images[0].url}
            alt={product.images[0].altText || product.name}
            className="product-card__image"
            onError={() => setImageError(true)}
            loading="lazy"
          />
        ) : (
          <div className="product-card__placeholder">No image</div>
        )}

        {product.stockQuantity === 0 && (
          <div className="product-card__badge product-card__badge--out-of-stock">
            Out of Stock
          </div>
        )}
      </div>

      <div className="product-card__content">
        <h3 className="product-card__title">{product.name}</h3>

        {product.description && (
          <p className="product-card__description">
            {product.description.slice(0, 100)}
            {product.description.length > 100 && '...'}
          </p>
        )}

        <div className="product-card__footer">
          <div className="product-card__price">
            {product.currency} {product.price.toFixed(2)}
          </div>

          <div className="product-card__actions">
            <button
              onClick={handleViewDetails}
              className="button button--secondary"
              aria-label={`View details for ${product.name}`}
            >
              Details
            </button>

            <button
              onClick={handleAddToCart}
              disabled={product.stockQuantity === 0}
              className="button button--primary"
              aria-label={`Add ${product.name} to cart`}
            >
              Add to Cart
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
```

```typescript
// features/products/components/ProductList.tsx
import React from 'react';
import { ProductCard } from './ProductCard';
import { useProducts } from '../hooks/useProducts';
import { Pagination } from '@/components/Pagination';
import { LoadingSpinner } from '@/components/LoadingSpinner';
import { ErrorMessage } from '@/components/ErrorMessage';

interface ProductListProps {
  categoryId?: string;
  searchQuery?: string;
}

export const ProductList: React.FC<ProductListProps> = ({
  categoryId,
  searchQuery,
}) => {
  const {
    products,
    isLoading,
    error,
    pagination,
    onPageChange,
    onAddToCart,
  } = useProducts({ categoryId, searchQuery });

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner />
      </div>
    );
  }

  if (error) {
    return (
      <ErrorMessage
        message={error.message}
        onRetry={() => window.location.reload()}
      />
    );
  }

  if (products.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">No products found.</p>
      </div>
    );
  }

  return (
    <div className="product-list">
      <div className="product-list__grid">
        {products.map((product) => (
          <ProductCard
            key={product.id}
            product={product}
            onAddToCart={onAddToCart}
            onViewDetails={(id) => console.log('View', id)}
          />
        ))}
      </div>

      {pagination && (
        <Pagination
          currentPage={pagination.page}
          totalPages={pagination.totalPages}
          onPageChange={onPageChange}
        />
      )}
    </div>
  );
};
```

### 4. Implement State Management

#### Using Zustand

```typescript
// features/products/store/productStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import { productApi } from '../api/productApi';
import { Product } from '../types';

interface ProductState {
  products: Product[];
  selectedProduct: Product | null;
  isLoading: boolean;
  error: Error | null;

  fetchProducts: (filters?: any) => Promise<void>;
  fetchProduct: (id: string) => Promise<void>;
  createProduct: (data: any) => Promise<void>;
  updateProduct: (id: string, data: any) => Promise<void>;
  deleteProduct: (id: string) => Promise<void>;
  clearError: () => void;
}

export const useProductStore = create<ProductState>()(
  devtools(
    persist(
      (set, get) => ({
        products: [],
        selectedProduct: null,
        isLoading: false,
        error: null,

        fetchProducts: async (filters = {}) => {
          set({ isLoading: true, error: null });
          try {
            const response = await productApi.list(filters);
            set({ products: response.data, isLoading: false });
          } catch (error: any) {
            set({ error, isLoading: false });
          }
        },

        fetchProduct: async (id: string) => {
          set({ isLoading: true, error: null });
          try {
            const product = await productApi.getById(id);
            set({ selectedProduct: product, isLoading: false });
          } catch (error: any) {
            set({ error, isLoading: false });
          }
        },

        createProduct: async (data) => {
          set({ isLoading: true, error: null });
          try {
            const product = await productApi.create(data);
            set((state) => ({
              products: [...state.products, product],
              isLoading: false,
            }));
          } catch (error: any) {
            set({ error, isLoading: false });
            throw error;
          }
        },

        updateProduct: async (id, data) => {
          set({ isLoading: true, error: null });
          try {
            const product = await productApi.update(id, data);
            set((state) => ({
              products: state.products.map((p) =>
                p.id === id ? product : p
              ),
              selectedProduct:
                state.selectedProduct?.id === id
                  ? product
                  : state.selectedProduct,
              isLoading: false,
            }));
          } catch (error: any) {
            set({ error, isLoading: false });
            throw error;
          }
        },

        deleteProduct: async (id) => {
          set({ isLoading: true, error: null });
          try {
            await productApi.delete(id);
            set((state) => ({
              products: state.products.filter((p) => p.id !== id),
              isLoading: false,
            }));
          } catch (error: any) {
            set({ error, isLoading: false });
            throw error;
          }
        },

        clearError: () => set({ error: null }),
      }),
      {
        name: 'product-storage',
        partialize: (state) => ({ products: state.products }),
      }
    )
  )
);
```

### 5. Implement API Integration

```typescript
// features/products/api/productApi.ts
import axios from 'axios';
import { Product, ProductFilters, PaginatedResponse } from '../types';

const API_BASE_URL = import.meta.env.VITE_API_URL || '/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized
      localStorage.removeItem('accessToken');
      window.location.href = '/login';
    }
    throw error;
  }
);

export const productApi = {
  list: async (filters: ProductFilters): Promise<PaginatedResponse<Product>> => {
    const response = await apiClient.get('/products', { params: filters });
    return response.data;
  },

  getById: async (id: string): Promise<Product> => {
    const response = await apiClient.get(`/products/${id}`);
    return response.data.data;
  },

  create: async (data: Partial<Product>): Promise<Product> => {
    const response = await apiClient.post('/products', data);
    return response.data.data;
  },

  update: async (id: string, data: Partial<Product>): Promise<Product> => {
    const response = await apiClient.put(`/products/${id}`, data);
    return response.data.data;
  },

  delete: async (id: string): Promise<void> => {
    await apiClient.delete(`/products/${id}`);
  },
};
```

### 6. Create Custom Hooks

```typescript
// features/products/hooks/useProducts.ts
import { useState, useEffect, useCallback } from 'react';
import { productApi } from '../api/productApi';
import { Product, ProductFilters } from '../types';

interface UseProductsOptions {
  categoryId?: string;
  searchQuery?: string;
  autoFetch?: boolean;
}

export const useProducts = (options: UseProductsOptions = {}) => {
  const [products, setProducts] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [pagination, setPagination] = useState({
    page: 1,
    totalPages: 1,
    total: 0,
  });

  const fetchProducts = useCallback(
    async (page: number = 1) => {
      setIsLoading(true);
      setError(null);

      try {
        const filters: ProductFilters = {
          page,
          limit: 20,
          categoryId: options.categoryId,
          search: options.searchQuery,
        };

        const response = await productApi.list(filters);

        setProducts(response.data);
        setPagination({
          page: response.meta.page,
          totalPages: response.meta.totalPages,
          total: response.meta.total,
        });
      } catch (err: any) {
        setError(err);
      } finally {
        setIsLoading(false);
      }
    },
    [options.categoryId, options.searchQuery]
  );

  useEffect(() => {
    if (options.autoFetch !== false) {
      fetchProducts();
    }
  }, [fetchProducts, options.autoFetch]);

  const onPageChange = useCallback(
    (page: number) => {
      fetchProducts(page);
    },
    [fetchProducts]
  );

  const onAddToCart = useCallback((productId: string) => {
    // Implement add to cart logic
    console.log('Add to cart:', productId);
  }, []);

  return {
    products,
    isLoading,
    error,
    pagination,
    fetchProducts,
    onPageChange,
    onAddToCart,
  };
};
```

### 7. Write Tests

```typescript
// features/products/components/__tests__/ProductCard.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { ProductCard } from '../ProductCard';

const mockProduct = {
  id: '1',
  name: 'Test Product',
  description: 'Test description',
  price: 99.99,
  currency: 'USD',
  stockQuantity: 10,
  images: [{ url: 'https://example.com/image.jpg', altText: 'Product image' }],
};

describe('ProductCard', () => {
  it('should render product information', () => {
    render(<ProductCard product={mockProduct} />);

    expect(screen.getByText('Test Product')).toBeInTheDocument();
    expect(screen.getByText(/Test description/)).toBeInTheDocument();
    expect(screen.getByText('USD 99.99')).toBeInTheDocument();
  });

  it('should call onAddToCart when button clicked', () => {
    const onAddToCart = jest.fn();
    render(<ProductCard product={mockProduct} onAddToCart={onAddToCart} />);

    const addButton = screen.getByRole('button', { name: /add to cart/i });
    fireEvent.click(addButton);

    expect(onAddToCart).toHaveBeenCalledWith('1');
  });

  it('should disable add to cart button when out of stock', () => {
    const outOfStockProduct = { ...mockProduct, stockQuantity: 0 };
    render(<ProductCard product={outOfStockProduct} />);

    const addButton = screen.getByRole('button', { name: /add to cart/i });
    expect(addButton).toBeDisabled();
    expect(screen.getByText('Out of Stock')).toBeInTheDocument();
  });

  it('should handle image load error', () => {
    render(<ProductCard product={mockProduct} />);

    const image = screen.getByRole('img');
    fireEvent.error(image);

    expect(screen.getByText('No image')).toBeInTheDocument();
  });
});
```

```typescript
// features/products/hooks/__tests__/useProducts.test.ts
import { renderHook, act, waitFor } from '@testing-library/react';
import { useProducts } from '../useProducts';
import { productApi } from '../../api/productApi';

jest.mock('../../api/productApi');

const mockProductApi = productApi as jest.Mocked<typeof productApi>;

describe('useProducts', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should fetch products on mount', async () => {
    mockProductApi.list.mockResolvedValue({
      data: [{ id: '1', name: 'Product 1' }],
      meta: { page: 1, totalPages: 1, total: 1 },
    } as any);

    const { result } = renderHook(() => useProducts());

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });

    expect(result.current.products).toHaveLength(1);
    expect(mockProductApi.list).toHaveBeenCalled();
  });

  it('should handle fetch error', async () => {
    const error = new Error('Fetch failed');
    mockProductApi.list.mockRejectedValue(error);

    const { result } = renderHook(() => useProducts());

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });

    expect(result.current.error).toEqual(error);
  });

  it('should refetch on page change', async () => {
    mockProductApi.list.mockResolvedValue({
      data: [],
      meta: { page: 1, totalPages: 2, total: 20 },
    } as any);

    const { result } = renderHook(() => useProducts());

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });

    act(() => {
      result.current.onPageChange(2);
    });

    await waitFor(() => {
      expect(mockProductApi.list).toHaveBeenCalledWith(
        expect.objectContaining({ page: 2 })
      );
    });
  });
});
```

## Output Format

```markdown
# Frontend Layer: {Feature Name}

## Components

### {ComponentName}
- Purpose: {description}
- Props: {props_list}
- State: {state_description}
- Code: {component_code}

## State Management

### Store/Context
\`\`\`typescript
{state_management_code}
\`\`\`

## API Integration

### API Client
\`\`\`typescript
{api_client_code}
\`\`\`

## Custom Hooks

### {HookName}
\`\`\`typescript
{hook_code}
\`\`\`

## Testing

### Component Tests
- {test_description}: {status}

### Hook Tests
- {test_description}: {status}

## Accessibility
- {a11y_considerations}

## Performance
- {performance_optimizations}
```

## Error Handling

- If framework unclear: Detect from package.json or ask
- If state management unclear: Suggest options
- Provide examples for detected framework
