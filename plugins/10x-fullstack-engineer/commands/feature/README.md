# Feature Implementation Skill

Production-ready feature implementation across database, backend, and frontend layers with incremental phased approach and comprehensive quality standards.

## Overview

This skill provides a complete workflow for implementing full-stack features from database schema to frontend components. It follows industry best practices including layered architecture, comprehensive testing, security hardening, and performance optimization.

## Available Operations

### `implement` - Complete Full-Stack Implementation

Implement a feature across all layers (database, backend, frontend, integration) with production-ready code, tests, and documentation.

**Usage:**
```bash
/10x-fullstack-engineer:feature implement description:"user authentication with OAuth and 2FA" tests:"comprehensive"
```

**Parameters:**
- `description` (required) - Detailed feature description
- `scope` (optional) - Specific area to focus on
- `priority` (optional) - high|medium|low
- `tests` (optional) - Coverage level
- `framework` (optional) - react|vue|angular

**What it does:**
1. **Requirements Understanding** - Clarifies functional and non-functional requirements
2. **Codebase Analysis** - Examines existing patterns and conventions
3. **Implementation Design** - Designs database schema, API endpoints, and UI components
4. **Incremental Implementation** - Implements in phases (data → backend → frontend → integration)
5. **Quality Assurance** - Tests, security, performance, and documentation

### `database` - Database Layer Only

Implement database migrations, models, schemas, indexes, and validation for a feature.

**Usage:**
```bash
/10x-fullstack-engineer:feature database description:"user profiles table with indexes" migration:"add_user_profiles"
```

**Parameters:**
- `description` (required) - Database changes needed
- `migration` (optional) - Migration name
- `orm` (optional) - prisma|typeorm|sequelize

**What it does:**
- Schema design with proper types and constraints
- Index strategy for query optimization
- Migration scripts (up and down)
- ORM models/entities
- Database operation tests

**Supports:**
- SQL databases (PostgreSQL, MySQL, SQLite)
- NoSQL databases (MongoDB)
- ORMs (Prisma, TypeORM, Sequelize, Mongoose)

### `backend` - Backend Layer Only

Implement repositories, services, API endpoints, validation, and tests for a feature.

**Usage:**
```bash
/10x-fullstack-engineer:feature backend description:"REST API for product search with filters" validation:"strict"
```

**Parameters:**
- `description` (required) - Backend functionality needed
- `api` (optional) - REST|GraphQL
- `validation` (optional) - strict|standard
- `auth` (optional) - required|optional

**What it does:**
- **Data Access Layer** - Repositories with query builders
- **Business Logic Layer** - Services with validation and error handling
- **API Layer** - Controllers and routes
- **Validation** - Request/response schemas
- **Testing** - Unit and integration tests

**Supports:**
- Express, Fastify, NestJS, Koa frameworks
- Zod, Joi, class-validator validation
- JWT authentication
- RBAC authorization

### `frontend` - Frontend Layer Only

Implement components, state management, API integration, and tests for a feature.

**Usage:**
```bash
/10x-fullstack-engineer:feature frontend description:"product catalog with infinite scroll and filters" framework:"react"
```

**Parameters:**
- `description` (required) - UI functionality needed
- `framework` (optional) - react|vue|angular
- `state` (optional) - redux|zustand|context
- `tests` (optional) - unit|integration|e2e

**What it does:**
- **Components** - Reusable, accessible UI components
- **State Management** - Zustand, Redux, Context API
- **API Integration** - HTTP client with interceptors
- **Custom Hooks** - Reusable logic
- **Testing** - Component and hook tests

**Supports:**
- React, Vue, Angular, Svelte
- TypeScript
- React Hook Form, Formik for forms
- React Query, SWR for server state
- TailwindCSS, CSS-in-JS

### `integrate` - Integration & Polish

Complete integration testing, performance optimization, security hardening, and documentation.

**Usage:**
```bash
/10x-fullstack-engineer:feature integrate feature:"authentication flow" scope:"E2E tests and performance"
```

**Parameters:**
- `feature` (required) - Feature name
- `scope` (optional) - e2e|performance|security|documentation
- `priority` (optional) - high|medium|low

**What it does:**
- **E2E Testing** - Playwright/Cypress tests for user workflows
- **Performance** - Frontend (lazy loading, memoization) and backend (caching, indexes) optimization
- **Security** - Input validation, XSS/CSRF protection, rate limiting, security headers
- **Documentation** - API docs (OpenAPI), user guides, developer documentation

