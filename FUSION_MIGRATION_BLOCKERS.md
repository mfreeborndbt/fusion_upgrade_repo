# dbt Fusion Migration Blockers - Jaffle Shop Project

This document outlines the intentionally introduced migration blockers in the refactored Jaffle Shop dbt project for testing dbt Fusion upgrade scenarios.

## 🚫 Hard Blockers

### 1. Python Model with Critical Path Dependency
**Files:** 
- `models/marts/customer_segments_python.py`
- `models/marts/customer_analytics_dashboard.sql` (depends on Python model)

**Blocker:** Python models are not supported in dbt Fusion. The downstream model creates a critical path dependency, making this a hard blocker that prevents migration until the Python model is refactored.

**Business Context:** Advanced customer segmentation using scikit-learn clustering that feeds into business intelligence dashboards.

### 2. Unparseable Model with Jinja/SQL Anti-patterns
**File:** `models/staging/stg_problematic_legacy.sql`

**Blocker:** Contains multiple parsing issues:
- Mismatched quotes and brackets in macro calls
- Undefined variables and recursive macro calls
- Malformed conditional logic
- Circular references
- Invalid Jinja syntax

**Business Context:** Legacy model with accumulated technical debt and problematic patterns that would prevent compilation.

## 🟡 Soft Blockers

### 3. Microbatch Incremental Model
**File:** `models/marts/order_events_microbatch.sql`

**Blocker:** Uses `incremental_strategy='microbatch'` configuration which is not supported in Fusion.

**Business Context:** Real-time event stream processing for order analytics with hourly batch processing.

### 4. Custom Materialization
**Files:**
- `macros/custom_audit_table_materialization.sql` (custom materialization definition)
- `models/marts/products_with_audit.sql` (uses custom materialization)

**Blocker:** Custom materializations are not supported in Fusion. The `audit_table` materialization creates both main and audit tables.

**Business Context:** Compliance requirement to maintain audit trails for product performance data.

### 5. Saved Query Export Flow
**Files:**
- `dbt_project.yml` (saved query configuration)
- `models/marts/saved_queries.yml` (saved query definitions)

**Blocker:** Saved query export configurations and CLI flags for automated exports may not be fully supported.

**Business Context:** Automated data exports for BI tools and executive reporting.

### 6. Exposure Definitions
**File:** `models/marts/customers.yml` (exposures section)

**Blocker:** Exposure blocks defining downstream dependencies may not be fully supported in Fusion.

**Business Context:** Tracking dependencies to Tableau dashboards, Excel reports, and ML pipelines.

### 7. Iceberg Table Materialization
**Files:**
- `dbt_project.yml` (Iceberg configuration)
- `models/marts/order_history_iceberg.sql`

**Blocker:** Iceberg table materialization with advanced features like time travel and schema evolution.

**Business Context:** Advanced analytics on historical order data requiring Iceberg's versioning and performance features.

### 8. Protected Model References and Access Restrictions
**Files:**
- `packages.yml` (protected package configuration)
- `models/marts/financial_reporting_with_protected.sql` (restrict_access=true)

**Blocker:** 
- Package with `restrict-access: true` configuration
- Model-level access restrictions
- References to protected models from packages

**Business Context:** Financial reporting with PII and sensitive data requiring access controls.

### 9. Model with Deprecation Date
**File:** `models/staging/stg_legacy_order_summary.sql`

**Blocker:** Uses `deprecation_date='2024-06-01'` configuration which may affect migration timeline and planning.

**Business Context:** Legacy business logic being phased out but still in use during transition period.

### 10. Semantic Model Definitions
**File:** `models/marts/customers.yml` (semantic_models section)

**Blocker:** Semantic models with entities, dimensions, and measures that define the semantic layer.

**Business Context:** MetricFlow semantic layer definitions for consistent business metrics.

### 11. Query Comment Macro Usage
**Files:**
- `macros/query_comment.sql` (macro definition)
- `models/marts/orders_with_query_comments.sql` (extensive macro usage)

