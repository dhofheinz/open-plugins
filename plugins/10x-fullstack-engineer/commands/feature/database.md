# Database Layer Operation

Implement database layer only: migrations, models, schemas, indexes, and validation for a feature.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'database' operation name)

Expected format: `description:"database changes needed" [migration:"migration_name"] [orm:"prisma|typeorm|sequelize"]`

## Workflow

### 1. Understand Database Requirements

Parse the requirements and clarify:
- What tables/collections need to be created or modified?
- What are the relationships between entities?
- What queries will be frequently executed (for index design)?
- What are the data validation requirements?
- Are there any data migration needs (existing data to transform)?

### 2. Analyze Existing Database Structure

Examine current database setup:

```bash
# Find existing migrations
find . -path "*/migrations/*" -o -path "*/prisma/migrations/*"

# Find existing models
find . -path "*/models/*" -o -path "*/entities/*" -o -name "schema.prisma"

# Check ORM configuration
find . -name "ormconfig.js" -o -name "datasource.ts" -o -name "schema.prisma"
```

**Identify:**
- ORM being used (Prisma, TypeORM, Sequelize, Mongoose, etc.)
- Database type (PostgreSQL, MySQL, MongoDB, etc.)
- Naming conventions for tables and columns
- Migration strategy and tooling
- Existing relationships and constraints

### 3. Design Database Schema

#### Schema Design Template

**For SQL Databases:**
```sql
-- Example: E-commerce Product Catalog

-- Main products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP, -- Soft delete

    -- Constraints
    CONSTRAINT price_positive CHECK (price >= 0),
    CONSTRAINT stock_non_negative CHECK (stock_quantity >= 0),
    CONSTRAINT slug_format CHECK (slug ~* '^[a-z0-9-]+$')
);

-- Categories table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    parent_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Product images table (one-to-many)
CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Product tags (many-to-many)
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE product_tags (
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, tag_id)
);

-- Indexes for performance
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_slug ON products(slug);
CREATE INDEX idx_products_created_at ON products(created_at DESC);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_stock ON products(stock_quantity) WHERE stock_quantity > 0;
CREATE INDEX idx_products_deleted_at ON products(deleted_at) WHERE deleted_at IS NULL;

CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_slug ON categories(slug);

CREATE INDEX idx_product_images_product_id ON product_images(product_id);
CREATE INDEX idx_product_tags_product_id ON product_tags(product_id);
CREATE INDEX idx_product_tags_tag_id ON product_tags(tag_id);

-- Full-text search index
CREATE INDEX idx_products_search ON products USING GIN(to_tsvector('english', name || ' ' || COALESCE(description, '')));
```

**For NoSQL (MongoDB):**
```javascript
// Product schema
{
  _id: ObjectId,
  name: String,
  slug: String, // indexed, unique
  description: String,
  price: {
    amount: Number,
    currency: String
  },
  stockQuantity: Number,
  category: {
    id: ObjectId,
    name: String, // denormalized for performance
    slug: String
  },
  images: [
    {
      url: String,
      altText: String,
      displayOrder: Number
    }
  ],
  tags: [String], // indexed for queries
  createdAt: Date,
  updatedAt: Date,
  deletedAt: Date // soft delete
}

// Indexes
db.products.createIndex({ slug: 1 }, { unique: true })
db.products.createIndex({ "category.id": 1 })
db.products.createIndex({ price.amount: 1 })
db.products.createIndex({ tags: 1 })
db.products.createIndex({ createdAt: -1 })
db.products.createIndex({ name: "text", description: "text" }) // Full-text search
```

#### Index Strategy

**When to add indexes:**
- Primary keys (always)
- Foreign keys (for JOIN performance)
- Columns used in WHERE clauses
- Columns used in ORDER BY
- Columns used in GROUP BY
- Columns used for full-text search

**Composite indexes** for queries with multiple conditions:
```sql
-- Query: SELECT * FROM products WHERE category_id = ? AND price > ? ORDER BY created_at DESC
CREATE INDEX idx_products_category_price_created ON products(category_id, price, created_at DESC);
```

