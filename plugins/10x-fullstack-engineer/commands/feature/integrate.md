# Integration & Polish Operation

Complete integration testing, performance optimization, security hardening, and documentation for a feature.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'integrate' operation name)

Expected format: `feature:"feature name" [scope:"e2e|performance|security|documentation"] [priority:"high|medium|low"]`

## Workflow

### 1. End-to-End Testing

Create comprehensive E2E tests covering critical user workflows.

#### Using Playwright

```typescript
// e2e/products.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Product Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3000');
  });

  test('should complete full product browsing flow', async ({ page }) => {
    // Navigate to products page
    await page.click('text=Products');
    await expect(page).toHaveURL(/\/products/);

    // Verify products are loaded
    await expect(page.locator('.product-card')).toHaveCount(20, { timeout: 10000 });

    // Filter by category
    await page.click('text=Electronics');
    await expect(page.locator('.product-card')).toHaveCount(5);

    // Search for product
    await page.fill('input[placeholder="Search products"]', 'laptop');
    await page.keyboard.press('Enter');
    await expect(page.locator('.product-card')).toHaveCount(2);

    // Click on first product
    await page.click('.product-card:first-child');
    await expect(page).toHaveURL(/\/products\/[a-z0-9-]+/);

    // Verify product details
    await expect(page.locator('h1')).toContainText('Laptop');
    await expect(page.locator('.product-price')).toBeVisible();

    // Add to cart
    await page.click('button:has-text("Add to Cart")');
    await expect(page.locator('.cart-badge')).toContainText('1');
  });

  test('should handle error states gracefully', async ({ page }) => {
    // Simulate network error
    await page.route('**/api/products', (route) => route.abort());

    await page.goto('http://localhost:3000/products');

    // Should show error message
    await expect(page.locator('text=Failed to load products')).toBeVisible();

    // Should have retry button
    await expect(page.locator('button:has-text("Retry")')).toBeVisible();
  });

  test('should handle authentication flow', async ({ page }) => {
    // Try to create product without auth
    await page.goto('http://localhost:3000/products/new');

    // Should redirect to login
    await expect(page).toHaveURL(/\/login/);

    // Login
    await page.fill('input[name="email"]', 'admin@example.com');
    await page.fill('input[name="password"]', 'Password123');
    await page.click('button:has-text("Login")');

    // Should redirect back to product creation
    await expect(page).toHaveURL(/\/products\/new/);

    // Create product
    await page.fill('input[name="name"]', 'New Test Product');
    await page.fill('textarea[name="description"]', 'Test description');
    await page.fill('input[name="price"]', '99.99');
    await page.fill('input[name="stockQuantity"]', '10');

    await page.click('button:has-text("Create Product")');

    // Should show success message
    await expect(page.locator('text=Product created successfully')).toBeVisible();
  });

  test('should be accessible', async ({ page }) => {
    await page.goto('http://localhost:3000/products');

    // Check for proper heading hierarchy
    const h1 = await page.locator('h1').count();
    expect(h1).toBeGreaterThan(0);

    // Check for alt text on images
    const images = page.locator('img');
    const count = await images.count();
    for (let i = 0; i < count; i++) {
      const alt = await images.nth(i).getAttribute('alt');
      expect(alt).toBeTruthy();
    }

    // Check for keyboard navigation
    await page.keyboard.press('Tab');
    const focusedElement = await page.evaluate(() => document.activeElement?.tagName);
    expect(focusedElement).toBeTruthy();
  });

  test('should work on mobile devices', async ({ page, viewport }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });

    await page.goto('http://localhost:3000/products');

    // Mobile menu should be visible
    await expect(page.locator('[aria-label="Menu"]')).toBeVisible();

    // Products should be in single column
    const gridColumns = await page.locator('.product-grid').evaluate((el) => {
      return window.getComputedStyle(el).gridTemplateColumns.split(' ').length;
    });

    expect(gridColumns).toBe(1);
  });
});
```

### 2. Performance Optimization

#### Frontend Performance

