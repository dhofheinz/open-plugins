# Feature Implementation Operation

Complete full-stack feature implementation across database, backend, and frontend layers with production-ready code, tests, and documentation.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'implement' operation name)

Expected format: `description:"feature details" [scope:"specific-area"] [priority:"high|medium|low"] [tests:"coverage-level"] [framework:"react|vue|angular"]`

## Workflow

### Phase 1: Requirements Understanding

Parse the feature description and clarify:

**Functional Requirements:**
- What is the user-facing functionality?
- What business problem does it solve?
- What are the acceptance criteria?
- What are the expected inputs and outputs?

**Non-Functional Requirements:**
- Performance expectations (response time, throughput)
- Security considerations (authentication, authorization, data protection)
- Scalability requirements (concurrent users, data volume)
- UI/UX requirements (responsive, accessible, real-time updates)

**Ask clarifying questions if:**
- Requirements are ambiguous or incomplete
- Multiple implementation approaches are possible
- Technical constraints are unclear
- Acceptance criteria are not well-defined

### Phase 2: Codebase Analysis

Before implementation, examine the existing project:

**Project Structure:**
```bash
# Discover project layout
ls -la
find . -maxdepth 3 -type d | grep -E "(src|app|api|components|models)"

# Identify tech stack
find . -name "package.json" -o -name "requirements.txt" -o -name "go.mod" -o -name "pom.xml"
cat package.json | grep -E "(react|vue|angular|express|fastify|prisma|typeorm)"
```

**Existing Patterns:**
```bash
# Database patterns
find . -path "*/migrations/*" -o -path "*/models/*" -o -path "*/schemas/*"

# Backend patterns
find . -path "*/services/*" -o -path "*/controllers/*" -o -path "*/routes/*"

# Frontend patterns
find . -path "*/components/*" -o -path "*/hooks/*" -o -path "*/store/*"

# Testing patterns
find . -path "*/__tests__/*" -o -path "*/test/*" -name "*.test.*" -o -name "*.spec.*"
```

**Conventions to Follow:**
- Naming conventions (camelCase, PascalCase, snake_case)
- File organization patterns
- Import/export patterns
- Error handling approaches
- Testing frameworks and patterns
- Documentation style

### Phase 3: Implementation Design

Design the implementation across all layers:

#### Database Design

**Schema Design:**
```sql
-- Example: User authentication feature
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_sessions_user_id (user_id),
    INDEX idx_user_sessions_token_hash (token_hash),
    INDEX idx_user_sessions_expires_at (expires_at)
);
```

**Index Strategy:**
- Primary keys for unique identification
- Foreign keys for relationships
- Indexes on frequently queried columns
- Composite indexes for multi-column queries
- Consider query patterns and performance

**Migration Planning:**
- Forward migration (up)
- Rollback migration (down)
- Data seeding if needed
- Migration testing strategy

#### Backend Design

**API Endpoint Design:**
```typescript
// Example: Authentication endpoints
POST   /api/auth/register          # Register new user
POST   /api/auth/login             # Login with credentials
POST   /api/auth/logout            # Logout current session
POST   /api/auth/refresh           # Refresh access token
GET    /api/auth/me                # Get current user profile
POST   /api/auth/verify-email      # Verify email address
POST   /api/auth/forgot-password   # Request password reset
POST   /api/auth/reset-password    # Reset password with token
```

**Request/Response Models:**
```typescript
// Register request
interface RegisterRequest {
  email: string;
  password: string;
  name?: string;
}

// Register response
interface RegisterResponse {
  user: {
    id: string;
    email: string;
    name: string | null;
  };
  accessToken: string;
  refreshToken: string;
}

// Error response
interface ErrorResponse {
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
}
```

**Service Layer Architecture:**
- Business logic separated from controllers
- Single responsibility per service
- Dependency injection for testability
- Error handling with custom exceptions
- Validation at service boundaries

**Data Access Layer:**
- Repository pattern for data operations
- Query builders or ORM usage
- Transaction management
- Connection pooling
- Caching strategy

#### Frontend Design

**Component Structure:**
```
src/features/auth/
├── components/
│   ├── LoginForm.tsx
│   ├── RegisterForm.tsx
│   ├── ForgotPasswordForm.tsx
│   └── EmailVerification.tsx
├── hooks/
│   ├── useAuth.ts
│   ├── useLogin.ts
│   └── useRegister.ts
├── store/
│   ├── authSlice.ts         # Redux/Zustand
│   └── authSelectors.ts
├── api/
│   └── authApi.ts           # API client
├── types/
│   └── auth.types.ts
└── __tests__/
    ├── LoginForm.test.tsx
    └── useAuth.test.ts
```

**State Management:**
- Local state vs global state decisions
- Server state management (React Query, SWR)
- Form state (React Hook Form, Formik)
- Authentication state persistence
- Loading and error states

**API Integration:**
- HTTP client configuration (axios, fetch)
- Request/response interceptors
- Error handling and retry logic
- Token management and refresh
- API request cancellation

### Phase 4: Incremental Implementation

Implement in phases for robustness and testability:

#### Phase 4.1 - Data Layer Implementation

**Step 1: Create Migration Script**

```sql
-- migrations/20240101120000_add_user_authentication.up.sql
BEGIN;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token_hash ON user_sessions(token_hash);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

COMMIT;
```

```sql
-- migrations/20240101120000_add_user_authentication.down.sql
BEGIN;

DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS users;

COMMIT;
```

**Step 2: Create/Update Models**

```typescript
// models/User.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { UserSession } from './UserSession';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255, unique: true })
  email: string;

  @Column({ type: 'varchar', length: 255, select: false })
  passwordHash: string;

  @Column({ type: 'boolean', default: false })
  emailVerified: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => UserSession, session => session.user)
  sessions: UserSession[];
}
```

