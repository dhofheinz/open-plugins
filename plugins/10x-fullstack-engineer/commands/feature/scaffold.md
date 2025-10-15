# Scaffold Feature Operation

Generate boilerplate code structure for a new feature across database, backend, and frontend layers.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'scaffold' operation name)

Expected format: `name:"feature-name" [layers:"database,backend,frontend"] [pattern:"crud|workflow|custom"]`

## Workflow

### 1. Understand Scaffolding Requirements

Clarify:
- What is the feature name?
- Which layers need scaffolding?
- What pattern does it follow (CRUD, workflow, custom)?
- What entity/resource is being managed?

### 2. Analyze Project Structure

```bash
# Detect project structure
ls -la src/

# Detect ORM
cat package.json | grep -E "(prisma|typeorm|sequelize|mongoose)"

# Detect frontend framework
cat package.json | grep -E "(react|vue|angular|svelte)"

# Detect backend framework
cat package.json | grep -E "(express|fastify|nest|koa)"
```

### 3. Generate Database Layer

#### Migration Scaffold

```typescript
// migrations/TIMESTAMP_add_{feature_name}.ts
import { MigrationInterface, QueryRunner, Table, TableIndex, TableForeignKey } from 'typeorm';

export class Add{FeatureName}{Timestamp} implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.createTable(
            new Table({
                name: '{table_name}',
                columns: [
                    {
                        name: 'id',
                        type: 'uuid',
                        isPrimary: true,
                        default: 'gen_random_uuid()',
                    },
                    {
                        name: 'name',
                        type: 'varchar',
                        length: '255',
                        isNullable: false,
                    },
                    {
                        name: 'created_at',
                        type: 'timestamp',
                        default: 'now()',
                    },
                    {
                        name: 'updated_at',
                        type: 'timestamp',
                        default: 'now()',
                    },
                ],
            }),
            true
        );

        // Add indexes
        await queryRunner.createIndex(
            '{table_name}',
            new TableIndex({
                name: 'idx_{table_name}_created_at',
                columnNames: ['created_at'],
            })
        );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable('{table_name}');
    }
}
```

#### Entity/Model Scaffold

```typescript
// entities/{FeatureName}.entity.ts
import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    Index,
} from 'typeorm';

@Entity('{table_name}')
export class {FeatureName} {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'varchar', length: 255 })
    name: string;

    @CreateDateColumn({ name: 'created_at' })
    @Index()
    createdAt: Date;

    @UpdateDateColumn({ name: 'updated_at' })
    updatedAt: Date;
}
```

### 4. Generate Backend Layer

#### Repository Scaffold

```typescript
// repositories/{FeatureName}Repository.ts
import { Repository } from 'typeorm';
import { {FeatureName} } from '../entities/{FeatureName}.entity';
import { AppDataSource } from '../config/database';

export class {FeatureName}Repository {
    private repository: Repository<{FeatureName}>;

    constructor() {
        this.repository = AppDataSource.getRepository({FeatureName});
    }

    async findById(id: string): Promise<{FeatureName} | null> {
        return this.repository.findOne({ where: { id } });
    }

    async findAll(page: number = 1, limit: number = 20): Promise<[{FeatureName}[], number]> {
        const skip = (page - 1) * limit;
        return this.repository.findAndCount({
            skip,
            take: limit,
            order: { createdAt: 'DESC' },
        });
    }

    async create(data: Partial<{FeatureName}>): Promise<{FeatureName}> {
        const entity = this.repository.create(data);
        return this.repository.save(entity);
    }

    async update(id: string, data: Partial<{FeatureName}>): Promise<{FeatureName}> {
        await this.repository.update(id, data);
        const updated = await this.findById(id);
        if (!updated) {
            throw new Error('{FeatureName} not found after update');
        }
        return updated;
    }

    async delete(id: string): Promise<void> {
        await this.repository.delete(id);
    }
}
```

#### Service Scaffold