### `scaffold` - Generate Boilerplate

Scaffold feature structure and boilerplate across all layers.

**Usage:**
```bash
/10x-fullstack-engineer:feature scaffold name:"notification-system" layers:"database,backend,frontend"
```

**Parameters:**
- `name` (required) - Feature name (kebab-case)
- `layers` (optional) - database,backend,frontend (default: all)
- `pattern` (optional) - crud|workflow|custom

**What it does:**
Generates complete boilerplate structure:
- Database migrations and entities
- Repository, service, controller, routes
- API client and types
- React components and hooks
- Test files

## Feature Types Supported

### Authentication & Authorization
- User registration/login
- OAuth/SSO integration
- 2FA/MFA
- Session management
- JWT token handling
- RBAC/ABAC

### Data Management (CRUD)
- Resource listing with pagination
- Filtering and sorting
- Search functionality
- Create/update/delete operations
- Soft delete support
- Audit logging

### Real-time Features
- WebSocket connections
- Server-Sent Events (SSE)
- Live updates
- Presence tracking
- Collaborative editing

### Payment Integration
- Stripe/PayPal checkout
- Subscription management
- Invoice generation
- Payment webhooks
- Refund processing

### File Management
- Upload with progress
- Image optimization
- S3/GCS integration
- Virus scanning
- File validation

### Search Features
- Full-text search
- Faceted search
- Autocomplete
- Advanced filtering
- Relevance scoring

## Implementation Phases

### Phase 1: Requirements Understanding
- Functional requirements clarification
- Non-functional requirements (performance, security, scalability)
- Acceptance criteria definition
- Edge case identification

### Phase 2: Codebase Analysis
- Project structure discovery
- Tech stack identification
- Existing patterns examination
- Convention adoption

### Phase 3: Implementation Design
- **Database Design** - Schema, relationships, indexes
- **Backend Design** - API endpoints, request/response models, service architecture
- **Frontend Design** - Component structure, state management, API integration

### Phase 4: Incremental Implementation

#### Phase 4.1 - Data Layer
1. Create migration scripts
2. Create/update models
3. Test database operations

#### Phase 4.2 - Backend Layer
1. Create repository layer
2. Create service layer
3. Create API controllers
4. Create routes
5. Write tests

#### Phase 4.3 - Frontend Layer
1. Create API client
2. Create React hooks
3. Create components
4. Write component tests

#### Phase 4.4 - Integration & Polish
1. End-to-end tests
2. Performance optimization
3. Security hardening
4. Documentation

## Quality Standards

