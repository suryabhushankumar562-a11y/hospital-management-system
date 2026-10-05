-- 11_indexes.sql
SET search_path TO hospital, public;

-- Indexes should follow actual query patterns, not be added to every column.
CREATE INDEX IF NOT EXISTS idx_patients_city ON patients(city);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor_date ON appointments(doctor_id, appointment_date);
CREATE INDEX IF NOT EXISTS idx_admissions_status ON admissions(status);
CREATE INDEX IF NOT EXISTS idx_lab_results_test_date ON lab_results(lab_test_id, ordered_at);
CREATE INDEX IF NOT EXISTS idx_bills_status_date ON bills(status, bill_date);
CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date);

ANALYZE patients;
ANALYZE appointments;
ANALYZE bills;
ANALYZE payments;

-- EXPLAIN ANALYZE examples.
-- Run these after indexes exist. The actual plan/cost/time will depend on
-- PostgreSQL version, hardware, cache state and table statistics.
EXPLAIN ANALYZE
SELECT appointment_id, patient_id, doctor_id, appointment_date
FROM appointments
WHERE appointment_date >= TIMESTAMP '2026-06-01'
  AND appointment_date < TIMESTAMP '2026-07-01';

EXPLAIN ANALYZE
SELECT bill_id, patient_id, total_amount
FROM bills
WHERE status = 'Unpaid'
ORDER BY bill_date DESC;

EXPLAIN ANALYZE
SELECT payment_id, bill_id, payment_date, amount
FROM payments
WHERE payment_date >= TIMESTAMP '2026-06-01'
  AND payment_date < TIMESTAMP '2026-07-01';
