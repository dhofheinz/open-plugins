# Backend Layer Operation

Implement backend layer only: repositories, services, API endpoints, validation, and tests for a feature.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'backend' operation name)

Expected format: `description:"backend functionality needed" [api:"REST|GraphQL"] [validation:"strict|standard"] [auth:"required|optional"]`

## Workflow

### 1. Understand Backend Requirements

Clarify:
- What business logic needs to be implemented?
- What API endpoints are needed (methods, paths, parameters)?
- What validation rules apply?
- What authentication/authorization is required?
- What external services need integration?

### 2. Analyze Existing Backend Structure

```bash
# Find backend structure
find . -path "*/src/server/*" -o -path "*/api/*" -o -path "*/backend/*"

# Identify framework
cat package.json | grep -E "(express|fastify|nest|koa|hapi)"

# Find existing patterns
find . -path "*/controllers/*" -o -path "*/services/*" -o -path "*/routes/*"
```

**Identify:**
- Framework (Express, Fastify, NestJS, etc.)
- Architecture pattern (MVC, Clean Architecture, Layered)
- Error handling approach
- Validation library (class-validator, Joi, Zod)
- Testing framework (Jest, Mocha, Vitest)

### 3. Implement Layers

#### Layer 1: Data Access (Repository Pattern)

```typescript
// repositories/ProductRepository.ts
import { Repository } from 'typeorm';
import { Product } from '../entities/Product.entity';
import { AppDataSource } from '../config/database';

export interface ProductFilters {
    categoryId?: string;
    minPrice?: number;
    maxPrice?: number;
    inStock?: boolean;
    search?: string;
}

export interface PaginationOptions {
    page: number;
    limit: number;
    sortBy?: string;
    sortOrder?: 'ASC' | 'DESC';
}

export class ProductRepository {
    private repository: Repository<Product>;

    constructor() {
        this.repository = AppDataSource.getRepository(Product);
    }

    async findById(id: string): Promise<Product | null> {
        return this.repository.findOne({
            where: { id },
            relations: ['category', 'images', 'tags'],
        });
    }

    async findAll(
        filters: ProductFilters,
        pagination: PaginationOptions
    ): Promise<{ products: Product[]; total: number }> {
        const query = this.repository
            .createQueryBuilder('product')
            .leftJoinAndSelect('product.category', 'category')
            .leftJoinAndSelect('product.images', 'images')
            .leftJoinAndSelect('product.tags', 'tags');

        // Apply filters
        if (filters.categoryId) {
            query.andWhere('product.categoryId = :categoryId', {
                categoryId: filters.categoryId,
            });
        }

        if (filters.minPrice !== undefined) {
            query.andWhere('product.price >= :minPrice', { minPrice: filters.minPrice });
        }

        if (filters.maxPrice !== undefined) {
            query.andWhere('product.price <= :maxPrice', { maxPrice: filters.maxPrice });
        }

        if (filters.inStock) {
            query.andWhere('product.stockQuantity > 0');
        }

        if (filters.search) {
            query.andWhere(
                '(product.name ILIKE :search OR product.description ILIKE :search)',
                { search: `%${filters.search}%` }
            );
        }

        // Apply sorting
        const sortBy = pagination.sortBy || 'createdAt';
        const sortOrder = pagination.sortOrder || 'DESC';
        query.orderBy(`product.${sortBy}`, sortOrder);

        // Apply pagination
        const skip = (pagination.page - 1) * pagination.limit;
        query.skip(skip).take(pagination.limit);

        const [products, total] = await query.getManyAndCount();

        return { products, total };
    }

    async create(data: Partial<Product>): Promise<Product> {
        const product = this.repository.create(data);
        return this.repository.save(product);
    }

    async update(id: string, data: Partial<Product>): Promise<Product> {
        await this.repository.update(id, data);
        const updated = await this.findById(id);
        if (!updated) {
            throw new Error('Product not found after update');
        }
        return updated;
    }

    async delete(id: string): Promise<void> {
        await this.repository.softDelete(id);
    }
}
```

#### Layer 2: Business Logic (Service Layer)

