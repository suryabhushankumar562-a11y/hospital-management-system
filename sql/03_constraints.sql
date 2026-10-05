-- 03_constraints.sql
SET search_path TO hospital, public;

ALTER TABLE patients
    ADD CONSTRAINT chk_patient_gender
    CHECK (gender IN ('Male', 'Female', 'Other')),
    ADD CONSTRAINT chk_patient_blood_group
    CHECK (blood_group IS NULL OR blood_group IN
        ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'));

ALTER TABLE doctors
    ADD CONSTRAINT chk_doctor_experience CHECK (experience_years BETWEEN 0 AND 60),
    ADD CONSTRAINT chk_doctor_fee CHECK (consultation_fee >= 0);

ALTER TABLE appointments
    ADD CONSTRAINT chk_appointment_status
    CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'No Show')),
    ADD CONSTRAINT uq_doctor_appointment_slot UNIQUE (doctor_id, appointment_date);

ALTER TABLE rooms
    ADD CONSTRAINT chk_room_type
    CHECK (room_type IN ('General', 'Semi-Private', 'Private', 'ICU')),
    ADD CONSTRAINT chk_room_floor CHECK (floor_number BETWEEN 0 AND 50),
    ADD CONSTRAINT chk_room_rate CHECK (daily_rate >= 0);

ALTER TABLE admissions
    ADD CONSTRAINT chk_admission_status
    CHECK (status IN ('Admitted', 'Discharged', 'Transferred', 'Cancelled')),
    ADD CONSTRAINT chk_admission_dates
    CHECK (discharge_date IS NULL OR discharge_date >= admission_date);

ALTER TABLE medicines
    ADD CONSTRAINT chk_medicine_price CHECK (unit_price >= 0),
    ADD CONSTRAINT chk_stock CHECK (stock_quantity >= 0),
    ADD CONSTRAINT chk_reorder_level CHECK (reorder_level >= 0);

ALTER TABLE prescription_items
    ADD CONSTRAINT chk_prescription_duration CHECK (duration_days > 0),
    ADD CONSTRAINT chk_prescription_quantity CHECK (quantity > 0),
    ADD CONSTRAINT chk_prescription_unit_price CHECK (unit_price >= 0);

ALTER TABLE lab_tests
    ADD CONSTRAINT chk_lab_price CHECK (standard_price >= 0),
    ADD CONSTRAINT chk_turnaround CHECK (turnaround_hours > 0);

ALTER TABLE lab_results
    ADD CONSTRAINT chk_lab_result_status
    CHECK (result_status IN ('Pending', 'Completed', 'Abnormal', 'Cancelled'));

ALTER TABLE insurance
    ADD CONSTRAINT chk_coverage_percent CHECK (coverage_percent BETWEEN 0 AND 100),
    ADD CONSTRAINT chk_coverage_limit CHECK (coverage_limit >= 0),
    ADD CONSTRAINT chk_insurance_dates CHECK (valid_until >= valid_from);

ALTER TABLE bills
    ADD CONSTRAINT chk_bill_amounts
    CHECK (
        subtotal >= 0 AND discount_amount >= 0 AND
        insurance_covered_amount >= 0 AND tax_amount >= 0 AND
        total_amount >= 0 AND paid_amount >= 0 AND
        discount_amount <= subtotal AND
        insurance_covered_amount <= (subtotal - discount_amount + tax_amount) AND
        paid_amount <= total_amount
    ),
    ADD CONSTRAINT chk_bill_status
    CHECK (status IN ('Unpaid', 'Partially Paid', 'Paid', 'Cancelled'));

ALTER TABLE payments
    ADD CONSTRAINT chk_payment_amount CHECK (amount > 0),
    ADD CONSTRAINT chk_payment_status CHECK (status IN ('Completed', 'Failed', 'Refunded')),
    ADD CONSTRAINT uq_payment_reference UNIQUE (transaction_reference);

CREATE INDEX IF NOT EXISTS idx_doctors_department ON doctors(department_id);
CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_admissions_patient ON admissions(patient_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_prescription_items_prescription ON prescription_items(prescription_id);
CREATE INDEX IF NOT EXISTS idx_lab_results_patient ON lab_results(patient_id);
CREATE INDEX IF NOT EXISTS idx_bills_patient ON bills(patient_id);
CREATE INDEX IF NOT EXISTS idx_payments_bill ON payments(bill_id);
