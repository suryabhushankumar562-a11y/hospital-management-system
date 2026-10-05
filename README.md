# Hospital Management & Analytics System

A portfolio-ready PostgreSQL project demonstrating relational database design, data integrity, analytics, CTEs, window functions, views, functions, triggers, transactions, indexing, and query-plan analysis.

> **Scope:** PostgreSQL + SQL only. No frontend or backend. All patient/person data is fictional demo data.

## Problem Statement

Hospitals generate operational and financial data across patients, doctors, appointments, admissions, medicines, laboratory work, billing, payments, and insurance. This project models those workflows in a normalized relational database and provides analytical SQL for operational reporting.

## Features

- 14 core business modules
- Primary/foreign keys, UNIQUE, NOT NULL, CHECK and DEFAULT constraints
- One-to-many and many-to-many relationships
- 60+ patients, 18 doctors, 8 departments, 150 appointments, 70 admissions, 24 rooms
- 40 medicines, 120 prescriptions/prescription items, 100 lab results, 100 bills, 150 payments
- Basic, intermediate and advanced analytical queries
- CTEs and multi-CTE analysis
- ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, running totals and moving averages
- Three reporting views
- PostgreSQL functions and practical triggers
- Targeted indexes
- Transaction and rollback examples
- EXPLAIN ANALYZE examples without fabricated execution statistics

## Tech Stack

- PostgreSQL 14+
- SQL / PL/pgSQL
- pgAdmin 4 or `psql`
- Mermaid for ER documentation

## Database Modules

Patients, Doctors, Departments, Appointments, Admissions, Rooms, Prescriptions, Medicines, Prescription Items, Lab Tests, Lab Results, Bills, Payments and Insurance.

## Architecture

The `hospital` schema is isolated from the default `public` schema. Patient and doctor master data are separated from transactional tables. Prescription items and insurance coverage use separate tables to avoid repeating data and to preserve normalization.

## Project Structure

```text
hospital-management-sql/
├── README.md
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_constraints.sql
│   ├── 04_insert_data.sql
│   ├── 05_basic_queries.sql
│   ├── 06_joins_and_aggregations.sql
│   ├── 07_subqueries_and_ctes.sql
│   ├── 08_window_functions.sql
│   ├── 09_views.sql
│   ├── 10_functions_and_triggers.sql
│   ├── 11_indexes.sql
│   ├── 12_transactions.sql
│   └── 13_analytics.sql
└── docs/
    ├── PROJECT_EXPLANATION.md
    ├── INTERVIEW_QA.md
    └── ER_DIAGRAM.md
```

## Setup

1. Create/open any PostgreSQL database, for example `hospital_analytics`.
2. Run SQL files in numerical order.
3. `01_create_database.sql` creates the schema; it does not create a separate database.
4. Use pgAdmin Query Tool or `psql`.
5. Each script begins with `SET search_path TO hospital;`.

### psql

```bash
psql -U postgres -d hospital_analytics -f sql/01_create_database.sql
psql -U postgres -d hospital_analytics -f sql/02_create_tables.sql
psql -U postgres -d hospital_analytics -f sql/03_constraints.sql
psql -U postgres -d hospital_analytics -f sql/04_insert_data.sql
psql -U postgres -d hospital_analytics -f sql/05_basic_queries.sql
psql -U postgres -d hospital_analytics -f sql/06_joins_and_aggregations.sql
psql -U postgres -d hospital_analytics -f sql/07_subqueries_and_ctes.sql
psql -U postgres -d hospital_analytics -f sql/08_window_functions.sql
psql -U postgres -d hospital_analytics -f sql/09_views.sql
psql -U postgres -d hospital_analytics -f sql/10_functions_and_triggers.sql
psql -U postgres -d hospital_analytics -f sql/11_indexes.sql
psql -U postgres -d hospital_analytics -f sql/12_transactions.sql
psql -U postgres -d hospital_analytics -f sql/13_analytics.sql
```

## Important Execution Note

The first four scripts build the data foundation. Scripts 05–13 are reporting/demo scripts. `12_transactions.sql` contains transaction examples intentionally wrapped in comments so that running the file cannot accidentally modify the demo database.

## Example Analytics

```sql
SELECT * FROM hospital.monthly_revenue;
SELECT * FROM hospital.doctor_performance ORDER BY appointment_count DESC;
SELECT * FROM hospital.patient_summary ORDER BY total_billed DESC;
```

## Performance Optimization

Indexes are created only for realistic filter/join paths such as appointment dates, patient/doctor IDs, bill status and payment dates. Use `EXPLAIN ANALYZE` in your own environment to compare plans. Do not quote execution times from this README because they depend on PostgreSQL version, hardware, cache state and data statistics.

## Security Note

This is a portfolio/demo database. It contains fictional records only. A production hospital system would require authentication/authorization, encryption, auditing, row-level access controls, secure backups, retention policies, privacy/compliance controls and carefully protected clinical data.

## Future Improvements

- Role-based database permissions
- Audit/event tables
- Materialized reporting views for very large datasets
- Partitioning for appointments, payments and lab results
- More detailed insurance claims
- Production-grade observability and backup strategy

## Author / Project

**Hospital Management & Analytics System** — PostgreSQL portfolio project focused on practical SQL and database engineering.

## Resume Project Entry

**Hospital Management & Analytics System | PostgreSQL, SQL, PL/pgSQL**

- Designed a normalized PostgreSQL hospital database covering patients, doctors, appointments, admissions, prescriptions, laboratory workflows, billing, payments and insurance.
- Built analytical SQL using multi-table joins, CTEs, subqueries, CASE/COALESCE and aggregate functions to analyze operational and financial KPIs.
- Implemented window-function reporting for departmental rankings, top doctors, running revenue, month-over-month comparisons and patient spending.
- Added reusable reporting views, PL/pgSQL functions, business-rule triggers and targeted indexes; used `EXPLAIN ANALYZE` for query-plan inspection.
- Applied primary/foreign keys, UNIQUE, CHECK, NOT NULL, defaults and transaction control to maintain database integrity.

**Key concepts:** PostgreSQL, relational modeling, normalization, JOINs, CTEs, subqueries, window functions, views, functions, triggers, indexes, transactions, EXPLAIN ANALYZE.