```typescript
// services/ProductService.ts
import { ProductRepository, ProductFilters, PaginationOptions } from '../repositories/ProductRepository';
import { Product } from '../entities/Product.entity';
import { NotFoundError, ValidationError, ConflictError } from '../errors';
import { slugify } from '../utils/slugify';

export interface CreateProductInput {
    name: string;
    description?: string;
    price: number;
    currency?: string;
    stockQuantity: number;
    categoryId?: string;
    images?: Array<{ url: string; altText?: string }>;
    tags?: string[];
}

export interface UpdateProductInput {
    name?: string;
    description?: string;
    price?: number;
    stockQuantity?: number;
    categoryId?: string;
}

export class ProductService {
    constructor(private productRepository: ProductRepository) {}

    async getProduct(id: string): Promise<Product> {
        const product = await this.productRepository.findById(id);
        if (!product) {
            throw new NotFoundError(`Product with ID ${id} not found`);
        }
        return product;
    }

    async listProducts(
        filters: ProductFilters,
        pagination: PaginationOptions
    ): Promise<{ products: Product[]; total: number; page: number; totalPages: number }> {
        const { products, total } = await this.productRepository.findAll(filters, pagination);

        return {
            products,
            total,
            page: pagination.page,
            totalPages: Math.ceil(total / pagination.limit),
        };
    }

    async createProduct(input: CreateProductInput): Promise<Product> {
        // Validate input
        this.validateProductInput(input);

        // Generate slug from name
        const slug = slugify(input.name);

        // Check if slug already exists
        const existing = await this.productRepository.findBySlug(slug);
        if (existing) {
            throw new ConflictError('Product with this name already exists');
        }

        // Create product
        const product = await this.productRepository.create({
            ...input,
            slug,
        });

        return product;
    }

    async updateProduct(id: string, input: UpdateProductInput): Promise<Product> {
        // Check if product exists
        await this.getProduct(id);

        // Validate input
        if (input.price !== undefined && input.price < 0) {
            throw new ValidationError('Price must be non-negative');
        }

        if (input.stockQuantity !== undefined && input.stockQuantity < 0) {
            throw new ValidationError('Stock quantity must be non-negative');
        }

        // Update product
        const updated = await this.productRepository.update(id, input);

        return updated;
    }

    async deleteProduct(id: string): Promise<void> {
        // Check if product exists
        await this.getProduct(id);

        // Soft delete
        await this.productRepository.delete(id);
    }

    async adjustStock(id: string, quantity: number): Promise<Product> {
        const product = await this.getProduct(id);

        const newQuantity = product.stockQuantity + quantity;
        if (newQuantity < 0) {
            throw new ValidationError('Insufficient stock');
        }

        return this.productRepository.update(id, { stockQuantity: newQuantity });
    }

    private validateProductInput(input: CreateProductInput): void {
        if (!input.name || input.name.trim().length === 0) {
            throw new ValidationError('Product name is required');
        }

        if (input.name.length > 255) {
            throw new ValidationError('Product name must not exceed 255 characters');
        }

        if (input.price < 0) {
            throw new ValidationError('Price must be non-negative');
        }

        if (input.stockQuantity < 0) {
            throw new ValidationError('Stock quantity must be non-negative');
        }
    }
}
```

#### Layer 3: API Layer (Controllers & Routes)

```typescript
// controllers/ProductController.ts
import { Request, Response, NextFunction } from 'express';
import { ProductService } from '../services/ProductService';

export class ProductController {
    constructor(private productService: ProductService) {}

    getProduct = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { id } = req.params;
            const product = await this.productService.getProduct(id);

            res.json({
                success: true,
                data: product,
            });
        } catch (error) {
            next(error);
        }
    };

    listProducts = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const filters = {
                categoryId: req.query.categoryId as string,
                minPrice: req.query.minPrice ? parseFloat(req.query.minPrice as string) : undefined,
                maxPrice: req.query.maxPrice ? parseFloat(req.query.maxPrice as string) : undefined,
                inStock: req.query.inStock === 'true',
                search: req.query.search as string,
            };

            const pagination = {
                page: parseInt(req.query.page as string) || 1,
                limit: parseInt(req.query.limit as string) || 20,
                sortBy: (req.query.sortBy as string) || 'createdAt',
                sortOrder: (req.query.sortOrder as 'ASC' | 'DESC') || 'DESC',
            };

            const result = await this.productService.listProducts(filters, pagination);

            res.json({
                success: true,
                data: result.products,
                meta: {
                    total: result.total,
                    page: result.page,
                    totalPages: result.totalPages,
                    limit: pagination.limit,
                },
            });
        } catch (error) {
            next(error);
        }
    };

    createProduct = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const product = await this.productService.createProduct(req.body);

            res.status(201).json({
                success: true,
                data: product,
            });
        } catch (error) {
            next(error);
        }
    };

    updateProduct = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { id } = req.params;
            const product = await this.productService.updateProduct(id, req.body);

            res.json({
                success: true,
                data: product,
            });
        } catch (error) {
            next(error);
        }
    };

    deleteProduct = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { id } = req.params;
            await this.productService.deleteProduct(id);

            res.status(204).send();
        } catch (error) {
            next(error);
        }
    };
}
```

