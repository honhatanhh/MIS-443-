---Return all department names and their locations.
SELECT department_name, location
FROM h_care.departments; 

---1. The registration team is auditing the full patient directory ahead of a system migration.
---The scheduling team needs to review all appointments booked during a two-week window. Find all appointments with appointment_date between January 15, 2025 and January 20, 2025 (inclusive). Show appointment_id, patient_id, appointment_date, and status.
SELECT *FROM h_care.patients; 

---2. The facilities team needs a directory of all departments and their physical locations for signage updates.
--- Return all department names and their locations.
SELECT department_name, location
FROM  h_care.departments; 

---3. The cardiology department head needs the current physician roster for the department meeting.
---Return doctors assigned to the Cardiology department.
SELECT first_name, last_name, specialty
FROM h_care.doctors
WHERE department_id = 1; 

---4.The outreach team is preparing materials for a women's health campaign and needs a contact list of female patients.
--- Return all female patients with their contact information.
SELECT first_name, last_name, phone
FROM h_care.patients
WHERE gender = 'F';

---5. HR needs the physician roster ordered by seniority for a credentialing renewal review.
--- Return all doctors sorted by hire date from oldest to most recent.
SELECT first_name, last_name, hire_date
FROM h_care.doctors
Order by hire_date ASC;

--- 6. The quality team is reviewing recently closed patient visits to validate that appointments were properly finalised.
--- Return all appointments with a Completed status.
SELECT appointment_id, patient_id, appointment_date
FROM h_care.appointments
WHERE status =  'Completed'; 

---7. The staffing office needs a single headcount of all currently active physicians for a regulatory submission.
--- Count the total number of doctors on staff.
SELECT COUNT (doctor_id) AS total_doctors
FROM h_care.doctors; 

---8.The epidemiology team is reviewing all new diagnoses made in 2025 for an annual disease incidence report.
--- Return all diagnoses recorded in the year 2025.
SELECT 
    d.condition_name, 
    d.diagnosis_date, 
    p.last_name
FROM h_care.diagnoses d
JOIN h_care. patients p ON d.patient_id = p.patient_id
WHERE d.diagnosis_date BETWEEN '2025-01-01' AND '2025-12-31';

---9. Count appointments per year using strftime to extract the year from appointment_date. Show year and appointment_count. Order by year.
SELECT 
    EXTRACT(YEAR FROM appointment_date) AS year,
    COUNT(appointment_id) AS appointment_count
FROM h_care.appointments
GROUP BY EXTRACT(YEAR FROM appointment_date)
ORDER BY year ASC;

---10. Show the number of distinct diagnoses per patient. Join patients to diagnoses. Show first name, last name, and diagnosis_count. Order by count descending.
SELECT 
    p.first_name, 
    p.last_name,
    COUNT(d.diagnosis_id) AS diagnosis_count
FROM h_care.patients p
JOIN h_care.diagnoses d ON p.patient_id = d.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY diagnosis_count DESC; 

---11. Find distinct patients who have at least one appointment in 2025. Use strftime to extract the year. Show first name and last name ordered by last name.
SELECT 
    p.first_name, 
    p.last_name
FROM h_care.patients p
JOIN h_care.appointments a ON p.patient_id = a.patient_id
WHERE CAST(a.appointment_date AS TEXT) LIKE '2025%'
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY p.last_name ASC;

---12. The analytics team wants to know what gender values exist in the patient database. List the distinct gender values from the patients table.
SELECT DISTINCT(gender)
FROM h_care.patients;

---13. The scheduling team needs to review all appointments booked during a two-week window. Find all appointments with appointment_date between January 15, 2025 and January 20, 2025 (inclusive). Show appointment_id, patient_id, appointment_date, and status.
SELECT appointment_id, patient_id, appointment_date, status
FROM h_care.appointments
WHERE appointment_date BETWEEN '2025-01-15' AND '2025-01-20'
 ORDER BY appointment_date;

---14. The engagement team is measuring how frequently each patient visits the clinic to flag under-served patients.
---Count the number of appointments per patient.
 SELECT patient_id, 
 COUNT(*) AS appointment_count 
 FROM h_care.appointments 
 GROUP BY patient_id 
 ORDER BY patient_id;

