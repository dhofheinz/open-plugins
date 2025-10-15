# Architecture Design Operation

You are executing the **design** operation using the 10x-fullstack-engineer agent to create comprehensive system architecture.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'design' operation name)

Expected format: `requirements:"description" [scope:"area"] [constraints:"limitations"] [scale:"expected-load"]`

Parse the arguments to extract:
- **requirements** (required): Feature or system description
- **scope** (optional): Specific area to focus on (e.g., "backend", "database", "full-stack")
- **constraints** (optional): Technical limitations, existing systems, team expertise
- **scale** (optional): Expected load, user count, data volume, growth projections

## Workflow

### Phase 1: Requirements Analysis

Analyze and clarify the requirements:

1. **Parse Requirements**: Extract core functionality, features, and capabilities needed
2. **Identify Stakeholders**: Understand who will use/maintain the system
3. **Extract Non-Functional Requirements**: Performance, security, reliability, scalability
4. **Clarify Ambiguities**: List any unclear aspects that need user input
5. **Document Assumptions**: Clearly state what you're assuming

**Questions to answer**:
- What problem does this solve?
- Who are the users (internal, external, both)?
- What are the critical success factors?
- What are the must-haves vs nice-to-haves?
- What is the expected timeline and budget?

### Phase 2: Context Gathering

Before designing, collect comprehensive context:

1. **Examine Existing Codebase**:
   - Directory structure and organization
   - Current tech stack and frameworks
   - Existing patterns and conventions
   - Package managers and dependencies
   - Configuration management approach

2. **Infrastructure Assessment**:
   - Deployment environment (cloud, on-prem, hybrid)
   - Current infrastructure configuration
   - CI/CD pipeline if exists
   - Monitoring and logging setup
   - Security measures in place

3. **Documentation Review**:
   - Existing ADRs in `docs/adr/`
   - README and technical documentation
   - API documentation
   - Architecture diagrams if available

4. **Team Capabilities**:
   - Languages and frameworks they know
   - DevOps maturity level
   - Team size and structure
   - Support and maintenance capacity

Use available tools:
- `Glob` to find configuration files (package.json, requirements.txt, docker-compose.yml, etc.)
- `Read` to examine key files
- `Grep` to search for patterns and dependencies
- `Bash` to run analysis scripts if needed

### Phase 3: Architecture Design

Create a comprehensive architecture covering all layers:

#### Database Layer Design

**Schema Design**:
- Entity-Relationship modeling
- Primary and foreign key relationships
- Indexes for query optimization
- Constraints and validation rules
- Audit trails and soft deletes if needed

**Data Modeling Approach**:
- Relational (PostgreSQL, MySQL) for structured data with complex relationships
- Document (MongoDB, DynamoDB) for flexible schemas and rapid iteration
- Graph (Neo4j, Amazon Neptune) for highly connected data
- Time-series (TimescaleDB, InfluxDB) for metrics and logs
- Key-Value (Redis, Memcached) for caching and sessions

**Migration Strategy**:
- Version control for schema changes
- Migration tooling (Flyway, Liquibase, Alembic, Prisma Migrate)
- Rollback procedures
- Zero-downtime migration approach for production

**Query Optimization**:
- Index strategy for common queries
- Query performance monitoring
- Connection pooling configuration
- Read replicas for scaling reads
- Sharding strategy if needed

**Data Consistency**:
- Transaction boundaries
- ACID guarantees where needed
- Eventual consistency where acceptable
- Distributed transaction handling
- Conflict resolution strategies

#### Backend Layer Design

**API Design**:
- REST API endpoints with resource modeling
- GraphQL schema if using GraphQL
- WebSocket connections for real-time features
- API versioning strategy (URL, header, content negotiation)
- Request/response formats (JSON, Protocol Buffers)
- Pagination, filtering, sorting conventions
- Rate limiting and throttling

**Service Architecture**:
- Monolith: Single deployable unit, simpler operations, faster initial development
- Microservices: Independent services, polyglot, scalable but complex
- Modular Monolith: Monolith with clear module boundaries, easier to extract later
- Serverless: Functions-as-a-Service, auto-scaling, pay-per-use