```typescript
// models/UserSession.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn, Index } from 'typeorm';
import { User } from './User';

@Entity('user_sessions')
export class UserSession {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  @Index()
  userId: string;

  @Column({ type: 'varchar', length: 255 })
  @Index()
  tokenHash: string;

  @Column({ type: 'timestamp' })
  @Index()
  expiresAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User, user => user.sessions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;
}
```

**Step 3: Test Database Operations**

```typescript
// models/__tests__/User.test.ts
import { DataSource } from 'typeorm';
import { User } from '../User';

describe('User Model', () => {
  let dataSource: DataSource;

  beforeAll(async () => {
    dataSource = await createTestDataSource();
  });

  afterAll(async () => {
    await dataSource.destroy();
  });

  it('should create user with valid data', async () => {
    const userRepo = dataSource.getRepository(User);
    const user = userRepo.create({
      email: 'test@example.com',
      passwordHash: 'hashed_password',
    });

    await userRepo.save(user);

    expect(user.id).toBeDefined();
    expect(user.email).toBe('test@example.com');
    expect(user.emailVerified).toBe(false);
  });

  it('should enforce unique email constraint', async () => {
    const userRepo = dataSource.getRepository(User);

    await userRepo.save({
      email: 'duplicate@example.com',
      passwordHash: 'hash1',
    });

    await expect(
      userRepo.save({
        email: 'duplicate@example.com',
        passwordHash: 'hash2',
      })
    ).rejects.toThrow();
  });
});
```

#### Phase 4.2 - Backend Layer Implementation

**Step 1: Create Repository Layer**

```typescript
// repositories/UserRepository.ts
import { Repository } from 'typeorm';
import { User } from '../models/User';
import { AppDataSource } from '../config/database';

export class UserRepository {
  private repository: Repository<User>;

  constructor() {
    this.repository = AppDataSource.getRepository(User);
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.repository.findOne({
      where: { email: email.toLowerCase() },
      select: ['id', 'email', 'passwordHash', 'emailVerified', 'createdAt', 'updatedAt'],
    });
  }

  async findById(id: string): Promise<User | null> {
    return this.repository.findOne({
      where: { id },
    });
  }

  async create(data: { email: string; passwordHash: string }): Promise<User> {
    const user = this.repository.create({
      email: data.email.toLowerCase(),
      passwordHash: data.passwordHash,
    });
    return this.repository.save(user);
  }

  async updateEmailVerified(userId: string, verified: boolean): Promise<void> {
    await this.repository.update(userId, { emailVerified: verified });
  }

  async updatePassword(userId: string, passwordHash: string): Promise<void> {
    await this.repository.update(userId, { passwordHash });
  }

  async delete(userId: string): Promise<void> {
    await this.repository.delete(userId);
  }
}
```

**Step 2: Create Service Layer**

```typescript
// services/AuthService.ts
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { UserRepository } from '../repositories/UserRepository';
import { SessionRepository } from '../repositories/SessionRepository';
import {
  UnauthorizedError,
  ConflictError,
  ValidationError
} from '../errors';

export interface RegisterInput {
  email: string;
  password: string;
  name?: string;
}

export interface LoginInput {
  email: string;
  password: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export class AuthService {
  constructor(
    private userRepository: UserRepository,
    private sessionRepository: SessionRepository
  ) {}

  async register(input: RegisterInput): Promise<{ user: User; tokens: AuthTokens }> {
    // Validate input
    this.validateEmail(input.email);
    this.validatePassword(input.password);

    // Check if user exists
    const existingUser = await this.userRepository.findByEmail(input.email);
    if (existingUser) {
      throw new ConflictError('User with this email already exists');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(input.password, 12);

    // Create user
    const user = await this.userRepository.create({
      email: input.email,
      passwordHash,
    });

    // Generate tokens
    const tokens = await this.generateTokens(user.id);

    // Create session
    await this.sessionRepository.create({
      userId: user.id,
      tokenHash: await this.hashToken(tokens.refreshToken),
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
    });

    return { user, tokens };
  }

  async login(input: LoginInput): Promise<{ user: User; tokens: AuthTokens }> {
    // Find user
    const user = await this.userRepository.findByEmail(input.email);
    if (!user) {
      throw new UnauthorizedError('Invalid credentials');
    }

    // Verify password
    const isValid = await bcrypt.compare(input.password, user.passwordHash);
    if (!isValid) {
      throw new UnauthorizedError('Invalid credentials');
    }

    // Generate tokens
    const tokens = await this.generateTokens(user.id);

    // Create session
    await this.sessionRepository.create({
      userId: user.id,
      tokenHash: await this.hashToken(tokens.refreshToken),
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    });

    return { user, tokens };
  }

  async logout(refreshToken: string): Promise<void> {
    const tokenHash = await this.hashToken(refreshToken);
    await this.sessionRepository.deleteByTokenHash(tokenHash);
  }

  async refreshTokens(refreshToken: string): Promise<AuthTokens> {
    // Verify refresh token
    const payload = jwt.verify(refreshToken, process.env.JWT_SECRET!) as { userId: string };

    // Check if session exists
    const tokenHash = await this.hashToken(refreshToken);
    const session = await this.sessionRepository.findByTokenHash(tokenHash);

    if (!session || session.expiresAt < new Date()) {
      throw new UnauthorizedError('Invalid or expired refresh token');
    }

    // Generate new tokens
    const tokens = await this.generateTokens(payload.userId);

    // Update session
    await this.sessionRepository.update(session.id, {
      tokenHash: await this.hashToken(tokens.refreshToken),
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    });

    return tokens;
  }

  private async generateTokens(userId: string): Promise<AuthTokens> {
    const accessToken = jwt.sign(
      { userId, type: 'access' },
      process.env.JWT_SECRET!,
      { expiresIn: '15m' }
    );

    const refreshToken = jwt.sign(
      { userId, type: 'refresh' },
      process.env.JWT_SECRET!,
      { expiresIn: '7d' }
    );

    return { accessToken, refreshToken };
  }

  private async hashToken(token: string): Promise<string> {
    return bcrypt.hash(token, 10);
  }

  private validateEmail(email: string): void {
    const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$/;
    if (!emailRegex.test(email)) {
      throw new ValidationError('Invalid email format');
    }
  }

  private validatePassword(password: string): void {
    if (password.length < 8) {
      throw new ValidationError('Password must be at least 8 characters');
    }
    if (!/[A-Z]/.test(password)) {
      throw new ValidationError('Password must contain at least one uppercase letter');
    }
    if (!/[a-z]/.test(password)) {
      throw new ValidationError('Password must contain at least one lowercase letter');
    }
    if (!/[0-9]/.test(password)) {
      throw new ValidationError('Password must contain at least one number');
    }
  }
}
```

