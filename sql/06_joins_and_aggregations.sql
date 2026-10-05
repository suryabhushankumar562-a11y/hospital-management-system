-- 06_joins_and_aggregations.sql
SET search_path TO hospital, public;

-- INTERMEDIATE

-- 1. Patients per department based on completed appointments
SELECT dep.department_name, COUNT(DISTINCT a.patient_id) AS patient_count
FROM departments dep
LEFT JOIN doctors d ON d.department_id = dep.department_id
LEFT JOIN appointments a ON a.doctor_id = d.doctor_id AND a.status = 'Completed'
GROUP BY dep.department_id, dep.department_name
ORDER BY patient_count DESC;

-- 2. Appointment count per doctor
SELECT d.doctor_id, d.first_name || ' ' || d.last_name AS doctor_name,
       COUNT(a.appointment_id) AS appointment_count
FROM doctors d
LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, doctor_name
ORDER BY appointment_count DESC;

-- 3. Total billed revenue
SELECT SUM(total_amount) AS total_billed
FROM bills
WHERE status <> 'Cancelled';

-- 4. Monthly billed revenue
SELECT DATE_TRUNC('month', bill_date)::date AS month,
       SUM(total_amount) AS revenue
FROM bills
WHERE status <> 'Cancelled'
GROUP BY 1
ORDER BY 1;

-- 5. Average bill
SELECT ROUND(AVG(total_amount),2) AS average_bill
FROM bills
WHERE status <> 'Cancelled';

-- 6. Most frequently prescribed medicines
SELECT m.medicine_name, COUNT(*) AS prescription_count,
       SUM(pi.quantity) AS units_prescribed
FROM medicines m
JOIN prescription_items pi ON pi.medicine_id = m.medicine_id
GROUP BY m.medicine_id, m.medicine_name
ORDER BY prescription_count DESC, units_prescribed DESC;

-- 7. Patients with unpaid or partially paid bills
SELECT p.patient_id, p.first_name || ' ' || p.last_name AS patient_name,
       SUM(b.total_amount - b.paid_amount) AS outstanding
FROM patients p
JOIN bills b ON b.patient_id = p.patient_id
WHERE b.status IN ('Unpaid','Partially Paid')
GROUP BY p.patient_id, patient_name
ORDER BY outstanding DESC;

-- 8. Doctors with highest appointment count
SELECT d.first_name || ' ' || d.last_name AS doctor_name,
       dep.department_name, COUNT(*) AS appointments
FROM doctors d
JOIN departments dep ON dep.department_id = d.department_id
JOIN appointments a ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, doctor_name, dep.department_name
ORDER BY appointments DESC
LIMIT 10;

-- 9. Departments by billed revenue
SELECT dep.department_name, COALESCE(SUM(b.total_amount),0) AS billed_revenue
FROM departments dep
LEFT JOIN doctors d ON d.department_id = dep.department_id
LEFT JOIN bills b ON b.doctor_id = d.doctor_id
GROUP BY dep.department_id, dep.department_name
ORDER BY billed_revenue DESC;

-- 10. Patients with multiple appointments
SELECT patient_id, COUNT(*) AS appointment_count
FROM appointments
GROUP BY patient_id
HAVING COUNT(*) > 1
ORDER BY appointment_count DESC;

-- 11. Currently admitted patients
SELECT a.admission_id, p.first_name || ' ' || p.last_name AS patient_name,
       r.room_number, a.admission_date, a.status
FROM admissions a
JOIN patients p ON p.patient_id = a.patient_id
LEFT JOIN rooms r ON r.room_id = a.room_id
WHERE a.discharge_date IS NULL
ORDER BY a.admission_date;

-- 12. Doctors with no appointments
SELECT d.doctor_id, d.first_name || ' ' || d.last_name AS doctor_name
FROM doctors d
LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
WHERE a.appointment_id IS NULL;

-- 13. Patients whose expenses exceed average patient expense
WITH patient_expenses AS (
    SELECT patient_id, SUM(total_amount) AS total_expense
    FROM bills
    WHERE status <> 'Cancelled'
    GROUP BY patient_id
)
SELECT p.patient_id, p.first_name || ' ' || p.last_name AS patient_name,
       pe.total_expense
FROM patient_expenses pe
JOIN patients p ON p.patient_id = pe.patient_id
WHERE pe.total_expense > (SELECT AVG(total_expense) FROM patient_expenses)
ORDER BY pe.total_expense DESC;

-- 14. Most common lab tests
SELECT lt.test_name, COUNT(*) AS test_count
FROM lab_tests lt
JOIN lab_results lr ON lr.lab_test_id = lt.lab_test_id
GROUP BY lt.lab_test_id, lt.test_name
ORDER BY test_count DESC;

-- 15. Average hospital stay in days
SELECT ROUND(AVG(discharge_date - admission_date),2) AS average_stay_days
FROM admissions
WHERE discharge_date IS NOT NULL;

-- 16. Revenue by payment method
SELECT payment_method, SUM(amount) AS collected_amount, COUNT(*) AS transactions
FROM payments
WHERE status = 'Completed'
GROUP BY payment_method
ORDER BY collected_amount DESC;

-- 17. Appointment status distribution
SELECT status, COUNT(*) AS appointment_count
FROM appointments
GROUP BY status
ORDER BY appointment_count DESC;

-- 18. Department appointment workload
SELECT dep.department_name,
       COUNT(a.appointment_id) AS appointments,
       ROUND(AVG(d.consultation_fee),2) AS avg_consultation_fee
FROM departments dep
LEFT JOIN doctors d ON d.department_id = dep.department_id
LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
GROUP BY dep.department_id, dep.department_name
ORDER BY appointments DESC;

-- 19. Patients with at least one abnormal lab result
SELECT DISTINCT p.patient_id, p.first_name || ' ' || p.last_name AS patient_name
FROM patients p
JOIN lab_results lr ON lr.patient_id = p.patient_id
WHERE lr.result_status = 'Abnormal'
ORDER BY p.patient_id;

-- 20. Admission count by room type
SELECT r.room_type, COUNT(*) AS admissions
FROM admissions a
JOIN rooms r ON r.room_id = a.room_id
GROUP BY r.room_type
ORDER BY admissions DESC;
