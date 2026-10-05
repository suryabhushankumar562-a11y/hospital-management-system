-- 04_insert_data.sql
-- Deterministic fictional data. The use of generate_series keeps this portfolio
-- project compact while producing enough rows for meaningful analytics.
SET search_path TO hospital, public;

BEGIN;

INSERT INTO departments (department_name, location, phone_extension)
VALUES
('Cardiology','Block A - 2nd Floor','2101'),
('Neurology','Block A - 3rd Floor','2201'),
('Orthopedics','Block B - 2nd Floor','2301'),
('Pediatrics','Block B - 1st Floor','2401'),
('General Medicine','Block A - 1st Floor','2501'),
('Dermatology','Block C - 1st Floor','2601'),
('Gastroenterology','Block C - 2nd Floor','2701'),
('Emergency Medicine','Block E - Ground Floor','2801');

INSERT INTO patients
(first_name,last_name,date_of_birth,gender,phone,email,city,blood_group,emergency_contact_name,emergency_contact_phone)
SELECT
    (ARRAY['Aarav','Vivaan','Aditya','Arjun','Kabir','Rohan','Ishaan','Krish','Rahul','Nikhil','Ananya','Diya','Ira','Meera','Aditi','Kavya','Pihu','Sara','Tanya','Riya'])[((g-1)%20)+1],
    (ARRAY['Sharma','Verma','Gupta','Singh','Yadav','Mishra','Khan','Patel','Jain','Mehta'])[((g-1)%10)+1],
    DATE '1960-01-01' + ((g * 731) % 20000),
    (ARRAY['Male','Female','Male','Female','Male','Female','Other'])[((g-1)%7)+1],
    '90000' || LPAD(g::text,6,'0'),
    'patient' || g || '@example.test',
    (ARRAY['Lucknow','Kanpur','Gorakhpur','Prayagraj','Varanasi','Jaipur','Agra','Noida'])[((g-1)%8)+1],
    (ARRAY['A+','B+','O+','AB+','A-','B-','O-','AB-'])[((g-1)%8)+1],
    'Emergency Contact ' || g,
    '91000' || LPAD(g::text,6,'0')
FROM generate_series(1,60) AS s(g);

INSERT INTO doctors
(department_id,first_name,last_name,specialization,license_number,experience_years,consultation_fee,phone,email)
SELECT
    ((g-1)%8)+1,
    (ARRAY['Vikram','Neha','Sanjay','Pooja','Manish','Kiran','Amit','Sneha','Rajiv','Nandini','Deepak','Ritu','Anil','Shreya','Suresh','Priya','Mohit','Anita'])[((g-1)%18)+1],
    (ARRAY['Kapoor','Malhotra','Bansal','Tiwari','Saxena','Chauhan','Agarwal','Srivastava','Joshi','Pandey'])[((g-1)%10)+1],
    (ARRAY['Interventional Cardiology','Clinical Neurology','Joint Replacement','Child Medicine','Internal Medicine','Clinical Dermatology','Digestive Diseases','Emergency Care'])[((g-1)%8)+1],
    'LIC-' || LPAD(g::text,5,'0'),
    3 + ((g*3)%25),
    700 + ((g*137)%1100),
    '88000' || LPAD(g::text,6,'0'),
    'doctor' || g || '@example.test'
FROM generate_series(1,18) AS s(g);

INSERT INTO rooms (room_number,room_type,floor_number,daily_rate,is_available)
SELECT
    'R-' || LPAD(g::text,3,'0'),
    CASE
        WHEN g <= 8 THEN 'General'
        WHEN g <= 14 THEN 'Semi-Private'
        WHEN g <= 20 THEN 'Private'
        ELSE 'ICU'
    END,
    CASE WHEN g <= 8 THEN 1 WHEN g <= 14 THEN 2 WHEN g <= 20 THEN 3 ELSE 4 END,
    CASE
        WHEN g <= 8 THEN 1800
        WHEN g <= 14 THEN 3000
        WHEN g <= 20 THEN 4800
        ELSE 8500
    END,
    CASE WHEN g % 5 = 0 THEN FALSE ELSE TRUE END
FROM generate_series(1,24) AS s(g);

