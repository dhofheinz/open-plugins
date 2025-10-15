# Infrastructure Optimization Operation

You are executing the **infrastructure** operation to optimize infrastructure scaling, CDN configuration, resource allocation, deployment, and cost efficiency.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'infrastructure' operation name)

Expected format: `target:"scaling|cdn|resources|deployment|costs|all" [environment:"prod|staging|dev"] [provider:"aws|azure|gcp|vercel"] [budget_constraint:"true|false"]`

**Parameter definitions**:
- `target` (required): What to optimize - `scaling`, `cdn`, `resources`, `deployment`, `costs`, or `all`
- `environment` (optional): Target environment (default: production)
- `provider` (optional): Cloud provider (auto-detected if not specified)
- `budget_constraint` (optional): Prioritize cost reduction (default: false)

## Workflow

### 1. Detect Infrastructure Provider

```bash
# Check for cloud provider configuration
ls -la .aws/ .azure/ .gcp/ vercel.json netlify.toml 2>/dev/null

# Check for container orchestration
kubectl config current-context 2>/dev/null
docker-compose version 2>/dev/null

# Check for IaC tools
ls -la terraform/ *.tf serverless.yml cloudformation/ 2>/dev/null
```

### 2. Analyze Current Infrastructure

**Resource Utilization (Kubernetes)**:
```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods --all-namespaces

# Check resource requests vs limits
kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources}{"\n"}{end}'
```

**Resource Utilization (AWS EC2)**:
```bash
# CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2025-10-07T00:00:00Z \
  --end-time 2025-10-14T00:00:00Z \
  --period 3600 \
  --statistics Average
```

### 3. Scaling Optimization

#### 3.1. Horizontal Pod Autoscaling (Kubernetes)

```yaml
# BEFORE (fixed 3 replicas)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
spec:
  replicas: 3  # Fixed count, wastes resources at low traffic
  template:
    spec:
      containers:
      - name: api
        image: api:v1.0.0
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"

# AFTER (horizontal pod autoscaler)
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-server-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-server
  minReplicas: 2  # Minimum for high availability
  maxReplicas: 10  # Scale up under load
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # Target 70% CPU
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # Wait 5 min before scaling down
    scaleUp:
      stabilizationWindowSeconds: 0  # Scale up immediately
      policies:
      - type: Percent
        value: 100  # Double pods at a time
        periodSeconds: 15

# Result:
# - Off-peak: 2 pods (save 33% resources)
# - Peak: Up to 10 pods (handle 5x traffic)
# - Cost savings: ~40% while maintaining performance
```

#### 3.2. Vertical Pod Autoscaling

```yaml
# Automatically adjust resource requests/limits
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: api-server-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-server
  updatePolicy:
    updateMode: "Auto"  # Automatically apply recommendations
  resourcePolicy:
    containerPolicies:
    - containerName: api
      minAllowed:
        memory: "256Mi"
        cpu: "100m"
      maxAllowed:
        memory: "2Gi"
        cpu: "2000m"
      controlledResources: ["cpu", "memory"]
```

#### 3.3. AWS Auto Scaling Groups

```json
{
  "AutoScalingGroupName": "api-server-asg",
  "MinSize": 2,
  "MaxSize": 10,
  "DesiredCapacity": 2,
  "DefaultCooldown": 300,
  "HealthCheckType": "ELB",
  "HealthCheckGracePeriod": 180,
  "TargetGroupARNs": ["arn:aws:elasticloadbalancing:..."],
  "TargetTrackingScalingPolicies": [
    {
      "PolicyName": "target-tracking-cpu",
      "TargetValue": 70.0,
      "PredefinedMetricSpecification": {
        "PredefinedMetricType": "ASGAverageCPUUtilization"
      }
    }
  ]
}
```

### 4. CDN Optimization

#### 4.1. CloudFront Configuration (AWS)