**Partial indexes** for specific conditions:
```sql
-- Only index active (non-deleted) products
CREATE INDEX idx_active_products ON products(created_at) WHERE deleted_at IS NULL;
```

### 4. Create Migration Scripts

#### Example: TypeORM Migration

```typescript
// migrations/1704124800000-AddProductCatalog.ts
import { MigrationInterface, QueryRunner, Table, TableForeignKey, TableIndex } from 'typeorm';

export class AddProductCatalog1704124800000 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create categories table
        await queryRunner.createTable(
            new Table({
                name: 'categories',
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
                        length: '100',
                        isNullable: false,
                    },
                    {
                        name: 'slug',
                        type: 'varchar',
                        length: '100',
                        isUnique: true,
                        isNullable: false,
                    },
                    {
                        name: 'parent_id',
                        type: 'uuid',
                        isNullable: true,
                    },
                    {
                        name: 'description',
                        type: 'text',
                        isNullable: true,
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

        // Create products table
        await queryRunner.createTable(
            new Table({
                name: 'products',
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
                        name: 'slug',
                        type: 'varchar',
                        length: '255',
                        isUnique: true,
                        isNullable: false,
                    },
                    {
                        name: 'description',
                        type: 'text',
                        isNullable: true,
                    },
                    {
                        name: 'price',
                        type: 'decimal',
                        precision: 10,
                        scale: 2,
                        isNullable: false,
                    },
                    {
                        name: 'currency',
                        type: 'varchar',
                        length: '3',
                        default: "'USD'",
                    },
                    {
                        name: 'stock_quantity',
                        type: 'integer',
                        default: 0,
                    },
                    {
                        name: 'category_id',
                        type: 'uuid',
                        isNullable: true,
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
                    {
                        name: 'deleted_at',
                        type: 'timestamp',
                        isNullable: true,
                    },
                ],
            }),
            true
        );

        // Add foreign keys
        await queryRunner.createForeignKey(
            'categories',
            new TableForeignKey({
                columnNames: ['parent_id'],
                referencedColumnNames: ['id'],
                referencedTableName: 'categories',
                onDelete: 'CASCADE',
            })
        );

        await queryRunner.createForeignKey(
            'products',
            new TableForeignKey({
                columnNames: ['category_id'],
                referencedColumnNames: ['id'],
                referencedTableName: 'categories',
                onDelete: 'SET NULL',
            })
        );

        // Create indexes
        await queryRunner.createIndex(
            'products',
            new TableIndex({
                name: 'idx_products_category_id',
                columnNames: ['category_id'],
            })
        );

        await queryRunner.createIndex(
            'products',
            new TableIndex({
                name: 'idx_products_slug',
                columnNames: ['slug'],
            })
        );

        await queryRunner.createIndex(
            'products',
            new TableIndex({
                name: 'idx_products_price',
                columnNames: ['price'],
            })
        );

        await queryRunner.createIndex(
            'categories',
            new TableIndex({
                name: 'idx_categories_parent_id',
                columnNames: ['parent_id'],
            })
        );

        // Add check constraints
        await queryRunner.query(
            `ALTER TABLE products ADD CONSTRAINT price_positive CHECK (price >= 0)`
        );
        await queryRunner.query(
            `ALTER TABLE products ADD CONSTRAINT stock_non_negative CHECK (stock_quantity >= 0)`
        );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Drop in reverse order
        await queryRunner.dropTable('products');
        await queryRunner.dropTable('categories');
    }
}
```

#### Example: Prisma Migration