--- 15. The hospital directory needs each physician listed alongside their department name for the public-facing staff page.
---Return each doctor's name paired with their department name.
SELECT 
    d.first_name, 
    d.last_name,
    de.department_name
FROM h_care.doctors d
JOIN h_care.departments de ON d.department_id = de.department_id; 

--- 16. The clinical records team needs a patient-linked view of all diagnoses for a care history audit.
---Return each diagnosis with the patient's first name, last name, condition name, and diagnosis date.
SELECT p.first_name, p.last_name, d.condition_name, d.diagnosis_date 
  FROM h_care.patients p
JOIN h_care.diagnoses d ON p.patient_id= d.patient_id
Order by diagnosis_date;

---17. The scheduling team needs a forward-looking appointment list with both patient and doctor names for daily briefing sheets.
---Return all scheduled appointments with patient and doctor full names.
SELECT a.appointment_date,
p.first_name  || ' ' || p.last_name  AS patient_name,
d.first_name || ' ' || d.last_name AS doctor_name
FROM h_care.appointments a
JOIN h_care.doctors d  on d.doctor_id  = a.doctor_id
JOIN h_care.patients p ON p.patient_id = a.patient_id
WHERE a.status =  'Scheduled'
ORDER BY a.appointment_date;

---18. The capacity planning team needs to know physician headcount per department to identify under-staffed units.
---Return the number of doctors in each department.
SELECT department_name, COUNT (doctor_id) AS doctor_count
FROM h_care.departments d 
LEFT JOIN h_care.doctors doc 
	ON d.department_id = doc.department_id
GROUP BY department_name
ORDER BY doctor_count DESC; 

---19. The chronic care team is identifying patients who carry multiple diagnoses to prioritise case management outreach.
--- Return patients who have more than one recorded diagnosis.
SELECT patient_id, COUNT(diagnosis_id) AS diagnosis_count
FROM  h_care.diagnoses
GROUP BY patient_id HAVING COUNT(*) > 1;

---20. The patient flow team needs each appointment linked to the department responsible so throughput can be measured by clinical unit.
---Return each appointment's date, patient last name, and the department of the attending doctor.
SELECT a.appointment_date, p.last_name AS patient_last_name, dep.department_name 
FROM h_care.appointments a 
  JOIN h_care.patients p ON a.patient_id = p.patient_id 
  JOIN h_care.doctors doc ON a.doctor_id = doc.doctor_id 
  JOIN h_care.departments dep ON doc.department_id = dep.department_id 
ORDER BY a.appointment_date, p.last_name; 

---21. The hospital audit team needs a complete view of every appointment. Show full appointment details including patient name, doctor name, department name, appointment date, and status. Order by appointment date.
SELECT p.first_name, p.last_name, d.first_name AS dr_first, d.last_name AS dr_last,
de.department_name, a.appointment_date, a.status
FROM h_care.appointments a
JOIN h_care.patients p ON a.patient_id = p.patient_id
JOIN h_care.doctors d ON a.doctor_id = d.doctor_id
JOIN h_care.departments de ON d.department_id = de.department_id
ORDER BY a.appointment_date;

---22. The admissions team wants to know which registered patients have never had an appointment scheduled. Find patients who have no appointment records. Show first name, last name, and gender.
SELECT p.first_name, p.last_name, p.gender
FROM h_care.patients p LEFT 
JOIN h_care.appointments a ON p.patient_id = a.patient_id 
WHERE a.appointment_id IS NULL;

---23. Create a unified appointment list by combining Scheduled (labelled 'Upcoming') and Completed (labelled 'Past') appointments. Show patient_id, doctor_id, appointment_date, and category. Order by appointment_date.
SELECT patient_id, doctor_id, appointment_date, 
'Upcoming' AS category FROM h_care.appointments WHERE status = 'Scheduled' 
UNION ALL SELECT patient_id, doctor_id, appointment_date,
'Past' AS category FROM h_care.appointments WHERE status = 'Completed'
ORDER BY appointment_date;

