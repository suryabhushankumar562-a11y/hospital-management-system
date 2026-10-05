# Project Explanation

## 1. Architecture

The project uses one PostgreSQL schema named `hospital`. Master entities such as patients, doctors, departments, medicines and lab tests are separated from transactional entities such as appointments, admissions, prescriptions, lab results, bills and payments.

The main design goal is to avoid repeating the same business facts in multiple rows.

## 2. Why the tables are separated

- `patients`: stable patient demographic/contact data.
- `doctors`: doctor-specific information and department relationship.
- `departments`: reusable department master data.
- `appointments`: time-based patient/doctor interactions.
- `admissions`: inpatient stays and room assignment.
- `rooms`: room inventory and rates.
- `prescriptions`: prescription header.
- `medicines`: medicine master data.
- `prescription_items`: junction/detail table connecting prescriptions and medicines.
- `lab_tests`: reusable test definitions.
- `lab_results`: patient-specific test events/results.
- `bills`: financial charge summary.
- `payments`: individual financial transactions.
- `insurance`: policy information associated with a patient.

## 3. Normalization

For example, a doctor's department name is not stored repeatedly inside every appointment. The appointment stores `doctor_id`, and the doctor stores `department_id`.

Similarly, a prescription does not contain repeated medicine columns. `prescription_items` allows any prescription to contain multiple medicines and any medicine to appear in many prescriptions.

## 4. Relationships

Most relationships are one-to-many:

- department → doctors
- patient → appointments
- doctor → appointments
- patient → admissions
- patient → bills
- bill → payments

The prescription/medicine relationship is many-to-many and therefore uses `prescription_items`.

## 5. JOIN strategy

Use `INNER JOIN` when a related record is required for the report. Use `LEFT JOIN` when the report should keep the parent even when no child exists.

A good interview example is finding doctors with no appointments:

```sql
SELECT d.doctor_id, d.first_name, d.last_name
FROM doctors d
LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
WHERE a.appointment_id IS NULL;
```

The unmatched side becomes NULL, which lets us identify missing child rows.

## 6. CTEs

CTEs make multi-stage analytics easier to read. For example, first calculate spending per patient and then compare it with a threshold or join it back to patient names.

A CTE is not automatically faster than an equivalent query. Its main benefit here is clarity and composability.

## 7. Window functions

Window functions calculate across related rows without collapsing them like `GROUP BY`.

- `ROW_NUMBER()` gives a unique sequence.
- `RANK()` gives equal ranks with gaps after ties.
- `DENSE_RANK()` gives equal ranks without gaps.
- `LAG()` reads a previous row.
- `LEAD()` reads a following row.
- `SUM() OVER()` supports running totals.
- `AVG() OVER()` supports moving/partitioned averages.

The project uses them for top doctors, department ranking, patient spending, monthly revenue trends and appointment sequences.

## 8. Views

Three views provide reusable reporting interfaces:

- `patient_summary`: patient activity and financial balance.
- `doctor_performance`: appointment workload.
- `monthly_revenue`: monthly billing and collection metrics.

A view stores the query definition, not a copied result set. If the data changes, a normal view reflects the current data.

## 9. Functions

`patient_outstanding_balance(patient_id)` returns the current outstanding amount for one patient.

`hospital_stay_days(admission_id)` returns stay duration, using the current date for an active admission.

These functions encapsulate reusable business calculations.

## 10. Triggers

Two business rules are implemented.

### Updated timestamp trigger

`trg_bill_updated_at` fires `BEFORE UPDATE` on `bills` and sets `updated_at`.

### Payment synchronization trigger

`trg_apply_payment_to_bill` fires `AFTER INSERT` on `payments`. For a completed payment it updates the corresponding bill's `paid_amount` and status.

This keeps the financial summary synchronized with payment events. In a larger system, the design would also need careful handling of refunds, corrections and concurrency.

## 11. Constraints

The database uses:

- PKs for row identity.
- FKs for referential integrity.
- UNIQUE for emails, license numbers, policy numbers and transaction references.
- CHECK constraints for valid statuses, amounts, dates and percentages.
- NOT NULL for required business attributes.
- DEFAULT for timestamps and statuses.

This moves important integrity rules into the database rather than trusting only application code.

