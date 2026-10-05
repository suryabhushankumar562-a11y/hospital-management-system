-- 12_transactions.sql
SET search_path TO hospital, public;

-- These examples are intentionally commented out.
-- Uncomment ONE transaction at a time when practicing.
-- This prevents an accidental payment/update during a normal script run.

-- Example 1: successful payment workflow
/*
BEGIN;

INSERT INTO payments
    (bill_id, amount, payment_method, transaction_reference, status)
VALUES
    (1, 500.00, 'UPI', 'TXN-MANUAL-001', 'Completed');

-- The AFTER INSERT trigger updates bills.paid_amount and bill status.
SELECT bill_id, total_amount, paid_amount, status
FROM bills
WHERE bill_id = 1;

COMMIT;
*/

-- Example 2: rollback a test payment
/*
BEGIN;

INSERT INTO payments
    (bill_id, amount, payment_method, transaction_reference, status)
VALUES
    (1, 250.00, 'Card', 'TXN-ROLLBACK-001', 'Completed');

SELECT *
FROM payments
WHERE transaction_reference = 'TXN-ROLLBACK-001';

ROLLBACK;

-- The payment and trigger side effects are rolled back together.
SELECT *
FROM payments
WHERE transaction_reference = 'TXN-ROLLBACK-001';
*/

-- Interview point:
-- A transaction keeps related changes atomic. If a payment insertion or
-- dependent update fails, ROLLBACK prevents a partially completed workflow.