---24. The clinical team wants to identify patients who have never received a diagnosis. Find all patients who have no records in the diagnoses table. Show first name, last name, and gender.
SELECT p.first_name, p.last_name, p.gender
FROM h_care.patients p 
LEFT JOIN h_care.diagnoses di ON p.patient_id = di.patient_id 
WHERE di.diagnosis_id IS NULL;

---25. Generate a patient summary report showing every registered patient alongside how many diagnoses they have received, including patients with zero diagnoses. Show first name, last name, and diagnosis_count. Order by diagnosis_count descending, then last name.
SELECT p.first_name, p.last_name, COUNT(di.diagnosis_id)
AS diagnosis_count
FROM h_care.patients p 
LEFT JOIN h_care.diagnoses di ON p.patient_id = di.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY diagnosis_count DESC, p.last_name;


--- 26. Find doctors who have more appointments than the average number of appointments for all doctors in their department. Show first name, last name, specialty, and appointment count.
SELECT d.first_name, d.last_name, d.specialty, COUNT(a.appointment_id)
AS appt_count
FROM h_care.doctors d
JOIN h_care.appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialty, d.department_id
HAVING COUNT(a.appointment_id) > (SELECT AVG(cnt) FROM(SELECT COUNT(a2.appointment_id) 
AS cnt FROM h_care.doctors d2 JOIN h_care.appointments a2 ON d2.doctor_id = a2.doctor_id
WHERE d2.department_id = d.department_id GROUP BY d2.doctor_id))
ORDER BY appt_count DESC;


---27. Rank each doctor by their appointment count within their department. Show first name, last name, department_id, appt_count, and dept_rank. Order by department, then rank.
SELECT d.first_name, d.last_name, d.department_id, COUNT(a.appointment_id)
AS appt_count, RANK() OVER(PARTITION BY d.department_id 
ORDER BY COUNT(a.appointment_id)DESC) AS dept_rank
FROM h_care.doctors d LEFT JOIN h_care.appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.department_id
ORDER BY d.department_id, dept_rank;

---28.  Find the doctor with the most appointments in each department. Show doctor name, department name, and appointment count.
WITH doctor_counts AS (
SELECT d.doctor_id, d.first_name, d.last_name, d.department_id,
COUNT(a.appointment_id) AS appt_count
FROM h_care.doctors d LEFT JOIN h_care.appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.department_id
  ),
  ranked AS (SELECT *, RANK() OVER (PARTITION BY department_id
ORDER BY appt_count DESC) AS rnk
FROM doctor_counts)
SELECT r.first_name, r.last_name, de.department_name, r.appt_count
FROM ranked r
JOIN h_care.departments de ON r.department_id = de.department_id
WHERE r.rnk = 1
ORDER BY de.department_name;

---29.  Classify patients into age groups based on their age as of 2026-01-01: Young Adult (under 35), Middle-Aged (35–49), Senior (50+). Show each group's patient count and average age. Order by avg_age ascending.
WITH patient_ages AS (
     SELECT patient_id, last_name,
(EXTRACT(YEAR FROM DATE '2026-01-01')-EXTRACT(YEAR FROM date_of_birth)) AS age FROM h_care.patients)
SELECT CASE WHEN age < 35 THEN 'Young Adult' WHEN age < 50 THEN 'Middle-Aged' ELSE 'Senior'
END AS age_group, COUNT(*) AS patient_count, ROUND(AVG(age),1)
AS avg_age FROM patient_ages GROUP BY age_group ORDER BY avg_age;

---30. The operations team wants to flag doctors who are busier than the hospital average. Find doctors whose appointment count exceeds the hospital-wide average appointment count per doctor. Show first name, last name, specialty, and appointment count.
SELECT d.first_name, d.last_name, d.specialty, 
COUNT(a.appointment_id) AS appt_count 
FROM h_care.doctors d JOIN h_care.appointments a 
ON d.doctor_id = a.doctor_id 
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialty 
HAVING COUNT(a.appointment_id) > (SELECT AVG(cnt) 
FROM (SELECT COUNT(appointment_id) AS cnt 
FROM h_care.appointments GROUP BY doctor_id)) 
ORDER BY appt_count DESC;