**Business Logic Organization**:
- Layered architecture (Controller → Service → Repository)
- Domain-Driven Design patterns
- Command Query Responsibility Segregation (CQRS) if complex
- Event-driven architecture for decoupling
- Saga pattern for distributed transactions

**Authentication & Authorization**:
- Authentication mechanism (JWT, OAuth 2.0, SAML, session-based)
- Authorization model (RBAC, ABAC, ACL)
- Token management and refresh strategy
- SSO integration if needed
- Multi-factor authentication approach

**Error Handling & Validation**:
- Standardized error response format
- HTTP status codes usage
- Input validation strategy (schema validation, sanitization)
- Error logging and monitoring
- User-friendly error messages

**Caching Strategy**:
- Cache layers (CDN, application cache, database cache)
- Cache invalidation approach
- TTL configuration
- Cache-aside vs write-through patterns
- Distributed caching with Redis/Memcached

**Message Queuing** (if asynchronous processing needed):
- Queue technology (RabbitMQ, Kafka, AWS SQS/SNS, Redis Streams)
- Message patterns (pub/sub, work queues, routing)
- Dead letter queues for failures
- Message durability and ordering guarantees
- Consumer scaling strategy

#### Frontend Layer Design

**Component Architecture**:
- Component hierarchy and composition
- Smart vs presentational components
- Shared component library
- Component communication patterns
- Reusability and maintainability

**State Management**:
- Local component state vs global state
- State management solution (Redux, MobX, Zustand, Context API, Recoil)
- State persistence strategy
- Optimistic updates for better UX
- State synchronization with backend

**Routing & Navigation**:
- Client-side routing structure
- Code splitting by route
- Authentication guards
- Deep linking support
- History management

**Data Fetching & Caching**:
- API client architecture (Axios, Fetch, GraphQL client)
- Request batching and deduplication
- Client-side caching (React Query, SWR, Apollo Cache)
- Offline support strategy
- Real-time data updates

**UI/UX Patterns**:
- Design system and component library
- Responsive design approach
- Loading states and skeleton screens
- Error boundaries and fallbacks
- Progressive enhancement
- Accessibility (WCAG compliance)

**Performance Optimization**:
- Code splitting and lazy loading
- Bundle size optimization
- Image optimization and lazy loading
- Critical CSS and above-the-fold rendering
- Service worker for PWA features
- Performance monitoring (Web Vitals)

#### Infrastructure Layer Design

**Deployment Architecture**:
- Containerization (Docker, containerd)
- Orchestration (Kubernetes, ECS, Docker Swarm)
- Serverless functions (Lambda, Cloud Functions, Azure Functions)
- Virtual machines if needed
- Edge computing for global distribution

**Scaling Strategy**:
- Horizontal scaling (add more instances)
- Vertical scaling (increase instance size)
- Auto-scaling policies based on metrics
- Load balancing configuration
- Database scaling (read replicas, sharding)
- CDN for static assets and edge caching

**CI/CD Pipeline**:
- Source control strategy (GitFlow, trunk-based)
- Build automation
- Testing stages (unit, integration, e2e)
- Deployment stages (dev, staging, production)
- Blue-green or canary deployment
- Rollback procedures

**Monitoring & Logging**:
- Application monitoring (New Relic, Datadog, AppDynamics)
- Infrastructure monitoring (Prometheus, CloudWatch, Grafana)
- Distributed tracing (Jaeger, Zipkin, X-Ray)
- Centralized logging (ELK Stack, Splunk, CloudWatch Logs)
- Alerting and on-call procedures
- Performance metrics and SLOs

**Security Measures**:
- Network security (VPC, security groups, firewalls)
- Web Application Firewall (WAF)
- DDoS protection
- Encryption at rest and in transit (TLS/SSL)
- Secrets management (Vault, AWS Secrets Manager)
- Security scanning in CI/CD
- Regular security audits
- Compliance requirements (GDPR, HIPAA, SOC2)

**Disaster Recovery & Backup**:
- Backup strategy and frequency
- Point-in-time recovery
- Cross-region replication
- RTO and RPO targets
- Disaster recovery testing
- Data retention policies

### Phase 4: Trade-off Analysis

For each major architectural decision, document:

