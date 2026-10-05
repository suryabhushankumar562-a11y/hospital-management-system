-- 10_functions_and_triggers.sql
SET search_path TO hospital, public;

-- 1. Calculate a patient's current outstanding balance.
CREATE OR REPLACE FUNCTION patient_outstanding_balance(p_patient_id BIGINT)
RETURNS NUMERIC(12,2)
LANGUAGE SQL
STABLE
AS $$
    SELECT COALESCE(ROUND(SUM(total_amount - paid_amount),2),0)::NUMERIC(12,2)
    FROM bills
    WHERE patient_id = p_patient_id
      AND status <> 'Cancelled';
$$;

-- 2. Calculate hospital stay duration.
CREATE OR REPLACE FUNCTION hospital_stay_days(p_admission_id BIGINT)
RETURNS INTEGER
LANGUAGE SQL
STABLE
AS $$
    SELECT CASE
        WHEN discharge_date IS NULL THEN CURRENT_DATE - admission_date
        ELSE discharge_date - admission_date
    END
    FROM admissions
    WHERE admission_id = p_admission_id;
$$;

-- 3. Generic updated_at trigger function for bills.
CREATE OR REPLACE FUNCTION set_bill_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_bill_updated_at ON bills;

CREATE TRIGGER trg_bill_updated_at
BEFORE UPDATE ON bills
FOR EACH ROW
EXECUTE FUNCTION set_bill_updated_at();

-- 4. Maintain bill paid_amount/status after a successful payment.
CREATE OR REPLACE FUNCTION apply_payment_to_bill()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    new_paid NUMERIC(12,2);
BEGIN
    IF NEW.status = 'Completed' THEN
        UPDATE bills
        SET paid_amount = LEAST(total_amount, paid_amount + NEW.amount),
            status = CASE
                WHEN LEAST(total_amount, paid_amount + NEW.amount) >= total_amount
                    THEN 'Paid'
                WHEN LEAST(total_amount, paid_amount + NEW.amount) > 0
                    THEN 'Partially Paid'
                ELSE 'Unpaid'
            END
        WHERE bill_id = NEW.bill_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_apply_payment_to_bill ON payments;

CREATE TRIGGER trg_apply_payment_to_bill
AFTER INSERT ON payments
FOR EACH ROW
EXECUTE FUNCTION apply_payment_to_bill();

-- Function demos:
SELECT patient_outstanding_balance(1) AS sample_patient_balance;
SELECT hospital_stay_days(1) AS sample_stay_days;
