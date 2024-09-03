create database employees;
use employees;

CREATE TABLE EmployeeDetails (
EmployeeID INT PRIMARY KEY,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Department VARCHAR(50),
Salary DECIMAL(10,2),
HireDate DATE);


INSERT INTO EmployeeDetails (EmployeeID, FirstName, LastName, Department, Salary, HireDate)
VALUES
(1, 'Amit'   , 'Sharma'   , 'HR'       , 50000.00, '2015-05-20'),
(2, 'Anjali' , 'Singh'    , 'IT'       , 60000.00, '2017-08-15'),
(3, 'Rahul'  , 'Verma'    , 'Marketing', 55000.00, '2020-01-10'),
(4, 'Priya'  , 'Reddy'    , 'Finance'  , 65000.00, '2017-04-25'),
(5, 'Vikram' , 'Patel'    , 'HR'       , 52000.00, '2017-09-30'),
(6, 'Amit'  , 'Mishra'   , 'IT'        , 62000.00, '2021-11-18'),
(7, 'Suresh' , 'Iyer'     , 'Marketing', 58000.00, '2024-02-26'),
(8, 'Lakshmi', 'Menon'    , 'Finance'  , 70000.00, '2022-07-12'),
(9, 'Arjun'  , 'Menon'    , 'HR'       , 53000.00, '2023-10-05'),
(10, 'Nisha' , 'Mehta'    , 'IT'       , 64000.00, '2016-03-08');

SELECT * FROM EmployeeDetails;

--   Retrieve only the FirstName and LastName of all employees.
SELECT FirstName, LastName FROM employeeDetails;

--   Retrieve distinct departments from the employeeDetails table.
SELECT DISTINCT Department FROM employeeDetails;

--  Retrieve employees whose salary is greater than 55000.
SELECT * FROM employeeDetails WHERE Salary > 55000;

--  Retrieve employees hired after 2019.
SELECT * FROM employeeDetails WHERE HireDate > '2019-12-31';

--   Retrieve employees sorted by their salary in descending order.
SELECT * FROM employeeDetails ORDER BY Salary DESC;

--  Retrieve the count of employees in each department.
SELECT Department, COUNT(*) AS EmployeeCount FROM employeeDetails GROUP BY Department;

--  Retrieve the average salary of employees in the Finance department.
SELECT AVG(Salary) AS AverageSalary FROM employeeDetails WHERE Department = 'Finance';

--  Retrieve the maximum salary among all employees.
SELECT MAX(Salary) AS MaxSalary FROM employeeDetails;

-- Retrieve the total salary expense for the company.
SELECT SUM(Salary) AS TotalSalaryExpense FROM employeeDetails;

--  Retrieve the oldest and newest hire date among all employees.
SELECT MIN(HireDate) AS OldestHireDate, MAX(HireDate) AS NewestHireDate FROM employeeDetails;

--  Retrieve employees with a salary between 50000 and 60000.
SELECT * FROM employeeDetails WHERE Salary BETWEEN 50000 AND 60000;

--  Retrieve employees who are in the HR department and were hired before 2019.
SELECT * FROM employeeDetails WHERE Department = 'HR' AND HireDate < '2019-01-01';

--  Retrieve employees with a salary less than the average salary of all employees.
SELECT * FROM employeeDetails WHERE Salary < (SELECT AVG(Salary) FROM employeeDetails);

--  Retrieve the top 3 highest paid employees.
SELECT * FROM employeeDetails ORDER BY Salary DESC limit 3;

--  Retrieve employees whose hire date is not in 2017.
SELECT * FROM employeeDetails WHERE YEAR(HireDate) <> 2017;

--   Retrieve the 3rd highest salary .
SELECT Salary FROM employeeDetails GROUP BY Salary ORDER BY Salary DESC LIMIT 1 OFFSET 2;

--  Retrieve employees who were hired in the same year as ‘Priya Reddy’.
SELECT * FROM employeeDetails WHERE YEAR(HireDate) = (SELECT YEAR(HireDate) FROM employeeDetails WHERE FirstName = 'Priya' AND LastName = 'Reddy');

--   Retrieve employees who have been hired on weekends (Saturday or Sunday).
SELECT *  FROM employeeDetails WHERE  DAYOFWEEK(HireDate) IN (1, 7);

--   Retrieve employees who have been hired in the last 6 years.
SELECT * FROM employeeDetails  WHERE HireDate >=  DATE_SUB(CURDATE(), INTERVAL 6 YEAR);

