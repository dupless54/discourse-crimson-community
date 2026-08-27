---
name: project-schema-review
description: Review migrations, indexes, constraints, and stored-data changes for correctness and production safety.
---
# Schema review
Check existing visit rows, growth/query cadence, null/default/backfill, uniqueness/FKs, indexes, lock/table-scan risk, retention, rollback/recovery, and deploy ordering. Stop for irreversible/ambiguous data decisions; never execute destructive production operations.
