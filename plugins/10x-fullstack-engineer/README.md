# 10x Fullstack Engineer Plugin

**Elite-level full-stack development capabilities with AI-augmented expertise across the entire software development lifecycle**

The 10x Fullstack Engineer plugin provides a comprehensive suite of integrated skills that embody the expertise of a senior engineer with 20+ years of production experience. Each skill operates as a specialized expert system, working in concert to deliver production-ready software across architecture, development, optimization, debugging, refactoring, and quality assurance.

---

## Philosophy

Modern software engineering in 2025 requires more than technical proficiency—it demands **systemic thinking**, **quality-first execution**, and **continuous optimization**. This plugin embodies the mindset of a 10x engineer:

- **First Principles Thinking**: Understand the "why" before the "how"
- **Quality is Non-Negotiable**: Production-ready code from the start
- **Performance by Design**: Optimize for speed, scalability, and efficiency
- **Security by Default**: Build secure systems, not bolt-on security
- **Aggressive Modernization**: Embrace modern patterns, eliminate legacy debt
- **Comprehensive Solutions**: Think across the entire stack
- **Continuous Improvement**: Refactor, optimize, evolve

---

## Architecture

The plugin follows a **skill-based architecture** where each skill is a self-contained expert system with:

```
10x-fullstack-engineer/
├── agents/
│   └── 10x-fullstack-engineer.md    # Core agent with 15+ years expertise
├── commands/
│   ├── architect/                    # System architecture & design
│   │   ├── skill.md                  # Router
│   │   ├── design.md                 # Architecture design
│   │   ├── review.md                 # Architecture review
│   │   ├── adr.md                    # Decision records
│   │   ├── assess.md                 # Health assessment
│   │   ├── .scripts/                 # Utility tools
│   │   └── README.md
│   ├── feature/                      # Full-stack implementation
│   │   ├── skill.md                  # Router
│   │   ├── implement.md              # Complete implementation
│   │   ├── database.md               # Database layer
│   │   ├── backend.md                # Backend layer
│   │   ├── frontend.md               # Frontend layer
│   │   ├── integrate.md              # Integration & polish
│   │   ├── scaffold.md               # Boilerplate generation
│   │   └── README.md
│   ├── debug/                        # Debugging toolkit
│   │   ├── skill.md                  # Router
│   │   ├── diagnose.md               # Root cause analysis
│   │   ├── reproduce.md              # Reproduction strategies
│   │   ├── fix.md                    # Fix implementation
│   │   ├── analyze-logs.md           # Log analysis
│   │   ├── performance.md            # Performance debugging
│   │   ├── memory.md                 # Memory leak detection
│   │   ├── .scripts/                 # Profiling tools
│   │   └── README.md
│   ├── optimize/                     # Performance optimization
│   │   ├── skill.md                  # Router
│   │   ├── analyze.md                # Performance analysis
│   │   ├── database.md               # Database optimization
│   │   ├── backend.md                # Backend optimization
│   │   ├── frontend.md               # Frontend optimization
│   │   ├── infrastructure.md         # Infrastructure optimization
│   │   ├── benchmark.md              # Performance benchmarking
│   │   └── README.md
│   ├── refactor/                     # Code refactoring
│   │   ├── skill.md                  # Router
│   │   ├── analyze.md                # Code quality analysis
│   │   ├── extract.md                # Method/class extraction
│   │   ├── patterns.md               # Design pattern introduction
│   │   ├── types.md                  # TypeScript type safety
│   │   ├── duplicate.md              # Duplication elimination
│   │   ├── modernize.md              # Legacy code modernization
│   │   ├── .scripts/                 # Analysis tools
│   │   └── README.md
│   └── review/                       # Code review
│       ├── skill.md                  # Router
│       ├── full.md                   # Comprehensive review
│       ├── security.md               # Security audit
│       ├── performance.md            # Performance review
│       ├── quality.md                # Code quality review
│       ├── pr.md                     # Pull request review
│       ├── accessibility.md          # Accessibility review
│       └── README.md
└── plugin.json
```

### Design Patterns

**Router Pattern**: Each skill uses a `skill.md` router that parses arguments and delegates to specialized operation files.

**Agent Integration**: All operations invoke the **10x-fullstack-engineer** agent for expert-level guidance.

