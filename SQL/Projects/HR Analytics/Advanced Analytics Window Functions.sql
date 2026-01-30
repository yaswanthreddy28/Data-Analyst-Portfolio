/* HR Analytics Project
Author - Yaswanth Reddy
DB - PostgreSQL*/

--Company-wide Salary, Rank all employees across the entire company by salary.

SELECT 
	e.employee_name,s.salary_amount,dense_rank() over(order by s.salary_amount DESC) as rnk
FROM employees e
join salaries s ON s.employee_id = e.employee_id


--Departmental Averages: For every employee, show their name, their salary, and the average salary of their department in the next column.
SELECT 
	e.employee_name,d.department_name,s.salary_amount,round(avg(s.salary_amount) OVER(partition by d.department_name),2) as dept_salary
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN salaries s ON s.employee_id = e.employee_id


--Top Performers per Dept: Use a window function to find the highest-rated employee in each department.
WITH dept_emps AS(
	Select d.department_name,e.employee_name,s.salary_amount,dense_rank() OVER(PARTITION by d.department_name ORDER BY s.salary_amount DESC) as rnk
	FROM employees e
	JOIN departments d ON d.department_id = e.department_id
	JOIN salaries s ON s.employee_id = e.employee_id
)
SELECT department_name,employee_name,salary_amount
FROM dept_emps
where rnk = 1;

--How the company’s workforce salary base grew as we hired more people
SELECT 
	extract(year from hire_date) as year,sum(s.salary_amount) over(order by hire_date) as cumulative_sum
FROM employees e
join salaries s on e.employee_id = s.employee_id


--Salary Percentiles: group employees into salary quartiles across the whole company.

SELECT e.employee_name,s.salary_amount,ntile(4) OVER(order by s.salary_amount DESC) as Salary_quartile
FROM employees e
join salaries s on s.employee_id = e.employee_id

--Budget Share: Calculate what percentage of their department's total salary budget each individual employee represents.
SELECT
	d.department_name,e.employee_name,s.salary_amount,round((s.salary_amount/sum(s.salary_amount) OVER(partition by d.department_name))*100,2) as Contribution_pct
FROM employees e
join departments d on e.department_id = d.department_id
JOIN salaries s on e.employee_id = s.employee_id
ORDER BY d.department_name,contribution_pct DESC


--Hiring Sequence: Rank employees by their hire_date within each department to identify who was the first hire for each team.
SELECT * from(
	select d.department_name,e.employee_name,e.hire_date,dense_rank() OVER(partition by d.department_name ORDER BY hire_date) as Hire_rank
FROM employees e
join departments d on e.department_id = d.department_id
JOIN salaries s on e.employee_id = s.employee_id
) r
WHERE Hire_rank = 1;


--Growth Comparison: Calculate the difference between an employee's salary and the highest salary in their department.

SELECT d.department_name,e.employee_name,s.salary_amount, max(s.salary_amount) OVER(partition by d.department_name) - s.salary_amount as dept_diff
FROM employees e
join departments d on e.department_id = d.department_id
JOIN salaries s on e.employee_id = s.employee_id


--Department Salary Rank: Rank employees by salary within each department using RANK().

SELECT d.department_name,e.employee_name,s.salary_amount,rank() over(partition by d.department_id ORDER BY s.salary_amount DESC) as rnk
FROM employees e
join departments d on e.department_id = d.department_id
JOIN salaries s on e.employee_id = s.employee_id

--Company-wide Salary Rank: Rank all employees across the entire company by salary using DENSE_RANK().

SELECT employee_name,salary_amount,dense_rank() over(order by salary_amount DESC) rnk
FROM employees e
join salaries s on s.employee_id = e.employee_id



