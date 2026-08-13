-- ═══════════════ 8. TRUY VẤN KIỂM TRA SAU KHI NẠP ═══════════════

-- 8.1 Đếm dòng — phải ra: 74 / 36 / 114 / 69 / 141 / 216 / 233 / 363 / 2697
SELECT 'dim_instructor' t, COUNT(*) FROM tkb.dim_instructor
UNION ALL SELECT 'dim_room',        COUNT(*) FROM tkb.dim_room
UNION ALL SELECT 'dim_course',      COUNT(*) FROM tkb.dim_course
UNION ALL SELECT 'dim_date',        COUNT(*) FROM tkb.dim_date
UNION ALL SELECT 'dim_class',       COUNT(*) FROM tkb.dim_class
UNION ALL SELECT 'fact_schedule',   COUNT(*) FROM tkb.fact_schedule
UNION ALL SELECT 'schedule_period', COUNT(*) FROM tkb.schedule_period
UNION ALL SELECT 'schedule_day',    COUNT(*) FROM tkb.schedule_day
UNION ALL SELECT 'fact_session',    COUNT(*) FROM tkb.fact_session;

-- 8.2 Tổng giờ phải bằng nhau ở hai cấp — cả hai ra 5564
SELECT (SELECT SUM(teaching_hours) FROM tkb.fact_schedule) AS tu_schedule,
       (SELECT SUM(duration_hours) FROM tkb.fact_session)  AS tu_session;

-- 8.3 Các lớp không đạt chuẩn giờ
SELECT * FROM tkb.v_class_hours_check WHERE status <> 'OK' ORDER BY status, class_code;
--có các lớp 60 giờ là do ec

-- 8.4 Trùng lịch giảng viên — cùng người, cùng ngày, giờ chồng nhau
SELECT i.instructor_name, a.session_date,
       ca.class_code AS lop_1, a.start_time || '–' || a.end_time AS gio_1,
       cb.class_code AS lop_2, b.start_time || '–' || b.end_time AS gio_2
FROM tkb.fact_session a
JOIN tkb.fact_session b   ON a.session_date = b.session_date AND a.session_id < b.session_id
JOIN tkb.fact_schedule sa ON sa.schedule_id = a.schedule_id
JOIN tkb.fact_schedule sb ON sb.schedule_id = b.schedule_id
JOIN tkb.dim_instructor i ON i.instructor_code = sa.instructor_code AND i.instructor_code = sb.instructor_code
JOIN tkb.dim_class ca ON ca.class_code = sa.class_code
JOIN tkb.dim_class cb ON cb.class_code = sb.class_code
WHERE a.start_time < b.end_time AND b.start_time < a.end_time
ORDER BY a.session_date;

-- 8.5 Trùng lịch phòng
SELECT r.room_code, a.session_date, a.start_time, b.start_time,
       ca.class_code, cb.class_code
FROM tkb.fact_session a
JOIN tkb.fact_session b   ON a.session_date = b.session_date AND a.session_id < b.session_id
JOIN tkb.fact_schedule sa ON sa.schedule_id = a.schedule_id
JOIN tkb.fact_schedule sb ON sb.schedule_id = b.schedule_id
JOIN tkb.dim_room r  ON r.room_id = sa.room_id AND r.room_id = sb.room_id
JOIN tkb.dim_class ca ON ca.class_code = sa.class_code
JOIN tkb.dim_class cb ON cb.class_code = sb.class_code
WHERE a.start_time < b.end_time AND b.start_time < a.end_time
  AND sa.class_code <> sb.class_code;

-- 8.6 Tỷ lệ sử dụng phòng (mẫu số 550 giờ khả dụng mỗi phòng)
SELECT r.building, r.room_code,
       SUM(fs.duration_hours) AS gio_su_dung,
       ROUND(SUM(fs.duration_hours) / 550.0 * 100, 1) AS ty_le_pct
FROM tkb.fact_session fs
JOIN tkb.fact_schedule s ON s.schedule_id = fs.schedule_id
JOIN tkb.dim_room r      ON r.room_id     = s.room_id
GROUP BY r.building, r.room_code
ORDER BY gio_su_dung DESC;

-- 8.7 Tải giảng viên theo tuần học — tìm tuần quá tải
----- Ngưỡng 14h ≈ percentile 95 của toàn bộ 712 tổ hợp (giảng viên × tuần) -> estimate
SELECT i.instructor_code, i.instructor_name, d.term_week, SUM(fs.duration_hours) AS gio_trong_tuan
FROM tkb.fact_session fs
JOIN tkb.fact_schedule s  ON s.schedule_id     = fs.schedule_id
JOIN tkb.dim_instructor i ON i.instructor_code = s.instructor_code
JOIN tkb.dim_date d       ON d.date_id         = fs.session_date
GROUP BY i.instructor_code, i.instructor_name, d.term_week
HAVING SUM(fs.duration_hours) >= 14
ORDER BY gio_trong_tuan DESC;

---8.8 Top 10 Most Loaded Instructors (By Classes)
SELECT 
    i.instructor_code,
    i.instructor_name,
    COUNT(DISTINCT s.class_code) AS classes_taught,
    COUNT(DISTINCT c.course_code) AS unique_courses,
    ROUND(SUM(s.teaching_hours)::numeric, 1) AS total_teaching_hours
FROM tkb.fact_schedule s
JOIN tkb.dim_instructor i ON i.instructor_code = s.instructor_code
JOIN tkb.dim_class c ON c.class_code = s.class_code
GROUP BY i.instructor_code, i.instructor_name
ORDER BY classes_taught DESC
LIMIT 10;

--8.9 TỶ LỆ SỬ DỤNG TRUNG BÌNH THEO TÒA NHÀ 
-- LƯU Ý: không được SUM trực tiếp giờ của cả tòa rồi chia 550 —
-- vì mỗi tòa có số phòng khác nhau (B03: 9 phòng, B08: 10 phòng).
-- Phải tính % của TỪNG phòng trước, rồi mới AVG() các % đó lại.
-- Đây là lý do dùng subquery (bảng con) ở bước 1 trước khi GROUP BY building.
 
SELECT
    r.building,
    COUNT(*)                                    AS so_phong,
    ROUND(AVG(gio_phong)::numeric, 1)           AS gio_tb_moi_phong,
    ROUND(AVG(gio_phong) / 550.0 * 100, 1)      AS ty_le_tb_pct
FROM (
--: tính tổng giờ sử dụng của TỪNG phòng riêng lẻ trước
    SELECT r.room_id, r.building, SUM(fs.duration_hours) AS gio_phong
    FROM tkb.fact_session fs
    JOIN tkb.fact_schedule s ON s.schedule_id = fs.schedule_id
    JOIN tkb.dim_room r       ON r.room_id     = s.room_id
    GROUP BY r.room_id, r.building
) AS gio_theo_phong
JOIN tkb.dim_room r ON r.room_id = gio_theo_phong.room_id
GROUP BY r.building
ORDER BY ty_le_tb_pct DESC;