**Utility Scripts**: Each skill includes `.scripts/` directory with automated analysis tools.

**Consistent Interface**: All skills use `key:"value"` parameter format for predictability.

**Layered Abstraction**: Database → Backend → Frontend → Infrastructure layers across all skills.

---

## Skills Overview

### 🏗️ `/10x-fullstack-engineer:architect` - System Architecture & Design

**Purpose**: Design, review, document, and assess system architecture with industry best practices.

**Operations**:
- `design` - Create comprehensive architecture for new systems
- `review` - Analyze existing architecture for quality and scalability
- `adr` - Document architectural decisions (ADR format)
- `assess` - Health assessment with scoring and trend analysis

**Key Capabilities**:
- Multi-layer architecture design (database, backend, frontend, infrastructure)
- Trade-off analysis and technology selection
- ADR creation following Michael Nygard's template
- Architecture health scoring across 6 dimensions
- Dependency and complexity analysis utilities

**Example**:
```bash
/10x-fullstack-engineer:architect design requirements:"real-time notification system" scale:"10k concurrent users" constraints:"AWS, TypeScript"
/10x-fullstack-engineer:architect adr decision:"use PostgreSQL with row-level security for multi-tenancy" status:"accepted"
/10x-fullstack-engineer:architect assess baseline:"previous"
```

[Full Documentation →](/commands/architect/README.md)

---

### ⚙️ `/10x-fullstack-engineer:feature` - Full-Stack Feature Implementation

**Purpose**: Implement production-ready features across all stack layers with comprehensive quality standards.

**Operations**:
- `implement` - Complete full-stack feature implementation
- `database` - Database schema, migrations, models
- `backend` - API endpoints, services, business logic
- `frontend` - Components, state management, API integration
- `integrate` - E2E tests, performance, security, documentation
- `scaffold` - Generate boilerplate structure

**Key Capabilities**:
- Incremental phased implementation (data → backend → frontend → integration)
- Production-grade code with tests, security, performance
- Layered architecture (repository, service, controller, component)
- Support for React, Vue, Angular, Node.js, Python, Go
- Type safety with TypeScript
- Comprehensive testing (unit, integration, E2E)

**Example**:
```bash
/10x-fullstack-engineer:feature implement description:"blog post management with rich text editor" tests:"comprehensive"
/10x-fullstack-engineer:feature backend description:"REST API for product search with filters" validation:"strict"
/10x-fullstack-engineer:feature frontend description:"admin dashboard with charts" framework:"react"
```

[Full Documentation →](commands/feature/README.md)

---

### 🐛 `/10x-fullstack-engineer:debug` - Comprehensive Debugging Toolkit

**Purpose**: Systematic debugging across all layers with root cause analysis and permanent fixes.

**Operations**:
- `diagnose` - Comprehensive diagnosis and root cause analysis
- `reproduce` - Create reliable reproduction strategies
- `fix` - Implement fixes with verification and safeguards
- `analyze-logs` - Deep log analysis with pattern detection
- `performance` - Performance debugging and profiling
- `memory` - Memory leak detection and optimization

**Key Capabilities**:
- Cross-stack debugging (frontend, backend, database, infrastructure)
- Hypothesis-driven root cause analysis
- Automated reproduction with test cases
- Log pattern detection and correlation
- Performance profiling with bottleneck identification
- Memory leak detection with heap analysis

**Example**:
```bash
/10x-fullstack-engineer:debug diagnose issue:"500 errors on checkout" environment:"production" logs:"logs/app.log"
/10x-fullstack-engineer:debug reproduce issue:"payment webhook fails intermittently"
/10x-fullstack-engineer:debug fix issue:"race condition in order processing" root_cause:"missing transaction lock"
```

[Full Documentation →](commands/debug/README.md)

---

### ⚡ `/10x-fullstack-engineer:optimize` - Performance Optimization

**Purpose**: Comprehensive performance optimization across database, backend, frontend, and infrastructure.

**Operations**:
- `analyze` - Comprehensive performance analysis with bottleneck identification
- `database` - Query optimization, indexing, connection pooling
- `backend` - API performance, caching, concurrency
- `frontend` - Bundle size, rendering, Web Vitals
- `infrastructure` - Auto-scaling, CDN, resource allocation
- `benchmark` - Load testing and regression detection

