# MIS443 - Healthcare Database Project

**Course:** MIS 443 - Business Data Management
**Institution:** Eastern International University (EIU)
**Student:** Đặng Huỳnh Quỳnh Như - 2032300287
**Major:** Business Analytics

## Project Description

This project implements a relational database for a healthcare / clinic environment using **PostgreSQL** and **pgAdmin 4**. The **Healthcare Database** (schema `h_care`) centralizes core operational entities — **Departments, Patients, Doctors, Appointments, and Diagnoses** — supporting use cases such as physician rostering, appointment scheduling, diagnosis tracking, and staffing/capacity analysis.

## Tools Used

- PostgreSQL (database engine)
- pgAdmin 4 (database creation, ERD design, and query execution)
- pgAdmin ERD Tool (schema diagram)
- GitHub (project publication)

## Folder Structure

```
MIS443_2032300287_Healthcare/
│
├── codes/
│   ├── import_data.sql
│   └── exercise.sql
│
├── report/
│   └── ERD.pgerd
│
└── README.md
```

## Database Architecture & Schema Design

The schema `h_care` contains 5 tables:

1. **`h_care.departments`**: Department names and physical locations.
2. **`h_care.patients`**: Patient profiles — name, date of birth, gender, and phone contact.
3. **`h_care.doctors`**: Physician records, including specialty, hire date, and assigned department.
4. **`h_care.appointments`**: Appointment records linking a patient and a doctor, with date and status (e.g. Scheduled, Completed).
5. **`h_care.diagnoses`**: Diagnosis records linking a patient and a doctor, with condition name and diagnosis date.

### Relationships

- **Departments ➔ Doctors (1:N):** One department can have multiple doctors.
- **Doctors ➔ Appointments (1:N)** and **Patients ➔ Appointments (1:N):** Each appointment links one doctor to one patient.
- **Doctors ➔ Diagnoses (1:N)** and **Patients ➔ Diagnoses (1:N):** Each diagnosis links one doctor to one patient.

The full entity-relationship diagram is in `report/ERD.pgerd` — a pgAdmin ERD Tool project file. Open it in pgAdmin 4 via **Tools → ERD Tool → Open** to view/edit the diagram (it isn't a plain image file).

## How to Run

1. Open pgAdmin 4 and connect to your local PostgreSQL server.
2. Run `codes/import_data.sql` to create the `h_care` schema, all 5 tables with their relationships, and preview the data.
3. Run `codes/exercise.sql` to execute the SQL practice questions (30 business-driven queries covering filtering, aggregation, joins, subqueries, and window functions) and review the results.

## GitHub Repository

https://github.com/NhuqDangg/MIS-443---Business-Data-Management/tree/main/MIS443_2032300287_Healthcare