```prisma
// prisma/schema.prisma
model Category {
  id          String    @id @default(uuid()) @db.Uuid
  name        String    @db.VarChar(100)
  slug        String    @unique @db.VarChar(100)
  parentId    String?   @map("parent_id") @db.Uuid
  description String?   @db.Text
  createdAt   DateTime  @default(now()) @map("created_at")
  updatedAt   DateTime  @updatedAt @map("updated_at")

  parent   Category?  @relation("CategoryHierarchy", fields: [parentId], references: [id], onDelete: Cascade)
  children Category[] @relation("CategoryHierarchy")
  products Product[]

  @@index([parentId])
  @@index([slug])
  @@map("categories")
}

model Product {
  id            String    @id @default(uuid()) @db.Uuid
  name          String    @db.VarChar(255)
  slug          String    @unique @db.VarChar(255)
  description   String?   @db.Text
  price         Decimal   @db.Decimal(10, 2)
  currency      String    @default("USD") @db.VarChar(3)
  stockQuantity Int       @default(0) @map("stock_quantity")
  categoryId    String?   @map("category_id") @db.Uuid
  createdAt     DateTime  @default(now()) @map("created_at")
  updatedAt     DateTime  @updatedAt @map("updated_at")
  deletedAt     DateTime? @map("deleted_at")

  category Category?       @relation(fields: [categoryId], references: [id], onDelete: SetNull)
  images   ProductImage[]
  tags     ProductTag[]

  @@index([categoryId])
  @@index([slug])
  @@index([price])
  @@index([createdAt(sort: Desc)])
  @@index([stockQuantity], where: stockQuantity > 0)
  @@map("products")
}

model ProductImage {
  id           String   @id @default(uuid()) @db.Uuid
  productId    String   @map("product_id") @db.Uuid
  url          String   @db.VarChar(500)
  altText      String?  @map("alt_text") @db.VarChar(255)
  displayOrder Int      @default(0) @map("display_order")
  createdAt    DateTime @default(now()) @map("created_at")

  product Product @relation(fields: [productId], references: [id], onDelete: Cascade)

  @@index([productId])
  @@map("product_images")
}

model Tag {
  id   String @id @default(uuid()) @db.Uuid
  name String @unique @db.VarChar(50)
  slug String @unique @db.VarChar(50)

  products ProductTag[]

  @@map("tags")
}

model ProductTag {
  productId String @map("product_id") @db.Uuid
  tagId     String @map("tag_id") @db.Uuid

  product Product @relation(fields: [productId], references: [id], onDelete: Cascade)
  tag     Tag     @relation(fields: [tagId], references: [id], onDelete: Cascade)

  @@id([productId, tagId])
  @@index([productId])
  @@index([tagId])
  @@map("product_tags")
}
```

```bash
# Generate migration
npx prisma migrate dev --name add_product_catalog

# Apply migration to production
npx prisma migrate deploy
```

### 5. Create/Update Models

#### TypeORM Models

```typescript
// entities/Product.entity.ts
import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    DeleteDateColumn,
    ManyToOne,
    OneToMany,
    ManyToMany,
    JoinTable,
    JoinColumn,
    Index,
    Check,
} from 'typeorm';
import { Category } from './Category.entity';
import { ProductImage } from './ProductImage.entity';
import { Tag } from './Tag.entity';

@Entity('products')
@Check('"price" >= 0')
@Check('"stock_quantity" >= 0')
export class Product {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'varchar', length: 255 })
    name: string;

    @Column({ type: 'varchar', length: 255, unique: true })
    @Index()
    slug: string;

    @Column({ type: 'text', nullable: true })
    description: string | null;

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    @Index()
    price: number;

    @Column({ type: 'varchar', length: 3, default: 'USD' })
    currency: string;

    @Column({ type: 'integer', default: 0, name: 'stock_quantity' })
    stockQuantity: number;

    @Column({ type: 'uuid', name: 'category_id', nullable: true })
    @Index()
    categoryId: string | null;

    @CreateDateColumn({ name: 'created_at' })
    @Index()
    createdAt: Date;

    @UpdateDateColumn({ name: 'updated_at' })
    updatedAt: Date;

    @DeleteDateColumn({ name: 'deleted_at' })
    deletedAt: Date | null;

    // Relations
    @ManyToOne(() => Category, (category) => category.products, {
        onDelete: 'SET NULL',
    })
    @JoinColumn({ name: 'category_id' })
    category: Category;

    @OneToMany(() => ProductImage, (image) => image.product, {
        cascade: true,
    })
    images: ProductImage[];

    @ManyToMany(() => Tag, (tag) => tag.products)
    @JoinTable({
        name: 'product_tags',
        joinColumn: { name: 'product_id', referencedColumnName: 'id' },
        inverseJoinColumn: { name: 'tag_id', referencedColumnName: 'id' },
    })
    tags: Tag[];
}
```