**Decision**: What was chosen
**Rationale**: Why this approach
**Alternatives Considered**: What other options were evaluated
**Trade-offs**:
- **Pros**: Benefits of this approach
- **Cons**: Drawbacks and limitations
- **Cost**: Development, operational, maintenance costs
- **Complexity**: Implementation and operational complexity
- **Scalability**: How it scales under load
- **Maintainability**: Ease of updates and debugging
- **Time-to-Market**: Impact on delivery timeline

**Example Trade-off**:
```
Decision: Microservices architecture
Rationale: Need independent scaling and deployment of services
Alternatives: Monolith, modular monolith, serverless
Pros: Independent deployment, polyglot tech stack, team autonomy, fault isolation
Cons: Distributed complexity, network latency, data consistency challenges, higher operational overhead
Cost: Higher initial development and operational costs
Complexity: Significant increase in operational complexity
Scalability: Excellent - can scale services independently
Maintainability: Good for large teams, challenging for small teams
Time-to-Market: Slower initially, faster for parallel feature development
```

### Phase 5: Create Deliverables

Produce comprehensive documentation:

#### 1. Architecture Diagram

Provide a visual representation (ASCII art or detailed textual description):

```
┌─────────────────────────────────────────────────────────────┐
│                         CDN / Edge                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Load Balancer                          │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
    ┌──────────┐        ┌──────────┐        ┌──────────┐
    │  Web     │        │  API     │        │  WebSocket│
    │  Server  │        │  Server  │        │  Server   │
    └──────────┘        └──────────┘        └──────────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
    ┌──────────┐        ┌──────────┐        ┌──────────┐
    │  Auth    │        │Business  │        │  Queue   │
    │  Service │        │  Logic   │        │  Workers │
    └──────────┘        └──────────┘        └──────────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
    ┌──────────┐        ┌──────────┐        ┌──────────┐
    │PostgreSQL│        │  Redis   │        │   S3     │
    │ Primary  │        │  Cache   │        │  Storage │
    └──────────┘        └──────────┘        └──────────┘
```

#### 2. Component Breakdown

List all components with:
- Name and purpose
- Responsibilities and boundaries
- Dependencies on other components
- Technology stack
- Scaling characteristics

#### 3. Data Flow

Describe how data moves through the system:
- User request flow
- Data read operations
- Data write operations
- Real-time event flow
- Background job processing
- Cache invalidation flow

#### 4. Technology Stack

Justify each technology choice:
- **Frontend**: Framework, state management, build tools
- **Backend**: Language, framework, libraries
- **Database**: Primary database, caching, search
- **Infrastructure**: Cloud provider, container orchestration, CI/CD
- **Monitoring**: Application and infrastructure monitoring
- **Security**: Authentication, encryption, secrets management

#### 5. Implementation Phases

Break down into deliverable phases:

**Phase 1** (Foundation - 2-3 weeks):
- Database schema and migrations
- Basic API endpoints
- Authentication system
- Development environment setup

**Phase 2** (Core Features - 4-6 weeks):
- Primary business logic
- Frontend components
- Integration testing
- CI/CD pipeline

**Phase 3** (Advanced Features - 3-4 weeks):
- Real-time features
- Background processing
- Advanced UI components
- Performance optimization

**Phase 4** (Production Readiness - 2-3 weeks):
- Security hardening
- Monitoring and alerting
- Load testing
- Documentation

#### 6. Risk Assessment

Identify potential risks:
- **Technical Risks**: New technologies, integration challenges, scalability unknowns
- **Operational Risks**: Deployment complexity, monitoring gaps, disaster recovery
- **Team Risks**: Knowledge gaps, resource constraints, timeline pressure
- **Business Risks**: Market timing, competitive pressure, budget limitations

For each risk, provide:
- Likelihood (Low/Medium/High)
- Impact (Low/Medium/High)
- Mitigation strategy
- Contingency plan

#### 7. Success Metrics

Define measurable outcomes:
- **Performance**: Response time < 200ms p95, throughput > 1000 rps
- **Reliability**: Uptime > 99.9%, MTTR < 1 hour
- **Scalability**: Support 10k concurrent users, linear scaling to 100k
- **Security**: Zero critical vulnerabilities, < 5 medium vulnerabilities
- **User Experience**: Load time < 2s, accessibility score > 90
- **Development Velocity**: Deploy to production 10+ times/week

