-- 13_analytics.sql
SET search_path TO hospital, public;

-- 1. Executive KPI dashboard
SELECT
    (SELECT COUNT(*) FROM patients) AS patients,
    (SELECT COUNT(*) FROM doctors WHERE is_active) AS active_doctors,
    (SELECT COUNT(*) FROM appointments) AS appointments,
    (SELECT COUNT(*) FROM admissions) AS admissions,
    (SELECT COUNT(*) FROM bills WHERE status <> 'Cancelled') AS bills,
    (SELECT COALESCE(SUM(total_amount),0) FROM bills WHERE status <> 'Cancelled') AS billed_revenue,
    (SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='Completed') AS collected_cash;

-- 2. Outstanding balance by patient
SELECT patient_id,
       patient_name,
       total_billed,
       total_paid,
       outstanding_balance
FROM patient_summary
WHERE outstanding_balance > 0
ORDER BY outstanding_balance DESC;

-- 3. Department operational scorecard
WITH metrics AS (
    SELECT
        dep.department_name,
        COUNT(DISTINCT d.doctor_id) AS doctors,
        COUNT(a.appointment_id) AS appointments,
        COUNT(a.appointment_id) FILTER (WHERE a.status='Completed') AS completed,
        COUNT(ad.admission_id) AS admissions
    FROM departments dep
    LEFT JOIN doctors d ON d.department_id = dep.department_id
    LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
    LEFT JOIN admissions ad ON ad.attending_doctor_id = d.doctor_id
    GROUP BY dep.department_id, dep.department_name
)
SELECT *,
       ROUND(100.0 * completed / NULLIF(appointments,0),2) AS completion_rate
FROM metrics
ORDER BY completion_rate DESC NULLS LAST;

-- 4. Monthly revenue + MoM percentage
WITH monthly AS (
    SELECT DATE_TRUNC('month', bill_date)::date AS month,
           SUM(total_amount) AS revenue
    FROM bills
    WHERE status <> 'Cancelled'
    GROUP BY 1
),
with_previous AS (
    SELECT month, revenue,
           LAG(revenue) OVER (ORDER BY month) AS previous_revenue
    FROM monthly
)
SELECT month, revenue, previous_revenue,
       ROUND(
           100.0 * (revenue - previous_revenue) / NULLIF(previous_revenue,0),
           2
       ) AS mom_growth_percent
FROM with_previous
ORDER BY month;

-- 5. Top 5 spending patients
WITH spend AS (
    SELECT patient_id, SUM(total_amount) AS total_spend
    FROM bills
    WHERE status <> 'Cancelled'
    GROUP BY patient_id
)
SELECT p.patient_id,
       p.first_name || ' ' || p.last_name AS patient_name,
       s.total_spend
FROM spend s
JOIN patients p ON p.patient_id = s.patient_id
ORDER BY s.total_spend DESC
LIMIT 5;

-- 6. Prescription cost analysis
SELECT pr.prescription_id,
       pr.patient_id,
       pr.prescription_date,
       SUM(pi.quantity * pi.unit_price) AS medication_cost
FROM prescriptions pr
JOIN prescription_items pi ON pi.prescription_id = pr.prescription_id
GROUP BY pr.prescription_id, pr.patient_id, pr.prescription_date
ORDER BY medication_cost DESC;

-- 7. Lab turnaround review
SELECT lt.test_name,
       COUNT(lr.lab_result_id) AS tests,
       ROUND(AVG(
           EXTRACT(EPOCH FROM (lr.result_date - lr.ordered_at))/3600
       ),2) AS avg_turnaround_hours
FROM lab_tests lt
LEFT JOIN lab_results lr ON lr.lab_test_id = lt.lab_test_id
    AND lr.result_date IS NOT NULL
GROUP BY lt.lab_test_id, lt.test_name
ORDER BY avg_turnaround_hours DESC NULLS LAST;

-- 8. Room utilization proxy
SELECT r.room_type,
       COUNT(a.admission_id) AS admissions,
       ROUND(AVG(
           CASE
               WHEN a.discharge_date IS NULL THEN CURRENT_DATE - a.admission_date
               ELSE a.discharge_date - a.admission_date
           END
       ),2) AS avg_stay_days
FROM rooms r
LEFT JOIN admissions a ON a.room_id = r.room_id
GROUP BY r.room_type
ORDER BY admissions DESC;

-- 9. Payment collection rate
SELECT
    ROUND(
        100.0 * SUM(paid_amount) / NULLIF(SUM(total_amount),0),
        2
    ) AS collection_rate_percent
FROM bills
WHERE status <> 'Cancelled';

-- 10. Appointment conversion / no-show view
SELECT
    COUNT(*) AS total_appointments,
    COUNT(*) FILTER (WHERE status='Completed') AS completed,
    COUNT(*) FILTER (WHERE status='No Show') AS no_shows,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status='Completed') / COUNT(*),
        2
    ) AS completion_percent
FROM appointments;

-- 11. Patients with repeated abnormal labs
SELECT patient_id, COUNT(*) AS abnormal_results
FROM lab_results
WHERE result_status='Abnormal'
GROUP BY patient_id
HAVING COUNT(*) >= 2
ORDER BY abnormal_results DESC;

-- 12. Low-stock medicine report
SELECT medicine_name, stock_quantity, reorder_level,
       reorder_level - stock_quantity AS units_below_reorder
FROM medicines
WHERE stock_quantity <= reorder_level
ORDER BY units_below_reorder DESC;