**Blocker:** Dynamic query comment generation that injects metadata into SQL may not be supported.

**Business Context:** Compliance and audit requirements for query tracking and performance monitoring.

### 12. Programmatic dbt Invocation
**File:** `tests/test_dbt_programmatic_invocation.py`

**Blocker:** Python unit tests that programmatically invoke dbt CLI commands and parse results.

**Business Context:** CI/CD pipeline integration, automated testing, and custom workflow orchestration.

## 🚩 Behavior Change Flags

**File:** `dbt_project.yml` (flags section)

**Purpose:** Modern dbt behavior change flags that test additional migration scenarios and enforce best practices.

**Flags Enabled:**
- `require_explicit_package_overrides_for_builtin_materializations: true` - Prevents automatic package overrides of built-in materializations
- `require_model_names_without_spaces: true` - Enforces clean naming conventions  
- `source_freshness_run_project_hooks: true` - Includes project hooks in freshness commands
- `state_modified_compare_more_unrendered_values: true` - Improves state comparison accuracy
- `validate_macro_args: true` - Validates macro argument names and types
- `require_generic_test_arguments_property: true` - Enforces modern test syntax

**Migration Context:** These flags ensure the project uses modern dbt patterns and could reveal additional migration considerations or compatibility requirements during Fusion migration.

## 📊 Migration Impact Summary

| Blocker Type | Count | Migration Impact |
|--------------|-------|------------------|
| **Hard Blockers** | 2 | Must be resolved before migration |
| **Soft Blockers** | 10 | May require feature parity or workarounds |
| **Behavior Flags** | 11 | Modern practices that may affect migration |
| **Total** | 23 | Comprehensive coverage of common blockers |

## 🔧 Project Structure

The project maintains all original Jaffle Shop functionality while adding realistic migration blockers:

```
fusion_upgrade_repo/
├── models/
│   ├── marts/
│   │   ├── customer_segments_python.py          # Hard blocker
│   │   ├── customer_analytics_dashboard.sql     # Depends on Python model
│   │   ├── order_events_microbatch.sql          # Microbatch blocker
│   │   ├── products_with_audit.sql              # Custom materialization
│   │   ├── order_history_iceberg.sql            # Iceberg blocker
│   │   ├── financial_reporting_with_protected.sql # Access restrictions
│   │   ├── orders_with_query_comments.sql       # Query comment macro
│   │   ├── saved_queries.yml                    # Saved queries
│   │   └── customers.yml                        # Exposures, semantic models
│   └── staging/
│       ├── stg_problematic_legacy.sql           # Hard blocker - unparseable
│       └── stg_legacy_order_summary.sql         # Deprecation date
├── macros/
│   ├── custom_audit_table_materialization.sql  # Custom materialization
│   └── query_comment.sql                        # Query comment macro
├── tests/
│   └── test_dbt_programmatic_invocation.py      # Python integration tests
├── dbt_project.yml                              # Project configuration
└── packages.yml                                 # Package dependencies
```

## 🎯 Testing Migration Scenarios

This setup allows testing various migration scenarios:

1. **Assessment Phase:** Identify all blockers using dbt Fusion migration tools
2. **Planning Phase:** Prioritize hard vs soft blockers  
3. **Resolution Phase:** Address blockers incrementally
4. **Validation Phase:** Ensure functionality is preserved after migration
5. **Modernization Phase:** Test behavior change flags and modern dbt practices

**Enhanced Testing Capabilities:**
- **Behavior Flag Testing:** The enabled flags test how modern dbt behaviors interact with migration processes
- **Macro Validation:** `validate_macro_args: true` will catch any macro issues during migration
- **Package Override Testing:** Tests explicit package override requirements
- **State Comparison:** Enhanced state comparison logic for better dev/prod parity testing

Each blocker represents realistic patterns found in production dbt environments, making this a comprehensive test case for Fusion migration tooling and processes. The behavior change flags add an additional layer of modern dbt compliance testing.