**Key Capabilities**:
- Performance baseline establishment and tracking
- Layer-specific optimization strategies
- 70-98% performance improvements typical
- Lighthouse audits, database profiling, load testing
- Cost optimization alongside performance

**Example**:
```bash
/10x-fullstack-engineer:optimize analyze target:"production app" scope:all
/10x-fullstack-engineer:optimize database target:queries threshold:200ms
/10x-fullstack-engineer:optimize frontend target:all framework:react
/10x-fullstack-engineer:optimize benchmark type:load duration:300s concurrency:100
```

[Full Documentation →](commands/optimize/README.md)

---

### 🔧 `/10x-fullstack-engineer:refactor` - Code Refactoring

**Purpose**: Improve code quality, maintainability, and architecture without changing external behavior.

**Operations**:
- `analyze` - Code quality analysis with metrics
- `extract` - Method/class/module extraction
- `patterns` - Introduce design patterns
- `types` - Improve TypeScript type safety
- `duplicate` - Eliminate code duplication
- `modernize` - Update legacy code patterns

**Key Capabilities**:
- Safety-first refactoring with test coverage verification
- Complexity and duplication detection
- Design pattern application (Strategy, DI, Observer, etc.)
- TypeScript migration and type strengthening
- Legacy code modernization (callbacks→async, var→const, classes→hooks)

**Example**:
```bash
/10x-fullstack-engineer:refactor analyze scope:"src/" metrics:"complexity,duplication" depth:"detailed"
/10x-fullstack-engineer:refactor extract scope:"UserService.ts" type:"method" target:"validateUser"
/10x-fullstack-engineer:refactor patterns scope:"PaymentProcessor.ts" pattern:"strategy"
/10x-fullstack-engineer:refactor modernize scope:"legacy/" targets:"callbacks-to-async,var-to-const"
```

[Full Documentation →](commands/refactor/README.md)

---

### 🔍 `/10x-fullstack-engineer:review` - Code Review System

**Purpose**: Multi-category code review with structured, actionable feedback across security, performance, and quality.

**Operations**:
- `full` - Comprehensive multi-category review
- `security` - Security-focused audit (OWASP Top 10)
- `performance` - Performance optimization review
- `quality` - Code quality and maintainability
- `pr` - Pull request review with git integration
- `accessibility` - WCAG compliance review

**Key Capabilities**:
- Structured feedback with priority levels (Critical/High/Medium/Low)
- Depth levels (quick/standard/deep) for time management
- Category-specific checklists and analysis
- Integration with git for PR workflows
- Comprehensive output format with actionable recommendations

**Example**:
```bash
/10x-fullstack-engineer:review full scope:"authentication feature" depth:"deep"
/10x-fullstack-engineer:review security scope:"payment module" depth:"deep"
/10x-fullstack-engineer:review pr scope:"PR #456" depth:"standard"
/10x-fullstack-engineer:review accessibility scope:"checkout flow" depth:"deep" level:"AA"
```

[Full Documentation →](commands/review/README.md)

---

## Integrated Workflows

The true power of this plugin emerges from integrating skills across the development lifecycle.

### 1. New Feature Development (End-to-End)

```bash
# Phase 1: Design
/10x-fullstack-engineer:architect design requirements:"user authentication with OAuth and 2FA"
/10x-fullstack-engineer:architect adr decision:"use PostgreSQL for session storage" status:"accepted"

# Phase 2: Implementation
/10x-fullstack-engineer:feature implement description:"OAuth authentication with 2FA" tests:"comprehensive"

# Phase 3: Quality Assurance
/10x-fullstack-engineer:review security scope:"authentication module" depth:"deep"
/10x-fullstack-engineer:review quality scope:"authentication module" depth:"standard"

# Phase 4: Optimization
/10x-fullstack-engineer:optimize analyze target:"auth endpoints" scope:backend
/10x-fullstack-engineer:optimize backend target:api endpoints:"/auth/*"

# Phase 5: Final Validation
/10x-fullstack-engineer:architect assess
/10x-fullstack-engineer:review full scope:"authentication system" depth:"deep"
```

**Result**: Production-ready authentication system with comprehensive security, performance optimization, and quality validation.

