
-- ═══════════════ 6. NẠP DỮ LIỆU ═══════════════
-- THỨ TỰ BẮT BUỘC: dimension trước, fact sau, bridge cuối.
--Flow thứ tự: dim_instructor -> dim_room -> dim_course -> dim_date ->dim_class -> fact_schedule -> schedule_period -> schedule_day -> fact_session
-- Trong pgAdmin: chuột phải vào bảng → Import/Export Data → Import,
-- chọn file CSV, Format = csv, Header = Yes, Encoding = UTF8.
--
-- Nếu chạy bằng psql trên máy bạn, dùng \copy (không cần quyền superuser):
/*
\copy tkb.dim_instructor  FROM 'csv/dim_instructor.csv'  CSV HEADER;
\copy tkb.dim_room        FROM 'csv/dim_room.csv'        CSV HEADER;
\copy tkb.dim_course      FROM 'csv/dim_course.csv'      CSV HEADER;
\copy tkb.dim_date        FROM 'csv/dim_date.csv'        CSV HEADER;
\copy tkb.dim_class       FROM 'csv/dim_class.csv'       CSV HEADER;
\copy tkb.fact_schedule   FROM 'csv/fact_schedule.csv'   CSV HEADER;
\copy tkb.schedule_period FROM 'csv/schedule_period.csv' CSV HEADER;
\copy tkb.schedule_day    FROM 'csv/schedule_day.csv'    CSV HEADER;
\copy tkb.fact_session    FROM 'csv/fact_session.csv'    CSV HEADER;
*/
---Testing:  
select *from tkb.dim_instructor; 
select *from tkb.dim_room; 
select *from tkb.dim_course; 
select *from tkb.dim_date; 
select *from tkb.dim_class; 
select *from tkb.fact_schedule; 
select *from tkb.schedule_period; 
select *from tkb.schedule_day; 
select *from tkb.fact_session; 