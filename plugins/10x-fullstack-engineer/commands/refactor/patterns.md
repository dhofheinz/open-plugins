# Design Pattern Introduction Operation

Introduce proven design patterns to solve recurring design problems and improve code structure.

## Parameters

**Received from $ARGUMENTS**: All arguments after "patterns"

**Expected format**:
```
scope:"<path>" pattern:"<pattern-name>" [reason:"<motivation>"]
```

**Parameter definitions**:
- `scope` (REQUIRED): Path to apply pattern (e.g., "src/services/", "src/components/UserForm.tsx")
- `pattern` (REQUIRED): Pattern to introduce
  - `factory` - Create objects without specifying exact class
  - `strategy` - Encapsulate interchangeable algorithms
  - `observer` - Publish-subscribe event system
  - `decorator` - Add behavior dynamically
  - `adapter` - Make incompatible interfaces work together
  - `repository` - Abstract data access layer
  - `dependency-injection` - Invert control, improve testability
  - `singleton` - Ensure single instance (use sparingly!)
  - `command` - Encapsulate requests as objects
  - `facade` - Simplified interface to complex subsystem
- `reason` (OPTIONAL): Why introducing this pattern (e.g., "eliminate switch statement", "improve testability")

## Workflow

### 1. Pattern Selection Validation

Verify pattern is appropriate for the problem:

**Anti-patterns to avoid**:
- Using pattern for pattern's sake (over-engineering)
- Singleton when not needed (global state)
- Factory when simple constructor suffices
- Strategy for only 2 simple options

**Good reasons to introduce pattern**:
- Eliminate complex conditional logic (Strategy, State)
- Improve testability (Dependency Injection, Repository)
- Enable extensibility without modification (Strategy, Decorator, Observer)
- Simplify complex interface (Facade, Adapter)
- Separate concerns (Repository, Factory)

### 2. Analyze Current Code Structure

Understand what needs to change:

```bash
# Find relevant files
find <scope> -type f -name "*.ts" -o -name "*.tsx"

# Analyze complexity
npx eslint <scope> --rule 'complexity: [error, { max: 10 }]'

# Check dependencies
npx madge <scope>
```

### 3. Pattern-Specific Implementation

## Pattern Examples

### Pattern 1: Factory Pattern

**Use when**:
- Object creation is complex
- Need to choose between multiple implementations
- Want to hide creation logic
- Need centralized object creation

**Before** (Direct instantiation everywhere):
```typescript
// Scattered throughout codebase
const emailNotif = new EmailNotification(config);
await emailNotif.send(user, message);

const smsNotif = new SMSNotification(twilioConfig);
await smsNotif.send(user, message);

const pushNotif = new PushNotification(fcmConfig);
await pushNotif.send(user, message);

// Different interfaces, hard to extend
```

**After** (Factory Pattern):
```typescript
// notifications/NotificationFactory.ts
interface Notification {
  send(user: User, message: string): Promise<void>;
}

export class NotificationFactory {
  constructor(private config: NotificationConfig) {}

  create(type: NotificationType): Notification {
    switch (type) {
      case 'email':
        return new EmailNotification(this.config.email);
      case 'sms':
        return new SMSNotification(this.config.sms);
      case 'push':
        return new PushNotification(this.config.push);
      default:
        throw new Error(`Unknown notification type: ${type}`);
    }
  }
}

// Usage
const factory = new NotificationFactory(config);
const notification = factory.create(user.preferences.notificationType);
await notification.send(user, message);
```

**Improvements**:
- Centralized creation logic
- Consistent interface
- Easy to add new notification types
- Configuration hidden from consumers

---

### Pattern 2: Strategy Pattern

**Use when**:
- Multiple algorithms for same task
- Need to switch algorithms at runtime
- Want to eliminate complex conditionals
- Algorithms have different implementations but same interface

