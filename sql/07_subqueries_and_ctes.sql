-- 07_subqueries_and_ctes.sql
SET search_path TO hospital, public;

-- 1. Scalar subquery: doctors charging above average
SELECT doctor_id, first_name, last_name, consultation_fee
FROM doctors
WHERE consultation_fee > (SELECT AVG(consultation_fee) FROM doctors)
ORDER BY consultation_fee DESC;

-- 2. Correlated subquery: patients having a bill above their own average bill
SELECT b.bill_id, b.patient_id, b.total_amount
FROM bills b
WHERE b.total_amount > (
    SELECT AVG(b2.total_amount)
    FROM bills b2
    WHERE b2.patient_id = b.patient_id
)
ORDER BY b.patient_id, b.total_amount DESC;

-- 3. CTE: monthly revenue
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', bill_date)::date AS month,
           SUM(total_amount) AS revenue
    FROM bills
    WHERE status <> 'Cancelled'
    GROUP BY 1
)
SELECT *
FROM monthly_revenue
ORDER BY month;

-- 4. CTE: high-value patients
WITH patient_spend AS (
    SELECT patient_id, SUM(total_amount) AS total_spend
    FROM bills
    WHERE status <> 'Cancelled'
    GROUP BY patient_id
)
SELECT p.patient_id, p.first_name || ' ' || p.last_name AS patient_name,
       ps.total_spend
FROM patient_spend ps
JOIN patients p ON p.patient_id = ps.patient_id
WHERE ps.total_spend >= 20000
ORDER BY ps.total_spend DESC;

-- 5. Multi-CTE doctor performance
WITH doctor_appointments AS (
    SELECT doctor_id, COUNT(*) AS appointment_count
    FROM appointments
    WHERE status = 'Completed'
    GROUP BY doctor_id
),
doctor_revenue AS (
    SELECT a.doctor_id, COALESCE(SUM(b.total_amount),0) AS billed_revenue
    FROM appointments a
    JOIN bills b ON b.patient_id = a.patient_id
    GROUP BY a.doctor_id
)
SELECT d.doctor_id, d.first_name || ' ' || d.last_name AS doctor_name,
       dep.department_name,
       COALESCE(da.appointment_count,0) AS completed_appointments,
       COALESCE(dr.billed_revenue,0) AS billed_revenue
FROM doctors d
JOIN departments dep ON dep.department_id = d.department_id
LEFT JOIN doctor_appointments da ON da.doctor_id = d.doctor_id
LEFT JOIN doctor_revenue dr ON dr.doctor_id = d.doctor_id
ORDER BY billed_revenue DESC;

-- 6. Department performance CTE
WITH department_metrics AS (
    SELECT dep.department_id, dep.department_name,
           COUNT(DISTINCT a.appointment_id) AS appointments,
           COUNT(DISTINCT d.doctor_id) AS doctors
    FROM departments dep
    LEFT JOIN doctors d ON d.department_id = dep.department_id
    LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
    GROUP BY dep.department_id, dep.department_name
)
SELECT *, ROUND(appointments::numeric / NULLIF(doctors,0),2) AS appointments_per_doctor
FROM department_metrics
ORDER BY appointments_per_doctor DESC NULLS LAST;

-- 7. Top doctors per department using a CTE
WITH doctor_counts AS (
    SELECT d.doctor_id, d.department_id,
           d.first_name || ' ' || d.last_name AS doctor_name,
           COUNT(a.appointment_id) AS appointment_count
    FROM doctors d
    LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
    GROUP BY d.doctor_id, d.department_id, doctor_name
)
SELECT *
FROM doctor_counts dc
WHERE (
    SELECT COUNT(*)
    FROM doctor_counts dc2
    WHERE dc2.department_id = dc.department_id
      AND dc2.appointment_count > dc.appointment_count
) < 3
ORDER BY department_id, appointment_count DESC;

-- 8. CASE + COALESCE: patient financial risk bucket
WITH balances AS (
    SELECT p.patient_id,
           p.first_name || ' ' || p.last_name AS patient_name,
           COALESCE(SUM(b.total_amount - b.paid_amount),0) AS outstanding
    FROM patients p
    LEFT JOIN bills b ON b.patient_id = p.patient_id AND b.status <> 'Cancelled'
    GROUP BY p.patient_id, patient_name
)
SELECT patient_id, patient_name, outstanding,
       CASE
           WHEN outstanding = 0 THEN 'Clear'
           WHEN outstanding < 5000 THEN 'Low'
           WHEN outstanding < 15000 THEN 'Medium'
           ELSE 'High'
       END AS financial_status
FROM balances
ORDER BY outstanding DESC;

-- 9. Duplicate detection pattern
SELECT email, COUNT(*) AS occurrences
FROM patients
GROUP BY email
HAVING COUNT(*) > 1;

-- 10. Percentage of abnormal lab results
SELECT ROUND(
    100.0 * COUNT(*) FILTER (WHERE result_status='Abnormal') / COUNT(*),
    2
) AS abnormal_percentage
FROM lab_results;
