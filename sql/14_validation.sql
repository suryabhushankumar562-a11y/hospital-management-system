-- 14_validation.sql
-- Optional final verification script.
SET search_path TO hospital, public;

SELECT 'departments' AS table_name, COUNT(*) AS rows FROM departments
UNION ALL SELECT 'patients', COUNT(*) FROM patients
UNION ALL SELECT 'doctors', COUNT(*) FROM doctors
UNION ALL SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL SELECT 'admissions', COUNT(*) FROM admissions
UNION ALL SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL SELECT 'medicines', COUNT(*) FROM medicines
UNION ALL SELECT 'prescriptions', COUNT(*) FROM prescriptions
UNION ALL SELECT 'prescription_items', COUNT(*) FROM prescription_items
UNION ALL SELECT 'lab_results', COUNT(*) FROM lab_results
UNION ALL SELECT 'bills', COUNT(*) FROM bills
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'insurance', COUNT(*) FROM insurance
ORDER BY table_name;

-- Foreign-key sanity checks
SELECT COUNT(*) AS orphan_appointments
FROM appointments a
LEFT JOIN patients p ON p.patient_id = a.patient_id
LEFT JOIN doctors d ON d.doctor_id = a.doctor_id
WHERE p.patient_id IS NULL OR d.doctor_id IS NULL;

SELECT COUNT(*) AS orphan_payment_bills
FROM payments py
LEFT JOIN bills b ON b.bill_id = py.bill_id
WHERE b.bill_id IS NULL;