INSERT INTO medicines (medicine_name,category,unit_price,stock_quantity,reorder_level)
SELECT
    (ARRAY['Paracetamol','Amoxicillin','Azithromycin','Metformin','Atorvastatin','Amlodipine','Pantoprazole','Cetirizine','Ibuprofen','Omeprazole',
           'Losartan','Insulin Regular','Levothyroxine','Doxycycline','Montelukast','Diclofenac','ORS Sachet','Calcium Carbonate','Vitamin D3','Aspirin',
           'Clopidogrel','Salbutamol','Ondansetron','Domperidone','Cefixime','Prednisolone','Gabapentin','Folic Acid','Iron Supplement','Loratadine',
           'Ranitidine Alternative','Budesonide','Rifaximin','Lactulose','Mupirocin','Hydrocortisone','Ketoconazole','Tramadol','Heparin','Enoxaparin'])[((g-1)%40)+1],
      
    (ARRAY['Analgesic','Antibiotic','Cardiac','Diabetes','Gastro','Allergy','Respiratory','Supplement'])[((g-1)%8)+1],
    ROUND((25 + ((g*17)%475))::numeric,2),
    30 + ((g*47)%500),
    20 + ((g*3)%40)
FROM generate_series(1,40) AS s(g);

INSERT INTO lab_tests (test_name,category,standard_price,turnaround_hours)
VALUES
('Complete Blood Count','Hematology',450,8),
('Lipid Profile','Biochemistry',800,12),
('Liver Function Test','Biochemistry',950,18),
('Kidney Function Test','Biochemistry',900,18),
('HbA1c','Diabetes',650,12),
('Thyroid Profile','Endocrinology',850,18),
('Urine Routine','Pathology',250,6),
('Chest X-Ray','Radiology',700,6),
('ECG','Cardiology',500,2),
('Ultrasound Abdomen','Radiology',1400,24),
('CT Head','Radiology',4200,24),
('MRI Brain','Radiology',8500,48),
('Vitamin D','Biochemistry',1200,24),
('CRP','Immunology',700,10),
('Blood Culture','Microbiology',1100,72);

INSERT INTO appointments (patient_id,doctor_id,appointment_date,status,reason,notes)
SELECT
    ((g-1)%60)+1,
    ((g-1)%18)+1,
    TIMESTAMP '2026-01-05 09:00:00'
      + ((g*2)%260) * INTERVAL '1 day'
      + ((g%8)*INTERVAL '1 hour'),
    CASE
        WHEN g%13=0 THEN 'Cancelled'
        WHEN g%11=0 THEN 'No Show'
        WHEN g%5=0 THEN 'Scheduled'
        ELSE 'Completed'
    END,
    (ARRAY['Routine consultation','Follow-up','Fever','Chest discomfort','Joint pain','Skin rash','Abdominal pain','Headache'])[((g-1)%8)+1],
    CASE WHEN g%7=0 THEN 'Follow-up recommended' ELSE NULL END
FROM generate_series(1,150) AS s(g);

INSERT INTO admissions
(patient_id,room_id,attending_doctor_id,admission_date,discharge_date,admission_reason,status)
SELECT
    ((g-1)%60)+1,
    ((g-1)%24)+1,
    ((g-1)%18)+1,
    DATE '2026-01-10' + ((g*3)%260),
    CASE
        WHEN g%7=0 THEN NULL
        ELSE DATE '2026-01-10' + ((g*3)%260) + (1 + (g%9))
    END,
    (ARRAY['Observation','Infection','Cardiac monitoring','Fracture management','Dehydration','Neurological evaluation','Gastrointestinal condition'])[((g-1)%7)+1],
    CASE WHEN g%7=0 THEN 'Admitted' ELSE 'Discharged' END
FROM generate_series(1,70) AS s(g);

INSERT INTO prescriptions (patient_id,doctor_id,prescription_date,diagnosis,notes)
SELECT
    ((g-1)%60)+1,
    ((g-1)%18)+1,
    DATE '2026-01-08' + ((g*2)%260),
    (ARRAY['Hypertension','Acute infection','Gastritis','Diabetes follow-up','Allergic symptoms','Pain management','Vitamin deficiency','Respiratory symptoms'])[((g-1)%8)+1],
    CASE WHEN g%6=0 THEN 'Review after 7 days' ELSE NULL END
FROM generate_series(1,120) AS s(g);

INSERT INTO prescription_items
(prescription_id,medicine_id,dosage,frequency,duration_days,quantity,unit_price)
SELECT
    g,
    ((g-1)%40)+1,
    CASE WHEN g%3=0 THEN '1 tablet' ELSE '1 capsule' END,
    CASE WHEN g%4=0 THEN 'Once daily' WHEN g%2=0 THEN 'Twice daily' ELSE 'Three times daily' END,
    3 + (g%12),
    6 + ((g*2)%30),
    m.unit_price