**Step 3: Create API Controllers**

```typescript
// controllers/AuthController.ts
import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/AuthService';

export class AuthController {
  constructor(private authService: AuthService) {}

  register = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { email, password, name } = req.body;

      const result = await this.authService.register({
        email,
        password,
        name,
      });

      res.status(201).json({
        user: {
          id: result.user.id,
          email: result.user.email,
          emailVerified: result.user.emailVerified,
        },
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      });
    } catch (error) {
      next(error);
    }
  };

  login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { email, password } = req.body;

      const result = await this.authService.login({ email, password });

      res.json({
        user: {
          id: result.user.id,
          email: result.user.email,
          emailVerified: result.user.emailVerified,
        },
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      });
    } catch (error) {
      next(error);
    }
  };

  logout = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { refreshToken } = req.body;

      await this.authService.logout(refreshToken);

      res.status(204).send();
    } catch (error) {
      next(error);
    }
  };

  refresh = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { refreshToken } = req.body;

      const tokens = await this.authService.refreshTokens(refreshToken);

      res.json(tokens);
    } catch (error) {
      next(error);
    }
  };

  me = async (req: Request, res: Response, next: NextFunction) => {
    try {
      // User is attached by auth middleware
      const user = req.user!;

      res.json({
        id: user.id,
        email: user.email,
        emailVerified: user.emailVerified,
        createdAt: user.createdAt,
      });
    } catch (error) {
      next(error);
    }
  };
}
```

**Step 4: Create Routes**

```typescript
// routes/auth.routes.ts
import { Router } from 'express';
import { AuthController } from '../controllers/AuthController';
import { AuthService } from '../services/AuthService';
import { UserRepository } from '../repositories/UserRepository';
import { SessionRepository } from '../repositories/SessionRepository';
import { authenticate } from '../middlewares/auth.middleware';
import { validateRequest } from '../middlewares/validation.middleware';
import { registerSchema, loginSchema, refreshSchema } from '../schemas/auth.schemas';

const router = Router();

// Initialize dependencies
const userRepository = new UserRepository();
const sessionRepository = new SessionRepository();
const authService = new AuthService(userRepository, sessionRepository);
const authController = new AuthController(authService);

// Public routes
router.post('/register', validateRequest(registerSchema), authController.register);
router.post('/login', validateRequest(loginSchema), authController.login);
router.post('/refresh', validateRequest(refreshSchema), authController.refresh);

// Protected routes
router.post('/logout', authenticate, authController.logout);
router.get('/me', authenticate, authController.me);

export default router;
```

**Step 5: Write Tests**

```typescript
// services/__tests__/AuthService.test.ts
import { AuthService } from '../AuthService';
import { UserRepository } from '../../repositories/UserRepository';
import { SessionRepository } from '../../repositories/SessionRepository';
import { ConflictError, UnauthorizedError, ValidationError } from '../../errors';

describe('AuthService', () => {
  let authService: AuthService;
  let userRepository: jest.Mocked<UserRepository>;
  let sessionRepository: jest.Mocked<SessionRepository>;

  beforeEach(() => {
    userRepository = {
      findByEmail: jest.fn(),
      create: jest.fn(),
      findById: jest.fn(),
    } as any;

    sessionRepository = {
      create: jest.fn(),
      findByTokenHash: jest.fn(),
      update: jest.fn(),
      deleteByTokenHash: jest.fn(),
    } as any;

    authService = new AuthService(userRepository, sessionRepository);
  });

  describe('register', () => {
    it('should register new user successfully', async () => {
      const input = {
        email: 'test@example.com',
        password: 'Password123',
      };

      userRepository.findByEmail.mockResolvedValue(null);
      userRepository.create.mockResolvedValue({
        id: 'user-id',
        email: input.email,
        emailVerified: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      } as any);

      const result = await authService.register(input);

      expect(result.user).toBeDefined();
      expect(result.tokens.accessToken).toBeDefined();
      expect(result.tokens.refreshToken).toBeDefined();
      expect(userRepository.create).toHaveBeenCalled();
      expect(sessionRepository.create).toHaveBeenCalled();
    });

    it('should throw ConflictError if user exists', async () => {
      userRepository.findByEmail.mockResolvedValue({ id: 'existing-id' } as any);

      await expect(
        authService.register({
          email: 'existing@example.com',
          password: 'Password123',
        })
      ).rejects.toThrow(ConflictError);
    });

    it('should throw ValidationError for invalid email', async () => {
      await expect(
        authService.register({
          email: 'invalid-email',
          password: 'Password123',
        })
      ).rejects.toThrow(ValidationError);
    });

    it('should throw ValidationError for weak password', async () => {
      await expect(
        authService.register({
          email: 'test@example.com',
          password: 'weak',
        })
      ).rejects.toThrow(ValidationError);
    });
  });

  describe('login', () => {
    it('should login user successfully', async () => {
      const user = {
        id: 'user-id',
        email: 'test@example.com',
        passwordHash: await bcrypt.hash('Password123', 12),
      };

      userRepository.findByEmail.mockResolvedValue(user as any);

      const result = await authService.login({
        email: 'test@example.com',
        password: 'Password123',
      });

      expect(result.user).toBeDefined();
      expect(result.tokens).toBeDefined();
      expect(sessionRepository.create).toHaveBeenCalled();
    });

    it('should throw UnauthorizedError for invalid credentials', async () => {
      userRepository.findByEmail.mockResolvedValue(null);

      await expect(
        authService.login({
          email: 'test@example.com',
          password: 'Password123',
        })
      ).rejects.toThrow(UnauthorizedError);
    });
  });
});
```

