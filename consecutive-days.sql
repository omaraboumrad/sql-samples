-- Input
-- 
-- Day         Location
-- ----------  --------
-- 2020-08-10  Home
-- 2020-08-11  Home
-- 2020-08-12  Home
-- 2020-08-13  Home
-- 2020-08-14  Hospital
-- 2020-08-15  Hospital
-- 2020-08-16  Hospital
-- 2020-08-17  Theater
-- 2020-08-19  Gym
-- 2020-08-20  Gym
-- 2020-08-22  Home
-- 2020-08-23  Home
-- 
-- Output
-- 
-- Start      End        Location
-- ---------- ---------- --------
-- 2020-08-10 2020-08-13 Home
-- 2020-08-14 2020-08-16 Hospital
-- 2020-08-17 2020-08-17 Theater
-- 2020-08-19 2020-08-20 Gym
-- 2020-08-22 2020-08-23 Home

-- Schema --

CREATE TABLE locations (
    day date NOT NULL,
	name text NOT NULL
);

INSERT INTO locations(day, name) VALUES
    ('2020-08-10', 'Home'),
    ('2020-08-11', 'Home'),
    ('2020-08-12', 'Home'),
    ('2020-08-13', 'Home'),
    ('2020-08-14', 'Hospital'),
    ('2020-08-15', 'Hospital'),
    ('2020-08-16', 'Hospital'),
    ('2020-08-17', 'Theater'),
    ('2020-08-19', 'Gym'),
    ('2020-08-20', 'Gym')
    ('2020-08-22', 'Home'),
    ('2020-08-23', 'Home')

-- Query --
SELECT
	MIN(day) as start,
	MAX(day) as end,
	name
FROM (
	SELECT
		day,
		name,
		day - (dense_rank() over (order by day))::int as rank
	FROM
		locations
) t
GROUP BY name, rank
ORDER BY start
