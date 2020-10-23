
-- Get all employees including their:
-- 		latest order date
--		latest order ship name
--		total orders on that day

-- Schema : Northwind DB --
-- https://github.com/pthom/northwind_psql --

SELECT
	DISTINCT ON (employees.employee_id)
	employees.employee_id,
	first_name,
	last_name,
	MAX(orders.order_date),
	ship_name,
	COUNT(orders.order_id) OVER (
        PARTITION BY (employees.employee_id, orders.order_date)
    )
FROM
	employees
LEFT JOIN orders ON orders.employee_id = employees.employee_id
GROUP BY employees.employee_id, ship_name, orders.order_date, orders.order_id
ORDER BY employees.employee_id ASC, orders.order_date DESC