```typescript
// controllers/__tests__/AuthController.test.ts
import request from 'supertest';
import { app } from '../../app';
import { UserRepository } from '../../repositories/UserRepository';

describe('AuthController', () => {
  let userRepository: UserRepository;

  beforeEach(async () => {
    await clearDatabase();
    userRepository = new UserRepository();
  });

  describe('POST /api/auth/register', () => {
    it('should register new user', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'newuser@example.com',
          password: 'Password123',
        })
        .expect(201);

      expect(response.body).toHaveProperty('user');
      expect(response.body).toHaveProperty('accessToken');
      expect(response.body).toHaveProperty('refreshToken');
      expect(response.body.user.email).toBe('newuser@example.com');
    });

    it('should return 409 for duplicate email', async () => {
      await userRepository.create({
        email: 'existing@example.com',
        passwordHash: 'hash',
      });

      await request(app)
        .post('/api/auth/register')
        .send({
          email: 'existing@example.com',
          password: 'Password123',
        })
        .expect(409);
    });

    it('should return 400 for invalid input', async () => {
      await request(app)
        .post('/api/auth/register')
        .send({
          email: 'invalid-email',
          password: 'weak',
        })
        .expect(400);
    });
  });

  describe('POST /api/auth/login', () => {
    it('should login existing user', async () => {
      // Create user first
      await request(app)
        .post('/api/auth/register')
        .send({
          email: 'test@example.com',
          password: 'Password123',
        });

      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'Password123',
        })
        .expect(200);

      expect(response.body).toHaveProperty('accessToken');
      expect(response.body).toHaveProperty('refreshToken');
    });

    it('should return 401 for invalid credentials', async () => {
      await request(app)
        .post('/api/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: 'Password123',
        })
        .expect(401);
    });
  });

  describe('GET /api/auth/me', () => {
    it('should return current user', async () => {
      // Register and login
      const registerResponse = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'test@example.com',
          password: 'Password123',
        });

      const { accessToken } = registerResponse.body;

      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(response.body.email).toBe('test@example.com');
    });

    it('should return 401 without token', async () => {
      await request(app)
        .get('/api/auth/me')
        .expect(401);
    });
  });
});
```

#### Phase 4.3 - Frontend Layer Implementation

**Step 1: Create API Client**

```typescript
// src/features/auth/api/authApi.ts
import axios, { AxiosInstance } from 'axios';

export interface RegisterRequest {
  email: string;
  password: string;
  name?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: {
    id: string;
    email: string;
    emailVerified: boolean;
  };
  accessToken: string;
  refreshToken: string;
}

export interface RefreshTokenResponse {
  accessToken: string;
  refreshToken: string;
}

export interface UserProfile {
  id: string;
  email: string;
  emailVerified: boolean;
  createdAt: string;
}

export class AuthApi {
  private client: AxiosInstance;

  constructor(baseURL: string = '/api') {
    this.client = axios.create({
      baseURL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor to add auth token
    this.client.interceptors.request.use((config) => {
      const token = localStorage.getItem('accessToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    // Response interceptor to handle token refresh
    this.client.interceptors.response.use(
      (response) => response,
      async (error) => {
        const originalRequest = error.config;

        // If 401 and not already retried, try to refresh token
        if (error.response?.status === 401 && !originalRequest._retry) {
          originalRequest._retry = true;

          try {
            const refreshToken = localStorage.getItem('refreshToken');
            if (refreshToken) {
              const response = await this.refreshTokens({ refreshToken });
              localStorage.setItem('accessToken', response.accessToken);
              localStorage.setItem('refreshToken', response.refreshToken);

              // Retry original request with new token
              originalRequest.headers.Authorization = `Bearer ${response.accessToken}`;
              return this.client(originalRequest);
            }
          } catch (refreshError) {
            // Refresh failed, clear tokens and redirect to login
            localStorage.removeItem('accessToken');
            localStorage.removeItem('refreshToken');
            window.location.href = '/login';
            throw refreshError;
          }
        }

        throw error;
      }
    );
  }

  async register(data: RegisterRequest): Promise<AuthResponse> {
    const response = await this.client.post<AuthResponse>('/auth/register', data);
    return response.data;
  }

  async login(data: LoginRequest): Promise<AuthResponse> {
    const response = await this.client.post<AuthResponse>('/auth/login', data);
    return response.data;
  }

  async logout(): Promise<void> {
    const refreshToken = localStorage.getItem('refreshToken');
    await this.client.post('/auth/logout', { refreshToken });
  }

  async refreshTokens(data: { refreshToken: string }): Promise<RefreshTokenResponse> {
    const response = await this.client.post<RefreshTokenResponse>('/auth/refresh', data);
    return response.data;
  }

  async getCurrentUser(): Promise<UserProfile> {
    const response = await this.client.get<UserProfile>('/auth/me');
    return response.data;
  }
}

export const authApi = new AuthApi();
```