## 12. Indexes

Indexes target common access paths:

- appointment date
- doctor + appointment date
- patient/doctor foreign keys
- bill status/date
- payment date
- lab test/date

Indexes speed reads but add storage and write/update cost. Therefore, indexing every column is usually a bad idea.

## 13. EXPLAIN ANALYZE

`EXPLAIN ANALYZE` executes a query and reports the actual execution plan. Important terms:

- Sequential Scan: PostgreSQL reads rows from the table sequentially.
- Index Scan: PostgreSQL uses an index to locate qualifying rows.
- Cost: planner estimate, not milliseconds.
- Actual time: measured execution timing for plan nodes.
- Rows: estimated and actual row counts.

Execution numbers in the project are intentionally not documented because they vary by machine, cache, PostgreSQL version and statistics.

## 14. Transactions

The payment workflow demonstrates:

```sql
BEGIN;
-- payment + related update
COMMIT;
```

or:

```sql
BEGIN;
-- test operation
ROLLBACK;
```

A transaction provides atomicity: the database should not leave half of a related workflow committed.

## 15. PostgreSQL-specific usage

- `GENERATED BY DEFAULT AS IDENTITY`
- `FILTER` in aggregate expressions
- `DATE_TRUNC`
- `EXTRACT`
- `INTERVAL`
- `STRING` concatenation
- PL/pgSQL trigger functions
- `EXPLAIN ANALYZE`
- `NUMERIC` for monetary values

## 16. 1-Hour Interview Preparation

### 0–10 minutes: Database architecture

Know this story:

> "I designed a normalized hospital database under a dedicated PostgreSQL schema. Master data is separated from transactional data, and the model covers outpatient, inpatient, clinical, laboratory and billing workflows."

Remember the major flow:

**Patient → Appointment → Doctor/Department**

and:

**Patient → Admission → Room**

and:

**Patient → Prescription → Prescription Items → Medicine**

and:

**Patient → Bill → Payments**

### 10–20 minutes: Tables and relationships

Be able to explain why `prescription_items` exists. It resolves the many-to-many relationship between prescriptions and medicines.

Know why `LEFT JOIN` is useful for "doctors with no appointments."

Know why foreign keys use restrictive or set-null behavior depending on business meaning.

### 20–30 minutes: Important queries

Focus on:

- revenue aggregation
- unpaid balances
- appointment workload
- department performance
- patients above average spending
- abnormal lab analysis

Explain the difference between `WHERE` and `HAVING`, and between `INNER JOIN` and `LEFT JOIN`.

### 30–40 minutes: CTEs + Window Functions

Memorize:

> "CTEs break a complex query into named logical stages."

> "Window functions calculate across related rows without collapsing the result set."

Know `ROW_NUMBER` vs `RANK` vs `DENSE_RANK`, and one `LAG` example for month-over-month revenue.

### 40–50 minutes: Views + Functions + Triggers + Transactions

Explain:

- View = reusable query definition.
- Function = reusable database-side calculation.
- Trigger = automatically runs a function after/before a specified table event.
- Transaction = atomic unit of work controlled with BEGIN/COMMIT/ROLLBACK.

### 50–60 minutes: Indexes + EXPLAIN ANALYZE + Interview Questions

Say:

> "I indexed columns based on actual access patterns rather than indexing everything."

For `EXPLAIN ANALYZE`, explain planner estimates versus actual execution metrics.

Be ready to discuss trade-offs: indexes improve reads but increase write/storage overhead.

## Resume Project Entry

**Hospital Management & Analytics System | PostgreSQL, SQL, PL/pgSQL**

- Designed a normalized relational schema for hospital operations spanning patients, doctors, appointments, admissions, prescriptions, laboratory results, billing, payments and insurance.
- Developed analytical SQL with joins, aggregations, subqueries, CTEs, CASE/COALESCE and PostgreSQL date functions for operational and financial reporting.
- Implemented window-function analytics using ranking, running totals, moving averages and month-over-month comparisons.
- Built reporting views, reusable PL/pgSQL functions, business-rule triggers and targeted indexes; analyzed query plans with `EXPLAIN ANALYZE`.
- Enforced database-level integrity with primary/foreign keys, unique constraints, checks, defaults and transaction control.
