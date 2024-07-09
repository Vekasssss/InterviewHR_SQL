create database Interview;
create table Interview.employee
(
empid int not null,
empName varchar(20),
gender char,
salary int,
city char(50),
primary key(empid)
);

Insert into employee
(empid, empName, gender, salary, city)
values
(1, 'Arjun', 'M', 75000, 'Pune'),
(2, 'Ekadanta', 'M', 125000, 'Bangalore'),
(3, 'Lalita', 'F', 150000 , 'Mathura'),
(4, 'Madhav', 'M', 250000 , 'Delhi'),
(5, 'Visakha', 'F', 120000 , 'Mathura')
;

select * from employee;
----------------------------------------------
create table Interview.employeeDetails
(
empid int(20) not null,
project Varchar(50),
EmpPosition char(20),
DOJ date
)
;
insert into employeeDetails
(empid, project, EmpPosition, DOJ)
values
(1, 'P1', 'Executive', STR_TO_DATE('26-01-2019', '%d-%m-%Y')),
(2, 'P2', 'Executive', STR_TO_DATE('04-05-2020', '%d-%m-%Y')),
(3, 'P1', 'Lead', STR_TO_DATE('21-10-2021', '%d-%m-%Y')),
(4, 'P3', 'Manager', STR_TO_DATE('29-11-2019', '%d-%m-%Y')),
(5, 'P2', 'Manager',STR_TO_DATE('01-08-2020', '%d-%m-%Y'))
;
select * from employeeDetails;

-- Q1> find list of employees whose salary is between 2-3L 
select empName, salary from employee
where (salary >= 200000) and (salary <= 300000)
;

-- Q2> Retrive list of employees from the same city 
select a.empName, a.city from employee as a
inner join employee as b 
on a.city = b.city and a.empName != b.empName;

-- Q3> Find cumulative sum of employee salary as per each employee 
with A as 
(
select a.empName as Empname, sum(a.salary) as Total_salary, datediff(CURDATE(),b.DOJ)/365 as years from employee as a 
left join employeedetails as b 
on a.empid = b.empid
group by 1,3
)
select Empname, Total_salary * years as Cum_salary from A; 

-- Find the Cumulative expenditure of company on the employees salary 
select empName, salary, sum(salary) over (order by b.DOJ) as cum_salary from employee as a 
join employeedetails as b
on a.empid = b.empid;

-- Q4> Find male female employee ratio 
with A as 
(
select gender, count(gender) as countt from employee
group by 1
)
select gender, countt, concat(round((countt / (select sum(countt) from A))*100,0), '%') as ratio from A;

-- Q5> Write a query to fetch 50% records from employee table 
select * from employee 
where empid <= (select round(count(empid)/2,0) from employee);

-- Q6> Fetch employee salary but replace the last 2 digits with XX 
select concat(LEFT(salary, LENGTH(salary)-2), 'XX') from employee;

-- Q7> fetch even and odd rows from Employee table.
select * from employee
where empid % 2 = 0;

select * from employee
where empid % 2 != 0;

select *, case when (empid % 2) = 0 then 'Even' else 'Odd' end as type from employee;

-- Q8> Write a query to find all the Employee names whose name:
-- • Begin with ‘A’
-- • Contains ‘A’ alphabet at second place
-- • Contains ‘Y’ alphabet at second last place
-- • Ends with ‘L’ and contains 4 alphabets
-- • Begins with ‘V’ and ends with ‘A’

select empName from employee
where empName like 'A%';

select empName from employee
where empName like '_A%';

select empName from employee where empName like '%y_';

select empName from employee where empName like '%L%' and length(empName)=4;

select empName from employee where empName like 'V%' and  empName like '%A';

-- Q9> Write a query to find the list of Employee names which is:
    -- starting with vowels (a, e, i, o, or u), without duplicates
    SELECT empName FROM employee
    WHERE lower(empName) regexp '^[aeiou]' ;  -- USE ^ FOR STARTING AND $ FOR ENDING WITH 'LETTERS'
    
    SELECT empName FROM employee
    WHERE lower(empName) regexp '[aeiou]$'; -- ending with 
    
    select empName from employee
    where lower(empName) regexp '^[aeiou].*[aeiou]$';
    
-- Q10> Find Nth highest salary from employee table with and without using the TOP/LIMIT keywords.
SELECT empName , salary FROM (
SELECT empName , salary, RANK() OVER (ORDER BY salary DESC) AS RANKK FROM employee) AS A
WHERE RANKK = 3 ; 

-- Q11> Write a query to find and remove duplicate records from a table.
with A as 
(
select  empid, empName, gender, salary, city , count(*) from employee   -- instead of writng count(each column), used count(*)
group by 1,2,3,4,5
Having count(*) >1
)
Delete from employee 
where empid in (select empid from A);

-- Q12> Query to retrieve the list of employees working in same project.
SELECT empName, project FROM employee AS A
LEFT JOIN  employeedetails AS B 
ON A.empid = B.empid
WHERE project = 'P1';
   -- Method 2 - Helps to get count of members in each project 
with a as 
(
SELECT empName, project FROM employee AS A
LEFT JOIN  employeedetails AS B 
ON A.empid = B.empid
)
select empName , project , count(project) over (partition by project) as members FROM A ; 

-- Q13> Show the employee with the highest salary for each project
WITH A AS 
(
SELECT DISTINCT empName AS emp, project, salary FROM employee AS A
LEFT JOIN  employeedetails AS B 
ON A.empid = B.empid
)
SELECT emp, project, max(salary) over (partition by project) as salaryMax from A;

-- Q14> Query to find the total count of employees joined each year
with A as 
(
SELECT empName, YEAR(DOJ) AS yearr FROM employee AS A
LEFT JOIN  employeedetails AS B 
ON A.empid = B.empid
)
select  yearr, count(empName) as EmpCnt from A
group by yearr;

-- Q15> Create 3 groups based on salary col, salary less than 1L is low, between 1-2L is medium and above 2L is High
SELECT *, 
CASE 
	WHEN (salary < '100000') THEN "lOW" 
	WHEN (salary >= '100000') AND (salary < '200000') THEN "MEDIUM" 
	ELSE "HIGH" 
	END as Type 
from employee; 

-- Q16> Query to pivot the data in the Employee table and retrieve the total salary for each city.
-- The result should display the EmpID, EmpName, and separate columns for each city (Mathura, Pune, Delhi), containing the corresponding total salary.
SELECT empid, empName, city, 
SUM(salary) OVER (PARTITION BY city) TOT_SALARY FROM employee; 