**Step 2: Create React Hooks**

```typescript
// src/features/auth/hooks/useAuth.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { authApi } from '../api/authApi';

interface User {
  id: string;
  email: string;
  emailVerified: boolean;
}

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;

  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, name?: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
  clearError: () => void;
}

export const useAuth = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (email: string, password: string) => {
        set({ isLoading: true, error: null });

        try {
          const response = await authApi.login({ email, password });

          localStorage.setItem('accessToken', response.accessToken);
          localStorage.setItem('refreshToken', response.refreshToken);

          set({
            user: response.user,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error: any) {
          const errorMessage = error.response?.data?.error?.message || 'Login failed';
          set({ error: errorMessage, isLoading: false });
          throw error;
        }
      },

      register: async (email: string, password: string, name?: string) => {
        set({ isLoading: true, error: null });

        try {
          const response = await authApi.register({ email, password, name });

          localStorage.setItem('accessToken', response.accessToken);
          localStorage.setItem('refreshToken', response.refreshToken);

          set({
            user: response.user,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error: any) {
          const errorMessage = error.response?.data?.error?.message || 'Registration failed';
          set({ error: errorMessage, isLoading: false });
          throw error;
        }
      },

      logout: async () => {
        set({ isLoading: true });

        try {
          await authApi.logout();
        } catch (error) {
          console.error('Logout error:', error);
        } finally {
          localStorage.removeItem('accessToken');
          localStorage.removeItem('refreshToken');

          set({
            user: null,
            isAuthenticated: false,
            isLoading: false,
            error: null,
          });
        }
      },

      refreshUser: async () => {
        if (!get().isAuthenticated) return;

        try {
          const user = await authApi.getCurrentUser();
          set({ user });
        } catch (error) {
          console.error('Failed to refresh user:', error);
        }
      },

      clearError: () => set({ error: null }),
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
```

**Step 3: Create Components**

```typescript
// src/features/auth/components/LoginForm.tsx
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export const LoginForm: React.FC = () => {
  const { login, isLoading, error, clearError } = useAuth();
  const navigate = useNavigate();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    try {
      clearError();
      await login(data.email, data.password);
      navigate('/dashboard');
    } catch (error) {
      // Error is handled by the store
    }
  };

  return (
    <div className="w-full max-w-md mx-auto p-6">
      <h2 className="text-2xl font-bold mb-6">Login</h2>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        {error && (
          <div className="p-3 bg-red-50 border border-red-200 text-red-700 rounded">
            {error}
          </div>
        )}

        <div>
          <label htmlFor="email" className="block text-sm font-medium mb-1">
            Email
          </label>
          <input
            id="email"
            type="email"
            {...register('email')}
            className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading}
          />
          {errors.email && (
            <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>
          )}
        </div>

        <div>
          <label htmlFor="password" className="block text-sm font-medium mb-1">
            Password
          </label>
          <input
            id="password"
            type="password"
            {...register('password')}
            className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading}
          />
          {errors.password && (
            <p className="mt-1 text-sm text-red-600">{errors.password.message}</p>
          )}
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className="w-full py-2 px-4 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          {isLoading ? 'Logging in...' : 'Login'}
        </button>
      </form>
    </div>
  );
};
```

```typescript
// src/features/auth/components/RegisterForm.tsx
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';

const registerSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number'),
  confirmPassword: z.string(),
  name: z.string().optional(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
});

type RegisterFormData = z.infer<typeof registerSchema>;

export const RegisterForm: React.FC = () => {
  const { register: registerUser, isLoading, error, clearError } = useAuth();
  const navigate = useNavigate();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = async (data: RegisterFormData) => {
    try {
      clearError();
      await registerUser(data.email, data.password, data.name);
      navigate('/dashboard');
    } catch (error) {
      // Error is handled by the store
    }
  };

  return (
    <div className="w-full max-w-md mx-auto p-6">
      <h2 className="text-2xl font-bold mb-6">Create Account</h2>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        {error && (
          <div className="p-3 bg-red-50 border border-red-200 text-red-700 rounded">
            {error}
          </div>
        )}

        <div>
          <label htmlFor="name" className="block text-sm font-medium mb-1">
            Name (Optional)
          </label>
          <input
            id="name"
            type="text"
            {...register('name')}
            className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading}
          />
        </div>

        <div>
          <label htmlFor="email" className="block text-sm font-medium mb-1">
            Email
          </label>
          <input
            id="email"
            type="email"
            {...register('email')}
            className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading}
          />
          {errors.email && (
            <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>
          )}
        </div>

        <div>
          <label htmlFor="password" className="block text-sm font-medium mb-1">
            Password
          </label>
          <input
            id="password"
            type="password"
            {...register('password')}
            className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading}
          />
          {errors.password && (
            <p className="mt-1 text-sm text-red-600">{errors.password.message}</p>
          )}
        </div>

        <div>
          <label htmlFor="confirmPassword" className="block text-sm font-medium mb-1">
            Confirm Password
          </label>
          <input
            id="confirmPassword"
            type="password"
            {...register('confirmPassword')}
            className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading}
          />
          {errors.confirmPassword && (
            <p className="mt-1 text-sm text-red-600">{errors.confirmPassword.message}</p>
          )}
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className="w-full py-2 px-4 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          {isLoading ? 'Creating account...' : 'Register'}
        </button>
      </form>
    </div>
  );
};
```