**Before** (Complex switch statement):
```typescript
// PaymentProcessor.ts - 180 lines, complexity: 15
class PaymentProcessor {
  async processPayment(order: Order, method: string) {
    switch (method) {
      case 'credit_card':
        // 40 lines of credit card processing
        const ccGateway = new CreditCardGateway(this.config.stripe);
        const ccToken = await ccGateway.tokenize(order.paymentDetails);
        const ccCharge = await ccGateway.charge(ccToken, order.amount);
        await this.recordTransaction(order.id, ccCharge);
        await this.sendReceipt(order.customer, ccCharge);
        return ccCharge;

      case 'paypal':
        // 40 lines of PayPal processing
        const ppGateway = new PayPalGateway(this.config.paypal);
        const ppAuth = await ppGateway.authenticate();
        const ppPayment = await ppGateway.createPayment(order);
        await this.recordTransaction(order.id, ppPayment);
        await this.sendReceipt(order.customer, ppPayment);
        return ppPayment;

      case 'bank_transfer':
        // 40 lines of bank transfer processing
        const btGateway = new BankTransferGateway(this.config.bank);
        const btReference = await btGateway.generateReference(order);
        await this.sendInstructions(order.customer, btReference);
        await this.recordTransaction(order.id, btReference);
        return btReference;

      case 'crypto':
        // 40 lines of crypto processing
        const cryptoGateway = new CryptoGateway(this.config.crypto);
        const wallet = await cryptoGateway.generateAddress();
        await this.sendInstructions(order.customer, wallet);
        await this.recordTransaction(order.id, wallet);
        return wallet;

      default:
        throw new Error(`Unsupported payment method: ${method}`);
    }
  }
}
```

**After** (Strategy Pattern):
```typescript
// payment/PaymentStrategy.ts
export interface PaymentStrategy {
  process(order: Order): Promise<PaymentResult>;
}

// payment/strategies/CreditCardStrategy.ts
export class CreditCardStrategy implements PaymentStrategy {
  constructor(private gateway: CreditCardGateway) {}

  async process(order: Order): Promise<PaymentResult> {
    const token = await this.gateway.tokenize(order.paymentDetails);
    const charge = await this.gateway.charge(token, order.amount);
    return {
      success: true,
      transactionId: charge.id,
      method: 'credit_card'
    };
  }
}

// payment/strategies/PayPalStrategy.ts
export class PayPalStrategy implements PaymentStrategy {
  constructor(private gateway: PayPalGateway) {}

  async process(order: Order): Promise<PaymentResult> {
    await this.gateway.authenticate();
    const payment = await this.gateway.createPayment(order);
    return {
      success: true,
      transactionId: payment.id,
      method: 'paypal'
    };
  }
}

// payment/strategies/BankTransferStrategy.ts
export class BankTransferStrategy implements PaymentStrategy {
  constructor(private gateway: BankTransferGateway) {}

  async process(order: Order): Promise<PaymentResult> {
    const reference = await this.gateway.generateReference(order);
    return {
      success: true,
      transactionId: reference,
      method: 'bank_transfer',
      requiresManualConfirmation: true
    };
  }
}

// payment/PaymentProcessor.ts - Now clean and extensible
export class PaymentProcessor {
  private strategies: Map<string, PaymentStrategy>;

  constructor(
    strategies: Map<string, PaymentStrategy>,
    private transactionRepo: TransactionRepository,
    private notificationService: NotificationService
  ) {
    this.strategies = strategies;
  }

  async processPayment(order: Order, method: string): Promise<PaymentResult> {
    const strategy = this.strategies.get(method);
    if (!strategy) {
      throw new UnsupportedPaymentMethodError(method);
    }

    const result = await strategy.process(order);
    await this.transactionRepo.record(order.id, result);
    await this.notificationService.sendReceipt(order.customer, result);

    return result;
  }
}

// Setup (dependency injection)
const processor = new PaymentProcessor(
  new Map([
    ['credit_card', new CreditCardStrategy(ccGateway)],
    ['paypal', new PayPalStrategy(ppGateway)],
    ['bank_transfer', new BankTransferStrategy(btGateway)],
    ['crypto', new CryptoStrategy(cryptoGateway)]
  ]),
  transactionRepo,
  notificationService
);
```

**Improvements**:
- Complexity: 15 → 3 (80% reduction)
- Open/Closed Principle: Add strategies without modifying processor
- Testability: Each strategy tested independently
- Maintainability: Clear separation of concerns
- Extensibility: Add new payment methods easily

---

### Pattern 3: Observer Pattern (Pub-Sub)