### Phase 6: Document Architectural Decisions

Create ADRs for significant decisions using the `adr` operation:

For each major decision:
1. Identify the architectural choice
2. Gather context and alternatives
3. Document rationale and consequences
4. Save to `docs/adr/` directory

Example decisions to document:
- Architecture pattern choice (monolith vs microservices)
- Database technology selection
- Authentication strategy
- Caching approach
- Message queue selection
- Frontend framework choice
- Deployment strategy

## Output Format

Provide a comprehensive architectural design document:

```markdown
# Architecture Design: [Feature/Project Name]

## Executive Summary
[2-3 paragraph overview of the system, key architectural decisions, and expected outcomes]

## Requirements Analysis

### Functional Requirements
- [Core features and capabilities]
- [User interactions and workflows]

### Non-Functional Requirements
- **Performance**: [Response time, throughput targets]
- **Scalability**: [User load, data volume expectations]
- **Reliability**: [Uptime targets, fault tolerance]
- **Security**: [Authentication, authorization, compliance]
- **Maintainability**: [Code quality, documentation, testing]

### Constraints
- [Technical constraints]
- [Budget and timeline constraints]
- [Team and resource constraints]
- [Compliance and regulatory constraints]

### Assumptions
- [Key assumptions made during design]
- [Areas needing further clarification]

## Architecture Overview

### High-Level Architecture
[Textual description or ASCII diagram of the system architecture]

### Architecture Patterns
- [Primary pattern: e.g., Microservices, Layered, Event-Driven]
- [Supporting patterns: e.g., CQRS, Saga, Circuit Breaker]

## Component Architecture

### Database Layer
**Technology**: [PostgreSQL/MongoDB/etc.]

**Schema Design**:
```sql
[Key schema definitions or entity descriptions]
```

**Optimization Strategy**:
- Indexes: [Primary indexes for performance]
- Caching: [Query caching approach]
- Scaling: [Read replicas, sharding strategy]

**Migration Strategy**:
- Tool: [Migration framework]
- Process: [Version control, review, deployment]
- Rollback: [Rollback procedure]

### Backend Layer
**Technology**: [Node.js/Python/Go/etc. + Framework]

**API Design**:
```
[Key endpoints with methods and descriptions]
GET    /api/v1/users           - List users
POST   /api/v1/users           - Create user
GET    /api/v1/users/:id       - Get user details
PUT    /api/v1/users/:id       - Update user
DELETE /api/v1/users/:id       - Delete user
```

**Service Architecture**:
- [Pattern: monolith/microservices/serverless]
- [Service breakdown with responsibilities]

**Business Logic**:
- [Organization pattern: layered/DDD/etc.]
- [Key business rules and validations]

**Authentication & Authorization**:
- Mechanism: [JWT/OAuth/SAML]
- Flow: [Authentication flow description]
- Authorization: [RBAC/ABAC model]

**Caching Strategy**:
- Cache layers: [CDN, Redis, in-memory]
- Invalidation: [Strategy for cache freshness]
- TTL: [Time-to-live configuration]

**Message Queuing** (if applicable):
- Technology: [RabbitMQ/Kafka/SQS]
- Use cases: [Async processing, event distribution]
- Scaling: [Consumer scaling approach]

### Frontend Layer
**Technology**: [React/Vue/Angular + state management]

**Component Architecture**:
- [Component hierarchy and structure]
- [Shared component library]
- [Component communication patterns]

**State Management**:
- Solution: [Redux/MobX/Context]
- Structure: [State organization]
- Persistence: [Local storage, session storage]

**Routing**:
- [Route structure]
- [Code splitting strategy]
- [Authentication guards]

**Data Fetching**:
- Client: [Axios/Fetch/Apollo]
- Caching: [React Query/SWR strategy]
- Real-time: [WebSocket/SSE approach]

**Performance**:
- [Code splitting points]
- [Bundle optimization]
- [Lazy loading strategy]
- [Performance monitoring]

### Infrastructure Layer
**Cloud Provider**: [AWS/GCP/Azure]

**Deployment Architecture**:
- Compute: [Kubernetes/ECS/Lambda]
- Networking: [VPC, load balancers, CDN]
- Storage: [S3/Blob Storage/etc.]

**Scaling Strategy**:
- Horizontal: [Auto-scaling configuration]
- Database: [Read replicas, sharding]
- CDN: [Static asset distribution]

**CI/CD Pipeline**:
```
[Source] → [Build] → [Test] → [Stage] → [Prod]
   │          │         │         │         │
  Git      Docker    Jest     Canary   Blue-Green