```typescript
// src/features/auth/components/ProtectedRoute.tsx
import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export const ProtectedRoute: React.FC = () => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-lg">Loading...</div>
      </div>
    );
  }

  return isAuthenticated ? <Outlet /> : <Navigate to="/login" replace />;
};
```

**Step 4: Write Component Tests**

```typescript
// src/features/auth/components/__tests__/LoginForm.test.tsx
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { LoginForm } from '../LoginForm';
import { useAuth } from '../../hooks/useAuth';
import { BrowserRouter } from 'react-router-dom';

jest.mock('../../hooks/useAuth');

const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>;

describe('LoginForm', () => {
  const mockLogin = jest.fn();
  const mockClearError = jest.fn();

  beforeEach(() => {
    mockUseAuth.mockReturnValue({
      login: mockLogin,
      isLoading: false,
      error: null,
      clearError: mockClearError,
    } as any);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  const renderLoginForm = () => {
    return render(
      <BrowserRouter>
        <LoginForm />
      </BrowserRouter>
    );
  };

  it('should render login form', () => {
    renderLoginForm();

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /login/i })).toBeInTheDocument();
  });

  it('should show validation errors for invalid input', async () => {
    renderLoginForm();

    const submitButton = screen.getByRole('button', { name: /login/i });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText(/invalid email address/i)).toBeInTheDocument();
    });
  });

  it('should call login with valid credentials', async () => {
    mockLogin.mockResolvedValue(undefined);
    renderLoginForm();

    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'test@example.com' },
    });
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: 'Password123' },
    });

    const submitButton = screen.getByRole('button', { name: /login/i });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith('test@example.com', 'Password123');
    });
  });

  it('should display error message on login failure', () => {
    mockUseAuth.mockReturnValue({
      login: mockLogin,
      isLoading: false,
      error: 'Invalid credentials',
      clearError: mockClearError,
    } as any);

    renderLoginForm();

    expect(screen.getByText(/invalid credentials/i)).toBeInTheDocument();
  });

  it('should disable form during loading', () => {
    mockUseAuth.mockReturnValue({
      login: mockLogin,
      isLoading: true,
      error: null,
      clearError: mockClearError,
    } as any);

    renderLoginForm();

    expect(screen.getByLabelText(/email/i)).toBeDisabled();
    expect(screen.getByLabelText(/password/i)).toBeDisabled();
    expect(screen.getByRole('button', { name: /logging in/i })).toBeDisabled();
  });
});
```

#### Phase 4.4 - Integration & Polish

**Step 1: End-to-End Tests**

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3000');
  });

  test('should complete full registration flow', async ({ page }) => {
    // Navigate to register page
    await page.click('text=Register');

    // Fill registration form
    await page.fill('input[name="name"]', 'Test User');
    await page.fill('input[name="email"]', `test-${Date.now()}@example.com`);
    await page.fill('input[name="password"]', 'Password123');
    await page.fill('input[name="confirmPassword"]', 'Password123');

    // Submit form
    await page.click('button:has-text("Register")');

    // Should redirect to dashboard
    await expect(page).toHaveURL(/\/dashboard/);
    await expect(page.locator('text=Welcome')).toBeVisible();
  });

  test('should complete full login flow', async ({ page }) => {
    // Assume user already registered
    await page.click('text=Login');

    // Fill login form
    await page.fill('input[name="email"]', 'existing@example.com');
    await page.fill('input[name="password"]', 'Password123');

    // Submit form
    await page.click('button:has-text("Login")');

    // Should redirect to dashboard
    await expect(page).toHaveURL(/\/dashboard/);
  });

  test('should handle logout correctly', async ({ page }) => {
    // Login first
    await page.click('text=Login');
    await page.fill('input[name="email"]', 'existing@example.com');
    await page.fill('input[name="password"]', 'Password123');
    await page.click('button:has-text("Login")');
    await expect(page).toHaveURL(/\/dashboard/);

    // Logout
    await page.click('button:has-text("Logout")');

    // Should redirect to home/login
    await expect(page).toHaveURL(/\/(login)?$/);
  });

  test('should protect routes when not authenticated', async ({ page }) => {
    // Try to access protected route
    await page.goto('http://localhost:3000/dashboard');

    // Should redirect to login
    await expect(page).toHaveURL(/\/login/);
  });

  test('should refresh token automatically', async ({ page, context }) => {
    // Login
    await page.click('text=Login');
    await page.fill('input[name="email"]', 'existing@example.com');
    await page.fill('input[name="password"]', 'Password123');
    await page.click('button:has-text("Login")');

    // Get initial access token
    const initialStorage = await context.storageState();
    const initialToken = initialStorage.origins[0]?.localStorage.find(
      (item) => item.name === 'accessToken'
    )?.value;

    // Wait for token to expire (in real scenario, this would be 15 minutes)
    // For testing, you might mock the token expiration
    await page.waitForTimeout(16 * 60 * 1000); // 16 minutes

    // Make an API request that should trigger token refresh
    await page.reload();

    // Get new access token
    const newStorage = await context.storageState();
    const newToken = newStorage.origins[0]?.localStorage.find(
      (item) => item.name === 'accessToken'
    )?.value;

    // Tokens should be different
    expect(newToken).not.toBe(initialToken);
  });
});
```

**Step 2: Performance Optimization**

```typescript
// Performance considerations for authentication feature

// 1. Database Indexes (already included in migration)
// - idx_users_email for login lookups
// - idx_user_sessions_user_id for session queries
// - idx_user_sessions_token_hash for token validation
// - idx_user_sessions_expires_at for cleanup queries

