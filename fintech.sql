-- I created a database to house the tables for the project (employees_details, project_departments and project_details)
create database fintech;
-- I right-clicked on tables under the created database "fintech" and imported csv files for each table after cleaning the datasets using excel
-- Used Table import Data Wizard 
-- using the database
use fintech;
select * from employees_details;
describe employees_details;
select * from project_details;
describe project_details;
select * from project_departments;
describe project_departments;

-- Data Cleaning / formatting of columns
alter table employees_details
modify column Date_of_Birth Date;

alter table employees_details
modify column Date_Joined Date,
modify column Date_Resigned Date;

alter table project_details
modify column Start_date Date,
modify column End_date Date;

-- I altered each table in order to establish relationships among the tables 
-- using constraints such as primary key, foreign key, not null, unique.
alter table employees_details
add primary key (employee_id) ;
alter table employees_details
modify column First_Name text not null,
modify column Last_Name text not null, 
modify column Age int not null,
modify column Gender text not null,
modify column Date_of_birth date not null,
modify column Date_Joined date not null,
modify column Date_Resigned date not null,
modify column Department text not null,
modify column Salary int not null,
modify column Performance_level text not null;

alter table project_departments
add primary key (project_id);

alter table project_departments
modify column Project_name text not null,
modify column Department text not null;
describe project_details;

alter table project_details 
add foreign key (project_id)
references project_departments(project_id);

alter table project_details 
add foreign key (employee_id)
references employees_details(employee_id);

alter table project_details
modify column Employee_id int not null, 
modify column Project_id int not null,
modify column Start_date date not null,
modify column End_date date not null,
modify column Project_status text not null,
modify column Department text not null;


-- I used the describe statement to validate the alterations made  
Describe employees_details;
Describe project_departments;
Describe project_details;
select * from employees_details;
select * from project_departments;
select * from project_details;

-- Questions
-- 1. Find the names of employees who are currently working on projects in the IT department.
select employees_details.First_Name, employees_details.Last_Name, 
employees_details.Department, project_details.Project_status
from employees_details inner join project_details 
on employees_details.Employee_id = project_details.Employee_id
where Project_status = 'Ongoing' and employees_details.Department = 'IT';

-- 2. List the project names and the corresponding start dates for all projects 
-- that are currently ongoing.
select distinct project_departments.Project_name, 
project_details.Start_date, project_details.Project_status
from project_details inner join project_departments
on project_details.Project_id = project_departments.Project_id
where Project_status = 'Ongoing';

-- 3. Retrieve the names and ages of employees who would resign after working for more than 3 years.
select First_Name, Last_Name, Age, timestampdiff(year, Date_Joined, Date_Resigned) 
as Experience from employees_details 
where timestampdiff(year, Date_Joined, Date_Resigned) > 3 ;

-- 4. Find the total salary paid to employees in the 'Finance' department.
select sum(Salary) as Total_Finance_Salary 
from employees_details where Department = 'Finance';
-- 5.  List the project names and employee names for projects that started in 2024.
select employees_details.First_Name, employees_details.Last_Name,
project_departments.Project_name, year(project_details.Start_date) as Start_year 
from employees_details inner join project_details
on employees_details.Employee_id = project_details.Employee_id 
inner join project_departments on project_departments.Project_id = project_details.Project_id 
where year(project_details.Start_date) = '2024';
 

-- 6. Find the employees who are currently working in the 'Operations' department and 
-- have a performance level of 'Exceeds'.
select employees_details.First_Name, employees_details.Last_Name, 
employees_details.Performance_level, project_details.Department
from employees_details
inner join project_details
on employees_details.Employee_id = project_details.Employee_id
where project_details.Department = 'Operations'
and Performance_level= 'Exceeds';

-- 7. Retrieve the names of employees who joined before 2023 and are working on ongoing projects.
select employees_details.First_Name, employees_details.Last_Name, year(employees_details.Date_joined) 
as Year_joined, project_details.Project_status
from employees_details
inner join project_details
on employees_details.Employee_id = project_details.Employee_id
where year(employees_details.Date_joined)  < 2023 and Project_status = 'Ongoing';

