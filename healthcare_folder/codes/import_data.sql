-- 1. Tạo một schema mới để chứa các bảng hệ thống Y tế này
CREATE SCHEMA IF NOT EXISTS h_care;

-- 2. Đặt schema h_care làm mặc định cho phiên làm việc hiện tại (để viết code gọn hơn)
SET search_path TO h_care, public;

-- Tạo bảng Phòng ban (departments)
CREATE TABLE h_care.departments (
    department_id INTEGER PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);

-- Tạo bảng Bệnh nhân (patients)
-- (Dựa trên cấu trúc chuẩn của ERD gồm: id, tên, họ, ngày sinh, và phần mở rộng thông thường)
CREATE TABLE h_care.patients (
    patient_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10),
    phone VARCHAR(20)
);
-- Tạo bảng Bác sĩ (doctors) - Tham chiếu tới bảng departments
CREATE TABLE h_care.doctors (
    doctor_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialty VARCHAR(100),
    department_id INTEGER,
    hire_date DATE,
    CONSTRAINT fk_doctor_department FOREIGN KEY (department_id) REFERENCES h_care.departments(department_id)
);

-- Tạo bảng Cuộc hẹn (appointments) - Tham chiếu tới cả patients và doctors
CREATE TABLE h_care.appointments (
    appointment_id INTEGER PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    appointment_date DATE NOT NULL,
    status VARCHAR(20),
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES h_care.patients(patient_id),
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES h_care.doctors(doctor_id)
);

-- Tạo bảng Chẩn đoán (diagnoses) - Tham chiếu tới cả patients và doctors
CREATE TABLE h_care.diagnoses (
    diagnosis_id INTEGER PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    condition_name VARCHAR(200) NOT NULL,
    diagnosis_date DATE,
    CONSTRAINT fk_diagnosis_patient FOREIGN KEY (patient_id) REFERENCES h_care.patients(patient_id),
    CONSTRAINT fk_diagnosis_doctor FOREIGN KEY (doctor_id) REFERENCES h_care.doctors(doctor_id)
);


select *from h_care.departments;
select *from h_care.patients;
select *from h_care.doctors;
select *from h_care.appointments;
select *from h_care.diagnoses;