// 2. Caching Strategy
// Example: Redis caching for user sessions
import { Redis } from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

// Cache user data after login
async function cacheUserSession(userId: string, userData: any) {
  await redis.setex(
    `user:${userId}`,
    15 * 60, // 15 minutes (access token lifetime)
    JSON.stringify(userData)
  );
}

// Get cached user data
async function getCachedUser(userId: string) {
  const cached = await redis.get(`user:${userId}`);
  return cached ? JSON.parse(cached) : null;
}

// 3. Password Hashing Optimization
// Use bcrypt with work factor 12 (balance security and performance)
const BCRYPT_ROUNDS = 12;

// 4. Token Generation Optimization
// Use JWT with short expiration for access tokens (15 minutes)
// Use longer expiration for refresh tokens (7 days)

// 5. Connection Pooling
// Configure database connection pool
{
  type: 'postgres',
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  extra: {
    max: 20,           // Maximum pool size
    min: 5,            // Minimum pool size
    idle: 10000,       // Idle timeout
    acquire: 30000,    // Acquire timeout
  }
}

// 6. Frontend Optimization
// - Use React.memo for authentication components
// - Lazy load protected routes
// - Implement request deduplication

// Example: Lazy loading
const Dashboard = React.lazy(() => import('./pages/Dashboard'));
const Profile = React.lazy(() => import('./pages/Profile'));

// Example: Request deduplication
import { useQuery } from '@tanstack/react-query';

function useCurrentUser() {
  return useQuery({
    queryKey: ['currentUser'],
    queryFn: () => authApi.getCurrentUser(),
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
}
```

**Step 3: Security Hardening**

```typescript
// Security measures for authentication feature

// 1. Rate Limiting
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
  message: 'Too many login attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/auth/login', loginLimiter);

// 2. Input Sanitization
import validator from 'validator';
import xss from 'xss';

function sanitizeInput(input: string): string {
  return xss(validator.trim(input));
}

// 3. SQL Injection Prevention (using parameterized queries with TypeORM)
// TypeORM automatically uses parameterized queries

// 4. XSS Prevention
// - Set security headers
import helmet from 'helmet';
app.use(helmet());

// - Content Security Policy
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:', 'https:'],
  },
}));

// 5. CSRF Protection
import csrf from 'csurf';
const csrfProtection = csrf({ cookie: true });
app.use(csrfProtection);

// 6. Secure Cookie Configuration
app.use(session({
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 24 * 60 * 60 * 1000, // 24 hours
  },
}));

// 7. Password Policy Enforcement
const PASSWORD_REQUIREMENTS = {
  minLength: 8,
  requireUppercase: true,
  requireLowercase: true,
  requireNumber: true,
  requireSpecialChar: false, // Optional
};

// 8. Account Lockout (after failed attempts)
async function checkAccountLockout(email: string): Promise<boolean> {
  const attempts = await redis.get(`login_attempts:${email}`);
  if (attempts && parseInt(attempts) >= 5) {
    const ttl = await redis.ttl(`login_attempts:${email}`);
    if (ttl > 0) {
      throw new Error(`Account locked. Try again in ${Math.ceil(ttl / 60)} minutes`);
    }
  }
  return false;
}

async function recordFailedLogin(email: string): Promise<void> {
  const key = `login_attempts:${email}`;
  const attempts = await redis.incr(key);
  if (attempts === 1) {
    await redis.expire(key, 15 * 60); // 15 minutes
  }
}

// 9. Session Management
// - Implement session rotation on privilege escalation
// - Invalidate sessions on password change
// - Implement "logout all devices" functionality

async function invalidateAllUserSessions(userId: string): Promise<void> {
  await sessionRepository.deleteAllByUserId(userId);
  await redis.del(`user:${userId}`);
}
```

**Step 4: Documentation**

```markdown
# Authentication Feature Documentation

## Overview

Complete user authentication system with email/password login, JWT tokens, session management, and secure password handling.

## Features

- User registration with email verification
- Login with email and password
- JWT-based authentication (access + refresh tokens)
- Token refresh mechanism
- Secure session management
- Password hashing with bcrypt
- Rate limiting on authentication endpoints
- CSRF protection
- Account lockout after failed attempts

## API Endpoints

### POST /api/auth/register

Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "name": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "emailVerified": false
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

**Error Responses:**
- 400 Bad Request - Invalid input
- 409 Conflict - Email already exists

### POST /api/auth/login

Login with existing credentials.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**Response (200 OK):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "emailVerified": true
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

**Error Responses:**
- 401 Unauthorized - Invalid credentials
- 429 Too Many Requests - Rate limit exceeded

### POST /api/auth/refresh

Refresh access token using refresh token.

**Request Body:**
```json
{
  "refreshToken": "jwt-refresh-token"
}
```

**Response (200 OK):**
```json
{
  "accessToken": "new-jwt-access-token",
  "refreshToken": "new-jwt-refresh-token"
}
```

### POST /api/auth/logout

Logout and invalidate current session.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "refreshToken": "jwt-refresh-token"
}
```

**Response (204 No Content)**

### GET /api/auth/me

Get current user profile.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200 OK):**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "emailVerified": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

## Frontend Usage

### Using the Auth Hook

```typescript
import { useAuth } from '@/features/auth/hooks/useAuth';