```typescript
// services/{FeatureName}Service.ts
import { {FeatureName}Repository } from '../repositories/{FeatureName}Repository';
import { {FeatureName} } from '../entities/{FeatureName}.entity';
import { NotFoundError, ValidationError } from '../errors';

export interface Create{FeatureName}Input {
    name: string;
}

export interface Update{FeatureName}Input {
    name?: string;
}

export class {FeatureName}Service {
    constructor(private repository: {FeatureName}Repository) {}

    async get{FeatureName}(id: string): Promise<{FeatureName}> {
        const entity = await this.repository.findById(id);
        if (!entity) {
            throw new NotFoundError(`{FeatureName} with ID ${id} not found`);
        }
        return entity;
    }

    async list{FeatureName}s(
        page: number = 1,
        limit: number = 20
    ): Promise<{ data: {FeatureName}[]; total: number; page: number; totalPages: number }> {
        const [data, total] = await this.repository.findAll(page, limit);

        return {
            data,
            total,
            page,
            totalPages: Math.ceil(total / limit),
        };
    }

    async create{FeatureName}(input: Create{FeatureName}Input): Promise<{FeatureName}> {
        this.validateInput(input);
        return this.repository.create(input);
    }

    async update{FeatureName}(id: string, input: Update{FeatureName}Input): Promise<{FeatureName}> {
        await this.get{FeatureName}(id); // Verify exists
        return this.repository.update(id, input);
    }

    async delete{FeatureName}(id: string): Promise<void> {
        await this.get{FeatureName}(id); // Verify exists
        await this.repository.delete(id);
    }

    private validateInput(input: Create{FeatureName}Input): void {
        if (!input.name || input.name.trim().length === 0) {
            throw new ValidationError('Name is required');
        }

        if (input.name.length > 255) {
            throw new ValidationError('Name must not exceed 255 characters');
        }
    }
}
```

#### Controller Scaffold

```typescript
// controllers/{FeatureName}Controller.ts
import { Request, Response, NextFunction } from 'express';
import { {FeatureName}Service } from '../services/{FeatureName}Service';

export class {FeatureName}Controller {
    constructor(private service: {FeatureName}Service) {}

    get{FeatureName} = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { id } = req.params;
            const entity = await this.service.get{FeatureName}(id);

            res.json({
                success: true,
                data: entity,
            });
        } catch (error) {
            next(error);
        }
    };

    list{FeatureName}s = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 20;

            const result = await this.service.list{FeatureName}s(page, limit);

            res.json({
                success: true,
                data: result.data,
                meta: {
                    total: result.total,
                    page: result.page,
                    totalPages: result.totalPages,
                    limit,
                },
            });
        } catch (error) {
            next(error);
        }
    };

    create{FeatureName} = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const entity = await this.service.create{FeatureName}(req.body);

            res.status(201).json({
                success: true,
                data: entity,
            });
        } catch (error) {
            next(error);
        }
    };

    update{FeatureName} = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { id } = req.params;
            const entity = await this.service.update{FeatureName}(id, req.body);

            res.json({
                success: true,
                data: entity,
            });
        } catch (error) {
            next(error);
        }
    };

    delete{FeatureName} = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { id } = req.params;
            await this.service.delete{FeatureName}(id);

            res.status(204).send();
        } catch (error) {
            next(error);
        }
    };
}
```

#### Routes Scaffold

```typescript
// routes/{feature-name}.routes.ts
import { Router } from 'express';
import { {FeatureName}Controller } from '../controllers/{FeatureName}Controller';
import { {FeatureName}Service } from '../services/{FeatureName}Service';
import { {FeatureName}Repository } from '../repositories/{FeatureName}Repository';
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validation.middleware';
import { create{FeatureName}Schema, update{FeatureName}Schema } from '../schemas/{feature-name}.schemas';

const router = Router();

// Initialize dependencies
const repository = new {FeatureName}Repository();
const service = new {FeatureName}Service(repository);
const controller = new {FeatureName}Controller(service);

// Public routes
router.get('/', controller.list{FeatureName}s);
router.get('/:id', controller.get{FeatureName});

// Protected routes
router.post(
    '/',
    authenticate,
    validate(create{FeatureName}Schema),
    controller.create{FeatureName}
);

router.put(
    '/:id',
    authenticate,
    validate(update{FeatureName}Schema),
    controller.update{FeatureName}
);

router.delete('/:id', authenticate, controller.delete{FeatureName});

export default router;
```

#### Validation Schema Scaffold

```typescript
// schemas/{feature-name}.schemas.ts
import { z } from 'zod';

export const create{FeatureName}Schema = z.object({
    body: z.object({
        name: z.string().min(1).max(255),
        // Add more fields as needed
    }),
});

export const update{FeatureName}Schema = z.object({
    body: z.object({
        name: z.string().min(1).max(255).optional(),
        // Add more fields as needed
    }),
    params: z.object({
        id: z.string().uuid(),
    }),
});
```

### 5. Generate Frontend Layer

#### Types Scaffold

```typescript
// features/{feature-name}/types/index.ts
export interface {FeatureName} {
    id: string;
    name: string;
    createdAt: string;
    updatedAt: string;
}

export interface Create{FeatureName}Input {
    name: string;
}

export interface Update{FeatureName}Input {
    name?: string;
}

export interface {FeatureName}Filters {
    page?: number;
    limit?: number;
}

export interface PaginatedResponse<T> {
    success: boolean;
    data: T[];
    meta: {
        total: number;
        page: number;
        totalPages: number;
        limit: number;
    };
}
```

#### API Client Scaffold