```

**Monitoring & Logging**:
- APM: [Application monitoring solution]
- Infrastructure: [Infrastructure monitoring]
- Logging: [Centralized logging solution]
- Tracing: [Distributed tracing]
- Alerting: [Alert configuration]

**Security**:
- Network: [Security groups, WAF]
- Encryption: [TLS, at-rest encryption]
- Secrets: [Secrets management]
- Compliance: [Required compliance standards]

**Disaster Recovery**:
- Backup: [Backup strategy and frequency]
- Recovery: [RTO and RPO targets]
- Testing: [DR testing schedule]

## Technology Stack

### Frontend
- **Framework**: [React 18] - Reason: [Modern, mature, large ecosystem]
- **State Management**: [Redux Toolkit] - Reason: [Standardized patterns, DevTools]
- **Build Tool**: [Vite] - Reason: [Fast HMR, optimized builds]

### Backend
- **Runtime**: [Node.js 20] - Reason: [Team expertise, async I/O, ecosystem]
- **Framework**: [Express] - Reason: [Mature, flexible, middleware ecosystem]
- **Language**: [TypeScript] - Reason: [Type safety, better DX, refactoring]

### Database
- **Primary**: [PostgreSQL 15] - Reason: [ACID, JSONB, performance, reliability]
- **Cache**: [Redis 7] - Reason: [Fast, versatile, pub/sub support]
- **Search**: [Elasticsearch] - Reason: [Full-text search, analytics]

### Infrastructure
- **Cloud**: [AWS] - Reason: [Feature breadth, team expertise, enterprise support]
- **Orchestration**: [ECS Fargate] - Reason: [Managed, serverless, cost-effective]
- **CI/CD**: [GitHub Actions] - Reason: [Integrated, flexible, cost-effective]

### Monitoring
- **APM**: [Datadog] - Reason: [Comprehensive, great UX, integrations]
- **Errors**: [Sentry] - Reason: [Detailed error tracking, source maps]

## Data Flow

### User Request Flow
1. User makes request → CDN (static assets) or Load Balancer (API)
2. Load Balancer → Web/API Server (with request authentication)
3. API Server → Auth Service (validate token)
4. API Server → Cache (check for cached response)
5. If cache miss → Business Logic → Database
6. Response → Cache (store for future requests)
7. Response → User (with appropriate headers)

### Real-Time Event Flow
1. Event occurs (user action, system event)
2. Event published to message queue
3. Queue distributes to WebSocket servers
4. WebSocket servers push to connected clients
5. Clients update UI optimistically

### Background Processing Flow
1. User action triggers job
2. Job queued in message queue
3. Worker picks up job
4. Worker processes (may involve multiple steps)
5. Worker updates database and cache
6. Worker sends notification if needed

## Scalability Strategy

### Current Scale
- Users: [Current user count]
- Requests: [Current request volume]
- Data: [Current data volume]

### Target Scale
- Users: [Target user count at 6mo, 1yr, 2yr]
- Requests: [Target request volume]
- Data: [Target data volume]
- Growth: [Expected growth rate]

### Scaling Approach

**Application Tier**:
- Horizontal auto-scaling based on CPU/memory
- Target: 70% utilization
- Min: 2 instances, Max: 20 instances
- Scale-out trigger: > 75% CPU for 2 minutes
- Scale-in trigger: < 40% CPU for 5 minutes

**Database Tier**:
- Read replicas for read-heavy workloads (3 replicas)
- Connection pooling (max 100 connections per instance)
- Query optimization and indexing
- Caching layer to reduce database load by 80%
- Sharding strategy ready (by user_id) if needed at 10M+ users

**Caching Tier**:
- Redis cluster with 3 nodes
- Cache-aside pattern
- TTL: 5 minutes for dynamic data, 1 hour for semi-static
- Projected cache hit rate: 85%

**Content Delivery**:
- CloudFront CDN for static assets
- Edge caching for API responses (public endpoints)
- Image optimization and lazy loading

### Bottleneck Analysis
- **Current**: Database writes
- **Mitigation**: Write batching, async processing, caching
- **Future**: Consider event sourcing for write-heavy operations

## Security Considerations

### Authentication
- JWT tokens with 15-minute expiry
- Refresh tokens with 7-day expiry
- Token rotation on refresh
- HttpOnly, Secure, SameSite cookies

### Authorization
- Role-Based Access Control (RBAC)
- Roles: Admin, User, Guest
- Permission checks at API layer
- Resource-level authorization

### Data Protection
- TLS 1.3 for all communication
- AES-256 encryption at rest
- Database encryption
- PII encryption in application layer

### Security Measures
- WAF with OWASP Top 10 rules
- DDoS protection via CloudFront
- Rate limiting: 100 req/min per user
- Input validation and sanitization
- SQL injection prevention (parameterized queries)
- XSS prevention (output encoding)
- CSRF tokens for state-changing operations

### Secrets Management
- AWS Secrets Manager for sensitive credentials
- No secrets in code or environment variables
- Automatic rotation for database credentials
- Service accounts with minimal permissions

### Compliance
- [GDPR/HIPAA/SOC2 as applicable]
- Regular security audits
- Penetration testing quarterly
- Vulnerability scanning in CI/CD

## Implementation Phases

### Phase 1: Foundation (Weeks 1-3)
**Goal**: Development environment and core infrastructure

**Deliverables**:
- Database schema and migrations
- Basic API structure with authentication
- CI/CD pipeline setup
- Development environment (local + cloud)

**Team**: 2 backend, 1 DevOps

**Success Criteria**:
- Can deploy to staging
- Basic auth flow works
- Database migrations automated

### Phase 2: Core Features (Weeks 4-9)
**Goal**: Primary business functionality

**Deliverables**:
- Key API endpoints implemented
- Frontend components for core features
- Integration tests
- Basic monitoring and logging

**Team**: 2 backend, 2 frontend, 1 DevOps

**Success Criteria**:
- Core user workflows functional
- 80% test coverage
- Monitoring dashboards operational

### Phase 3: Advanced Features (Weeks 10-13)
**Goal**: Enhanced functionality and user experience

**Deliverables**:
- Real-time features
- Background job processing
- Advanced UI components
- Performance optimization

**Team**: 2 backend, 2 frontend, 1 QA

**Success Criteria**:
- All features implemented
- Performance targets met
- User acceptance testing passed

### Phase 4: Production Readiness (Weeks 14-16)
**Goal**: Production launch preparation

**Deliverables**:
- Security hardening
- Load testing and optimization
- Disaster recovery procedures
- Documentation and runbooks

**Team**: Full team

**Success Criteria**:
- Passes security audit
- Handles target load
- Team trained on operations

### Phase 5: Launch & Stabilization (Week 17+)
**Goal**: Production launch and monitoring

**Activities**:
- Phased rollout (10% → 50% → 100%)
- 24/7 monitoring
- Quick response to issues
- Gather user feedback

**Success Criteria**:
- 99.9% uptime
- Performance SLOs met
- No critical incidents

## Risks and Mitigations

### Technical Risks

**Risk 1**: Database performance under load
- **Likelihood**: Medium
- **Impact**: High
- **Mitigation**: Extensive caching, read replicas, query optimization
- **Contingency**: Database sharding plan ready to implement

**Risk 2**: Third-party API reliability
- **Likelihood**: Medium
- **Impact**: Medium
- **Mitigation**: Circuit breakers, retries, fallback mechanisms
- **Contingency**: Alternative providers identified

**Risk 3**: Scaling WebSocket connections
- **Likelihood**: Low
- **Impact**: High
- **Mitigation**: Redis pub/sub for horizontal scaling, connection pooling
- **Contingency**: Polling fallback mechanism

### Operational Risks

**Risk 1**: Deployment failures
- **Likelihood**: Medium
- **Impact**: Medium
- **Mitigation**: Blue-green deployment, automated rollback, extensive testing
- **Contingency**: Manual rollback procedures documented

**Risk 2**: Security breach
- **Likelihood**: Low
- **Impact**: Critical
- **Mitigation**: Security audits, penetration testing, WAF, monitoring
- **Contingency**: Incident response plan, data breach procedures

### Team Risks

**Risk 1**: Key person dependency
- **Likelihood**: Medium
- **Impact**: High
- **Mitigation**: Knowledge sharing, documentation, pair programming
- **Contingency**: Cross-training plan, external consultant backup

**Risk 2**: Technology learning curve
- **Likelihood**: High
- **Impact**: Medium
- **Mitigation**: Training sessions, spikes, gradual adoption
- **Contingency**: Simpler alternative approaches documented

### Business Risks

**Risk 1**: Timeline pressure
- **Likelihood**: High
- **Impact**: Medium
- **Mitigation**: Phased approach, MVP focus, scope management
- **Contingency**: Feature cut list prioritized

**Risk 2**: Budget constraints
- **Likelihood**: Medium
- **Impact**: Medium
- **Mitigation**: Cost monitoring, reserved instances, auto-scaling
- **Contingency**: Cost reduction plan (features to defer)

## Success Metrics

### Performance Metrics
- API response time p50 < 100ms, p95 < 200ms, p99 < 500ms
- Page load time < 2 seconds (Lighthouse score > 90)
- Time to First Byte (TTFB) < 200ms
- First Contentful Paint (FCP) < 1.5s
- Largest Contentful Paint (LCP) < 2.5s

### Reliability Metrics
- Uptime: 99.9% (max 43 minutes downtime/month)
- Error rate < 0.1% of requests
- Mean Time To Recovery (MTTR) < 1 hour
- Mean Time Between Failures (MTBF) > 720 hours

### Scalability Metrics
- Support 10,000 concurrent users
- Handle 1,000 requests/second sustained
- Linear scaling to 100,000 users with infrastructure
- Database query performance < 50ms p95

### Security Metrics
- Zero critical vulnerabilities
- < 5 medium vulnerabilities
- Security audit pass rate > 95%
- Incident response time < 15 minutes

### User Experience Metrics
- Accessibility score > 90 (WCAG AA)
- Mobile performance score > 85
- User satisfaction score > 4.5/5
- Task completion rate > 90%

### Development Velocity Metrics
- Deploy to production 10+ times/week
- Lead time for changes < 1 day
- Deployment success rate > 95%
- Automated test coverage > 80%

### Cost Metrics
- Infrastructure cost per user < $0.50/month
- Cost per transaction < $0.01
- Cost growth rate < user growth rate

## Open Questions

[List any unresolved questions or decisions pending clarification]

1. **Question 1**: [Description]
   - **Impact**: [How this affects design]
   - **Options**: [Possible approaches]
   - **Needed by**: [Deadline for decision]

2. **Question 2**: [Description]
   - **Impact**: [How this affects design]
   - **Options**: [Possible approaches]
   - **Needed by**: [Deadline for decision]

## Next Steps

1. **Review and Approval**: Stakeholder review of architecture design
2. **Create ADRs**: Document major architectural decisions
3. **Spike Tasks**: Proof-of-concept for risky areas
4. **Team Briefing**: Present architecture to development team
5. **Begin Phase 1**: Start implementation foundation

## Appendices

### Glossary
[Define domain-specific terms and acronyms]

### References
- [Related documentation]
- [Industry standards]
- [Similar systems]
```