```typescript
// entities/Category.entity.ts
import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    OneToMany,
    JoinColumn,
    Index,
} from 'typeorm';
import { Product } from './Product.entity';

@Entity('categories')
export class Category {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'varchar', length: 100 })
    name: string;

    @Column({ type: 'varchar', length: 100, unique: true })
    @Index()
    slug: string;

    @Column({ type: 'uuid', name: 'parent_id', nullable: true })
    @Index()
    parentId: string | null;

    @Column({ type: 'text', nullable: true })
    description: string | null;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;

    @UpdateDateColumn({ name: 'updated_at' })
    updatedAt: Date;

    // Relations
    @ManyToOne(() => Category, (category) => category.children, {
        onDelete: 'CASCADE',
    })
    @JoinColumn({ name: 'parent_id' })
    parent: Category | null;

    @OneToMany(() => Category, (category) => category.parent)
    children: Category[];

    @OneToMany(() => Product, (product) => product.category)
    products: Product[];
}
```

#### Validation

Add validation decorators if using class-validator:

```typescript
import { IsString, IsNumber, Min, IsOptional, IsUUID, MaxLength, Matches } from 'class-validator';

export class CreateProductDto {
    @IsString()
    @MaxLength(255)
    name: string;

    @IsString()
    @MaxLength(255)
    @Matches(/^[a-z0-9-]+$/, { message: 'Slug must contain only lowercase letters, numbers, and hyphens' })
    slug: string;

    @IsString()
    @IsOptional()
    description?: string;

    @IsNumber()
    @Min(0)
    price: number;

    @IsString()
    @MaxLength(3)
    @IsOptional()
    currency?: string;

    @IsNumber()
    @Min(0)
    stockQuantity: number;

    @IsUUID()
    @IsOptional()
    categoryId?: string;
}
```

### 6. Test Database Operations

