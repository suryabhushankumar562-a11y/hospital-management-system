-- 09_views.sql
SET search_path TO hospital, public;

CREATE OR REPLACE VIEW patient_summary AS
SELECT
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.city,
    COUNT(DISTINCT a.appointment_id) AS appointment_count,
    COUNT(DISTINCT ad.admission_id) AS admission_count,
    COALESCE(SUM(b.total_amount),0) AS total_billed,
    COALESCE(SUM(b.paid_amount),0) AS total_paid,
    COALESCE(SUM(b.total_amount - b.paid_amount),0) AS outstanding_balance
FROM patients p
LEFT JOIN appointments a ON a.patient_id = p.patient_id
LEFT JOIN admissions ad ON ad.patient_id = p.patient_id
LEFT JOIN bills b ON b.patient_id = p.patient_id
GROUP BY p.patient_id, patient_name, p.city;

CREATE OR REPLACE VIEW doctor_performance AS
SELECT
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    dep.department_name,
    COUNT(a.appointment_id) FILTER (WHERE a.status='Completed') AS completed_appointments,
    COUNT(a.appointment_id) FILTER (WHERE a.status='Cancelled') AS cancelled_appointments,
    COUNT(a.appointment_id) AS appointment_count,
    ROUND(AVG(d.consultation_fee),2) AS consultation_fee
FROM doctors d
JOIN departments dep ON dep.department_id = d.department_id
LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, doctor_name, dep.department_name, d.consultation_fee;

CREATE OR REPLACE VIEW monthly_revenue AS
SELECT
    DATE_TRUNC('month', bill_date)::date AS month,
    COUNT(*) AS bill_count,
    SUM(total_amount) AS billed_revenue,
    SUM(paid_amount) AS collected_revenue,
    SUM(total_amount - paid_amount) AS outstanding_revenue
FROM bills
WHERE status <> 'Cancelled'
GROUP BY 1
ORDER BY 1;

-- Examples:
-- SELECT * FROM patient_summary ORDER BY outstanding_balance DESC;
-- SELECT * FROM doctor_performance ORDER BY completed_appointments DESC;
-- SELECT * FROM monthly_revenue;