```typescript
// Performance monitoring
import { onCLS, onFID, onLCP, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics(metric) {
  console.log(metric);
  // Send to analytics service
}

onCLS(sendToAnalytics);
onFID(sendToAnalytics);
onLCP(sendToAnalytics);
onFCP(sendToAnalytics);
onTTFB(sendToAnalytics);

// Code splitting
const ProductList = React.lazy(() => import('./features/products/components/ProductList'));
const ProductDetail = React.lazy(() => import('./features/products/components/ProductDetail'));

// Image optimization
<img
  src={product.images[0].url}
  srcSet={`
    ${product.images[0].url}?w=320 320w,
    ${product.images[0].url}?w=640 640w,
    ${product.images[0].url}?w=1024 1024w
  `}
  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
  loading="lazy"
  decoding="async"
/>

// Memoization
const MemoizedProductCard = React.memo(ProductCard, (prevProps, nextProps) => {
  return prevProps.product.id === nextProps.product.id &&
         prevProps.product.stockQuantity === nextProps.product.stockQuantity;
});

// Virtualization for long lists
import { FixedSizeList } from 'react-window';

const ProductVirtualList = ({ products }) => (
  <FixedSizeList
    height={600}
    itemCount={products.length}
    itemSize={200}
    width="100%"
  >
    {({ index, style }) => (
      <div style={style}>
        <ProductCard product={products[index]} />
      </div>
    )}
  </FixedSizeList>
);
```

#### Backend Performance

```typescript
// Database query optimization
// Add indexes (already in database.md)

// Query result caching
import { Redis } from 'ioredis';
const redis = new Redis();

async function getCachedProducts(filters: ProductFilters) {
  const cacheKey = `products:${JSON.stringify(filters)}`;
  const cached = await redis.get(cacheKey);

  if (cached) {
    return JSON.parse(cached);
  }

  const products = await productRepository.findAll(filters, pagination);
  await redis.setex(cacheKey, 300, JSON.stringify(products)); // 5 minutes

  return products;
}

// N+1 query prevention
const products = await productRepository.find({
  relations: ['category', 'images', 'tags'], // Eager load
});

// Response compression
import compression from 'compression';
app.use(compression());

// Connection pooling (already configured in database setup)

// API response caching
import apicache from 'apicache';
app.use('/api/products', apicache.middleware('5 minutes'));
```

### 3. Security Hardening

#### Input Validation & Sanitization

```typescript
// Backend validation (already in backend.md with Zod)

// SQL Injection prevention (using parameterized queries with TypeORM)

// XSS Prevention
import DOMPurify from 'dompurify';

function sanitizeHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty);
}

// In component
<div dangerouslySetInnerHTML={{ __html: sanitizeHtml(product.description) }} />
```

#### Security Headers

```typescript
// helmet middleware
import helmet from 'helmet';

app.use(helmet());

app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    scriptSrc: ["'self'"],
    imgSrc: ["'self'", 'data:', 'https:'],
    connectSrc: ["'self'", process.env.API_URL],
  },
}));

// CORS configuration
import cors from 'cors';

app.use(cors({
  origin: process.env.FRONTEND_URL,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
```

#### Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// General API rate limit
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: 'Too many requests from this IP',
});

app.use('/api/', apiLimiter);

// Stricter rate limit for mutations
const createLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10, // 10 creates per hour
});

app.use('/api/products', createLimiter);
```

#### Authentication & Authorization

```typescript
// JWT validation middleware (already in backend.md)

// RBAC (Role-Based Access Control)
function authorize(...allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    next();
  };
}

// Usage
router.post('/products', authenticate, authorize('admin', 'editor'), createProduct);
```

### 4. Error Handling & Logging

```typescript
// Centralized error handler
class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: {
        message: err.message,
        statusCode: err.statusCode,
      },
    });
  }

  // Log unexpected errors
  console.error('Unexpected error:', err);

  res.status(500).json({
    error: {
      message: 'Internal server error',
      statusCode: 500,
    },
  });
});

// Structured logging
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

// Request logging
import morgan from 'morgan';
app.use(morgan('combined', { stream: { write: (msg) => logger.info(msg) } }));
```

### 5. Documentation

#### API Documentation

```yaml
# openapi.yaml
openapi: 3.0.0
info:
  title: Product API
  version: 1.0.0
  description: API for managing products

servers:
  - url: http://localhost:3000/api
    description: Local server
  - url: https://api.example.com
    description: Production server