FROM generate_series(1,120) AS s(g)
JOIN medicines m ON m.medicine_id = ((g-1)%40)+1;

INSERT INTO lab_results
(patient_id,doctor_id,lab_test_id,ordered_at,result_date,result_value,unit,reference_range,result_status,notes)
SELECT
    ((g-1)%60)+1,
    ((g-1)%18)+1,
    ((g-1)%15)+1,
    TIMESTAMP '2026-01-05 08:00:00' + ((g*3)%260)*INTERVAL '1 day',
    TIMESTAMP '2026-01-05 08:00:00' + ((g*3)%260)*INTERVAL '1 day' + INTERVAL '12 hours',
    CASE WHEN g%9=0 THEN 'Above reference' ELSE (60 + ((g*17)%140))::text END,
    CASE WHEN g%2=0 THEN 'mg/dL' ELSE 'units' END,
    'Reference varies by test',
    CASE WHEN g%9=0 THEN 'Abnormal' ELSE 'Completed' END,
    CASE WHEN g%9=0 THEN 'Clinical review recommended' ELSE NULL END
FROM generate_series(1,100) AS s(g);

INSERT INTO insurance
(patient_id,provider_name,policy_number,plan_name,coverage_percent,coverage_limit,valid_from,valid_until,is_active)
SELECT
    g,
    (ARRAY['SecureCare Health','MediShield Services','Prime Health Assurance','WellLife Insurance'])[((g-1)%4)+1],
    'POL-2026-' || LPAD(g::text,5,'0'),
    (ARRAY['Essential','Silver','Gold','Family Plus'])[((g-1)%4)+1],
    50 + ((g*7)%46),
    50000 + ((g*1750)%150000),
    DATE '2026-01-01',
    DATE '2026-12-31',
    TRUE
FROM generate_series(1,60) AS s(g);

-- Bills are generated from realistic service categories. Some bills are fully paid,
-- some partially paid, and some unpaid.
INSERT INTO bills
(patient_id,doctor_id,admission_id,bill_date,subtotal,discount_amount,insurance_covered_amount,tax_amount,total_amount,paid_amount,status,description)
SELECT
    ((g-1)%60)+1,
    ((g-1)%18)+1,
    CASE WHEN g%3=0 THEN ((g-1)%70)+1 ELSE NULL END,
    DATE '2026-01-12' + ((g*4)%260),
    subtotal,
    discount,
    insurance_cover,
    tax,
    total,
    0,
    'Unpaid',
    CASE WHEN g%3=0 THEN 'Inpatient and diagnostic services' ELSE 'Outpatient services' END
FROM (
    SELECT
        g,
        ROUND((1200 + ((g*613)%14500))::numeric,2) AS subtotal,
        ROUND((50 + ((g*37)%600))::numeric,2) AS discount,
        ROUND(
            LEAST(
                (g%4 * 500)::numeric,
                (1200 + ((g*613)%14500))::numeric
                  - (50 + ((g*37)%600))::numeric
                  + (80 + ((g*29)%700))::numeric
            ), 2
        ) AS insurance_cover,
        ROUND((80 + ((g*29)%700))::numeric,2) AS tax
    FROM generate_series(1,100) AS s(g)
) x
CROSS JOIN LATERAL (
    SELECT
        ROUND(GREATEST(0, subtotal - discount - insurance_cover + tax)::numeric,2) AS total
) t;

INSERT INTO payments
(bill_id,payment_date,amount,payment_method,transaction_reference,status)
SELECT
    b.bill_id,
    b.bill_date + ((ROW_NUMBER() OVER (ORDER BY b.bill_id)::integer % 20)+1)*INTERVAL '1 day',
    CASE
        WHEN b.bill_id % 4 = 0 THEN b.total_amount
        WHEN b.bill_id % 4 = 1 THEN ROUND(b.total_amount/2,2)
        ELSE 100
    END,
    (ARRAY['Cash','Card','UPI','Bank Transfer'])[((b.bill_id-1)%4)+1],
    'TXN-2026-' || LPAD(b.bill_id::text,6,'0'),
    'Completed'
FROM bills b
WHERE b.bill_id % 4 IN (0,1);

COMMIT;

ANALYZE;