```json
{
  "DistributionConfig": {
    "CallerReference": "api-cdn-2025",
    "Comment": "Optimized CDN for static assets",
    "Enabled": true,
    "PriceClass": "PriceClass_100",
    "Origins": [
      {
        "Id": "S3-static-assets",
        "DomainName": "static-assets.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": "origin-access-identity/cloudfront/..."
        }
      }
    ],
    "DefaultCacheBehavior": {
      "TargetOriginId": "S3-static-assets",
      "ViewerProtocolPolicy": "redirect-to-https",
      "Compress": true,
      "MinTTL": 0,
      "DefaultTTL": 86400,
      "MaxTTL": 31536000,
      "ForwardedValues": {
        "QueryString": false,
        "Cookies": { "Forward": "none" }
      }
    },
    "CacheBehaviors": [
      {
        "PathPattern": "*.js",
        "TargetOriginId": "S3-static-assets",
        "Compress": true,
        "MinTTL": 31536000,
        "CachePolicyId": "immutable-assets"
      },
      {
        "PathPattern": "*.css",
        "TargetOriginId": "S3-static-assets",
        "Compress": true,
        "MinTTL": 31536000
      }
    ]
  }
}
```

**Cache Headers**:
```javascript
// Express server - set appropriate cache headers
app.use('/static', express.static('public', {
  maxAge: '1y',  // Immutable assets with hash in filename
  immutable: true
}));

app.use('/api', (req, res, next) => {
  res.set('Cache-Control', 'no-cache'); // API responses
  next();
});

// HTML pages - short cache with revalidation
app.get('/', (req, res) => {
  res.set('Cache-Control', 'public, max-age=300, must-revalidate');
  res.sendFile('index.html');
});
```

#### 4.2. Image Optimization with CDN

```nginx
# Nginx configuration for image optimization
location ~* \.(jpg|jpeg|png|gif|webp)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";

    # Enable compression
    gzip on;
    gzip_comp_level 6;

    # Serve WebP if browser supports it
    set $webp_suffix "";
    if ($http_accept ~* "webp") {
        set $webp_suffix ".webp";
    }
    try_files $uri$webp_suffix $uri =404;
}
```

### 5. Resource Right-Sizing

#### 5.1. Analyze Resource Usage Patterns

```bash
# Kubernetes - Resource usage over time
kubectl top pods --containers --namespace production | awk '{
  if (NR>1) {
    split($3, cpu, "m"); split($4, mem, "Mi");
    print $1, $2, cpu[1], mem[1]
  }
}' > resource-usage.txt

# Analyze patterns
# If CPU consistently <30% → reduce CPU request
# If memory consistently <50% → reduce memory request
```

**Optimization Example**:
```yaml
# BEFORE (over-provisioned)
resources:
  requests:
    memory: "2Gi"    # Usage: 600Mi (30%)
    cpu: "1000m"     # Usage: 200m (20%)
  limits:
    memory: "4Gi"
    cpu: "2000m"

# AFTER (right-sized)
resources:
  requests:
    memory: "768Mi"  # 600Mi + 28% headroom
    cpu: "300m"      # 200m + 50% headroom
  limits:
    memory: "1.5Gi"  # 2x request
    cpu: "600m"      # 2x request

# Savings: 62% CPU, 61% memory
# Cost impact: ~60% reduction per pod
```

#### 5.2. Reserved Instances / Savings Plans

**AWS Reserved Instances**:
```bash
# Analyze instance usage patterns
aws ce get-reservation-utilization \
  --time-period Start=2024-10-01,End=2025-10-01 \
  --granularity MONTHLY

# Recommendation: Convert frequently-used instances to Reserved Instances
# Example savings:
# - On-Demand t3.large: $0.0832/hour = $612/month
# - Reserved t3.large (1 year): $0.0520/hour = $383/month
# - Savings: 37% ($229/month per instance)
```

### 6. Deployment Optimization

#### 6.1. Container Image Optimization

