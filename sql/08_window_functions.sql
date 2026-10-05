-- 08_window_functions.sql
SET search_path TO hospital, public;

-- 1. ROW_NUMBER: top 3 doctors per department
WITH ranked_doctors AS (
    SELECT d.doctor_id,
           d.department_id,
           d.first_name || ' ' || d.last_name AS doctor_name,
           COUNT(a.appointment_id) AS appointment_count,
           ROW_NUMBER() OVER (
               PARTITION BY d.department_id
               ORDER BY COUNT(a.appointment_id) DESC, d.doctor_id
           ) AS row_num
    FROM doctors d
    LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
    GROUP BY d.doctor_id, d.department_id, doctor_name
)
SELECT rd.*, dep.department_name
FROM ranked_doctors rd
JOIN departments dep ON dep.department_id = rd.department_id
WHERE row_num <= 3
ORDER BY dep.department_name, row_num;

-- 2. RANK: departments by revenue
WITH department_revenue AS (
    SELECT dep.department_id, dep.department_name,
           COALESCE(SUM(b.total_amount),0) AS revenue
    FROM departments dep
    LEFT JOIN doctors d ON d.department_id = dep.department_id
    LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
    LEFT JOIN bills b ON b.patient_id = a.patient_id
    GROUP BY dep.department_id, dep.department_name
)
SELECT *, RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM department_revenue
ORDER BY revenue_rank;

-- 3. DENSE_RANK: patients by spending
WITH patient_spend AS (
    SELECT p.patient_id, p.first_name || ' ' || p.last_name AS patient_name,
           COALESCE(SUM(b.total_amount),0) AS total_spend
    FROM patients p
    LEFT JOIN bills b ON b.patient_id = p.patient_id
    GROUP BY p.patient_id, patient_name
)
SELECT *, DENSE_RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
FROM patient_spend
ORDER BY spend_rank, patient_id;

-- 4. Running monthly revenue
WITH monthly AS (
    SELECT DATE_TRUNC('month', bill_date)::date AS month,
           SUM(total_amount) AS revenue
    FROM bills
    WHERE status <> 'Cancelled'
    GROUP BY 1
)
SELECT month, revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_revenue
FROM monthly
ORDER BY month;

-- 5. LAG: month-over-month revenue comparison
WITH monthly AS (
    SELECT DATE_TRUNC('month', bill_date)::date AS month,
           SUM(total_amount) AS revenue
    FROM bills
    WHERE status <> 'Cancelled'
    GROUP BY 1
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
       revenue - LAG(revenue) OVER (ORDER BY month) AS change_amount
FROM monthly
ORDER BY month;

-- 6. LEAD: next month's revenue
WITH monthly AS (
    SELECT DATE_TRUNC('month', bill_date)::date AS month,
           SUM(total_amount) AS revenue
    FROM bills
    WHERE status <> 'Cancelled'
    GROUP BY 1
)
SELECT month, revenue,
       LEAD(revenue) OVER (ORDER BY month) AS next_month_revenue
FROM monthly
ORDER BY month;

-- 7. AVG OVER: three-month moving average
WITH monthly AS (
    SELECT DATE_TRUNC('month', bill_date)::date AS month,
           SUM(total_amount) AS revenue
    FROM bills
    WHERE status <> 'Cancelled'
    GROUP BY 1
)
SELECT month, revenue,
       ROUND(AVG(revenue) OVER (
           ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ),2) AS three_month_moving_average
FROM monthly
ORDER BY month;

-- 8. Patient appointment sequence
SELECT patient_id, appointment_id, appointment_date,
       ROW_NUMBER() OVER (
           PARTITION BY patient_id ORDER BY appointment_date
       ) AS appointment_sequence
FROM appointments
ORDER BY patient_id, appointment_sequence;

-- 9. Doctor workload percentile-like view using rank
WITH workload AS (
    SELECT doctor_id, COUNT(*) AS appointments
    FROM appointments
    GROUP BY doctor_id
)
SELECT doctor_id, appointments,
       RANK() OVER (ORDER BY appointments DESC) AS workload_rank
FROM workload
ORDER BY workload_rank;