```typescript
// entities/__tests__/Product.entity.test.ts
import { DataSource } from 'typeorm';
import { Product } from '../Product.entity';
import { Category } from '../Category.entity';
import { createTestDataSource } from '../../test/utils';

describe('Product Entity', () => {
    let dataSource: DataSource;
    let productRepository: ReturnType<typeof dataSource.getRepository<Product>>;
    let categoryRepository: ReturnType<typeof dataSource.getRepository<Category>>;

    beforeAll(async () => {
        dataSource = await createTestDataSource();
        productRepository = dataSource.getRepository(Product);
        categoryRepository = dataSource.getRepository(Category);
    });

    afterAll(async () => {
        await dataSource.destroy();
    });

    beforeEach(async () => {
        await productRepository.delete({});
        await categoryRepository.delete({});
    });

    describe('Creation', () => {
        it('should create product with valid data', async () => {
            const product = productRepository.create({
                name: 'Test Product',
                slug: 'test-product',
                price: 99.99,
                stockQuantity: 10,
            });

            await productRepository.save(product);

            expect(product.id).toBeDefined();
            expect(product.name).toBe('Test Product');
            expect(product.price).toBe(99.99);
        });

        it('should enforce unique slug constraint', async () => {
            await productRepository.save({
                name: 'Product 1',
                slug: 'duplicate-slug',
                price: 10,
                stockQuantity: 1,
            });

            await expect(
                productRepository.save({
                    name: 'Product 2',
                    slug: 'duplicate-slug',
                    price: 20,
                    stockQuantity: 2,
                })
            ).rejects.toThrow();
        });

        it('should enforce price check constraint', async () => {
            await expect(
                productRepository.save({
                    name: 'Invalid Product',
                    slug: 'invalid-price',
                    price: -10,
                    stockQuantity: 1,
                })
            ).rejects.toThrow(/price_positive/);
        });
    });

    describe('Relations', () => {
        it('should set category relationship', async () => {
            const category = await categoryRepository.save({
                name: 'Electronics',
                slug: 'electronics',
            });

            const product = await productRepository.save({
                name: 'Laptop',
                slug: 'laptop',
                price: 999,
                stockQuantity: 5,
                categoryId: category.id,
            });

            const loaded = await productRepository.findOne({
                where: { id: product.id },
                relations: ['category'],
            });

            expect(loaded?.category?.name).toBe('Electronics');
        });

        it('should cascade delete images', async () => {
            const product = await productRepository.save({
                name: 'Product with Images',
                slug: 'product-images',
                price: 50,
                stockQuantity: 1,
                images: [
                    { url: 'https://example.com/image1.jpg', displayOrder: 0 },
                    { url: 'https://example.com/image2.jpg', displayOrder: 1 },
                ],
            });

            await productRepository.delete(product.id);

            // Images should be deleted automatically
            // Verify by checking the images table is empty
        });
    });

    describe('Soft Delete', () => {
        it('should soft delete product', async () => {
            const product = await productRepository.save({
                name: 'Product to Delete',
                slug: 'product-delete',
                price: 10,
                stockQuantity: 1,
            });

            await productRepository.softDelete(product.id);

            const found = await productRepository.findOne({
                where: { id: product.id },
            });

            expect(found).toBeNull();

            // Can still find with withDeleted
            const deleted = await productRepository.findOne({
                where: { id: product.id },
                withDeleted: true,
            });

            expect(deleted).toBeDefined();
            expect(deleted?.deletedAt).toBeDefined();
        });
    });

    describe('Queries', () => {
        beforeEach(async () => {
            // Seed test data
            await productRepository.save([
                { name: 'Product A', slug: 'product-a', price: 10, stockQuantity: 5 },
                { name: 'Product B', slug: 'product-b', price: 20, stockQuantity: 0 },
                { name: 'Product C', slug: 'product-c', price: 30, stockQuantity: 10 },
            ]);
        });

        it('should find products by price range', async () => {
            const products = await productRepository.find({
                where: {
                    price: Between(15, 35),
                },
            });

            expect(products).toHaveLength(2);
        });

        it('should find in-stock products', async () => {
            const products = await productRepository
                .createQueryBuilder('product')
                .where('product.stock_quantity > 0')
                .getMany();

            expect(products).toHaveLength(2);
        });

        it('should order by created date', async () => {
            const products = await productRepository.find({
                order: { createdAt: 'DESC' },
            });

            expect(products[0].name).toBe('Product C');
        });
    });
});
```

## Output Format

```markdown
# Database Layer: {Feature Name}

## Schema Design

### Tables Created/Modified
- {table_name}: {description}

### Relationships
- {relationship_description}

### Indexes
- {index_name}: {purpose}

## Migration Scripts

### Up Migration
\`\`\`sql
{migration_sql}
\`\`\`

### Down Migration
\`\`\`sql
{rollback_sql}
\`\`\`

## Models/Entities

### {ModelName}
\`\`\`typescript
{model_code}
\`\`\`

## Validation

### DTOs
\`\`\`typescript
{validation_code}
\`\`\`

## Testing

### Test Results
- {test_description}: {status}

## Migration Commands

\`\`\`bash
# Run migration
{migration_command}

# Rollback migration
{rollback_command}
\`\`\`

## Performance Considerations
- {performance_note}
```

## Error Handling

- If ORM unclear: Ask which ORM is used or detect from codebase
- If database type unclear: Suggest common options or auto-detect
- If migration fails: Provide rollback instructions
- If constraints fail: Explain the constraint and suggest fixes