--   Retrieve the department with the highest average salary.
SELECT Department
FROM employeeDetails
GROUP BY Department
HAVING AVG(Salary) = (
    SELECT MAX(AvgSalary)
    FROM (
        SELECT AVG(Salary) AS AvgSalary
        FROM employeeDetails
        GROUP BY Department
    ) AS AvgSalaries
);

-- METHOD 2
SELECT Department, AVG(Salary) AS AvgSalary
FROM employeeDetails
GROUP BY Department
ORDER BY Avgsalary DESC
LIMIT 1;

--  Retrieve the top 2 highest paid employees in each department.
SELECT EmployeeID, FirstName, LastName, Department,
Salary
FROM (
    SELECT EmployeeID, FirstName,LastName,
    DepartmenT,
    Salary,
    ROW_NUMBER() OVER(PARTITION BY Department ORDER BY Salary DESC) AS Rankk
    FROM employeeDetails
    ) AS RankedemployeeDetails
    WHERE Rankk <= 2;

--  Method 2 :
WITH CTE AS
(
SELECT EmployeeID, FirstName, LastName, Department, Salary,
ROW_NUMBER() OVER(PARTITION BY Department ORDER BY Salary DESC) AS Rankk
FROM employeeDetails
)

SELECT * FROM CTE  WHERE Rankk <= 2;

--  Retrieve the cumulative salary expense for each department sorted by department and hire date.
SELECT EmployeeID, FirstName, LastName, Department, Salary,HireDate,
SUM(Salary) OVER(PARTITION BY Department ORDER BY HireDate) AS CumulativeSalaryExpense
FROM employeeDetails
ORDER BY Department, HireDate;

-- METHOD 2
SELECT 
    EmployeeID, FirstName, LastName, Department, Salary,HireDate,
    @cumulative_salary := @cumulative_salary + salary AS cumulative_salary
FROM employeeDetails, (SELECT @cumulative_salary := 0) AS init
ORDER BY Department,HireDate;


--    Retrieve the employee ID, salary, and the next highest salary for each employee.
SELECT EmployeeID,
Salary,
LEAD(Salary) OVER (ORDER BY Salary DESC) AS NextHighestSalary
FROM employeeDetails;

--    Retrieve the employee ID, salary, and the difference between the current salary and the next highest salary for each employee.
SELECT EmployeeID, Salary,
Salary - LEAD(Salary) OVER (ORDER BY Salary DESC)  AS SalaryDifference
FROM employeeDetails;

--   Retrieve the employee(s) with the highest salary in each department.
SELECT *FROM (
  SELECT *, dense_rank() OVER(PARTITION BY Department ORDER BY Salary DESC) AS Rankk
  FROM employeeDetails
) AS RankedemployeeDetails
  WHERE Rankk = 1;
  
-- METHOD 2
SELECT  EmployeeID, FirstName, LastName, Department, Salary
FROM employeeDetails
WHERE (Department, Salary) IN (
    SELECT Department, MAX(Salary)
    FROM employeeDetails
    GROUP BY Department
);

  
--   Retrieve the department(s) where the total salary expense is greater than the average total salary expense across all departments.
SELECT Department, SUM(Salary) AS TotalSalaryExpense
FROM employeeDetails
GROUP BY Department
HAVING SUM(Salary) >
(SELECT AVG(TotalSalaryExpense) FROM
            (SELECT SUM(Salary) AS TotalSalaryExpense
            FROM employeeDetails GROUP BY Department) AS AvgTotalSalary);
            
--   Retrieve the employee(s) who have the same first name and last name as any other employee.
SELECT *
FROM employeeDetails e1
WHERE EXISTS (
    SELECT 1
    FROM employeeDetails e2
    WHERE e1.EmployeeID != e2.EmployeeID
    AND e1.FirstName = e2.FirstName
    AND e1.LastName = e2.LastName );
    
-- METHOD 2
SELECT EmployeeID, FirstName,LastName 
FROM employeeDetails
WHERE (FirstName,LastName) IN (
    SELECT FirstName,LastName
    FROM employeeDetails
    GROUP BY FirstName,LastName
    HAVING COUNT(*) > 1
);

    
--  Retrieve the employee(s) who have been with the company for more then 7 Years.
SELECT EmployeeID, FirstName, LastName, Department, Salary,HireDate
FROM employeeDetails
WHERE DATEDIFF(CURDATE(), HireDate) > 7 * 365;


--   Retrieve the department with the highest salary range (Difference b/w highest and lowest).
SELECT Department, MAX(Salary) - MIN(Salary) AS SalaryRange
FROM employeeDetails
GROUP BY Department
ORDER BY SalaryRange DESC