function MyComponent() {
  const { user, isAuthenticated, login, logout } = useAuth();

  const handleLogin = async () => {
    try {
      await login('user@example.com', 'password');
      // User is now logged in
    } catch (error) {
      // Handle error
    }
  };

  return (
    <div>
      {isAuthenticated ? (
        <>
          <p>Welcome, {user?.email}</p>
          <button onClick={logout}>Logout</button>
        </>
      ) : (
        <button onClick={handleLogin}>Login</button>
      )}
    </div>
  );
}
```

### Protecting Routes

```typescript
import { ProtectedRoute } from '@/features/auth/components/ProtectedRoute';

<Routes>
  <Route path="/login" element={<LoginPage />} />
  <Route path="/register" element={<RegisterPage />} />

  <Route element={<ProtectedRoute />}>
    <Route path="/dashboard" element={<Dashboard />} />
    <Route path="/profile" element={<Profile />} />
  </Route>
</Routes>
```

## Security Considerations

1. **Password Requirements:**
   - Minimum 8 characters
   - At least one uppercase letter
   - At least one lowercase letter
   - At least one number

2. **Token Lifetimes:**
   - Access token: 15 minutes
   - Refresh token: 7 days

3. **Rate Limiting:**
   - Login: 5 attempts per 15 minutes
   - Register: 3 attempts per hour

4. **Session Management:**
   - Sessions are invalidated on logout
   - Sessions are automatically cleaned up after expiration
   - Multiple sessions per user are allowed

## Testing

Run tests with:
```bash
# Unit tests
npm run test

# Integration tests
npm run test:integration

# E2E tests
npm run test:e2e
```

## Environment Variables

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=myapp

# JWT
JWT_SECRET=your-secret-key-change-in-production

# Session
SESSION_SECRET=your-session-secret

# Redis (for rate limiting and caching)
REDIS_URL=redis://localhost:6379

# SMTP (for email verification)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=your-email@example.com
SMTP_PASSWORD=your-smtp-password
```

## Deployment

1. Run migrations:
   ```bash
   npm run migrate
   ```

2. Build the application:
   ```bash
   npm run build
   ```

3. Start the server:
   ```bash
   npm start
   ```

## Troubleshooting

### Token expired error
If you receive "Token expired" errors, ensure:
- The JWT_SECRET is correctly set
- System clocks are synchronized
- Token refresh is working correctly

### Cannot login
If login fails:
- Verify database connection
- Check password hashing (bcrypt rounds)
- Verify rate limiting isn't blocking requests
- Check error logs for details

### CORS issues
If frontend cannot connect to backend:
- Verify CORS configuration in backend
- Ensure credentials are included in requests
- Check allowed origins match frontend URL
```

## Output Format

Provide complete implementation organized by layer:

```markdown
# Feature Implementation: {Feature Name}

## Overview
{Brief description and purpose}

## Implementation Summary
{High-level approach and key decisions}

## Phase 1: Database Layer

### Migration Script
{SQL migration with up/down}

### Models/Schemas
{Data models with relationships}

### Testing
{Database operation tests}

## Phase 2: Backend Layer

### Data Access Layer
{Repositories and queries}

### Business Logic Layer
{Services with business rules}

### API Layer
{Controllers and routes}

### API Documentation
{Endpoint specs with examples}

### Testing
{Unit and integration tests}

## Phase 3: Frontend Layer

### API Client
{HTTP client with interceptors}

### State Management
{Hooks and stores}

### Components
{React/Vue/Angular components}

### Testing
{Component tests}

## Phase 4: Integration & Polish

### E2E Tests
{End-to-end test scenarios}

### Performance Optimizations
{Caching, indexing, lazy loading}

### Security Hardening
{Rate limiting, validation, CSRF}

### Documentation
{API docs, usage guide, troubleshooting}

## Configuration Changes

### Environment Variables
{New env vars needed}

### Dependencies
{New packages to install}

## Deployment Considerations
{Migration steps, monitoring, rollback}

## Follow-up Tasks
{Future improvements}
```

## Quality Checklist

Before considering the feature complete:
- [ ] All layers implemented (database, backend, frontend)
- [ ] Database migrations tested (up and down)
- [ ] Unit tests written and passing (>80% coverage)
- [ ] Integration tests written and passing
- [ ] E2E tests for critical flows
- [ ] Error handling comprehensive
- [ ] Validation on both frontend and backend
- [ ] Security measures implemented (auth, rate limiting, CSRF)
- [ ] Performance optimized (indexes, caching, lazy loading)
- [ ] Accessibility considered (WCAG 2.1 AA)
- [ ] Documentation complete (API docs, usage guide)
- [ ] No hardcoded secrets or sensitive data
- [ ] Code follows project conventions
- [ ] Ready for code review

## Error Handling

**Unclear Requirements:**
- Ask specific questions about acceptance criteria
- Request clarification on edge cases
- Provide examples to confirm understanding
- Suggest sensible defaults if context missing

**Missing Context:**
- List needed information (tech stack, patterns)
- Attempt to discover from codebase
- Document assumptions made
- Provide alternatives if context unclear

**Implementation Blockers:**
- Clearly identify the blocker
- Suggest alternative approaches
- Provide workarounds if available
- Document issue for resolution
- Continue with unblocked portions

## Examples by Feature Type

### Real-time Features (WebSocket/SSE)
- WebSocket connection management
- Event broadcasting and subscriptions
- Presence tracking
- Conflict resolution
- Reconnection handling

### Payment Features (Stripe/PayPal)
- Checkout flow integration
- Webhook handling
- Payment method management
- Subscription management
- Invoice generation
- Refund processing

### File Upload Features
- Multipart form handling
- File validation (type, size)
- Storage integration (S3, GCS)
- Progress tracking
- Image optimization
- Virus scanning

### Search Features
- Full-text search implementation
- Filter and sorting
- Pagination
- Search suggestions
- Relevance scoring
- Query optimization
