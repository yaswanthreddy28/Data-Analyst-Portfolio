/* HR Analytics Project
Author - Yaswanth Reddy
DB - PostgreSQL*/

--Display each employee's name along with their corresponding department name and role title.

SELECT employee_name, department_name, r.role_name
from employees e 
left JOIN departments d ON d.department_id = e.department_id--left join because we need employes without departmnt too
left join roles r ON e.role_id = r.role_id

--Calculate the total number of employees in each department.

SELECT d.department_name,count(e.employee_id) as employee_count
FROM departments d 
left join employees e ON e.department_id = d.department_id
group by d.department_name

--Find the average salary for each department (using only current salaries where the end date is null).
SELECT d.department_name,round(avg(s.salary_amount),2) as avg_salary
FROM departments d 
join employees e ON e.department_id = d.department_id
JOIN salaries s ON s.employee_id = e.employee_id
WHERE s.effective_to is null
group by d.department_name


--Show the count of male and female employees in the company.

--With set operators
SELECT count(*) as Male_Employees 
from employees
WHERE gender = 'Male'
union all
select count(*) as Female_Employees 
from employees
WHERE gender = 'Female'

--With Case statement
Select
	count(case when gender = 'Male' then 1 end) as Male_employees,
	count(case when gender = 'Female' then 1 end) as Female_employees
from employees;

	
--Display the highest and lowest performance rating ever given in the company.

SELECT max(rating) as Highest_rating,min(rating) as Lowest_rating
from performance_reviews

--For each role level (Junior, Mid, Senior, etc.), calculate the average salary.

SELECT r.level,round(avg(s.salary_amount),2) 
FROM salaries s 
JOIN employees e ON e.employee_id = s.employee_id
join roles r on e.role_id = r.role_id
GROUP BY r.level

--List departments that have more than 4 employees.

SELECT d.department_name,count(e.employee_id) as Emp_Count
FROM employees e
JOIN departments d on d.department_id = e.department_id
group by d.department_name
HAVING count(e.employee_id) > 4

--Show the total salary expenditure for the 'Engineering' department.

SELECT d.department_name,sum(salary_amount) as Total_Salary
FROM departments d 
JOIN employees e on e.department_id = d.department_id
JOIN salaries s on s.employee_id = e.employee_id
WHERE d.department_name = 'Engineering'
GROUP BY d.department_name

--Write a query to find employees whose current salary is higher than the current salary of their own manager.

SELECT e1.employee_name,s1.salary_amount,e2.employee_name as manager,s2.salary_amount
from employees e1
join employees e2 on e1.manager_id = e2.employee_id
join salaries s1 on e1.employee_id = s1.employee_id
JOIN salaries s2 on s2.employee_id = e2.employee_id
where e1.employee_id <> e2.employee_id -- use only where an employee is acting as a self manager. Like CEO.
and s1.salary_amount > s2.salary_amount


--Use a CTE to find the "Seniority" of each employee (years since hire) and group them into 'New' (0-2 years), 'Experienced' (2-5 years), and 'Veteran' (5+ years).

with emp_exp as (
	Select employee_name,(current_date - hire_date)/365 as experience
	from employees
)
select employee_name,
	case
		when experience < 2 then 'New'
		when experience between 2 and 5 then 'Experienced'
		when experience > 5 then 'Veteran'
		Else 'No Hire Date'
	End as Experience
from emp_exp

--Use a CTE to calculate the total salary cost per department, and then select the department with the highest total cost.

With dep_salary AS(
	Select department_name,sum(salary_amount) as total_salary
	FROM employees e
	join departments d on d.department_id = e.department_id
	JOIN salaries s ON s.employee_id = e.employee_id
	group by d.department_name
)
SELECT department_name,total_salary
from dep_salary	
ORDER BY total_salary desc
LIMIT 1

--Using a CTE, find the average performance rating for each department and then filter for departments that have an average rating above 4.0.

With avg_dep_rating as (
	Select department_name,avg(rating) as avg_rating
	from departments d 
	join employees e on	e.department_id = d.department_id
	join performance_reviews pr on pr.employee_id = e.employee_id
	group by d.department_name
)
Select department_name,round(avg_rating,2) 
from avg_dep_rating 
where avg_rating > 4.0

--Identify employees who have had more than one salary record in the history table (indicating a promotion or raise) using a subquery or IN clause.
Select employee_name
from employees 
where employee_id in (Select employee_id 
					from salaries
					group by employee_id
					having count(salary_id)>1)