---

### 2. Performance Crisis Resolution

```bash
# Phase 1: Diagnosis
/10x-fullstack-engineer:debug diagnose issue:"dashboard slow with 1000+ users" environment:"production"
/10x-fullstack-engineer:debug analyze-logs path:"logs/app.log" pattern:"slow" timeframe:"last-24h"

# Phase 2: Analysis
/10x-fullstack-engineer:optimize analyze target:"dashboard" scope:all metrics:"baseline"
/10x-fullstack-engineer:debug performance component:"dashboard-api" metric:"response-time"

# Phase 3: Optimization
/10x-fullstack-engineer:optimize database target:queries context:"dashboard queries" threshold:200ms
/10x-fullstack-engineer:optimize backend target:api endpoints:"/api/dashboard/*"
/10x-fullstack-engineer:optimize frontend target:rendering pages:"dashboard"

# Phase 4: Verification
/10x-fullstack-engineer:optimize benchmark type:load baseline:"pre-optimization" duration:300s
/10x-fullstack-engineer:review performance scope:"dashboard" depth:"standard"

# Phase 5: Documentation
/10x-fullstack-engineer:architect adr decision:"implement Redis caching for dashboard" status:"accepted"
```

**Result**: 70-95% performance improvement with permanent fixes and monitoring.

---

### 3. Technical Debt Paydown

```bash
# Phase 1: Assessment
/10x-fullstack-engineer:architect assess focus:"tech-debt"
/10x-fullstack-engineer:refactor analyze scope:"src/" metrics:"complexity,duplication,coverage"

# Phase 2: Planning
/10x-fullstack-engineer:architect review focus:"maintainability" depth:"deep"
# Identify top 10 refactoring opportunities

# Phase 3: Refactoring
/10x-fullstack-engineer:refactor extract scope:"UserService.ts" type:"method" target:"complex methods"
/10x-fullstack-engineer:refactor duplicate scope:"src/" threshold:80 strategy:"extract-function"
/10x-fullstack-engineer:refactor patterns scope:"services/" pattern:"dependency-injection"
/10x-fullstack-engineer:refactor modernize scope:"legacy/" targets:"callbacks-to-async"

# Phase 4: Type Safety
/10x-fullstack-engineer:refactor types scope:"src/" strategy:"eliminate-any" strict:true

# Phase 5: Validation
/10x-fullstack-engineer:review quality scope:"refactored modules" depth:"deep"
/10x-fullstack-engineer:architect assess baseline:"pre-refactoring"
```

**Result**: 60-80% complexity reduction, <3% duplication, 95%+ type coverage.

---

### 4. Pre-Production Validation

```bash
# Comprehensive security audit
/10x-fullstack-engineer:review security scope:"entire application" depth:"deep"
/10x-fullstack-engineer:architect review focus:"security" depth:"deep"

# Performance validation
/10x-fullstack-engineer:review performance scope:"critical paths" depth:"deep"
/10x-fullstack-engineer:optimize benchmark type:all duration:600s concurrency:200

# Architecture health
/10x-fullstack-engineer:architect assess
/10x-fullstack-engineer:architect review focus:"all" depth:"deep"

# Quality gates
/10x-fullstack-engineer:review full scope:"production code" depth:"deep"
/10x-fullstack-engineer:refactor analyze scope:"src/" metrics:"all"

# Final checks
/10x-fullstack-engineer:debug diagnose issue:"any production warnings" environment:"staging"
```

**Result**: Comprehensive production readiness validation across all dimensions.

---

### 5. Legacy System Modernization

```bash
# Phase 1: Understanding
/10x-fullstack-engineer:architect review focus:"all" depth:"deep"
/10x-fullstack-engineer:refactor analyze scope:"legacy/" metrics:"all" depth:"detailed"

# Phase 2: Architecture Design
/10x-fullstack-engineer:architect design requirements:"modernize to microservices" constraints:"gradual migration"
/10x-fullstack-engineer:architect adr decision:"strangler pattern for migration" status:"accepted"

# Phase 3: Incremental Refactoring
/10x-fullstack-engineer:refactor modernize scope:"src/" targets:"callbacks-to-async,var-to-const"
/10x-fullstack-engineer:refactor types scope:"src/" strategy:"migrate-to-ts"
/10x-fullstack-engineer:refactor patterns scope:"services/" pattern:"dependency-injection"

# Phase 4: Testing & Security
/10x-fullstack-engineer:review security scope:"migrated code" depth:"deep"
/10x-fullstack-engineer:feature integrate feature:"modernized services" scope:"e2e"

# Phase 5: Optimization
/10x-fullstack-engineer:optimize analyze target:"modernized system" scope:all
/10x-fullstack-engineer:optimize infrastructure target:all environment:production

# Phase 6: Validation
/10x-fullstack-engineer:architect assess baseline:"legacy-baseline"
/10x-fullstack-engineer:review full scope:"modernized system" depth:"deep"
```