**Use when**:
- Multiple objects need to react to events
- Want loose coupling between components
- Need publish-subscribe event system
- State changes should notify dependents

**Before** (Tight coupling, manual notification):
```typescript
class UserService {
  async createUser(data: CreateUserInput) {
    const user = await this.db.users.create(data);

    // Tightly coupled to all consumers
    await this.emailService.sendWelcome(user);
    await this.analyticsService.trackSignup(user);
    await this.subscriptionService.createTrialSubscription(user);
    await this.notificationService.sendAdminAlert(user);
    await this.auditLogger.logUserCreated(user);

    // Adding new consumer requires modifying this method
    return user;
  }
}
```

**After** (Observer Pattern):
```typescript
// events/EventEmitter.ts
type EventHandler<T = any> = (data: T) => Promise<void> | void;

export class EventEmitter {
  private handlers: Map<string, EventHandler[]> = new Map();

  on(event: string, handler: EventHandler): void {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, []);
    }
    this.handlers.get(event)!.push(handler);
  }

  async emit(event: string, data: any): Promise<void> {
    const handlers = this.handlers.get(event) || [];
    await Promise.all(handlers.map(handler => handler(data)));
  }
}

// events/UserEvents.ts
export const UserEvents = {
  CREATED: 'user.created',
  UPDATED: 'user.updated',
  DELETED: 'user.deleted'
} as const;

// services/UserService.ts - Now decoupled
export class UserService {
  constructor(
    private db: Database,
    private events: EventEmitter
  ) {}

  async createUser(data: CreateUserInput): Promise<User> {
    const user = await this.db.users.create(data);

    // Simply publish event
    await this.events.emit(UserEvents.CREATED, user);

    return user;
  }
}

// subscribers/WelcomeEmailSubscriber.ts
export class WelcomeEmailSubscriber {
  constructor(
    private emailService: EmailService,
    private events: EventEmitter
  ) {
    this.events.on(UserEvents.CREATED, this.handle.bind(this));
  }

  private async handle(user: User): Promise<void> {
    await this.emailService.sendWelcome(user);
  }
}

// subscribers/AnalyticsSubscriber.ts
export class AnalyticsSubscriber {
  constructor(
    private analyticsService: AnalyticsService,
    private events: EventEmitter
  ) {
    this.events.on(UserEvents.CREATED, this.handle.bind(this));
  }

  private async handle(user: User): Promise<void> {
    await this.analyticsService.trackSignup(user);
  }
}

// Setup
const events = new EventEmitter();
new WelcomeEmailSubscriber(emailService, events);
new AnalyticsSubscriber(analyticsService, events);
new SubscriptionSubscriber(subscriptionService, events);
new NotificationSubscriber(notificationService, events);
new AuditSubscriber(auditLogger, events);

const userService = new UserService(db, events);
```

**Improvements**:
- Loose coupling: UserService doesn't know about consumers
- Open/Closed: Add subscribers without modifying UserService
- Testability: Test UserService without dependencies
- Maintainability: Each subscriber isolated
- Flexibility: Enable/disable subscribers easily

---

### Pattern 4: Dependency Injection

**Use when**:
- Want to improve testability
- Need to swap implementations
- Want loose coupling
- Multiple dependencies

**Before** (Tight coupling, hard to test):
```typescript
class UserService {
  private db = new Database(process.env.DB_URL!);
  private emailService = new EmailService(process.env.SMTP_CONFIG!);
  private logger = new Logger('UserService');

  async createUser(data: CreateUserInput) {
    this.logger.info('Creating user', data);

    const user = await this.db.users.create(data);

    await this.emailService.sendWelcome(user);

    return user;
  }
}

// Testing is painful - can't mock dependencies
test('createUser', async () => {
  // Cannot inject test database or mock email service!
  const service = new UserService();
  // ...
});
```

