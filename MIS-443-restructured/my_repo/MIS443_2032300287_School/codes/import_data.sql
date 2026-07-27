
create schema sch;

create table sch.students (
	student_id INTEGER PRIMARY KEY, 
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR (100) UNIQUE NOT NULL
);


create table sch.professors (
	professor_id INTEGER PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR (100) NOT NULL,
	department VARCHAR(100) NOT NULL,
	hire_date DATE NOT NULL
);

create table sch.courses (
	course_id INTEGER PRIMARY KEY,
	course_name VARCHAR(100) NOT NULL,
	credits INTEGER NOT NULL,
	department VARCHAR(100) NOT NULL,
	professor_id INTEGER,
	CONSTRAINT fk_professor FOREIGN KEY (professor_id) REFERENCES sch.professors(professor_id)  
);


create table sch.enrollments (
	enrollment_id INTEGER NOT NULL,
	student_id INTEGER NOT NULL,
	course_id INTEGER NOT NULL,
	semeter VARCHAR(20) NOT NULL, 

CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES sch.students(student_id),
CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES sch.courses(course_id)
);

select *from sch.professors;

DROP TABLE public.students;

-- 1. Xóa bảng cũ đang bị sai kiểu dữ liệu
DROP TABLE IF EXISTS sch.courses CASCADE;
-- 2. Tạo lại bảng với kiểu dữ liệu VARCHAR phù hợp với file CSV
CREATE TABLE sch.courses (
    course_id VARCHAR(10) PRIMARY KEY, -- Thay đổi từ INTEGER sang VARCHAR
    course_name VARCHAR(100) NOT NULL,
    credits INTEGER NOT NULL,
    department VARCHAR(100) NOT NULL,
    professor_id INTEGER,
    CONSTRAINT fk_professor FOREIGN KEY (professor_id) REFERENCES sch.professors(professor_id)
);
select *from sch.courses;

-- 1. Xóa bảng cũ cấu trúc thiếu
DROP TABLE IF EXISTS sch.students CASCADE;

-- 2. Tạo lại bảng với đầy đủ 7 cột theo file CSV
CREATE TABLE sch.students (
    student_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    enrollment_date DATE,          -- Cột mới thêm
    graduation_year INTEGER,       -- Cột mới thêm
    major VARCHAR(100)             -- Cột mới thêm
);

-- 1. Đổi kiểu dữ liệu cột sang TEXT để nhận mọi định dạng chuỗi từ CSV
ALTER TABLE sch.students ALTER COLUMN enrollment_date TYPE TEXT;

-- 2. Chạy lệnh copy dữ liệu trực tiếp từ file (Bạn sửa lại đường dẫn ổ D nếu cần)
COPY sch.students(student_id, first_name, last_name, email, enrollment_date, graduation_year, major)
FROM 'D:/students.csv'
DELIMITER ','
CSV HEADER;

-- 3. Ép kiểu cột đó về lại DATE theo đúng định dạng Tháng/Ngày/Năm (MM/DD/YYYY) của file
ALTER TABLE sch.students 
ALTER COLUMN enrollment_date TYPE DATE USING to_date(enrollment_date, 'MM/DD/YYYY');
select *from sch.students;

-- 1. Xóa bảng cũ cấu trúc sai đi
DROP TABLE IF EXISTS sch.enrollments CASCADE; ---CASECADE xóa không quan tâm đã có relationship

-- 2. Tạo lại bảng với cấu trúc chuẩn chỉnh khớp với file CSV
CREATE TABLE sch.enrollments (
    enrollment_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id VARCHAR(10) NOT NULL,    -- Sửa từ INTEGER thành VARCHAR(10) để đồng bộ
    semester VARCHAR(20) NOT NULL,     -- Sửa lại lỗi chính tả (semester)
    year INTEGER NOT NULL,             -- Cột còn thiếu trong file CSV
    grade VARCHAR(5),                  -- Cột còn thiếu trong file CSV
    
    -- Tạo các khóa ngoại liên kết bảng
    CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES sch.students(student_id),
    CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES sch.courses(course_id)
);

COPY sch.enrollments(enrollment_id, student_id, course_id, semester, year, grade) 
FROM 'D:/enrollments.csv' 
DELIMITER ',' 
CSV HEADER;
select *from sch.enrollments;

-- 1. Xóa bảng cũ cấu trúc thiếu
DROP TABLE IF EXISTS sch.students CASCADE;

-- 2. Tạo lại bảng với đầy đủ 7 cột theo file CSV
CREATE TABLE sch.students (
    student_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    enrollment_date DATE,          -- Cột mới thêm
    graduation_year INTEGER,       -- Cột mới thêm
    major VARCHAR(100)             -- Cột mới thêm
);

-- 1. Đổi kiểu dữ liệu cột sang TEXT để nhận mọi định dạng chuỗi từ CSV
ALTER TABLE sch.students ALTER COLUMN enrollment_date TYPE TEXT;

-- 2. Chạy lệnh copy dữ liệu trực tiếp từ file (Bạn sửa lại đường dẫn ổ D nếu cần)
COPY sch.students(student_id, first_name, last_name, email, enrollment_date, graduation_year, major)
FROM 'D:/students.csv'
DELIMITER ','
CSV HEADER;

-- 3. Ép kiểu cột đó về lại DATE theo đúng định dạng Tháng/Ngày/Năm (MM/DD/YYYY) của file
ALTER TABLE sch.students 
ALTER COLUMN enrollment_date TYPE DATE USING to_date(enrollment_date, 'MM/DD/YYYY');
select *from sch.students;


