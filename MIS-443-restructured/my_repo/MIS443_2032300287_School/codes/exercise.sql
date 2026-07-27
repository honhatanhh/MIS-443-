---1. The registrar is auditing the full student directory ahead of the new academic term.
---Return the complete student roster from the students table.
select *from sch.students; 

---2. The Computer Science department needs a list of all enrolled CS students for an upcoming orientation session.
---Return students who are majoring in Computer Science.
select first_name, last_name, graduation_year
from sch.students
where major = 'Computer Science'; 

---3. The curriculum committee wants the course catalog ranked by academic workload.
---Return all courses ordered by credit hours from highest to lowest.
select course_name, credits
from sch.courses 
order by credits ASC; 

--- 4. Financial aid is preparing graduation milestone packages for the class of 2026.
---Return students who are expected to graduate in 2026.
select first_name, last_name, major
from sch.students
where graduation_year = '2026'; 

---5. The provost office needs a single count of active course offerings for the upcoming catalog publication.
---Count the total number of courses available.
select count(course_id) as total_courses
from sch.courses; 

---6. The curriculum review board wants the average credit load per course as a benchmark for workload balance.
---Calculate the average number of credits per course.
select avg(credits) as average_credits 
from sch.courses; 