## Agent Invocation

This operation MUST invoke the **10x-fullstack-engineer** agent for comprehensive architectural expertise.

**Agent context to provide**:
- Parsed requirements and parameters
- Gathered codebase context
- Existing architecture information
- Scale and performance targets
- Constraints and limitations
- Technology preferences

**Agent responsibilities**:
- Provide 15+ years of architectural experience
- Identify architectural patterns and anti-patterns
- Recommend technology stack with justifications
- Analyze trade-offs and implications
- Suggest best practices and optimizations
- Highlight potential risks and mitigations
- Review and validate architectural decisions

**Agent invocation approach**:
Present all gathered context comprehensively, then explicitly request:
"Using your 15+ years of full-stack architecture experience, design a comprehensive system architecture that addresses these requirements. Consider scalability, maintainability, security, and operational excellence. Provide detailed analysis and justifications for all major decisions."

## Error Handling

### Missing Requirements
If requirements are unclear or insufficient:

```
Insufficient requirements provided. To design a comprehensive architecture, I need:

**Missing Information**:
- [Specific missing details]

**Clarifying Questions**:
1. [Question about scope]
2. [Question about scale]
3. [Question about constraints]

**Would you like to**:
a) Provide additional requirements
b) Proceed with assumptions (I'll document them)
c) Start with a minimal architecture and iterate

Please provide more details or choose an option.
```