```typescript
// features/{feature-name}/api/{feature-name}Api.ts
import axios, { AxiosInstance } from 'axios';
import { {FeatureName}, Create{FeatureName}Input, Update{FeatureName}Input, {FeatureName}Filters, PaginatedResponse } from '../types';

class {FeatureName}Api {
    private client: AxiosInstance;

    constructor() {
        this.client = axios.create({
            baseURL: import.meta.env.VITE_API_URL || '/api',
            timeout: 10000,
        });

        this.client.interceptors.request.use((config) => {
            const token = localStorage.getItem('accessToken');
            if (token) {
                config.headers.Authorization = `Bearer ${token}`;
            }
            return config;
        });
    }

    async list(filters: {FeatureName}Filters = {}): Promise<PaginatedResponse<{FeatureName}>> {
        const response = await this.client.get('/{feature-name}', { params: filters });
        return response.data;
    }

    async getById(id: string): Promise<{FeatureName}> {
        const response = await this.client.get(`/{feature-name}/${id}`);
        return response.data.data;
    }

    async create(data: Create{FeatureName}Input): Promise<{FeatureName}> {
        const response = await this.client.post('/{feature-name}', data);
        return response.data.data;
    }

    async update(id: string, data: Update{FeatureName}Input): Promise<{FeatureName}> {
        const response = await this.client.put(`/{feature-name}/${id}`, data);
        return response.data.data;
    }

    async delete(id: string): Promise<void> {
        await this.client.delete(`/{feature-name}/${id}`);
    }
}

export const {featureName}Api = new {FeatureName}Api();
```

#### Component Scaffolds

```typescript
// features/{feature-name}/components/{FeatureName}List.tsx
import React from 'react';
import { use{FeatureName}s } from '../hooks/use{FeatureName}s';
import { {FeatureName}Card } from './{FeatureName}Card';
import { LoadingSpinner } from '@/components/LoadingSpinner';
import { ErrorMessage } from '@/components/ErrorMessage';

export const {FeatureName}List: React.FC = () => {
    const { items, isLoading, error, refetch } = use{FeatureName}s();

    if (isLoading) {
        return <LoadingSpinner />;
    }

    if (error) {
        return <ErrorMessage message={error.message} onRetry={refetch} />;
    }

    if (items.length === 0) {
        return <div>No items found.</div>;
    }

    return (
        <div className="{feature-name}-list">
            {items.map((item) => (
                <{FeatureName}Card key={item.id} item={item} />
            ))}
        </div>
    );
};
```

```typescript
// features/{feature-name}/components/{FeatureName}Card.tsx
import React from 'react';
import { {FeatureName} } from '../types';

interface {FeatureName}CardProps {
    item: {FeatureName};
    onEdit?: (id: string) => void;
    onDelete?: (id: string) => void;
}

export const {FeatureName}Card: React.FC<{FeatureName}CardProps> = ({
    item,
    onEdit,
    onDelete,
}) => {
    return (
        <div className="{feature-name}-card">
            <h3>{item.name}</h3>
            <div className="{feature-name}-card__actions">
                {onEdit && (
                    <button onClick={() => onEdit(item.id)}>Edit</button>
                )}
                {onDelete && (
                    <button onClick={() => onDelete(item.id)}>Delete</button>
                )}
            </div>
        </div>
    );
};
```

```typescript
// features/{feature-name}/components/{FeatureName}Form.tsx
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const {featureName}Schema = z.object({
    name: z.string().min(1, 'Name is required').max(255),
});

type {FeatureName}FormData = z.infer<typeof {featureName}Schema>;

interface {FeatureName}FormProps {
    initialData?: {FeatureName}FormData;
    onSubmit: (data: {FeatureName}FormData) => Promise<void>;
    onCancel?: () => void;
}

export const {FeatureName}Form: React.FC<{FeatureName}FormProps> = ({
    initialData,
    onSubmit,
    onCancel,
}) => {
    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting },
    } = useForm<{FeatureName}FormData>({
        resolver: zodResolver({featureName}Schema),
        defaultValues: initialData,
    });

    return (
        <form onSubmit={handleSubmit(onSubmit)} className="{feature-name}-form">
            <div className="form-group">
                <label htmlFor="name">Name</label>
                <input
                    id="name"
                    type="text"
                    {...register('name')}
                    disabled={isSubmitting}
                />
                {errors.name && (
                    <span className="error">{errors.name.message}</span>
                )}
            </div>

            <div className="form-actions">
                {onCancel && (
                    <button type="button" onClick={onCancel} disabled={isSubmitting}>
                        Cancel
                    </button>
                )}
                <button type="submit" disabled={isSubmitting}>
                    {isSubmitting ? 'Submitting...' : 'Submit'}
                </button>
            </div>
        </form>
    );
};
```

#### Custom Hook Scaffold