### Code Quality
- [x] Single Responsibility Principle
- [x] DRY (Don't Repeat Yourself)
- [x] Proper error handling
- [x] Input validation
- [x] Type safety (TypeScript)
- [x] Consistent naming conventions

### Testing
- [x] Unit tests (>80% coverage)
- [x] Integration tests for APIs
- [x] Component tests for UI
- [x] E2E tests for critical flows
- [x] Edge case coverage

### Security
- [x] Input validation and sanitization
- [x] SQL injection prevention (parameterized queries)
- [x] XSS prevention (DOMPurify)
- [x] CSRF protection
- [x] Authentication/authorization
- [x] Rate limiting
- [x] Security headers (Helmet)
- [x] No hardcoded secrets

### Performance
- [x] Database indexes on frequently queried columns
- [x] Query optimization (eager loading, no N+1)
- [x] Response caching
- [x] Connection pooling
- [x] Frontend code splitting
- [x] Lazy loading images
- [x] Memoization
- [x] Virtualization for long lists

### Accessibility
- [x] Semantic HTML
- [x] ARIA labels
- [x] Keyboard navigation
- [x] Alt text for images
- [x] Color contrast (WCAG 2.1 AA)
- [x] Screen reader support

### Documentation
- [x] API documentation (OpenAPI/Swagger)
- [x] Code comments for complex logic
- [x] Usage examples
- [x] Deployment instructions
- [x] Environment variables documented

## Common Workflows

### 1. Implement Complete CRUD Feature

```bash
# Full-stack implementation
/10x-fullstack-engineer:feature implement description:"blog post management with rich text editor, categories, tags, and draft/publish workflow"

# What you get:
# - Database: posts, categories, tags tables with relationships
# - Backend: REST API with CRUD endpoints, validation, search
# - Frontend: Post list, detail, create/edit forms, rich text editor
# - Tests: Unit, integration, E2E
# - Docs: API documentation
```

### 2. Add New API Endpoints to Existing Feature

```bash
# Backend only
/10x-fullstack-engineer:feature backend description:"Add bulk operations API for products (bulk delete, bulk update status, bulk export)"
```

### 3. Build New UI Screen

```bash
# Frontend only
/10x-fullstack-engineer:feature frontend description:"Admin dashboard with charts showing sales, users, and revenue metrics" framework:"react" state:"zustand"
```

### 4. Optimize Existing Feature

```bash
# Integration & polish
/10x-fullstack-engineer:feature integrate feature:"product catalog" scope:"performance and E2E tests"
```

### 5. Quick Feature Scaffolding

```bash
# Generate boilerplate
/10x-fullstack-engineer:feature scaffold name:"email-notifications" layers:"database,backend"

# Then customize the generated files
```

## Architecture Patterns

### Layered Architecture

```
┌─────────────────────────────────────┐
│         Presentation Layer          │  React/Vue/Angular Components
│  (Components, Hooks, State)         │
└──────────────┬──────────────────────┘
               │ API Client
┌──────────────▼──────────────────────┐
│          API Layer                  │  Controllers, Routes, Middleware
│  (Request/Response Handling)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Business Logic Layer          │  Services, Validation, Rules
│  (Domain Logic)                     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Data Access Layer             │  Repositories, Query Builders
│  (Database Operations)              │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Database Layer              │  PostgreSQL, MongoDB, etc.
│  (Schema, Migrations, Indexes)      │
└─────────────────────────────────────┘
```

### Repository Pattern
- Abstracts data access
- Enables testability
- Centralizes query logic

### Service Pattern
- Contains business logic
- Orchestrates repositories
- Handles validation

### Controller Pattern
- HTTP request/response handling
- Delegates to services
- Thin layer

## Example Output

For a feature like "user authentication", the implementation includes:

### Database Layer
```sql
-- Migration: users and sessions tables
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
```

### Backend Layer
```typescript
// Service with business logic
async register(input: RegisterInput): Promise<{ user: User; tokens: AuthTokens }> {
  this.validateEmail(input.email);
  this.validatePassword(input.password);

  const passwordHash = await bcrypt.hash(input.password, 12);
  const user = await this.userRepository.create({ email: input.email, passwordHash });
  const tokens = await this.generateTokens(user.id);

  return { user, tokens };
}
```

### Frontend Layer
```typescript
// React component with state management
export const LoginForm: React.FC = () => {
  const { login, isLoading, error } = useAuth();
  const { register, handleSubmit, formState: { errors } } = useForm();

  const onSubmit = async (data) => {
    await login(data.email, data.password);
  };

  return <form onSubmit={handleSubmit(onSubmit)}>...</form>;
};
```

## Error Handling

The skill handles various scenarios:

### Unclear Requirements
- Asks specific questions about acceptance criteria
- Requests clarification on edge cases
- Provides examples to confirm understanding
- Suggests sensible defaults

### Missing Context
- Lists needed information (tech stack, patterns)
- Attempts to discover from codebase
- Documents assumptions made
- Provides alternatives if context unclear

### Implementation Blockers
- Clearly identifies the blocker
- Suggests alternative approaches
- Provides workarounds if available
- Documents issue for resolution
- Continues with unblocked portions

## Dependencies

This skill works with common tech stacks:

**Backend:**
- Node.js with Express, Fastify, NestJS
- TypeScript
- TypeORM, Prisma, Sequelize (ORMs)
- PostgreSQL, MySQL, MongoDB
- Jest, Vitest (testing)

**Frontend:**
- React, Vue, Angular
- TypeScript
- Zustand, Redux, Context API (state)
- React Hook Form, Zod (forms/validation)
- React Testing Library (testing)
- Playwright, Cypress (E2E)

## Tips for Best Results

1. **Be specific in descriptions** - More detail leads to better implementations
2. **Specify framework/ORM** - Helps generate appropriate code
3. **Start with scaffold** - Use `scaffold` for quick boilerplate, then customize
4. **Layer-by-layer approach** - Implement database → backend → frontend for complex features
5. **Use integrate for polish** - Don't skip the integration phase for production features

## Related Skills

This skill is part of the 10x Fullstack Engineer plugin:
- `/api` - API design and implementation
- `/database` - Database design and optimization
- `/test` - Test generation and coverage
- `/deploy` - Deployment and CI/CD

## License

MIT