### Conflicting Constraints
If architectural constraints conflict:

```
Conflicting Requirements Detected:

**Conflict**: [Description of the conflict]
- Requirement A: [First requirement]
- Requirement B: [Conflicting requirement]

**Trade-off Analysis**:

**Option 1**: [Approach favoring requirement A]
- Pros: [Benefits]
- Cons: [Drawbacks]
- Recommendation: [When to choose this]

**Option 2**: [Approach favoring requirement B]
- Pros: [Benefits]
- Cons: [Drawbacks]
- Recommendation: [When to choose this]

**Option 3**: [Compromise approach]
- Pros: [Benefits]
- Cons: [Drawbacks]
- Recommendation: [When to choose this]

**My Recommendation**: [Preferred option with detailed justification]

Please clarify which approach aligns best with your priorities, or I can proceed with my recommendation.
```

### Incomplete Context
If critical context is missing from the codebase:

```
Unable to gather complete context. I need to make assumptions about:

**Missing Context**:
- [What's missing]
- [Impact on design]

**Assumptions I'll Make**:
1. [Assumption 1] - [Rationale]
2. [Assumption 2] - [Rationale]

**How to Provide Context**:
- [Specific files or information needed]

I'll proceed with these assumptions documented in the architecture design. You can correct them after review.
```