```typescript
// routes/product.routes.ts
import { Router } from 'express';
import { ProductController } from '../controllers/ProductController';
import { ProductService } from '../services/ProductService';
import { ProductRepository } from '../repositories/ProductRepository';
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validation.middleware';
import { createProductSchema, updateProductSchema } from '../schemas/product.schemas';

const router = Router();

// Initialize dependencies
const productRepository = new ProductRepository();
const productService = new ProductService(productRepository);
const productController = new ProductController(productService);

// Public routes
router.get('/', productController.listProducts);
router.get('/:id', productController.getProduct);

// Protected routes (require authentication)
router.post(
    '/',
    authenticate,
    validate(createProductSchema),
    productController.createProduct
);

router.put(
    '/:id',
    authenticate,
    validate(updateProductSchema),
    productController.updateProduct
);

router.delete('/:id', authenticate, productController.deleteProduct);

export default router;
```

#### Validation Schemas

```typescript
// schemas/product.schemas.ts
import { z } from 'zod';

export const createProductSchema = z.object({
    body: z.object({
        name: z.string().min(1).max(255),
        description: z.string().optional(),
        price: z.number().min(0),
        currency: z.string().length(3).optional(),
        stockQuantity: z.number().int().min(0),
        categoryId: z.string().uuid().optional(),
        images: z.array(
            z.object({
                url: z.string().url(),
                altText: z.string().optional(),
            })
        ).optional(),
        tags: z.array(z.string()).optional(),
    }),
});

export const updateProductSchema = z.object({
    body: z.object({
        name: z.string().min(1).max(255).optional(),
        description: z.string().optional(),
        price: z.number().min(0).optional(),
        stockQuantity: z.number().int().min(0).optional(),
        categoryId: z.string().uuid().optional(),
    }),
    params: z.object({
        id: z.string().uuid(),
    }),
});
```

### 4. Write Tests

```typescript
// services/__tests__/ProductService.test.ts
import { ProductService } from '../ProductService';
import { ProductRepository } from '../../repositories/ProductRepository';
import { NotFoundError, ValidationError } from '../../errors';

describe('ProductService', () => {
    let productService: ProductService;
    let productRepository: jest.Mocked<ProductRepository>;

    beforeEach(() => {
        productRepository = {
            findById: jest.fn(),
            findAll: jest.fn(),
            create: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
        } as any;

        productService = new ProductService(productRepository);
    });

    describe('createProduct', () => {
        it('should create product with valid input', async () => {
            const input = {
                name: 'Test Product',
                price: 99.99,
                stockQuantity: 10,
            };

            productRepository.create.mockResolvedValue({
                id: 'product-id',
                ...input,
                slug: 'test-product',
            } as any);

            const result = await productService.createProduct(input);

            expect(result.name).toBe('Test Product');
            expect(productRepository.create).toHaveBeenCalled();
        });

        it('should throw ValidationError for negative price', async () => {
            await expect(
                productService.createProduct({
                    name: 'Test',
                    price: -10,
                    stockQuantity: 5,
                })
            ).rejects.toThrow(ValidationError);
        });

        it('should throw ValidationError for empty name', async () => {
            await expect(
                productService.createProduct({
                    name: '',
                    price: 10,
                    stockQuantity: 5,
                })
            ).rejects.toThrow(ValidationError);
        });
    });

    describe('getProduct', () => {
        it('should return product if found', async () => {
            const product = { id: 'product-id', name: 'Test Product' };
            productRepository.findById.mockResolvedValue(product as any);

            const result = await productService.getProduct('product-id');

            expect(result).toEqual(product);
        });

        it('should throw NotFoundError if product not found', async () => {
            productRepository.findById.mockResolvedValue(null);

            await expect(productService.getProduct('invalid-id')).rejects.toThrow(
                NotFoundError
            );
        });
    });
});
```