```dockerfile
# BEFORE (large image: 1.2GB)
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]

# AFTER (optimized image: 180MB)
# Multi-stage build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000
CMD ["node", "dist/main.js"]

# Image size: 1.2GB → 180MB (85% smaller)
# Security: Non-root user, minimal attack surface
```

#### 6.2. Blue-Green Deployment

```yaml
# Kubernetes Blue-Green deployment
# Green (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
      version: green
  template:
    metadata:
      labels:
        app: api
        version: green
    spec:
      containers:
      - name: api
        image: api:v2.0.0

---
# Service - switch traffic by changing selector
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api
    version: green  # Change from 'blue' to 'green' to switch traffic
  ports:
  - port: 80
    targetPort: 3000

# Zero-downtime deployment
# Instant rollback by changing selector back to 'blue'
```

### 7. Cost Optimization

#### 7.1. Spot Instances for Non-Critical Workloads

```yaml
# Kubernetes - Use spot instances for batch jobs
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processing
spec:
  template:
    spec:
      nodeSelector:
        node.kubernetes.io/instance-type: spot  # Use spot instances
      tolerations:
      - key: "spot"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
      containers:
      - name: processor
        image: data-processor:v1.0.0

# Savings: 70-90% cost reduction for spot vs on-demand
# Trade-off: May be interrupted (acceptable for batch jobs)
```

#### 7.2. Storage Optimization

```bash
# S3 Lifecycle Policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket static-assets \
  --lifecycle-configuration '{
    "Rules": [
      {
        "Id": "archive-old-logs",
        "Status": "Enabled",
        "Filter": { "Prefix": "logs/" },
        "Transitions": [
          {
            "Days": 30,
            "StorageClass": "STANDARD_IA"
          },
          {
            "Days": 90,
            "StorageClass": "GLACIER"
          }
        ],
        "Expiration": { "Days": 365 }
      }
    ]
  }'

# Cost impact:
# - Standard: $0.023/GB/month
# - Standard-IA: $0.0125/GB/month (46% cheaper)
# - Glacier: $0.004/GB/month (83% cheaper)
```

#### 7.3. Database Instance Right-Sizing

```sql
-- Analyze actual database usage
SELECT
  datname,
  pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database
ORDER BY pg_database_size(datname) DESC;

-- Check connection usage
SELECT count(*) AS connections,
       max_conn,
       max_conn - count(*) AS available
FROM pg_stat_activity,
     (SELECT setting::int AS max_conn FROM pg_settings WHERE name='max_connections') mc
GROUP BY max_conn;

-- Recommendation: If consistently using <30% connections and <50% storage
-- Consider downsizing from db.r5.xlarge to db.r5.large
-- Savings: ~50% cost reduction
```

### 8. Monitoring and Alerting

**CloudWatch Alarms (AWS)**:
```json
{
  "AlarmName": "high-cpu-utilization",
  "ComparisonOperator": "GreaterThanThreshold",
  "EvaluationPeriods": 2,
  "MetricName": "CPUUtilization",
  "Namespace": "AWS/EC2",
  "Period": 300,
  "Statistic": "Average",
  "Threshold": 80.0,
  "ActionsEnabled": true,
  "AlarmActions": ["arn:aws:sns:us-east-1:123456789012:ops-team"]
}
```

**Prometheus Alerts (Kubernetes)**:
```yaml
groups:
- name: infrastructure
  rules:
  - alert: HighMemoryUsage
    expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.85
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage on {{ $labels.instance }}"

  - alert: HighCPUUsage
    expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
```

## Output Format