-- 8. Find the employees who have completed projects and are in either 'Finance' or 'IT' departments.
select employees_details.First_Name, employees_details.Last_Name, 
project_details.Project_status, project_details. Department
from employees_details
inner join project_details
on employees_details.Employee_id = project_details.Employee_id
where project_details.Project_status = 'Completed' having project_details.Department = 'Finance' 
or project_details.Department = 'IT';

-- 9. Retrieve the names of employees who share the same last name as another employee, 
-- along with their respective departments.
select employees_details.First_name, employees_details.Last_Name, employees_details.Department
from employees_details
inner join (select Last_name from employees_details group by Last_name
having count(*) > 1) as employee 
on employees_details.last_name = employee.last_name
order by employees_details.last_name, employees_details.first_name;
-- 10. Write an SQL query to find employees whose performance level is higher 
-- than the average performance level in their respective departments.
select First_Name, Last_Name, Department,
Performance_level from employees_details
where Performance_level = 'Exceeds' or 
Performance_level = 'Outstanding' order by Department;  

-- 11. Write an SQL query to find the top 3 departments with the highest average salary. 
-- Return the department and the average salary, rounded to 2 decimal places.
select employees_details.Department, round(avg(Salary), 2) as Total_Average_Salary 
from employees_details group by Department 
order by Total_Average_Salary DESC limit 3;

-- 12. Write an SQL query to find the project names and the total number of employees
-- who have joined before the project start date. Return the project_name and the count of such employees.
select project_departments.Project_name, count(employees_details.Employee_id) as Employee_count 
from employees_details
inner join project_details
on employees_details.Employee_id = project_details.Employee_id
inner join project_departments
on project_details.Project_id = project_departments.Project_id
where
employees_details.Date_Joined < project_details.Start_date
group by project_departments.Project_name;
-- 13. Write an SQL query to find the employees who have not been assigned to any project. 
-- Return the employee_id, first_name, last_name, and department.
select employees_details.Employee_id, employees_details.First_Name,
employees_details.Last_Name, employees_details.Department
from employees_details left join project_details
on employees_details.Employee_id = project_details.Employee_id
where project_details.Project_id is null;

-- 14. Write an SQL query to find the names of employees who have ongoing projects that are in 'Finance' 
-- and 'IT' departments. Return the employee_id, first_name, and last_name. 
select employees_details.Employee_id, employees_details.First_Name, employees_details.Last_Name, 
project_details.Project_status, project_details. Department
from employees_details
join project_details
on employees_details.Employee_id = project_details.Employee_id 
where project_details.Project_status = 'Ongoing' 
Having project_details.Department = 'Finance' or project_details.Department = 'IT';

-- 15. Write an SQL query to find the average salary of employees for each project, 
-- rounded to 2 decimal places. Return the project_id, project_name, and average salary. 
select  project_departments.Project_id, project_departments.Project_name, 
round(avg(employees_details.Salary), 2) as Average_Salary
from project_departments
inner join employees_details
on project_departments.Department = employees_details.Department
group by Project_id;

--  16. Write a SQL query to find the average salary of employees, grouped by department and performance 
-- level.
select round(avg(Salary),2) as avg_salary, Department, Performance_level from employees_details 
where Performance_level = 'Below' or Performance_level = 'Needs Improvement' 
or Performance_level = 'Meets' or Performance_level = 'Exceeds' or Performance_level = 'Outstanding'
group by Department, Performance_level order by Department asc ;

-- 17. Find the employee(s) who have the longest tenure 
-- (the difference between date_joined and date_resigned) in each department.
select timestampdiff(year, Date_joined, Date_Resigned) as Contract_length from employees_details ;
alter table employees_details
add column Contract_Length int;
update employees_details set Contract_Length = timestampdiff(year, Date_joined, Date_Resigned);
select Department, max(contract_length) as max_contract_length from employees_details group by Department;

-- 18. Write a query to retrieve the names of employees who have worked on projects that 
-- have been completed, along with the project names and their respective departments.
select employees_details.First_Name, employees_details.Last_Name, 
project_details.Project_status, project_departments.Project_name, project_details. Department
from employees_details
inner join project_details
on employees_details.Employee_id = project_details.Employee_id
inner join project_departments
on project_details.Project_id = project_departments.Project_id
where project_details.Project_status = 'Completed';