**After** (Dependency Injection):
```typescript
// Define interfaces
interface IDatabase {
  users: {
    create(data: CreateUserData): Promise<User>;
    findById(id: string): Promise<User | null>;
  };
}

interface IEmailService {
  sendWelcome(user: User): Promise<void>;
}

interface ILogger {
  info(message: string, data?: any): void;
  error(message: string, error?: Error): void;
}

// Inject dependencies
class UserService {
  constructor(
    private db: IDatabase,
    private emailService: IEmailService,
    private logger: ILogger
  ) {}

  async createUser(data: CreateUserInput): Promise<User> {
    this.logger.info('Creating user', data);

    const user = await this.db.users.create(data);

    await this.emailService.sendWelcome(user);

    return user;
  }
}

// Production setup
const db = new PostgresDatabase(config.database);
const emailService = new SMTPEmailService(config.smtp);
const logger = new WinstonLogger('UserService');
const userService = new UserService(db, emailService, logger);

// Test setup - Easy mocking!
test('createUser sends welcome email', async () => {
  const mockDb = {
    users: {
      create: jest.fn().mockResolvedValue({ id: '1', email: 'test@example.com' })
    }
  };
  const mockEmail = {
    sendWelcome: jest.fn().mockResolvedValue(undefined)
  };
  const mockLogger = {
    info: jest.fn(),
    error: jest.fn()
  };

  const service = new UserService(mockDb, mockEmail, mockLogger);
  await service.createUser({ email: 'test@example.com', name: 'Test' });

  expect(mockEmail.sendWelcome).toHaveBeenCalledWith({ id: '1', email: 'test@example.com' });
});
```

**Improvements**:
- Testability: Easy to inject mocks
- Flexibility: Swap implementations (PostgreSQL → MongoDB)
- Loose coupling: Depends on interfaces, not implementations
- Clear dependencies: Constructor shows all dependencies

---

### Pattern 5: Repository Pattern

**Use when**:
- Want to abstract data access
- Need to swap data sources
- Want consistent query interface
- Separate domain from persistence

**Before** (Data access mixed with business logic):
```typescript
class UserService {
  async getUsersByRole(role: string) {
    // Direct database queries in service
    const users = await prisma.user.findMany({
      where: { role },
      include: {
        profile: true,
        posts: { where: { published: true } }
      }
    });
    return users;
  }

  async getActiveUsers() {
    const users = await prisma.user.findMany({
      where: { status: 'active', deletedAt: null }
    });
    return users;
  }

  // Many more methods with direct queries...
}
```

**After** (Repository Pattern):
```typescript
// repositories/UserRepository.ts
export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  findByRole(role: string): Promise<User[]>;
  findActive(): Promise<User[]>;
  create(data: CreateUserData): Promise<User>;
  update(id: string, data: Partial<User>): Promise<User>;
  delete(id: string): Promise<void>;
}

export class PrismaUserRepository implements IUserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { id },
      include: { profile: true }
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { email },
      include: { profile: true }
    });
  }

  async findByRole(role: string): Promise<User[]> {
    return this.prisma.user.findMany({
      where: { role },
      include: {
        profile: true,
        posts: { where: { published: true } }
      }
    });
  }

  async findActive(): Promise<User[]> {
    return this.prisma.user.findMany({
      where: { status: 'active', deletedAt: null }
    });
  }

  async create(data: CreateUserData): Promise<User> {
    return this.prisma.user.create({ data });
  }

  async update(id: string, data: Partial<User>): Promise<User> {
    return this.prisma.user.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.user.update({
      where: { id },
      data: { deletedAt: new Date() }
    });
  }
}

// services/UserService.ts - Clean business logic
export class UserService {
  constructor(private userRepository: IUserRepository) {}

  async getUsersByRole(role: string): Promise<User[]> {
    return this.userRepository.findByRole(role);
  }

  async getActiveUsers(): Promise<User[]> {
    return this.userRepository.findActive();
  }

  // Business logic, no persistence concerns
}

// Easy to swap data sources
class InMemoryUserRepository implements IUserRepository {
  private users: Map<string, User> = new Map();

  async findById(id: string): Promise<User | null> {
    return this.users.get(id) || null;
  }

  // ... other methods using in-memory Map
}

// Testing with in-memory repository
test('getUsersByRole', async () => {
  const repo = new InMemoryUserRepository();
  await repo.create({ id: '1', email: 'admin@example.com', role: 'admin' });

  const service = new UserService(repo);
  const admins = await service.getUsersByRole('admin');

  expect(admins).toHaveLength(1);
});
```

