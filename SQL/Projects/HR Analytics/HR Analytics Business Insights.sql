/*HR Analytics Project
Author - Yaswanth Reddy
DB - PostgreSQL*/


--The "High-Potential" Identification: Find employees who have a performance rating of 5 AND are currently earning less than the average salary of their department. 
--(These are people at risk of leaving!)

WITH high_potential AS(
	Select d.department_name,e.employee_name,pr.rating,s.salary_amount,avg(s.salary_amount) OVER(partition by d.department_id) as dept_avg_salary
	FROM employees e
	JOIN departments d ON d.department_id = e.department_id
	JOIN salaries s ON s.employee_id = e.employee_id
	JOIN Performance_Reviews pr on pr.employee_id = e.employee_id
)
SELECT department_name,employee_name,Salary_amount,dept_avg_salary
FROM high_potential
where rating = 5
and salary_amount<dept_avg_salary


--Managerial Span of Control: List every manager and the total number of people they manage. Rank managers by the size of their team.
with manager_team as(
	Select e1.employee_name as manager,count(e2.employee_id) as emp_count
	from employees e1
	join employees e2 on e1.employee_id = e2.manager_id
	group by e1.employee_name
)
select *,rank() over(order by emp_count desc) as manager_rank
from manager_team


--The Gender Pay Gap Audit: For each department, calculate the average salary for Men vs. Women. Show the difference between these two averages.
Select 
	d.department_name,
	round(avg(case when e.gender='Male' then s.salary_amount end),2) as Male_avg_salary,
	round(avg(case when e.gender='Female' then s.salary_amount end),2) as Female_avg_salary,
	round(avg(case when e.gender='Male' then s.salary_amount end) - avg(case when e.gender='Female' then s.salary_amount end),2) as difference,
	case 
		when (avg(case when e.gender='Male' then s.salary_amount end) - avg(case when e.gender='Female' then s.salary_amount end))::int < 0 then 'Female Employees'
		when (avg(case when e.gender='Male' then s.salary_amount end) - avg(case when e.gender='Female' then s.salary_amount end))::int > 0 then 'Male Employees'
		Else 'No difference'
	end as "Earning_More_Gender"
from departments d
join employees e on e.department_id = d.department_id
join salaries s on e.employee_id = s.employee_id
group by d.department_name

	
--Departmental ROI: Calculate the "Performance per Dollar" for each department. 
--(Sum of all performance ratings in a department divided by the total salary expenditure of that department).
With dept_ratings as(
	Select d.department_id,d.department_name,sum(rating) as total_ratings
	from departments d 
	join employees e on e.department_id = d.department_id
	join performance_reviews pr on pr.employee_id = e.employee_id
	GROUP BY d.department_id,d.department_name
),
dept_salary as (
	Select d.department_id,d.department_name,sum(salary_amount) as total_salary
	from departments d 
	join employees e on e.department_id = d.department_id
	join salaries s on s.employee_id = e.employee_id
	GROUP BY d.department_id,d.department_name
)
SELECT dr.department_name,round((dr.total_ratings*1.0/ds.total_salary),6) as ROI
FROM dept_ratings dr
join dept_salary ds ON dr.department_id = ds.department_id


--Executive Bench Strength: Identify employees who are at the 'Senior' or 'Lead' level but do not currently have a manager.

SELECT employee_name,level
from employees e
join roles r on e.role_id = r.role_id
WHERE e.manager_id is null
and r.level in ('Senior','Lead')


--Top Talent Attrition Risk: List the top 2 highest-paid employees in each department. If they have a performance rating below 3, flag them as "Overpaid/Underperforming."

with highest_paid_emp as(
	select d.department_name,e.employee_id,e.employee_name,s.salary_amount,coalesce(pr.rating,0) as rating,dense_rank() over(partition by d.department_id order by s.salary_amount desc) as rnk
	from employees e
	left join departments d on d.department_id = e.department_id
	left join salaries s on e.employee_id = s.employee_id
	left join performance_reviews pr on pr.employee_id = e.employee_id
)
select department_name,employee_name,
	case
		when rnk <=2 and rating <3 then 'Overpaid/Underperforming'
	end as "Category"
from highest_paid_emp
where rnk <=2
and rating <3


--Hiring trend: Show the running total of hires we made.

with year_count as(
	Select extract(year from hire_date) as year,count(e.employee_id) as hires
	from employees e
	group by extract(year from hire_date)
)
Select 
	*,sum(hires) over(order by year) as Year_over_Year
from year_count



--Departmental Concentration: Which department has the highest percentage of the company's total headcount?

Select department_name,pct_of_total
from (
	Select department_name,round((COUNT(e.employee_id) * 100.0 / SUM(COUNT(e.employee_id)) OVER()),2) AS pct_of_total
	from employees e
	join departments d on e.department_id = d.department_id
	group by d.department_name
)
order by pct_of_total desc
limit 1

--The "Value" Report: Create a summary table showing: Department Name, Total Headcount, Total Salary Spend, Average Performance Rating, 
--and the name of the highest-paid person in that department.

/* this can be written using window function(First_value), but I chose 2 CTEs due to readability,maintainability*/

with department_summary as (
		SELECT d.department_id,d.department_name,count(e.employee_id) as Total_headcount,sum(s.salary_amount) as Total_salary_spend,round(avg(pr.rating),2) as average_rating
		FROM departments d
		left join employees e on e.department_id = d.department_id
		left join salaries s on e.employee_id = s.employee_id
		left join performance_reviews pr on e.employee_id = pr.employee_id
		GROUP BY d.department_id,d.department_name
),
highest_paid_employee AS(
	select * from(
		select d.department_id,e.employee_name,dense_rank() over(partition by d.department_id order by s.salary_amount DESC) as rnk
		from employees e
		join departments d on e.department_id = d.department_id
		join salaries s on e.employee_id = s.employee_id) r
	WHERE rnk = 1
)
SELECT ds.*,hpe.employee_name
from department_summary ds
join highest_paid_employee hpe on ds.department_id = hpe.department_id