**Result**: Modernized system with 40-60% performance improvement, reduced technical debt, improved maintainability.

---

## Quality Standards

All skills enforce production-grade quality standards:

### Code Quality
- ✅ SOLID principles and DRY
- ✅ TypeScript for type safety
- ✅ Functions <50 lines, complexity <10
- ✅ Meaningful naming and self-documenting code
- ✅ Comprehensive error handling
- ✅ No hardcoded secrets or sensitive data

### Testing
- ✅ >80% unit test coverage for critical code
- ✅ Integration tests for APIs
- ✅ Component tests for UI
- ✅ E2E tests for critical user flows
- ✅ Edge case and error scenario coverage

### Security
- ✅ Input validation and sanitization
- ✅ SQL injection prevention (parameterized queries)
- ✅ XSS prevention (DOMPurify, CSP)
- ✅ CSRF protection
- ✅ Authentication and authorization
- ✅ Rate limiting and security headers
- ✅ OWASP Top 10 compliance

### Performance
- ✅ Database indexes on frequently queried columns
- ✅ Query optimization (eager loading, no N+1)
- ✅ Response caching (Redis, CDN)
- ✅ Connection pooling
- ✅ Frontend code splitting and lazy loading
- ✅ Image optimization (WebP/AVIF)
- ✅ Web Vitals compliance (LCP <2.5s, FID <100ms, CLS <0.1)

### Accessibility
- ✅ Semantic HTML and ARIA labels
- ✅ Keyboard navigation
- ✅ Screen reader compatibility
- ✅ WCAG 2.1 AA compliance
- ✅ Color contrast (4.5:1 minimum)

### Documentation
- ✅ Architecture Decision Records (ADRs)
- ✅ API documentation (OpenAPI/Swagger)
- ✅ Code comments for complex logic
- ✅ README with setup and usage
- ✅ Environment variables documented

---

## Technology Stack Support

### Frontend
- **Frameworks**: React, Vue, Angular, Svelte, Next.js, Nuxt.js
- **Languages**: TypeScript, JavaScript (ES2020+)
- **State**: Zustand, Redux, Context API, Pinia, NgRx
- **Styling**: TailwindCSS, CSS-in-JS, SCSS, CSS Modules
- **Testing**: Jest, Vitest, React Testing Library, Playwright, Cypress

### Backend
- **Runtimes**: Node.js, Python, Go, Java
- **Frameworks**: Express, Fastify, NestJS, FastAPI, Django, Flask, Gin, Spring Boot
- **APIs**: REST, GraphQL, gRPC, WebSockets, Server-Sent Events
- **Testing**: Jest, Pytest, Go test, JUnit

### Database
- **SQL**: PostgreSQL, MySQL, SQLite
- **NoSQL**: MongoDB, Redis, DynamoDB
- **ORMs**: Prisma, TypeORM, Sequelize, SQLAlchemy, GORM
- **Tools**: Migrations, seeding, indexing, query optimization

### Infrastructure
- **Containers**: Docker, Docker Compose, Kubernetes
- **Cloud**: AWS, GCP, Azure, Vercel, Netlify
- **CI/CD**: GitHub Actions, GitLab CI, CircleCI, Jenkins
- **Monitoring**: CloudWatch, Prometheus, Grafana, Datadog, Sentry
- **Logging**: Winston, Pino, structlog, ELK stack

---

## Best Practices

### Development Workflow

**Start with Architecture**:
```bash
/10x-fullstack-engineer:architect design → /10x-fullstack-engineer:architect adr → /10x-fullstack-engineer:feature implement
```

