---
description: Comprehensive performance optimization across database, backend, frontend, and infrastructure layers
argument-hint: <operation> [parameters...]
model: inherit
---

# Performance Optimization Skill

You are routing performance optimization requests to specialized operations. Parse the `$ARGUMENTS` to determine which optimization operation to execute.

## Available Operations

- **analyze** - Comprehensive performance analysis with bottleneck identification
- **database** - Database query and schema optimization
- **backend** - Backend API and algorithm optimization
- **frontend** - Frontend bundle and rendering optimization
- **infrastructure** - Infrastructure and deployment optimization
- **benchmark** - Performance benchmarking and regression testing

## Routing Logic

Extract the first word from `$ARGUMENTS` as the operation name, and pass the remainder as operation parameters.

**Arguments received**: `$ARGUMENTS`

**Base directory**: `/home/danie/projects/plugins/architect/open-plugins/plugins/10x-fullstack-engineer/commands/optimize/`

**Routing Instructions**:

1. **Parse the operation**: Extract the first word from `$ARGUMENTS`
2. **Load operation instructions**: Read the corresponding operation file
3. **Execute with context**: Follow the operation's instructions with remaining parameters
4. **Invoke the agent**: Leverage the 10x-fullstack-engineer agent for optimization expertise

## Operation Routing

```
analyze → Read and follow: /home/danie/projects/plugins/architect/open-plugins/plugins/10x-fullstack-engineer/commands/optimize/analyze.md
database → Read and follow: /home/danie/projects/plugins/architect/open-plugins/plugins/10x-fullstack-engineer/commands/optimize/database.md
backend → Read and follow: /home/danie/projects/plugins/architect/open-plugins/plugins/10x-fullstack-engineer/commands/optimize/backend.md
frontend → Read and follow: /home/danie/projects/plugins/architect/open-plugins/plugins/10x-fullstack-engineer/commands/optimize/frontend.md
infrastructure → Read and follow: /home/danie/projects/plugins/architect/open-plugins/plugins/10x-fullstack-engineer/commands/optimize/infrastructure.md
benchmark → Read and follow: /home/danie/projects/plugins/architect/open-plugins/plugins/10x-fullstack-engineer/commands/optimize/benchmark.md
```

## Error Handling

If no operation is specified or the operation is not recognized, display:

**Available optimization operations**:
- `/optimize analyze` - Comprehensive performance analysis
- `/optimize database` - Database optimization
- `/optimize backend` - Backend API optimization
- `/optimize frontend` - Frontend bundle and rendering optimization
- `/optimize infrastructure` - Infrastructure and deployment optimization
- `/optimize benchmark` - Performance benchmarking

**Example usage**:
```
/optimize analyze target:"user dashboard" scope:all metrics:"baseline"
/optimize database target:queries context:"slow SELECT statements" threshold:500ms
/optimize backend target:api endpoints:"/api/users,/api/products" load_profile:high
/optimize frontend target:bundles pages:"dashboard,profile" metrics_target:"lighthouse>90"
/optimize infrastructure target:scaling environment:production provider:aws
/optimize benchmark type:load baseline:"v1.2.0" duration:300s concurrency:100
```

**Comprehensive workflow example**:
```bash
# 1. Analyze overall performance
/optimize analyze target:"production app" scope:all metrics:"baseline"

# 2. Optimize specific layers based on analysis
/optimize database target:all context:"queries from analysis" threshold:200ms
/optimize backend target:api endpoints:"/api/search" priority:high
/optimize frontend target:all pages:"checkout,dashboard" framework:react

# 3. Benchmark improvements
/optimize benchmark type:all baseline:"pre-optimization" duration:600s

# 4. Optimize infrastructure for efficiency
/optimize infrastructure target:costs environment:production budget_constraint:true
```

## Integration with 10x-Fullstack-Engineer

All optimization operations should leverage the **10x-fullstack-engineer** agent for:
- Expert performance analysis across all layers
- Industry best practices for optimization
- Trade-off analysis between performance and maintainability
- Scalability considerations
- Production-ready implementation guidance

## Execution

Based on the parsed operation from `$ARGUMENTS`, read the appropriate operation file and follow its instructions with the remaining parameters.