```typescript
// controllers/__tests__/ProductController.test.ts
import request from 'supertest';
import { app } from '../../app';
import { ProductRepository } from '../../repositories/ProductRepository';

describe('ProductController', () => {
    let productRepository: ProductRepository;

    beforeEach(async () => {
        await clearDatabase();
        productRepository = new ProductRepository();
    });

    describe('GET /api/products', () => {
        it('should return list of products', async () => {
            await productRepository.create({
                name: 'Product 1',
                slug: 'product-1',
                price: 10,
                stockQuantity: 5,
            });

            const response = await request(app).get('/api/products').expect(200);

            expect(response.body.success).toBe(true);
            expect(response.body.data).toHaveLength(1);
        });

        it('should filter by category', async () => {
            const category = await createTestCategory();

            await productRepository.create({
                name: 'Product 1',
                slug: 'product-1',
                price: 10,
                stockQuantity: 5,
                categoryId: category.id,
            });

            const response = await request(app)
                .get('/api/products')
                .query({ categoryId: category.id })
                .expect(200);

            expect(response.body.data).toHaveLength(1);
        });

        it('should paginate results', async () => {
            // Create 25 products
            for (let i = 0; i < 25; i++) {
                await productRepository.create({
                    name: `Product ${i}`,
                    slug: `product-${i}`,
                    price: 10,
                    stockQuantity: 5,
                });
            }

            const response = await request(app)
                .get('/api/products')
                .query({ page: 2, limit: 10 })
                .expect(200);

            expect(response.body.data).toHaveLength(10);
            expect(response.body.meta.page).toBe(2);
            expect(response.body.meta.totalPages).toBe(3);
        });
    });

    describe('POST /api/products', () => {
        it('should create product with valid data', async () => {
            const authToken = await getAuthToken();

            const response = await request(app)
                .post('/api/products')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    name: 'New Product',
                    price: 99.99,
                    stockQuantity: 10,
                })
                .expect(201);

            expect(response.body.data.name).toBe('New Product');
        });

        it('should return 401 without authentication', async () => {
            await request(app)
                .post('/api/products')
                .send({
                    name: 'New Product',
                    price: 99.99,
                    stockQuantity: 10,
                })
                .expect(401);
        });

        it('should return 400 for invalid data', async () => {
            const authToken = await getAuthToken();

            await request(app)
                .post('/api/products')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    name: '',
                    price: -10,
                })
                .expect(400);
        });
    });

    describe('PUT /api/products/:id', () => {
        it('should update product', async () => {
            const product = await productRepository.create({
                name: 'Original Name',
                slug: 'original',
                price: 10,
                stockQuantity: 5,
            });

            const authToken = await getAuthToken();

            const response = await request(app)
                .put(`/api/products/${product.id}`)
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    name: 'Updated Name',
                    price: 20,
                })
                .expect(200);

            expect(response.body.data.name).toBe('Updated Name');
            expect(response.body.data.price).toBe(20);
        });

        it('should return 404 for non-existent product', async () => {
            const authToken = await getAuthToken();

            await request(app)
                .put('/api/products/non-existent-id')
                .set('Authorization', `Bearer ${authToken}`)
                .send({ name: 'Updated' })
                .expect(404);
        });
    });

    describe('DELETE /api/products/:id', () => {
        it('should delete product', async () => {
            const product = await productRepository.create({
                name: 'To Delete',
                slug: 'to-delete',
                price: 10,
                stockQuantity: 5,
            });

            const authToken = await getAuthToken();

            await request(app)
                .delete(`/api/products/${product.id}`)
                .set('Authorization', `Bearer ${authToken}`)
                .expect(204);

            const deleted = await productRepository.findById(product.id);
            expect(deleted).toBeNull();
        });
    });
});
```

## Output Format

```markdown
# Backend Layer: {Feature Name}

## API Endpoints

### {Method} {Path}
- Description: {description}
- Authentication: {required|optional|none}
- Request: {request_schema}
- Response: {response_schema}
- Status Codes: {codes}

## Architecture

### Repository Layer
\`\`\`typescript
{repository_code}
\`\`\`

### Service Layer
\`\`\`typescript
{service_code}
\`\`\`

### Controller Layer
\`\`\`typescript
{controller_code}
\`\`\`

### Routes
\`\`\`typescript
{routes_code}
\`\`\`

## Validation

### Schemas
\`\`\`typescript
{validation_schemas}
\`\`\`

## Testing

### Unit Tests
- {test_description}: {status}

### Integration Tests
- {test_description}: {status}

## Error Handling
- {error_type}: {handling_approach}

## Authentication
- {auth_details}
```

## Error Handling

- If framework unclear: Detect from package.json or ask
- If auth unclear: Suggest standard JWT approach
- If validation library unclear: Provide examples for common libraries