```markdown
# Infrastructure Optimization Report: [Environment]

**Optimization Date**: [Date]
**Provider**: [AWS/Azure/GCP/Hybrid]
**Environment**: [production/staging]
**Target**: [scaling/cdn/resources/costs/all]

## Executive Summary

[Summary of infrastructure state and optimizations]

## Baseline Metrics

### Resource Utilization
- **CPU**: 68% average across nodes
- **Memory**: 72% average
- **Network**: 45% utilization
- **Storage**: 60% utilization

### Cost Breakdown (Monthly)
- **Compute**: $4,500 (EC2 instances)
- **Database**: $1,200 (RDS)
- **Storage**: $800 (S3, EBS)
- **Network**: $600 (Data transfer, CloudFront)
- **Total**: $7,100/month

### Scaling Configuration
- **Auto Scaling**: Fixed 5 instances (no scaling)
- **Pod Count**: Fixed 15 pods
- **Resource Allocation**: Static (no HPA/VPA)

## Optimizations Implemented

### 1. Horizontal Pod Autoscaling

**Before**: Fixed 15 pods
**After**: 8-25 pods based on load

**Impact**:
- Off-peak: 8 pods (47% reduction)
- Peak: 25 pods (67% increase capacity)
- Cost savings: $1,350/month (30%)

### 2. Resource Right-Sizing

**Optimized 12 deployments**:
- Average CPU reduction: 55%
- Average memory reduction: 48%
- Cost impact: $945/month savings

### 3. CDN Configuration

**Implemented**:
- CloudFront for static assets
- Cache-Control headers optimized
- Compression enabled

**Impact**:
- Origin requests: 85% reduction
- TTFB: 750ms → 120ms (84% faster)
- Bandwidth costs: $240/month savings

### 4. Reserved Instances

**Converted**:
- 3 x t3.large on-demand → Reserved
- Commitment: 1 year, no upfront

**Savings**: $687/month (37% per instance)

### 5. Storage Lifecycle Policies

**Implemented**:
- Logs: Standard → Standard-IA (30d) → Glacier (90d)
- Backups: Glacier after 30 days
- Old assets: Glacier after 180 days

**Savings**: $285/month

## Results Summary

### Cost Optimization

| Category | Before | After | Savings |
|----------|--------|-------|---------|
| Compute | $4,500 | $2,518 | $1,982 (44%) |
| Database | $1,200 | $720 | $480 (40%) |
| Storage | $800 | $515 | $285 (36%) |
| Network | $600 | $360 | $240 (40%) |
| **Total** | **$7,100** | **$4,113** | **$2,987 (42%)** |

**Annual Savings**: $35,844

### Performance Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Average Response Time | 285ms | 125ms | 56% faster |
| TTFB (with CDN) | 750ms | 120ms | 84% faster |
| Resource Utilization | 68% | 75% | Better efficiency |
| Auto-scaling Response | N/A | 30s | Handles traffic spikes |

### Scalability Improvements

- **Traffic Capacity**: 2x increase (25 pods vs 15 fixed)
- **Scaling Response Time**: 30 seconds to scale up
- **Cost Efficiency**: Pay for what you use

## Trade-offs and Considerations

**Auto-scaling**:
- **Benefit**: 42% cost reduction, 2x capacity
- **Trade-off**: 30s delay for cold starts
- **Mitigation**: Min 8 pods for baseline capacity

**Reserved Instances**:
- **Benefit**: 37% savings per instance
- **Trade-off**: 1-year commitment
- **Risk**: Low (steady baseline load confirmed)

**CDN Caching**:
- **Benefit**: 84% faster TTFB, 85% fewer origin requests
- **Trade-off**: Cache invalidation complexity
- **Mitigation**: Short TTL for dynamic content

## Monitoring Recommendations

1. **Cost Tracking**:
   - Daily cost reports
   - Budget alerts at 80%, 100%
   - Tag-based cost allocation

2. **Performance Monitoring**:
   - CloudWatch dashboards
   - Prometheus + Grafana
   - APM for application metrics

3. **Auto-scaling Health**:
   - HPA metrics (scale events)
   - Resource utilization trends
   - Alert on frequent scaling

## Next Steps

1. Evaluate spot instances for batch workloads (potential 70% savings)
2. Implement multi-region deployment for better global performance
3. Consider serverless for low-traffic endpoints
4. Review database read replicas for read-heavy workloads