**Continuous Quality**:
```bash
/10x-fullstack-engineer:review quality → /10x-fullstack-engineer:refactor → /10x-fullstack-engineer:review quality
```

**Performance First**:
```bash
/10x-fullstack-engineer:optimize analyze → /10x-fullstack-engineer:optimize [layer] → /10x-fullstack-engineer:optimize benchmark
```

**Debug Systematically**:
```bash
/10x-fullstack-engineer:debug diagnose → /10x-fullstack-engineer:debug reproduce → /10x-fullstack-engineer:debug fix
```

### When to Use Each Skill

| Scenario | Primary Skill | Supporting Skills |
|----------|---------------|-------------------|
| New Project | `/10x-fullstack-engineer:architect design` | `/10x-fullstack-engineer:architect adr`, `/10x-fullstack-engineer:feature scaffold` |
| New Feature | `/10x-fullstack-engineer:feature implement` | `/10x-fullstack-engineer:architect design`, `/10x-fullstack-engineer:review quality` |
| Bug Fixing | `/10x-fullstack-engineer:debug diagnose` | `/10x-fullstack-engineer:debug reproduce`, `/10x-fullstack-engineer:debug fix` |
| Slow Performance | `/10x-fullstack-engineer:optimize analyze` | `/10x-fullstack-engineer:debug performance`, `/10x-fullstack-engineer:optimize [layer]` |
| Code Quality Issues | `/10x-fullstack-engineer:refactor analyze` | `/10x-fullstack-engineer:refactor [operation]`, `/10x-fullstack-engineer:review quality` |
| Security Audit | `/10x-fullstack-engineer:review security` | `/10x-fullstack-engineer:architect review`, `/10x-fullstack-engineer:refactor patterns` |
| Technical Debt | `/10x-fullstack-engineer:architect assess` | `/10x-fullstack-engineer:refactor analyze`, `/10x-fullstack-engineer:refactor [operations]` |
| Pre-Production | `/10x-fullstack-engineer:review full` | `/10x-fullstack-engineer:architect review`, `/10x-fullstack-engineer:optimize benchmark` |

### Skill Integration Patterns

**Sequential Pattern** - Each skill builds on previous:
```
design → implement → review → optimize → assess
```

**Iterative Pattern** - Refine until criteria met:
```
implement → review → refactor → review → optimize → review
```

**Diagnostic Pattern** - Root cause to resolution:
```
diagnose → analyze → fix → verify → document
```

**Quality Gate Pattern** - Comprehensive validation:
```
review security → review performance → review quality → architect assess
```

---

## Advanced Techniques

### Compound Operations

Combine multiple skills in single workflow for maximum efficiency:

```bash
# Complete feature development with quality gates
/10x-fullstack-engineer:architect design requirements:"..." && \
/10x-fullstack-engineer:feature implement description:"..." && \
/10x-fullstack-engineer:review quality scope:"new feature" && \
/10x-fullstack-engineer:optimize analyze target:"new feature" && \
/10x-fullstack-engineer:architect adr decision:"key decisions"

# Performance optimization cycle
/10x-fullstack-engineer:debug performance component:"..." && \
/10x-fullstack-engineer:optimize analyze target:"..." && \
/10x-fullstack-engineer:optimize [layer] target:"..." && \
/10x-fullstack-engineer:optimize benchmark type:load baseline:"pre-opt" && \
/10x-fullstack-engineer:review performance scope:"optimized code"

# Refactoring sprint
/10x-fullstack-engineer:architect assess focus:"tech-debt" && \
/10x-fullstack-engineer:refactor analyze scope:"..." metrics:"all" && \
/10x-fullstack-engineer:refactor [multiple operations] && \
/10x-fullstack-engineer:review quality scope:"refactored code" && \
/10x-fullstack-engineer:architect assess baseline:"pre-refactoring"
```

### Utility Script Integration

All skills include powerful utility scripts:

