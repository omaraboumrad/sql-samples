-- Sample Input 
--
-- Employees
--
-- name
-- ----
-- omar
-- dany
-- jake
--
-- Schedules
--
-- name    start      end
-- ------- ---------- ----------
-- s1      01/01/2001 31/01/2001
-- s2      01/02/2001 29/02/2001
-- s3      01/03/2001 31/12/2001
--
-- Assignments
--
-- emp    schedule
-- ------ --------
-- omar   s1
-- omar   s2
-- omar   s3
-- dany   s1
-- dany   s3
-- jake   s3
--
-- Expected Output
--
-- name
-- ----
-- dany
-- jake

-- Schema --

CREATE TABLE assignments (
    emp text NOT NULL,
    schedule text NOT NULL
);
CREATE TABLE employees (
    name text NOT NULL
);
CREATE TABLE schedules (
    name text NOT NULL,
    start date NOT NULL,
    "end" date NOT NULL
);
INSERT INTO assignments (emp, schedule) VALUES ('omar', 's1');
INSERT INTO assignments (emp, schedule) VALUES ('omar', 's2');
INSERT INTO assignments (emp, schedule) VALUES ('omar', 's3');
INSERT INTO assignments (emp, schedule) VALUES ('dany', 's1');
INSERT INTO assignments (emp, schedule) VALUES ('dany', 's3');
INSERT INTO assignments (emp, schedule) VALUES ('jake', 's3');
INSERT INTO employees (name) VALUES ('omar');
INSERT INTO employees (name) VALUES ('dany');
INSERT INTO employees (name) VALUES ('jake');
INSERT INTO schedules (name, start, "end") VALUES ('s1', '2001-01-01', '2001-01-31');
INSERT INTO schedules (name, start, "end") VALUES ('s2', '2001-02-01', '2001-02-28');
INSERT INTO schedules (name, start, "end") VALUES ('s3', '2001-03-01', '2001-12-31');
ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (emp, schedule);
ALTER TABLE ONLY employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (name);
ALTER TABLE ONLY schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (name);
ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_emp_fkey FOREIGN KEY (emp) REFERENCES employees(name) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_schedule_fkey FOREIGN KEY (schedule) REFERENCES schedules(name) ON UPDATE CASCADE ON DELETE CASCADE;

-- Solution #1 --

WITH days (day) AS (
	SELECT generate_series(
		timestamp '2001-01-15',
		'2001-02-15',
		'1 day'
	)::DATE AS day
)
SELECT
	employees.name
FROM employees
INNER JOIN assignments ON assignments.emp = employees.name
INNER JOIN schedules ON schedules.name = assignments.schedule
LEFT JOIN days ON schedules.start <= days.day AND schedules.end >= days.day
GROUP BY employees.name
HAVING COUNT(days.day) < (select count(*) from days)


-- Solution #2 --

-- Another version without generating the dates --
-- It's more brittle because it considers there --
-- are no overlaps of schedules per employee    --
-- It may also fail on some scenarios...        --

SELECT employees.name
FROM employees
INNER JOIN assignments ON assignments.emp = employees.name
INNER JOIN schedules ON schedules.name = assignments.schedule
GROUP BY employees.name
HAVING COALESCE(SUM(
	upper(daterange('2001-01-15'::date, '2001-02-15'::date, '[]') * daterange(schedules.start, schedules.end, '[]'))
	- lower(daterange('2001-01-15'::date, '2001-02-15'::date, '[]') * daterange(schedules.start, schedules.end, '[]'))
))