**Improvements**:
- Separation of concerns: Business logic separate from persistence
- Testability: Easy to use in-memory repository for tests
- Flexibility: Swap Prisma → TypeORM → MongoDB without changing services
- Consistency: Standardized query interface
- Caching: Easy to add caching layer in repository

---

### Pattern 6: Decorator Pattern

**Use when**:
- Want to add behavior dynamically
- Need multiple combinations of features
- Avoid subclass explosion
- Wrap functionality around core

**Before** (Subclass explosion):
```typescript
class Logger { log(message: string) { /* ... */ } }
class TimestampLogger extends Logger { /* adds timestamp */ }
class ColorLogger extends Logger { /* adds colors */ }
class FileLogger extends Logger { /* writes to file */ }
class TimestampColorLogger extends TimestampLogger { /* both timestamp and color */ }
class TimestampFileLogger extends TimestampLogger { /* both timestamp and file */ }
// Need class for every combination!
```

**After** (Decorator Pattern):
```typescript
// Core interface
interface Logger {
  log(message: string): void;
}

// Base implementation
class ConsoleLogger implements Logger {
  log(message: string): void {
    console.log(message);
  }
}

// Decorators
class TimestampDecorator implements Logger {
  constructor(private logger: Logger) {}

  log(message: string): void {
    const timestamp = new Date().toISOString();
    this.logger.log(`[${timestamp}] ${message}`);
  }
}

class ColorDecorator implements Logger {
  constructor(private logger: Logger, private color: string) {}

  log(message: string): void {
    this.logger.log(`\x1b[${this.color}m${message}\x1b[0m`);
  }
}

class FileDecorator implements Logger {
  constructor(private logger: Logger, private filePath: string) {}

  log(message: string): void {
    this.logger.log(message);
    fs.appendFileSync(this.filePath, message + '\n');
  }
}

// Compose decorators
let logger: Logger = new ConsoleLogger();
logger = new TimestampDecorator(logger);
logger = new ColorDecorator(logger, '32'); // green
logger = new FileDecorator(logger, './app.log');

logger.log('Hello World');
// Output: [2025-01-15T10:30:00.000Z] Hello World (in green, also in file)
```

**Improvements**:
- Flexibility: Mix and match decorators
- No subclass explosion: N decorators instead of 2^N classes
- Open/Closed: Add decorators without modifying logger
- Composition over inheritance

---

## Output Format

```markdown
# Design Pattern Introduction Report

## Pattern Applied: <pattern-name>

**Scope**: <path>
**Reason**: <motivation>

## Problem Statement

**Before**:
- <issue 1>
- <issue 2>
- <issue 3>

**Symptoms**:
- Complex conditional logic
- Tight coupling
- Difficult to test
- Hard to extend

## Solution: <Pattern Name>

**Benefits**:
- <benefit 1>
- <benefit 2>
- <benefit 3>

**Trade-offs**:
- <trade-off 1> (if any)

## Implementation

### Files Created
- <new-file-1>
- <new-file-2>

### Files Modified
- <modified-file-1>
- <modified-file-2>

### Code Changes

**Before**:
```typescript
<original-code>
```

**After**:
```typescript
<refactored-code-with-pattern>
```

## Verification

**Tests**:
- All existing tests: PASS
- New pattern tests: 12 added
- Coverage: 78% → 85%

**Metrics**:
- Complexity: 15 → 4 (73% improvement)
- Coupling: High → Low
- Extensibility: Improved

## Usage Guide

**How to use the new pattern**:
```typescript
<usage-example>
```

**How to extend**:
```typescript
<extension-example>
```

## Next Steps

**Additional Improvements**:
1. <next-opportunity>
2. <another-opportunity>

---

**Pattern Introduction Complete**: Code is now more flexible, testable, and maintainable.
```

## Error Handling

**Pattern not appropriate**:
```
Warning: <pattern> may not be the best solution for this problem.

Current problem: <description>
Suggested pattern: <alternative-pattern>

Reason: <explanation>
```

**Over-engineering risk**:
```
Warning: Introducing <pattern> may be over-engineering for current needs.

Current complexity: LOW
Pattern complexity: HIGH

Recommendation: Consider simpler solutions first:
1. Extract method/function
2. Use simple conditional
3. Wait until pattern truly needed (YAGNI)
```
