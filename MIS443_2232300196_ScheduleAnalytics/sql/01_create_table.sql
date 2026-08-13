-- ═══════════════════════════════════════════════════════════════════════
-- SCHEMA THỜI KHÓA BIỂU — Quý 1, năm học 2025–2026
-- PostgreSQL 14+ · chạy trong pgAdmin 4 (Query Tool)
-- Mô hình: star schema, 5 bảng dimension + 1 fact + 2 bảng bridge + 1 fact chi tiết
--
-- THAY ĐỔI so với bản trước:
--   1. dim_class: PK đổi từ class_id (surrogate số) sang class_code (khóa tự nhiên, VD 'BUS 332 - 01')
--   2. dim_instructor: PK đổi từ instructor_id (số) sang instructor_code dạng 'GV_1', 'GV_2'...
--   fact_schedule và mọi INDEX/VIEW/query bên dưới đã cập nhật theo.
-- ═══════════════════════════════════════════════════════════════════════

DROP SCHEMA IF EXISTS tkb CASCADE;
CREATE SCHEMA tkb;
SET search_path TO tkb;


-- ═══════════════ 1. DIMENSION ═══════════════

-- Giảng viên. PK dạng 'GV_1'...'GV_74' — dễ đọc, dễ nhớ khi demo, nhưng vẫn là surrogate
-- (không mang ý nghĩa nghiệp vụ, không đổi nếu tên giảng viên đổi cách viết).
CREATE TABLE dim_instructor (
    instructor_code  VARCHAR(10)  PRIMARY KEY,   -- 'GV_1', 'GV_2', ...
    instructor_name  VARCHAR(100) NOT NULL UNIQUE
);

-- Phòng học. room_code là khóa tự nhiên nhưng vẫn dùng surrogate để join gọn.
CREATE TABLE dim_room (
    room_id     INTEGER     PRIMARY KEY,
    room_code   VARCHAR(20) NOT NULL UNIQUE,
    building    VARCHAR(10) NOT NULL,
    room_type   VARCHAR(20) NOT NULL,
    CONSTRAINT ck_room_type CHECK (room_type IN ('Lecture','LAB'))
);

-- Môn học. course_code là khóa tự nhiên ổn định — dùng luôn làm PK, không cần surrogate.
CREATE TABLE dim_course (
    course_code   VARCHAR(15) PRIMARY KEY,
    course_name   VARCHAR(120) NOT NULL,
    credit_hours  SMALLINT     NOT NULL,
    CONSTRAINT ck_crh CHECK (credit_hours BETWEEN 1 AND 6)
);

-- Lịch ngày. PK là chính ngày tháng — chuẩn cho dimension thời gian.
CREATE TABLE dim_date (
    date_id      DATE        PRIMARY KEY,
    year         SMALLINT    NOT NULL,
    month        SMALLINT    NOT NULL,
    month_name   VARCHAR(20) NOT NULL,
    week_number  SMALLINT    NOT NULL,
    day_name     VARCHAR(20) NOT NULL,
    term_week    SMALLINT               -- tuần thứ mấy của học kỳ (1–10)
);

-- LỚP HỌC PHẦN. Một môn (course) có thể mở nhiều lớp (CRN 01, 02, HNRS, E1...).
-- Đây là cấp độ mà quy tắc "40 hoặc 60 giờ" được áp dụng.
-- PK = class_code (khóa tự nhiên, VD 'BUS 332 - 01') — đọc trực tiếp ra tên lớp,
-- không cần join sang dim_course chỉ để hiển thị mã lớp khi demo hay debug.
CREATE TABLE dim_class (
    class_code  VARCHAR(30) PRIMARY KEY,          -- 'BUS 332 - 01'
    course_code VARCHAR(15) NOT NULL REFERENCES dim_course(course_code),
    crn         VARCHAR(10) NOT NULL,
    class_size  SMALLINT,                         -- NULL hợp lệ: 5 lớp chưa có sĩ số
    CONSTRAINT uq_class UNIQUE (course_code, crn)  -- vẫn giữ ràng buộc gốc: 1 CRN/1 môn chỉ 1 lớp
);


-- ═══════════════ 2. FACT ═══════════════

-- Grain: MỘT giảng viên dạy MỘT khối lịch (ngày + giờ + phòng) trong MỘT giai đoạn.
-- Đây chính là 216 dòng trong tab Table1_1 của bạn.
CREATE TABLE fact_schedule (
    schedule_id        INTEGER     PRIMARY KEY,
    class_code          VARCHAR(30) NOT NULL REFERENCES dim_class(class_code),
    instructor_code     VARCHAR(10) NOT NULL REFERENCES dim_instructor(instructor_code),
    room_id             INTEGER              REFERENCES dim_room(room_id),  -- NULL: môn thực tập, đồ án
    day_pattern         VARCHAR(5),      -- 'MR','TF'... giữ lại để đối chiếu nguồn
    start_time          TIME,
    end_time            TIME,
    session_part        VARCHAR(10),     -- 'Sáng' / 'Chiều'
    group_size          SMALLINT,
    num_weeks           SMALLINT NOT NULL,
    sessions_per_week   SMALLINT NOT NULL,
    hours_per_session   NUMERIC(4,1) NOT NULL,
    teaching_hours      NUMERIC(6,1) NOT NULL,
    CONSTRAINT ck_time  CHECK (end_time > start_time),
    CONSTRAINT ck_hours CHECK (teaching_hours = num_weeks * sessions_per_week * hours_per_session)
);


