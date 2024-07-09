-- 1. Fetch the employee number, first name and last name of those employees who are working as
-- Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)

select employeeNumber, firstName, lastName from	employees
where jobTitle = 'Sales Rep' and reportsTo = '1102';

-- 2. Show the unique productline values containing the word cars at the end from the products table.
select distinct productLine from products
where productLine like '%Cars%';

-- 3. CASE STATEMENTS for Segmentation
-- 1. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
-- &quot;North America&quot; for customers from USA or Canada &quot;Europe&quot; for customers from UK, France, or Germany and others 
select customerNumber, customerName, 
case 
	when country in ('USA', 'Canada') then 'North_America'
    when country in ('UK' , 'France' , 'Germany') then 'Europe'
    else 'Others'
end as CustomerSegment
from customers;

-- 4 Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.
select productCode, sum(quantityOrdered) as QTY from orderdetails
group by 1
order by sum(quantityOrdered) desc;

-- 5. Company wants to analyze payment frequency by month. Extract the month name from the
-- payment date to count the total number of payments for each month and include only those months
-- with a payment count exceeding 20 (Refer Payments table).

select date_format(paymentDate, '%M') as Monthh, count(paymentDate) as Countt from payments
group by 1, month(paymentDate)
Having count(paymentDate) > 20
order by month(paymentDate);

-- 6. Creating table customers 
create database Customers_Orders;
create table Customers_Orders.Customers
(
customer_id int auto_increment primary key,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(255),
phone_number varchar(20)
);

-- 7. Creating table Orders 
create table Customers_Orders.Orders
	(
	order_id int AUTO_INCREMENT primary key,
	customer_id int,
	order_date date, 
	total_amount Decimal(10,2),
	constraint check_positive check(total_amount>=0),
	foreign key (customer_id) references Customers(customer_id)
	);
    
-- 8. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)
select a.country , count(b.orderNumber) as shipped_count from customers a
inner join orders b
on a.customerNumber = b.customerNumber
group by 1
order by 2 desc
limit 5;

-- 9. SELF JOIN
create table classicmodels.project
(
EmployeeID int auto_increment primary key,
FullName varchar(50) not null,
Gender enum('Male','Female'),
ManagerID int 
);

insert into project
(FullName, Gender, ManagerID)
values
('Pranaya', 'Male', 3),
('Priyanka', 'Female', 1),
('Preety', 'Female', NULL),
('Anurag', 'Male', 1),
('Sambit', 'Male', 1),
('Rajesh', 'Male', 3),
('Hina', 'Female', 3);

select * from project;

select a.FullName as Manager, b.FullName EmpName from project a
right join project as b
on a.EmployeeID = b.ManagerID
where a.FullName is not null
order by 1;

-- 10. 
create table classicmodels.facility
(
Facility_ID int auto_increment primary key,
Name varchar(100),
State varchar(100),
Country varchar(100)
);
Alter table facility
add city varchar(100) not null after Name;
select * from facility;

-- 11. Using customers and orders tables, rank the customers based on their order frequency 
with A as 
(
select a.customerNumber as CustName, count(b.orderNumber) as OrderCount from customers a
inner join orders b
on a.customerNumber = b.customerNumber
group by 1
)
select *, dense_rank() over(order by OrderCount desc) Ranking from A; 

-- 12. Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.
with B as 
(
with A as
(
select year(orderDate) years, date_format(orderDate, '%M') Months, count(orderNumber) OrderCount from orders
group by 1, 2 
) 
select * , lag(OrderCount) over (order by years) PreCount, 
round((OrderCount - (lag(OrderCount) over (order by years)))/(lag(OrderCount) over (order by years))*100.0 ,0) MOM 
from A
)
select years, Months, OrderCount, PreCount, concat(MOM,'%') as MOM_P from B;

-- 13. Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.
-- Considering Each product line average --
SELECT productLine, count(productLine) AS countt from 
(
select productLine from 
 (select productLine,buyPrice, avg(buyPrice) over (partition by productLine) as AvgPrice from products) as A 
	WHERE buyPrice>AvgPrice
) as B
group by 1 
order by 2 desc;

-- Considering overall Avg--
select productLine, count(productLine) Tcount from products
where buyPrice > (select avg(buyPrice) from products)
group by 1
order by 2 desc;

--  14. Triggers : Create before insert trigger to make sure any new value of Working_hours, if it is negative, then it should be inserted as positive.

create table classicmodels.Emp_BIT
(
Name varchar(50),
Occupation varchar(50),
Working_date date,
Working_hours time
);

insert into Emp_BIT
(Name, Occupation, Working_date, Working_hours)
values
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);

ALTER TABLE Emp_BIT
MODIFY COLUMN Working_hours INT;
select * from Emp_BIT;

-- Triggers 
DELIMITER **
CREATE TRIGGER t1
before insert on Emp_BIT
for each row
begin
	if new.Working_hours<0 THEN 
	set NEW.Working_hours = ABS(NEW.Working_hours);
	end if; 
END** 

-- V I E W S -- 
select a.productLine, sum(b.quantityOrdered*b.priceEach) as price, count(distinct b.orderNumber) TotOrders from products a
inner join orderdetails b	
on a.productCode = b.productCode
group by 1;

select * from product_category_sales;

-- S T O R E D - P R O C E D U R E S -- orderdetails c -- customers b

Select year(a.orderDate) Yearr, b.country, round(sum(c.quantityOrdered*c.priceEach),1) Sales from orders a
inner join orderdetails c
on a.orderNumber = c.orderNumber
inner join customers b
on b.customerNumber = a.customerNumber
group by 1, 2; 

call `Get_country_payments`(2023, 'Germany')

--
