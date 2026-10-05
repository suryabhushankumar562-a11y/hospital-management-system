-- 05_basic_queries.sql
SET search_path TO hospital, public;

-- BASIC: 1. List patients
SELECT patient_id, first_name, last_name, city, blood_group
FROM patients
ORDER BY patient_id;

-- 2. Patients from a city
SELECT *
FROM patients
WHERE city = 'Lucknow'
ORDER BY last_name, first_name;

-- 3. Doctors with department
SELECT d.doctor_id, d.first_name, d.last_name, d.specialization, dep.department_name
FROM doctors d
JOIN departments dep ON dep.department_id = d.department_id
ORDER BY dep.department_name, d.last_name;

-- 4. Available rooms
SELECT room_number, room_type, floor_number, daily_rate
FROM rooms
WHERE is_available = TRUE
ORDER BY daily_rate;

-- 5. Appointments on a date
SELECT *
FROM appointments
WHERE appointment_date::date = DATE '2026-06-01'
ORDER BY appointment_date;

-- 6. Doctors by experience
SELECT doctor_id, first_name, last_name, experience_years
FROM doctors
ORDER BY experience_years DESC;

-- 7. Bills above a threshold
SELECT bill_id, patient_id, bill_date, total_amount, status
FROM bills
WHERE total_amount > 10000
ORDER BY total_amount DESC;

-- 8. Scheduled appointments
SELECT appointment_id, patient_id, doctor_id, appointment_date
FROM appointments
WHERE status = 'Scheduled'
ORDER BY appointment_date;

-- 9. Active insurance policies
SELECT patient_id, provider_name, plan_name, coverage_percent, coverage_limit
FROM insurance
WHERE is_active = TRUE
ORDER BY coverage_percent DESC;

-- 10. Medicines below reorder level
SELECT medicine_id, medicine_name, stock_quantity, reorder_level
FROM medicines
WHERE stock_quantity <= reorder_level
ORDER BY stock_quantity;