### Scale Uncertainty
If scale requirements are unclear:

```
Scale requirements are unclear. Architecture will vary significantly based on expected load.

**Please clarify**:
- Expected user count: [Daily active users]
- Request volume: [Requests per second]
- Data volume: [Database size]
- Growth rate: [Expected growth percentage]
- Geographic distribution: [Regions to serve]

**I can design for**:
- **Small Scale**: < 1k users, < 100 rps → Simpler architecture
- **Medium Scale**: 1k-50k users, 100-1000 rps → Standard architecture
- **Large Scale**: 50k-500k users, 1000-10k rps → Advanced architecture
- **Massive Scale**: 500k+ users, 10k+ rps → Distributed architecture

Which scale should I target?
```

## Examples

**Example 1 - E-commerce Product Catalog**:
```
/architect design requirements:"product catalog with search, filtering, recommendations, and real-time inventory updates" scale:"50,000 daily active users, 1 million products, 500 requests/second peak" constraints:"AWS infrastructure, Node.js backend, React frontend, must integrate with existing payment system"
```

**Example 2 - Real-Time Collaboration**:
```
/architect design requirements:"real-time collaborative document editing like Google Docs with presence awareness, comments, version history, and offline support" scale:"10,000 concurrent editors" constraints:"low latency required, must work on mobile, operational transforms or CRDT approach"
```

**Example 3 - Analytics Dashboard**:
```
/architect design requirements:"analytics dashboard with real-time metrics, historical reports, data visualization, and export functionality" scope:"backend data pipeline and API" scale:"process 1 million events per day" constraints:"must use existing PostgreSQL database, Python preferred"
```

**Example 4 - Microservices Migration**:
```
/architect design requirements:"migrate existing monolith to microservices" scope:"extract user management and authentication first" constraints:"zero-downtime migration, maintain existing API contracts, gradual rollout" scale:"100,000 users, 2000 rps"
```

**Example 5 - Mobile App Backend**:
```
/architect design requirements:"mobile app backend with offline sync, push notifications, media uploads, and social features" scale:"500,000 mobile users, 80% mobile, 20% web" constraints:"GraphQL API, serverless preferred for cost optimization, global user base"
```