-- 19.	Find the employee (s) with the oldest age, name, age, department, salary and performance level.
select First_Name, Last_Name, Age, Department, Salary, Performance_level
from employees_details
order by Age desc limit 1;

-- 20. Find the department(s) with the highest average salary for employees.
select Department, round(avg(Salary),2) as Highest_average_Salary from employees_details
group by Department 
order by Highest_average_Salary desc
limit 1;
-- 21. Retrieve the project details (project_name, start_date, end_date, and department) for projects 
-- that have no employees assigned from the Operations department.
select distinct(project_departments.Project_name), project_details.Start_date, 
project_details.End_date, project_details.Department
from project_departments
inner join project_details
on project_departments.Project_id = project_details.Project_id
where project_details.Department <> 'Operations';

-- 22. Write a query to retrieve the names of employees who have worked on projects that have a duration 
-- (end_date - start_date) longer than a specified number of days (e.g., 500 days).
select employees_details.First_Name, employees_details.Last_Name, project_departments.Project_name, 
datediff(project_details.End_date,project_details.Start_date)as Duration_of_Project
from employees_details
inner join project_details
on employees_details.Employee_id = project_details.Employee_id
inner join project_departments
on project_details.Project_id = project_departments.Project_id
where datediff(project_details.End_date,project_details.Start_date) > 500 ;

-- 23. Find the department(s) with the highest number of employees.
select Department, count(Employee_id) as Number_of_Employees from employees_details
group by Department
order by Number_of_Employees desc limit 1;

-- 24. Find the project(s) that have the highest number of employees assigned to them, and return 
-- the project details (project_name, start_date, end_date, project_status) along with the 
-- count of employees.
select project_departments.Project_name, count(project_details.Employee_id) as no_of_employees, project_details.Start_date, project_details.End_date, project_details.Project_status
from project_details
inner join project_departments
on project_details.Project_id = project_departments.Project_id
group by project_departments.Project_name, project_details.Project_status,
project_details.Start_date, project_details.End_date
order by count(project_details.Employee_id) desc;

-- 25. Find the name, department and performance level of the employee(s) who earns the highest salary. 
select First_Name, Last_Name, Salary, Department, Performance_level 
from employees_details order by Salary desc limit 1;

-- 26. Find the department(s) with the highest average age of employees.
select Department, round(avg(Age),2) as Average_age from employees_details
group by Department
order by Average_age desc limit 1;

-- 27. Write a query to retrieve the names of employees who have worked on projects with a status of 
-- 'Ongoing' and have a date_joined before a specific date (January 1, 2022), along with the project 
-- names and respective departments of the employees .
select employees_details.First_Name, project_departments.Department, employees_details.Last_Name, project_departments.Project_name,
project_details.Start_date, project_details.Project_status
from employees_details
inner join project_details
on employees_details.Employee_id = project_details.Employee_id
inner join project_departments
on project_details.Project_id = project_departments.Project_id
where Project_status = 'Ongoing' 
and Start_date < '2022-01-12';

-- 28. Write a SQL query to find the department(s) that have the highest average salary for employees 
-- and have an 'Outstanding' performance level, and return the department name and the average salary 
-- rounded to the nearest integer.
select  Department, round(avg(Salary)) as Highest_average_salary, Performance_level from employees_details
where Performance_level = 'Outstanding' 
group by Department, Performance_level
order by Highest_average_salary desc limit 1;

-- 29. Write a SQL query to find the project(s) that have the highest average age of employees assigned 
-- to them, and for each of those projects, return the project name, the average age of employees 
-- rounded to the nearest integer, and the count of employees assigned to that project.
select project_departments.Project_name, round(avg(employees_details.Age)) as avg_age, 
count(project_details.Employee_id) as Number_of_Employees_Assigned
from employees_details
inner join project_details
on employees_details.Employee_id = project_details.Employee_id
inner join project_departments
on project_details.Project_id = project_departments.Project_id
group by project_departments.Project_name;

-- 30. Find the department(s) with the highest average salary for employees who have worked on 
-- completed projects, and return the department name(s) and the corresponding average salary.
select project_details.Department, project_details.Project_status, 
round(avg(employees_details.Salary),2) as Average_Salary
from employees_details
inner join project_details
on employees_details.Employee_id = project_details.Project_id
where Project_status = 'Completed'
group by Department; 