-- ═══════════════ 3. BRIDGE — gỡ hai vi phạm 1NF ═══════════════

-- Cột Period của bạn có 15 dòng dạng '06/10-29/11 ; 08/12-13/12' — hai giá trị trong một ô.
CREATE TABLE schedule_period (
    period_id   INTEGER PRIMARY KEY,
    schedule_id INTEGER NOT NULL REFERENCES fact_schedule(schedule_id) ON DELETE CASCADE,
    start_date  DATE NOT NULL,
    end_date    DATE NOT NULL,
    CONSTRAINT ck_period CHECK (end_date >= start_date)
);

-- Cột Day của bạn có 156 dòng dạng 'MR','TF' — cũng là hai giá trị trong một ô.
CREATE TABLE schedule_day (
    schedule_id  INTEGER     NOT NULL REFERENCES fact_schedule(schedule_id) ON DELETE CASCADE,
    day_code     CHAR(1)     NOT NULL,
    iso_dow      SMALLINT    NOT NULL,   -- 0=Thứ 2 … 5=Thứ 7
    day_name_vi  VARCHAR(10) NOT NULL,
    PRIMARY KEY (schedule_id, day_code),
    CONSTRAINT ck_day CHECK (day_code IN ('M','T','W','R','F','S'))
);


-- ═══════════════ 4. FACT CHI TIẾT — mỗi buổi học một dòng ═══════════════

-- Bung fact_schedule × schedule_day × schedule_period thành từng buổi có ngày cụ thể.
-- Đây là bảng làm cho dim_date trở nên dùng được, và là bảng để dò trùng lịch.
CREATE TABLE fact_session (
    session_id      INTEGER PRIMARY KEY,
    schedule_id     INTEGER NOT NULL REFERENCES fact_schedule(schedule_id) ON DELETE CASCADE,
    session_date    DATE    NOT NULL REFERENCES dim_date(date_id),
    start_time       TIME    NOT NULL,
    end_time         TIME    NOT NULL,
    duration_hours   NUMERIC(4,1) NOT NULL
);


-- ═══════════════ 5. INDEX ═══════════════

CREATE INDEX ix_sch_class    ON fact_schedule(class_code);
CREATE INDEX ix_sch_instr    ON fact_schedule(instructor_code);
CREATE INDEX ix_sch_room     ON fact_schedule(room_id);
CREATE INDEX ix_class_course ON dim_class(course_code);
CREATE INDEX ix_ses_sched    ON fact_session(schedule_id);
CREATE INDEX ix_ses_date     ON fact_session(session_date);
CREATE INDEX ix_period_sched ON schedule_period(schedule_id);


-- ═══════════════ 7. VIEW ═══════════════

-- Trả về đúng hình dạng bảng phẳng bạn đang quen ở Excel.
CREATE VIEW v_schedule_full AS
SELECT s.schedule_id, c.course_code, co.course_name, c.crn, co.credit_hours,
       s.day_pattern, s.start_time, s.end_time, r.room_code, r.building, r.room_type,
       i.instructor_name, s.group_size, s.num_weeks, s.sessions_per_week,
       s.hours_per_session, s.teaching_hours, c.class_code
FROM fact_schedule s
JOIN dim_class      c  ON c.class_code      = s.class_code
JOIN dim_course     co ON co.course_code    = c.course_code
JOIN dim_instructor i  ON i.instructor_code = s.instructor_code
LEFT JOIN dim_room  r  ON r.room_id         = s.room_id;

-- Kiểm tra quy tắc giờ ngay trong database.
CREATE VIEW v_class_hours_check AS
SELECT c.class_code, co.credit_hours,
       SUM(s.teaching_hours)          AS total_hours,
       co.credit_hours * 10           AS expected_hours,
       CASE
         WHEN SUM(s.teaching_hours) = co.credit_hours * 10 THEN 'OK'
         WHEN SUM(s.teaching_hours) = 0                    THEN 'THIẾU LỊCH'
         WHEN SUM(s.teaching_hours) > co.credit_hours * 10 THEN 'VƯỢT GIỜ'
         ELSE 'THIẾU GIỜ'
       END AS status
FROM dim_class c
JOIN dim_course co    ON co.course_code = c.course_code
JOIN fact_schedule s  ON s.class_code   = c.class_code
GROUP BY c.class_code, co.credit_hours;