```typescript
// features/{feature-name}/hooks/use{FeatureName}s.ts
import { useState, useEffect, useCallback } from 'react';
import { {featureName}Api } from '../api/{feature-name}Api';
import { {FeatureName} } from '../types';

export const use{FeatureName}s = () => {
    const [items, setItems] = useState<{FeatureName}[]>([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<Error | null>(null);

    const fetch{FeatureName}s = useCallback(async () => {
        setIsLoading(true);
        setError(null);

        try {
            const response = await {featureName}Api.list();
            setItems(response.data);
        } catch (err: any) {
            setError(err);
        } finally {
            setIsLoading(false);
        }
    }, []);

    useEffect(() => {
        fetch{FeatureName}s();
    }, [fetch{FeatureName}s]);

    const create = useCallback(async (data: any) => {
        const newItem = await {featureName}Api.create(data);
        setItems((prev) => [...prev, newItem]);
    }, []);

    const update = useCallback(async (id: string, data: any) => {
        const updated = await {featureName}Api.update(id, data);
        setItems((prev) => prev.map((item) => (item.id === id ? updated : item)));
    }, []);

    const remove = useCallback(async (id: string) => {
        await {featureName}Api.delete(id);
        setItems((prev) => prev.filter((item) => item.id !== id));
    }, []);

    return {
        items,
        isLoading,
        error,
        refetch: fetch{FeatureName}s,
        create,
        update,
        remove,
    };
};
```

### 6. Generate Test Scaffolds

```typescript
// Backend test scaffold
// repositories/__tests__/{FeatureName}Repository.test.ts
import { {FeatureName}Repository } from '../{FeatureName}Repository';
import { createTestDataSource } from '../../test/utils';

describe('{FeatureName}Repository', () => {
    let repository: {FeatureName}Repository;

    beforeAll(async () => {
        await createTestDataSource();
        repository = new {FeatureName}Repository();
    });

    it('should create {feature-name}', async () => {
        const entity = await repository.create({ name: 'Test' });
        expect(entity.id).toBeDefined();
        expect(entity.name).toBe('Test');
    });

    it('should find {feature-name} by id', async () => {
        const created = await repository.create({ name: 'Test' });
        const found = await repository.findById(created.id);
        expect(found?.name).toBe('Test');
    });

    // Add more tests
});
```

```typescript
// Frontend test scaffold
// features/{feature-name}/components/__tests__/{FeatureName}List.test.tsx
import { render, screen } from '@testing-library/react';
import { {FeatureName}List } from '../{FeatureName}List';
import { use{FeatureName}s } from '../../hooks/use{FeatureName}s';

jest.mock('../../hooks/use{FeatureName}s');

describe('{FeatureName}List', () => {
    it('should render list of items', () => {
        (use{FeatureName}s as jest.Mock).mockReturnValue({
            items: [{ id: '1', name: 'Test Item' }],
            isLoading: false,
            error: null,
        });

        render(<{FeatureName}List />);

        expect(screen.getByText('Test Item')).toBeInTheDocument();
    });

    it('should show loading state', () => {
        (use{FeatureName}s as jest.Mock).mockReturnValue({
            items: [],
            isLoading: true,
            error: null,
        });

        render(<{FeatureName}List />);

        expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
    });

    // Add more tests
});
```

## Output Format

```markdown
# Scaffolded Feature: {Feature Name}

## Generated Files

### Database Layer
- migrations/TIMESTAMP_add_{feature_name}.ts
- entities/{FeatureName}.entity.ts

### Backend Layer
- repositories/{FeatureName}Repository.ts
- services/{FeatureName}Service.ts
- controllers/{FeatureName}Controller.ts
- routes/{feature-name}.routes.ts
- schemas/{feature-name}.schemas.ts

### Frontend Layer
- features/{feature-name}/types/index.ts
- features/{feature-name}/api/{feature-name}Api.ts
- features/{feature-name}/components/{FeatureName}List.tsx
- features/{feature-name}/components/{FeatureName}Card.tsx
- features/{feature-name}/components/{FeatureName}Form.tsx
- features/{feature-name}/hooks/use{FeatureName}s.ts

### Test Files
- repositories/__tests__/{FeatureName}Repository.test.ts
- services/__tests__/{FeatureName}Service.test.ts
- components/__tests__/{FeatureName}List.test.tsx

## Next Steps

1. Run database migration
2. Register routes in main app
3. Implement custom business logic
4. Add additional validations
5. Customize UI components
6. Write comprehensive tests
7. Add documentation

## Customization Points

- Add custom fields to entity
- Implement complex queries in repository
- Add business logic to service
- Customize UI components
- Add additional API endpoints
```

## Error Handling

- If project structure unclear: Ask for clarification or detect automatically
- If naming conflicts: Suggest alternative names
- Generate placeholders for unknown patterns