```bash
# Architecture analysis
./.claude/commands/architect/.scripts/analyze-dependencies.sh . json
./.claude/commands/architect/.scripts/complexity-metrics.py . --format json
./.claude/commands/architect/.scripts/diagram-generator.sh microservices

# Debug profiling
./.claude/commands/debug/.scripts/analyze-logs.sh --file logs/app.log --level ERROR
./.claude/commands/debug/.scripts/profile.sh --app node_app --duration 60
./.claude/commands/debug/.scripts/memory-check.sh --app node_app --threshold 1024

# Refactoring analysis
./.claude/commands/refactor/.scripts/analyze-complexity.sh src/ 10
./.claude/commands/refactor/.scripts/detect-duplication.sh src/ 80
./.claude/commands/refactor/.scripts/verify-tests.sh src/ 70
```

### Custom Workflows

Create project-specific workflows by chaining skills:

```bash
# Daily development workflow
alias dev-start="/10x-fullstack-engineer:review quality scope:'recent changes' depth:quick"
alias dev-commit="/10x-fullstack-engineer:review security scope:'staged files' depth:quick && /10x-fullstack-engineer:review quality scope:'staged files' depth:quick"
alias dev-pr="/10x-fullstack-engineer:review pr scope:'current PR' depth:standard"

# Weekly maintenance
alias weekly-review="/10x-fullstack-engineer:architect assess baseline:'previous' && /10x-fullstack-engineer:refactor analyze scope:'src/' metrics:'all'"

# Release validation
alias pre-release="/10x-fullstack-engineer:review security depth:deep && /10x-fullstack-engineer:review performance depth:deep && /10x-fullstack-engineer:optimize benchmark type:all && /10x-fullstack-engineer:architect assess"
```

---

## Troubleshooting

### Common Issues

**Skill Not Found**:
- Verify skill is installed: `/plugin list`
- Check skill name: Use `/10x-fullstack-engineer:architect`, not `/10x-fullstack-engineer:architecture`
- Ensure plugin enabled: `/plugin enable 10x-fullstack-engineer`

**Parameter Errors**:
- Use `key:"value"` format (quotes for values with spaces)
- Check required parameters in skill README
- Example: `scope:"src/"` not `scope=src/`

**Performance Issues**:
- Start with `analyze` operation to identify bottlenecks
- Use `depth:quick` for faster initial assessments
- Focus on specific layers: `scope:backend` vs `scope:all`

**Unexpected Results**:
- Provide more context via parameters
- Review skill README for parameter options
- Use utility scripts for additional analysis

### Getting Help

Each skill includes comprehensive documentation:
- Skill README: `/commands/<skill>/README.md`
- Operation details: Read individual operation `.md` files
- Utility scripts: Check `.scripts/` with `--help` flags
- Agent capabilities: Review `agents/10x-fullstack-engineer.md`

---

## Contributing

### Adding New Skills

1. Create skill directory: `commands/<skill-name>/`
2. Add router: `skill.md` with parameter parsing
3. Add operations: Individual `.md` files
4. Add utilities: `.scripts/` directory (optional)
5. Document: Comprehensive `README.md`
6. Follow patterns: Consistent with existing skills

### Enhancing Existing Skills

1. Review skill architecture in README
2. Add operation as new `.md` file
3. Update router in `skill.md`
4. Add to README with examples
5. Include utility scripts if needed

---

## Version History

**v1.0.0** (2025-10-14)
- Initial release with 6 core skills
- 36 operations across all skills
- 10+ utility scripts
- Comprehensive agent integration
- Production-grade quality standards

---

## License

MIT License - See LICENSE file for details

---

## Support

- **Documentation**: Each skill has comprehensive README
- **Examples**: Real-world workflows throughout documentation
- **Agent**: 10x-fullstack-engineer agent provides expert guidance
- **Utilities**: Automated analysis scripts in each skill

---

## Summary

The 10x Fullstack Engineer plugin represents the synthesis of 20+ years of software engineering expertise, embodied in AI-augmented skills that work together across the entire development lifecycle. From architectural design to production deployment, from debugging complex issues to optimizing performance, each skill provides expert-level capabilities that maintain the highest quality standards.

**Use this plugin when**:
- Designing and building production-grade systems
- Solving complex technical challenges across the stack
- Optimizing performance and reducing costs
- Improving code quality and reducing technical debt
- Conducting comprehensive security and quality reviews
- Documenting architectural decisions and system design

**The result**: Production-ready software that is secure, performant, maintainable, and built to scale.

---

**Built with expertise. Delivered with quality. Optimized for performance.**
