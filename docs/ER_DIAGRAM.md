# ER Diagram

Copy the Mermaid block below into a Mermaid-enabled Markdown viewer.

```mermaid
erDiagram
    DEPARTMENTS ||--o{ DOCTORS : has
    PATIENTS ||--o{ APPOINTMENTS : books
    DOCTORS ||--o{ APPOINTMENTS : handles
    PATIENTS ||--o{ ADMISSIONS : has
    ROOMS ||--o{ ADMISSIONS : assigned
    DOCTORS ||--o{ ADMISSIONS : attends
    PATIENTS ||--o{ PRESCRIPTIONS : receives
    DOCTORS ||--o{ PRESCRIPTIONS : writes
    PRESCRIPTIONS ||--o{ PRESCRIPTION_ITEMS : contains
    MEDICINES ||--o{ PRESCRIPTION_ITEMS : appears_in
    PATIENTS ||--o{ LAB_RESULTS : receives
    DOCTORS ||--o{ LAB_RESULTS : orders
    LAB_TESTS ||--o{ LAB_RESULTS : produces
    PATIENTS ||--o{ BILLS : owns
    ADMISSIONS ||--o{ BILLS : may_generate
    BILLS ||--o{ PAYMENTS : receives
    PATIENTS ||--o{ INSURANCE : owns

    DEPARTMENTS {
        bigint department_id PK
        varchar department_name UK
        varchar location
    }
    PATIENTS {
        bigint patient_id PK
        varchar email UK
        date date_of_birth
        varchar gender
    }
    DOCTORS {
        bigint doctor_id PK
        bigint department_id FK
        varchar license_number UK
        varchar specialization
    }
    APPOINTMENTS {
        bigint appointment_id PK
        bigint patient_id FK
        bigint doctor_id FK
        timestamp appointment_date
    }
    ROOMS {
        bigint room_id PK
        varchar room_number UK
        varchar room_type
    }
    ADMISSIONS {
        bigint admission_id PK
        bigint patient_id FK
        bigint room_id FK
        bigint attending_doctor_id FK
        date admission_date
        date discharge_date
    }
    PRESCRIPTIONS {
        bigint prescription_id PK
        bigint patient_id FK
        bigint doctor_id FK
        date prescription_date
    }
    MEDICINES {
        bigint medicine_id PK
        varchar medicine_name UK
        numeric unit_price
    }
    PRESCRIPTION_ITEMS {
        bigint prescription_item_id PK
        bigint prescription_id FK
        bigint medicine_id FK
        integer quantity
    }
    LAB_TESTS {
        bigint lab_test_id PK
        varchar test_name UK
        numeric standard_price
    }
    LAB_RESULTS {
        bigint lab_result_id PK
        bigint patient_id FK
        bigint doctor_id FK
        bigint lab_test_id FK
        timestamp ordered_at
        timestamp result_date
    }
    INSURANCE {
        bigint insurance_id PK
        bigint patient_id FK
        varchar policy_number UK
        numeric coverage_percent
    }
    BILLS {
        bigint bill_id PK
        bigint patient_id FK
        bigint admission_id FK
        numeric total_amount
        numeric paid_amount
        varchar status
    }
    PAYMENTS {
        bigint payment_id PK
        bigint bill_id FK
        numeric amount
        timestamp payment_date
    }
```

## Relationship Notes

- A department has many doctors; each doctor belongs to one department.
- A patient can have many appointments; each appointment is handled by one doctor.
- Admissions optionally reference a room because a room assignment can change or be unavailable.
- Prescriptions and medicines form a many-to-many relationship through `prescription_items`.
- A bill can have multiple payments.
- A patient can have an insurance policy in this demo model; a production claims model would usually separate policy enrollment and claims.