paths:
  /products:
    get:
      summary: List products
      description: Retrieve a paginated list of products with optional filters
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
        - name: categoryId
          in: query
          schema:
            type: string
            format: uuid
        - name: search
          in: query
          schema:
            type: string
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/Product'
                  meta:
                    type: object
                    properties:
                      page:
                        type: integer
                      totalPages:
                        type: integer
                      total:
                        type: integer

    post:
      summary: Create product
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateProductInput'
      responses:
        '201':
          description: Product created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Product'
        '401':
          description: Unauthorized
        '400':
          description: Invalid input

  /products/{id}:
    get:
      summary: Get product by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Product'
        '404':
          description: Product not found

components:
  schemas:
    Product:
      type: object
      properties:
        id:
          type: string
          format: uuid
        name:
          type: string
        slug:
          type: string
        description:
          type: string
        price:
          type: number
          format: decimal
        currency:
          type: string
        stockQuantity:
          type: integer
        createdAt:
          type: string
          format: date-time

    CreateProductInput:
      type: object
      required:
        - name
        - price
        - stockQuantity
      properties:
        name:
          type: string
          maxLength: 255
        description:
          type: string
        price:
          type: number
          minimum: 0
        stockQuantity:
          type: integer
          minimum: 0

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

#### Feature Documentation

```markdown
# Product Management Feature

## Overview

Complete product catalog management with support for categories, images, tags, search, and filtering.

## Features

- Product listing with pagination
- Product search and filtering
- Category hierarchy
- Multiple product images
- Tag management
- Stock tracking
- Soft delete support

## User Flows

### Browsing Products

1. User navigates to products page
2. Products are loaded with pagination (20 per page)
3. User can filter by category
4. User can search by name/description
5. User clicks on product to view details

### Creating Product (Admin)

1. Admin logs in
2. Admin navigates to "Create Product"
3. Admin fills in product details
4. Admin uploads product images
5. Admin selects category and tags
6. Admin submits form
7. Product is created and admin is redirected to product page

## API Usage Examples

### List Products

\`\`\`bash
curl -X GET "http://localhost:3000/api/products?page=1&limit=20&categoryId=abc123"
\`\`\`

### Create Product

\`\`\`bash
curl -X POST "http://localhost:3000/api/products" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Product",
    "description": "Product description",
    "price": 99.99,
    "stockQuantity": 10,
    "categoryId": "abc123"
  }'
\`\`\`

## Performance Characteristics

- API response time: <100ms (p95)
- Page load time: <2s (p95)
- Database queries: Optimized with indexes
- Image loading: Lazy loaded with srcSet
- List rendering: Virtualized for 1000+ items

## Security Measures

- JWT authentication for mutations
- Role-based access control (RBAC)
- Input validation on backend
- XSS protection with DOMPurify
- SQL injection prevention
- Rate limiting (100 req/15min)
- CORS configured
- Security headers with Helmet

## Known Limitations

- Maximum 10 images per product
- Product names limited to 255 characters
- Search limited to name and description
- Bulk operations not yet supported

## Future Enhancements

- [ ] Bulk product import/export
- [ ] Product variants (size, color)
- [ ] Advanced inventory management
- [ ] Product recommendations
- [ ] Analytics dashboard
```

## Output Format

```markdown
# Integration & Polish: {Feature Name}

## E2E Test Results

### Test Suites
- {suite_name}: {passed/failed} ({count} tests)

### Coverage
- User flows covered: {percentage}%
- Edge cases tested: {count}

## Performance Metrics

### Frontend
- LCP: {time}ms
- FID: {time}ms
- CLS: {score}

### Backend
- API response time (p95): {time}ms
- Database query time (p95): {time}ms
- Memory usage: {mb}MB

### Optimizations Applied
- {optimization_description}

## Security Audit

### Vulnerabilities Fixed
- {vulnerability}: {fix_description}

### Security Measures
- {measure_description}

## Documentation

### API Documentation
- {documentation_location}

### User Guide
- {guide_location}

### Developer Documentation
- {docs_location}

## Deployment Checklist

- [ ] All tests passing
- [ ] Performance benchmarks met
- [ ] Security audit completed
- [ ] Documentation updated
- [ ] Environment variables documented
- [ ] Monitoring configured
- [ ] Backup strategy in place

## Known Issues

- {issue_description}: {workaround}

## Next Steps

- {future_enhancement}
```

## Error Handling

- If tests fail: Provide failure details and suggested fixes
- If performance targets not met: Suggest optimizations
- If security issues found: Provide remediation steps
