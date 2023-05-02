-------------------------------------------------<< Indeces >>--------------------------------------------
/*1- create a non-clustered index on the column(Dept_Manager) that allows you to enter a unique dept id in the table Department.*/
create unique index dep_manager
	on Department(ManagerID)

--Index --2
/*Create a non-clustered index on column(EducationLevel) in table(Education)*/
CREATE NONCLUSTERED INDEX in1
ON [dbo].[Education](EducationLevel)

DROP INDEX in1 ON Education



-------------------------------------------------<< VIEWS >>--------------------------------------------

/*1- This is a Summary View for the HR Manger over their department*/

CREATE View HR 
AS
	SELECT 
		COUNT(e.EmployeeID) Total_Employees,
		SUM(e.Salary) Total_Salary,
		AVG(e.Salary) Average_Salary,
		AVG(r.ManagerRate) Average_Performance
	FROM Employee e INNER JOIN Review r
		ON e.EmployeeID = r.EmployeeID
	WHERE e.Attrition = 'No' and e.DepartmentID = 1
Go
select * from HR



/*2- This is a Summary View for the Sales Manger over their department*/

CREATE View Sales 
AS
	SELECT 
		COUNT(e.EmployeeID) Total_Employees,
		SUM(e.Salary) Total_Salary,
		AVG(e.Salary) Average_Salary,
		AVG(r.ManagerRate) Average_Performance
	FROM Employee e INNER JOIN Review r
		ON e.EmployeeID = r.EmployeeID
	WHERE e.Attrition = 'No' and e.DepartmentID = 2
Go
select * from Sales



/*3- This is a Summary View for the Technology Manger over their department*/

CREATE View Technology 
AS
	SELECT 
		COUNT(e.EmployeeID) Total_Employees,
		SUM(e.Salary) Total_Salary,
		AVG(e.Salary) Average_Salary,
		AVG(r.ManagerRate) Average_Performance
	FROM Employee e INNER JOIN Review r
		ON e.EmployeeID = r.EmployeeID
	WHERE e.Attrition = 'No' and e.DepartmentID = 3
Go
select * from Technology


/*4- View to display Active Employees in the company*/

Create view ActiveEmployees
as 
select * from Employee
where Attrition = 'No'
Go
select * from ActiveEmployees


--View --2
/*Rating for employees' satisfaction with their environment. 
(Count 1, 2, 3, 4, and 5) separately.*/
GO
CREATE VIEW environment_satisfaction AS
	SELECT EnvironmentSatisfaction Environment_satisfaction_rate, COUNT(EmployeeID) Employee_count
	FROM Review
	GROUP BY EnvironmentSatisfaction
GO
SELECT * 
FROM environment_satisfaction
ORDER BY Environment_satisfaction_rate
DROP VIEW environment_satisfaction --drop view


/**************************************************************/
--View --3
/*Rating for employees' satisfaction with their job role. 
(Count 1, 2, 3, 4, and 5) separately.*/
GO
CREATE VIEW job_satisfaction AS
	SELECT JobSatisfaction job_satisfaction_rate, COUNT(EmployeeID) employee_count
	FROM Review
	GROUP BY JobSatisfaction
GO
SELECT *
FROM job_satisfaction
ORDER BY job_satisfaction_rate
DROP VIEW job_satisfaction --drop view

/**************************************************************/
--View --4
/*Rating for employees' satisfaction with their relationships at work. 
(Count 1, 2, 3, 4, and 5) separately.*/
GO
CREATE VIEW relationships_satisfaction AS
	SELECT RelationshipSatisfaction relationship_satisfaction_rate, COUNT(EmployeeID) employee_count
	FROM Review
	GROUP BY RelationshipSatisfaction
GO
SELECT *
FROM relationships_satisfaction
ORDER BY relationship_satisfaction_rate
DROP VIEW relationships_satisfaction --drop view


/**************************************************************/
--View --5
/*Rating for employees' satisfaction with their work-life balance. 
(Count 1, 2, 3, 4, and 5) separately.*/
GO
CREATE VIEW work_life_balance_satisfaction AS
	SELECT WorkLifeBalance workLife_balance_rate, COUNT(EmployeeID) employee_count
	FROM Review
	GROUP BY WorkLifeBalance
GO
SELECT *
FROM work_life_balance_satisfaction
ORDER BY workLife_balance_rate
DROP VIEW work_life_balance_satisfaction --drop view


/**************************************************************/
--View --6
/*Rating for employees' performance based on their own views. 
(Count 3, 4, 5) separately.*/
GO
CREATE VIEW self_rate AS
	SELECT SelfRate self_rate, COUNT(EmployeeID) employee_count
	FROM Review
	GROUP BY SelfRate
GO
SELECT *
FROM self_rate
ORDER BY self_rate
DROP VIEW self_rate --drop view



-------------------------------------------------<< FUNCTIONS >>--------------------------------------------

/*1-Function takes  department id as an input to calculate attrition rates for this department*/
Create function AttritionRate(@deptID int)
returns varchar(100) 
as
begin

declare @turnover float
declare @dept_name varchar(50)

select @turnover = CAST(count(case when attrition = 'Yes' then 1 end) as float)/
CAST(count(attrition)as float)*100, @dept_name = Department.DepartmentName
from Employee join Department
on Department.DepartmentID = Employee.DepartmentID
where Employee.DepartmentID = @deptID
group by Department.DepartmentName

return  Concat('Attrition rate in ' , @dept_name, ' department ' , ' is ' , @turnover ,'%')
end
Go
select dbo.AttritionRate(1)



/*2-Function takes employee is as an input to detect if an employee is qualified for promotion or not based on
1- Education Level
2- Manager Rate
3- Years in Most Recent Role
4- Years Since Last Promotion */

Create function promotionCritera (@id nvarchar(100))
returns varchar(50)
as 
begin

declare @education_level int
declare @manager_rate int
declare @avg_manager_rate float
declare @YearsInMostRecentRole int 
declare @YearsSinceLastPromotion int 
declare @avg_YearsInMostRecentRole float
declare @avg_YearsSinceLastPromotion float


select @avg_YearsInMostRecentRole = cast(AVG(History.YearsInMostRecentRole)as float), @avg_YearsSinceLastPromotion = cast(AVG(YearsSinceLastPromotion) as float),  @manager_rate = cast(AVG (ManagerRate) as float)
from ActiveEmployees join Review
on ActiveEmployees.EmployeeID = Review.EmployeeID
join History
on ActiveEmployees.EmployeeID = History.EmployeeID
join Education
on Education.EmployeeID = ActiveEmployees.EmployeeID

select @education_level = EducationLevel, @manager_rate = avg(Review.ManagerRate), @YearsInMostRecentRole = YearsInMostRecentRole, @YearsSinceLastPromotion = YearsSinceLastPromotion
from ActiveEmployees join Review
on ActiveEmployees.EmployeeID = Review.EmployeeID
join History
on ActiveEmployees.EmployeeID = History.EmployeeID
join Education
on Education.EmployeeID = ActiveEmployees.EmployeeID
where ActiveEmployees.EmployeeID = @id
group by ActiveEmployees.EmployeeID, EducationLevel, YearsInMostRecentRole,YearsSinceLastPromotion

return
case 
when @education_level >= 3 
and
( @manager_rate >= @avg_manager_rate or
@YearsInMostRecentRole> @avg_YearsInMostRecentRole 
or  @YearsSinceLastPromotion > @avg_YearsSinceLastPromotion)
then 'Employee is qalified for promotion'
else 'Employee is not qalified for promotion'
end
end 
Go
select dbo.promotionCritera('005C-E0FB')
Go



/*3- This Function Takes a certain rate and gets a list of employees who had more than that rate for 2 consecutive years which 
makes them eligible for a promotion*/
Create Function WhoToPromote (@rate INT) 
RETURNS Table 
AS 
RETURN
	(
		SELECT e.FirstName + ' ' + e.LastName AS Employees 
		FROM Review r1 INNER JOIN Review r2
			ON r1.EmployeeID = r2.EmployeeID and YEAR(r1.ReviewDate) = YEAR(r2.ReviewDate) - 1
			INNER JOIN Employee e 
			ON r1.EmployeeID = e.EmployeeID
		WHERE r1.ManagerRate = @rate and r2.ManagerRate = @rate and e.Attrition = 'NO'
	)
GO
SELECT * FROM WhoToPromote(5)
GO


--Function --5
--Create function takes DepartmentID and gets the best employee in it (without duplicates)
GO
CREATE FUNCTION best_employee_dapartment(@DepartmentID INT)
RETURNS TABLE
AS
RETURN(
	SELECT TOP 1 e.FirstName + ' ' + e.LastName full_name, d.DepartmentName
	FROM Employee e
	JOIN Department d
	ON e.DepartmentID = d.DepartmentID
	JOIN Review r
	ON r.EmployeeID = e.EmployeeID
	WHERE d.DepartmentID = @DepartmentID
	GROUP BY e.FirstName + ' ' + e.LastName, d.DepartmentName
	ORDER BY AVG(r.ManagerRate) DESC
)
GO
SELECT * FROM best_employee_dapartment(1)
DROP FUNCTION best_employee_dapartment --drop function


/*********************************************************************/
--Function --6
/*What is the average of "yes" and"no" in overtime?
What is the average of "yes" and"no" in overtime for each job role?*/
GO
CREATE FUNCTION overtime_average()
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @yes_count FLOAT, @no_count FLOAT, @count_all FLOAT

	SELECT @yes_count = COUNT(OverTime)
	FROM Employee
	WHERE OverTime = 'Yes' AND Attrition = 'No'

	SELECT @no_count = COUNT(OverTime)
	FROM Employee
	WHERE OverTime = 'No' AND Attrition = 'No'

	SELECT @count_all = COUNT(OverTime)
	FROM Employee

	RETURN
		CONCAT('"Yes" average in over time = ', @yes_count/@count_all
				, ' And "No" average in over time = ', @no_count/@count_all)
END
GO
SELECT dbo.overtime_average()
DROP FUNCTION overtime_average



-------------------------------------------------<< Stored Procedures >>--------------------------------------------

/*1-SP to give annual raise based on overage salary for each job role (annual raise)
if salary < average salaries raise is 15% 
if salary > average salaries raise is 10% 
*/

Create PROCEDURE GiveAnnualRaise
AS
BEGIN

with cte
as
(
SELECT JobRole, AVG(salary) AS avg_salary
FROM ActiveEmployees
GROUP BY JobRole
)

UPDATE ActiveEmployees
SET salary = 
CASE
WHEN salary < (SELECT avg_salary FROM cte WHERE cte.JobRole = ActiveEmployees.JobRole) THEN salary * 1.15
ELSE salary * 1.1
END
FROM ActiveEmployees INNER JOIN cte 
ON ActiveEmployees.JobRole = cte.JobRole
END
Go
GiveAnnualRaise



/*2-SP takes the reqiured top N employees and department id to get full name and rate of top N rated employees 
in this department based on manager rate of the employees*/

Create proc NTopEmployee (@topN int, @dept_id int)
as
with cte 
as
(
select ActiveEmployees.EmployeeID, avg(ManagerRate) as avg_mgr_rate
from ActiveEmployees join Review
on ActiveEmployees.EmployeeID = Review.EmployeeID
group by ActiveEmployees.EmployeeID
)

select top(@topN) DR_table.emp_id, EmplyeeNmae
from
(
select cte.EmployeeID as emp_id, ActiveEmployees.FirstName+ ' ' + ActiveEmployees.LastName as EmplyeeNmae, DENSE_RANK() over(order by cte.avg_mgr_rate desc ) as DR
from cte join ActiveEmployees
on cte.EmployeeID = ActiveEmployees.EmployeeID
where ActiveEmployees.DepartmentID = @dept_id
) as DR_table
order by DR
Go
TopEmployee  5,1



/*3-Sp to calculate performance for each emp(Excellent-Good-Needs Evaluation)*/

Create Proc GetEmployeePerformance (@id nvarchar(20))
as
declare @manager_rate int 
declare @avg_manager_rate float 
declare @overtime char(10)


select @avg_manager_rate = cast(AVG (ManagerRate) as float)
from Review

select @id= ActiveEmployees.EmployeeID, @manager_rate = cast(AVG (ManagerRate) as float), @overtime = OverTime
from Review join ActiveEmployees
on Review.EmployeeID = ActiveEmployees.EmployeeID
where ActiveEmployees.EmployeeID = @id
group by ActiveEmployees.EmployeeID, OverTime

if @manager_rate>@avg_manager_rate and @overtime = 'Yes'
	select 'Excellent'
if @manager_rate>@avg_manager_rate or @overtime = 'Yes'
	select 'Good'
else select 'Needs Evaluation'
Go
GetEmployeePerformance '001A-8F88'


/*4- SP to insert employee and department*/
CREATE PROCEDURE Insert_EmployeeAnd_Department
    @FirstName nvarchar(50),
    @LastName nvarchar(50),
    @Jobrole nvarchar(50),
    @DepartmentName nvarchar(50),
	@gender nvarchar(2),
	@age int,
	@BusinessTravel nvarchar(50) = NULL ,
	@DistanceFromHome int = NULL ,
	@State nvarchar(50),
	@MaritalStatus nvarchar(50) = NULL ,
	@Salary int

AS
BEGIN
    DECLARE @DepartmentId int

    -- Insert department
    INSERT INTO Department (DepartmentName)
    VALUES (@DepartmentName)

    -- Get the id of the inserted department
    SET @DepartmentId = SCOPE_IDENTITY()

    -- Insert employee
    INSERT INTO Employee (FirstName, LastName, Gender, Age, BusinessTravel, DepartmentId, DistanceFromHome,State,JobRole,MaritalStatus,Salary,HireDate)
	VALUES (@FirstName, @LastName,@gender,@age,@BusinessTravel, @DepartmentId,@DistanceFromHome,@State, @Jobrole,@MaritalStatus,@Salary,GETDATE())
END



/*5- This procedure is used to promote Employees. It takes the ID of the employee, the new Slary, and their new Role as arguments.
It also Resets the YearsInMostRecentRole and YearsSinceLastPromotion to Zeros*/
Create Proc Promotion @ID INT, @Salary INT, @Role nvarchar(100)
AS 
	BEGIN TRY
		UPDATE Employee SET Salary = @Salary, JobRole = @Role WHERE EmployeeID = @ID
		UPDATE History SET YearsInMostRecentRole = 0, YearsSinceLastPromotion = 0 WHERE EmployeeID = @ID
	END TRY
	BEGIN CATCH
		SELECT 'Error'
	END Catch 
GO


/*6- This Procedure takes a current date, can be the GETDATE() and a percentage It compares the date to the HireDate
if an Employee was hired on the same date it increases their salary by the percentage as the annual raise*/ 
Create Proc AnnualRaise @Date date, @Percent INT
AS 
	BEGIN TRY
		UPDATE Employee SET Salary = ((Salary * @Percent)/100)+Salary 
			WHERE DAY(HireDate) = DAY(@Date) AND MONTH(HireDate) = MONTH(@Date) and Attrition = 'NO'
	END TRY
	BEGIN CATCH
		SELECT 'Error'
	END Catch 
GO


--SP --10
--Create a stored procedure responsible for DML Queries for table employee.
--Insert
GO 
CREATE PROC insert_employee(@EmployeeID VARCHAR(100), @FirstName VARCHAR(100)=NULL, 
			@LastName VARCHAR(100)=NULL, @Gender VARCHAR(50)=NULL, @Age INT=NULL, 
			@BusinessTravel VARCHAR(100)=NULL, @DepartmentID INT=NULL, 
			@DistanceFromHome INT=NULL, @State VARCHAR(20)=NULL, 
			@JobRole VARCHAR(100)=NULL, @MaritalStatus VARCHAR(50)=NULL, 
			@Salary INT=NULL, @OverTime VARCHAR(20)=NULL, @HireDate DATE=NULL, 
			@Attrition VARCHAR(20)=NULL)
AS
	INSERT INTO Employee
	VALUES(@EmployeeID, @FirstName, @LastName, @Gender, @Age, 
		@BusinessTravel, @DepartmentID, @DistanceFromHome, @State, 
		@JobRole, @MaritalStatus, @Salary, @OverTime, @HireDate, @Attrition)
GO
insert_employee gg5248
insert_employee @EmployeeID=gg5249, @LastName=ahmed
insert_employee @EmployeeID=gg5250, @FirstName=sara, @LastName=ali, @Salary=6000
SELECT *
FROM Employee
DROP PROC insert_employee --drop SP


/********************************/
--Update Salary
GO
CREATE PROC update_employee_salary(@EmployeeID VARCHAR(100), @Salary INT)
AS
	UPDATE Employee
	SET Salary = @Salary
	WHERE EmployeeID = @EmployeeID

	SELECT CONCAT('You updated the salary of the employee that has an id = ', @EmployeeID, 
	' to be ', @Salary, '$') AS Result
GO
update_employee_salary gg5250, 7500
SELECT *
FROM Employee
DROP PROC update_employee_salary --drop SP


/********************************/
--Update DepartmentID
GO
CREATE PROC update_employee_departmentID(@EmployeeID VARCHAR(100), @DepartmentID INT)
AS
	UPDATE Employee
	SET DepartmentID = @DepartmentID
	WHERE EXISTS(
			SELECT *
			FROM Department
			WHERE DepartmentID = @DepartmentID)
			AND EmployeeID = @EmployeeID

	SELECT CONCAT('You updated the departmentID of the employee that has an id = ', @EmployeeID, 
	' to be ', @DepartmentID, '.') AS Result
GO
update_employee_departmentID gg5250, 3
SELECT *
FROM Employee
DROP PROC update_employee_departmentID --drop SP


/********************************/
--Delete with EmployeeID
GO
CREATE PROC delete_employee(@EmployeeID VARCHAR(100))
AS
	DELETE FROM Employee
	WHERE EmployeeID = @EmployeeID
GO
delete_employee gg5248
SELECT *
FROM Employee
DROP PROC delete_employee --drop SP


-------------------------------------------------<< Triggers >>--------------------------------------------

--1- Trigger 
/* This is an Audit Table for Salary, Job Role, or Attrition Update, and for New Employee Insert and New Review Insert
This Helps the HR team to Track the changes that hppened in certain times*/
CREATE TABLE AuditTable
(
Old VARCHAR(100) , 
New VARCHAR(100) , 
UserInfo VARCHAR(MAX) , 
DateOfUpdate DATE
)
GO
Create Trigger UpdateAudit
ON Employee 
After Update 
AS
	IF Update(Salary)
	BEGIN	
		DECLARE @OldSal VARCHAR(100), @NewSal VARCHAR(100)
		SELECT @OldSal = Salary FROM deleted
		SELECT @NewSal = Salary FROM inserted
		INSERT INTO AuditTable VALUES (@OldSal, @NewSal, SUSER_NAME(), GETDATE())
	END
	
	IF Update(JobRole)
	BEGIN
		DECLARE @OldRole VARCHAR(100), @NewRole VARCHAR(100)
		SELECT @OldRole = JobRole FROM deleted
		SELECT @NewRole = JobRole FROM inserted
		INSERT INTO AuditTable VALUES (@OldRole, @NewRole, SUSER_NAME(), GETDATE())	
	END

	IF Update(Attrition)
	BEGIN
		DECLARE @OldAtt VARCHAR(100), @NewAtt VARCHAR(100)
		SELECT @OldAtt = Attrition FROM deleted
		SELECT @NewAtt = Attrition FROM inserted
		INSERT INTO AuditTable VALUES (@OldAtt, @NewAtt, SUSER_NAME(), GETDATE())	
	END

GO 

CREATE Trigger InsertEmp
On Employee 
After Insert 
AS
	Declare @NewID nvarchar(100), @NewFName nvarchar(100)
	SELECT @NewID = EmployeeID FROM inserted
	SELECT @NewFName = FirstName FROM inserted 
	INSERT INTO AuditTable VALUES (Null, @NewID, SUSER_NAME(), GETDATE())
	SELECT Concat ('Welcome ', @NewFName, ' to our Company')
GO

CREATE Trigger InsertRev
On Review 
After Insert 
AS
	Declare @RevID nvarchar(50), @EmployeeID nvarchar(100), @ReviewDate Date
	SELECT @RevID = ReviewID FROM inserted
	SELECT @EmployeeID = EmployeeID FROM inserted 
	SELECT @ReviewDate = ReviewDate FROM inserted
	INSERT INTO AuditTable VALUES (Null, @RevID, SUSER_NAME(), GETDATE())
	SELECT Concat ('Thank you ', @EmployeeID, ' for your Review on ', @ReviewDate)

GO



/*2- Create trigger to raise salary by 10% on updating marital status to 'married'*/
Create Trigger MaritalStatusRaise
on Employee
After update
AS
    if Update(MaritalStatus)
	Begin
		if exists (select 1 from inserted where MaritalStatus = 'Married')
		Begin 
			update Employee
			SET Salary = i.Salary * 1.1
			from Employee e inner join inserted i
			on e.EmployeeID = i.EmployeeID
			where i.MaritalStatus = 'Married'
		End
	End



/*3-Trigger to welcome new employees and handle error if the employee id already exists in table*/
Create Trigger t1
on Employee
after insert
as
begin
	SET NOCOUNT ON
	begin try
		declare @emp_id  int, @Name varchar(10)

		SELECT @emp_id = inserted.EmployeeID, @Name = inserted.FirstName FROM inserted;

		if exists (select * from Employee where @emp_id =EmployeeID) 
		begin
			Throw 5000, 'This employee ID already exists in the table',1
		end
		else select 'Welcome ' + @Name + ' !'
	end try
	begin catch
		Rollback
		select 'Error ' + ERROR_MESSAGE()
	end catch

end

--Trigger --3
--Trigger that prevents users from dropping any table
GO
CREATE TRIGGER prevent_drop
ON DATABASE
FOR DROP_TABLE
AS
	ROLLBACK 
	SELECT 'You can not drop any table in HR Database'
GO
DROP TABLE Rate



-------------------------------------------------<< CURSORS >>--------------------------------------------

/*1- Cursor to Check if Gender='Male' add 'Mr Befor Employee name??
else if Gender='Female' add Mrs Befor Employee name? then display all names? use cursor for update */

DECLARE c_name CURSOR FOR
    SELECT e.Gender, e.FirstName
    FROM Employee e;

DECLARE @employee_name VARCHAR(MAX), @gend VARCHAR(10)

OPEN c_name
FETCH c_name INTO @gend, @employee_name

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @gend = 'Male'
    BEGIN
        UPDATE Employee
        SET FirstName = CONCAT( 'MR' ,' ', @employee_name)
        WHERE CURRENT OF c_name;
    END
    ELSE IF @gend = 'Female'
    BEGIN
        UPDATE Employee
        SET FirstName = CONCAT( 'MRs' ,' ', @employee_name)
        WHERE CURRENT OF c_name;
    END;
    FETCH c_name INTO @gend, @employee_name
END

CLOSE c_name
DEALLOCATE c_name
Go
SELECT e.Gender, e.FirstName
FROM Employee e



/*2- apply cursor on promotionCritera function to shaw table of which employee is qualified for promotion and which is not*/
-- Declare cursor to loop through employee IDs
DECLARE c1 CURSOR FOR
SELECT EmployeeID FROM Employee

OPEN c1;

CREATE TABLE #promotion_eligibility (
    employee_id nvarchar(50),
    is_eligible varchar(50)
);

declare @employee_id nvarchar(50)
declare @is_eligible varchar(50)

FETCH NEXT FROM c1 INTO @employee_id;

WHILE @@FETCH_STATUS = 0
BEGIN

    SET @is_eligible = dbo.promotionCritera(@employee_id);


    INSERT INTO #promotion_eligibility (employee_id, is_eligible)
    VALUES (@employee_id, @is_eligible);

    FETCH NEXT FROM c1 INTO @employee_id;
END

CLOSE c1;
DEALLOCATE c1;
Go
SELECT * FROM #promotion_eligibility


--Cursor --3
/*If the employee's marital status is "Married" and distance from home > 30KM increase his salary by 1000$. 
And if his marital status is "Divorced" and distance from home > 40KM increase his salary by 700$. 
And if his marital status is "Single" and distance from home > 40KM increase his salary by 500$. */
DECLARE c1 CURSOR 
FOR
	SELECT MaritalStatus, DistanceFromHome
	FROM Employee
	WHERE Attrition = 'No'
FOR UPDATE
DECLARE @MaritalStatus NVARCHAR(50)
DECLARE @DistanceFromHome INT
OPEN c1
FETCH c1 INTO @MaritalStatus, @DistanceFromHome
WHILE @@FETCH_STATUS = 0
	BEGIN
		IF(@MaritalStatus = 'Married') AND (@DistanceFromHome > 30)
			BEGIN
				UPDATE Employee
				SET Salary = Salary + 1000
				WHERE CURRENT OF c1
			END
		ELSE IF (@MaritalStatus = 'Divorced') AND (@DistanceFromHome > 40)
			BEGIN
				UPDATE Employee
				SET Salary = Salary + 700
				WHERE CURRENT OF c1
			END
		ELSE IF (@MaritalStatus = 'Single') AND (@DistanceFromHome > 40)
			BEGIN
				UPDATE Employee
				SET Salary = Salary + 500
				WHERE CURRENT OF c1
			END
		FETCH c1 INTO @MaritalStatus, @DistanceFromHome
	END
SELECT * FROM Employee
CLOSE c1



-------------------------------------------------<< Queries >>--------------------------------------------

-- 1- Retrive for each Department its' name , total number of employee , total salary , Cume_Dist and STD

select d.DepartmentName, COUNT(e.FirstName) as Number_Employees
, SUM(e.Salary) as Total_Salary , CUME_DIST() OVER(ORDER BY SUM(e.Salary)) AS CUM_DIST , STDEV(SUM(e.Salary)) over (order by SUM(e.Salary) DESC) as The_difference_between_your_salary_each_department_and_another
from Employee e
inner join Department d on d.DepartmentID = e.DepartmentID
group by d.DepartmentName
order by Total_Salary DESC

-- 2- Retrive for each Department its' name , MAX SALARY , Average_Salary, Minumum_Salary

select d.DepartmentName, MAX(e.Salary) Maxmimum_Salary , AVG(e.Salary) Average_Salary ,MIN(e.Salary) Minumum_Salary
from Employee e
inner join Department d on d.DepartmentID = e.DepartmentID
group by d.DepartmentName


-- 3- Retrive for each Department its' name , Employee_Name , EducationLevel , DepartmentName ,Salary , YearsSinceLastPromotion

select e.FirstName + ' ' +e.LastName as Employee_Name , ed.EducationLevel , ed.EducationField,d.DepartmentName, e.Salary , h.YearsSinceLastPromotion
from Employee e
inner join Department d on d.DepartmentID = e.DepartmentID
inner join Education ed on e.EmployeeID = ed.EmployeeID
inner join History h on e.EmployeeID = h.EmployeeID
group by d.DepartmentName,ed.EducationLevel , e.FirstName , e.LastName , ed.EducationField, h.YearsSinceLastPromotion , e.Salary 
having AVG(e.Salary) < (select AVG(Salary) from Employee)
order by d.DepartmentName, e.Salary DESC



-- 4- Get the max 2 salaries??? 

select top(2) Salary
from Employee
order by Salary DESC



-- 5- Average of employees' age.

select AVG(Age ) [Average Age for Employee]
from Employee 



--  6- How many employees age from 25 to 40 and from 40 to 60?

SELECT COUNT(*) AS 'Number of Employees'
FROM Employee
WHERE Age BETWEEN 25 AND 40 OR Age BETWEEN 40 AND 60;



-- 7- Count the number of employees in each department then rank them in ascending order.

SELECT DepartmentID, COUNT(*) AS NumberOfEmployees
FROM Employee
GROUP BY DepartmentID
ORDER BY NumberOfEmployees ASC;

--Query --9
--What is the most frequently reviewed month for employees?
SELECT TOP 1 MONTH(ReviewDate) review_month, COUNT(ReviewID) no_of_reviews
FROM Review
GROUP BY MONTH(ReviewDate)
ORDER BY no_of_reviews DESC


/**************************************************************/
--Query --10
--What is the job that employees are most satisfied with?
SELECT TOP 1 e.JobRole, COUNT(*) employee_count
FROM Employee e
JOIN Review r
ON r.EmployeeID = e.EmployeeID
WHERE r.JobSatisfaction = 5 AND e.Attrition = 'No'
GROUP BY e.JobRole, r.JobSatisfaction
ORDER BY employee_count DESC


/**************************************************************/
--Query --11
--What is the job that employees are least satisfied with?
SELECT TOP 1 e.JobRole, COUNT(*) employee_count
FROM Employee e
JOIN Review r
ON r.EmployeeID = e.EmployeeID
WHERE r.JobSatisfaction = 1 AND e.Attrition = 'No'
GROUP BY e.JobRole, r.JobSatisfaction
ORDER BY employee_count DESC


/**************************************************************/
--Query --12
/*Who is the best employees in each department (have the same rank)
from the manager's point of view? (ManagerRating)*/
SELECT *
FROM (
	SELECT DISTINCT e.FirstName + ' ' + e.LastName full_name, d.DepartmentName
					,DENSE_RANK() OVER(PARTITION BY d.DepartmentName ORDER BY AVG(r.ManagerRate) DESC) dr_best_average --with duplicates
					,ROW_NUMBER() OVER(PARTITION BY d.DepartmentName ORDER BY AVG(r.ManagerRate) DESC) rn_best_average --without duplicates
	FROM Employee e
	JOIN Department d
	ON e.DepartmentID = d.DepartmentID
	JOIN Review r
	ON r.EmployeeID = e.EmployeeID 
	WHERE e.Attrition = 'No'
	GROUP BY d.DepartmentName, e.FirstName + ' ' + e.LastName
) AS average_table
WHERE dr_best_average = 1


/**************************************************************/
--Query --13
/*Know the number of male employees and the number of female employees in the company.  
(in each department)*/
SELECT e.DepartmentID, d.DepartmentName, e.Gender, COUNT(e.gender) gender_count
FROM Employee e
JOIN Department d
ON e.DepartmentID = d.DepartmentID
WHERE e.Gender = 'Male' OR e.Gender = 'Female' AND e.Attrition = 'No'
GROUP BY e.Gender, e.DepartmentID, d.DepartmentName
ORDER BY e.DepartmentID, gender_count DESC


/**************************************************************/
--Query --16
/*How many employees' age is greater than the average of all employees' age?*/
SELECT COUNT(*)
FROM Employee
WHERE Age > (
	SELECT AVG(Age)
	FROM Employee
) AND Attrition = 'No'


/**************************************************************/
--Query --17
/*Count Frequency of the three categories of business travel*/
SELECT BusinessTravel, COUNT(*) business_travel_frequency 
FROM Employee
WHERE BusinessTravel IS NOT NULL AND Attrition = 'No'
GROUP BY BusinessTravel
ORDER BY COUNT(*) DESC


/**************************************************************/
--Query --19
/*How many employees are more than 35 km away from work? and What is their average age?*/
SELECT COUNT(EmployeeID) employee_count, AVG(Age) average_age
FROM Employee
WHERE DistanceFromHome > 35 AND Attrition = 'No'


/**************************************************************/
--Query --20
/*What is the number of employees in each state and what are their departments?*/
SELECT d.DepartmentName, e.State, COUNT(e.EmployeeID) employees_number
FROM Employee e
JOIN Department d
ON e.DepartmentID = d.DepartmentID
WHERE e.State IS NOT NULL AND e.Attrition = 'No'
GROUP BY e.State, d.DepartmentName


/**************************************************************/
--Query --21
/*Does the level of education affect the job role or salary?*/
--From the result we fined that level 5 in education affects the salay in a good way
SELECT ed.EducationLevel, AVG(em.Salary) average_salary
FROM Employee em
JOIN Education ed
ON ed.EmployeeID = em.EmployeeID
WHERE em.Attrition = 'No'
GROUP BY EducationLevel
ORDER BY AVG(em.Salary) DESC


/**************************************************************/
--Query --23
/*How many employees are in each job role?*/
SELECT JobRole, COUNT(EmployeeID) employees_count
FROM Employee
WHERE JobRole IS NOT NULL AND Attrition = 'No'
GROUP BY JobRole
ORDER BY employees_count DESC


/**************************************************************/
--Query --25
/*What is the average salary for each job role?*/
SELECT JobRole, AVG(Salary) average_salary
FROM Employee
WHERE JobRole IS NOT NULL AND Attrition = 'No'
GROUP BY JobRole
ORDER BY AVG(Salary) DESC


/**************************************************************/
--Query --26
/*What is the count of "yes" and"no" in overtime for each job role?*/
SELECT JobRole, COUNT(OverTime) yes_OverTime
FROM Employee
WHERE OverTime = 'Yes' AND Attrition = 'No'
GROUP BY JobRole
ORDER BY COUNT(OverTime) DESC

SELECT JobRole, COUNT(OverTime) no_OverTime
FROM Employee
WHERE OverTime = 'No' AND Attrition = 'No'
GROUP BY JobRole
ORDER BY COUNT(OverTime) DESC
/**************************************************************/
--Query --21
/*Does the level of education affect the salary?*/
--From the result we fined that level 5 in education affects the salay in a good way
SELECT ed.EducationLevel, AVG(em.Salary) average_salary
FROM Employee em
JOIN Education ed
ON ed.EmployeeID = em.EmployeeID
WHERE Attrition = 'No'
GROUP BY EducationLevel
ORDER BY AVG(em.Salary) DESC


/**************************************************************/
--Query --22
/*What is the field in which employees are recruited the most and what are their average salaries?*/
SELECT JobRole, COUNT(*) employee_count, AVG(Salary) average_salary
FROM Employee
WHERE JobRole IS NOT NULL AND Attrition = 'No'
GROUP BY JobRole
ORDER BY employee_count DESC


/**************************************************************/
--Query --24
/*Does marital status affect the performance of the employee? (use rating)*/
--From the insights we see that marital status doesn't affect the performance
SELECT MaritalStatus, AVG(ManagerRate) average_manager_rate
FROM Employee e
JOIN Review r
ON r.EmployeeID = e.EmployeeID
WHERE MaritalStatus IS NOT NULL AND e.Attrition = 'No'
GROUP BY MaritalStatus


/**************************************************************/
--Query --29
/*What is the most and least hiring year?*/
--From the insights we see that 2022 is the most hiring year and 2017 is the least hiring year
SELECT YEAR(HireDate) hiring_year, COUNT(EmployeeID) employee_count
FROM Employee
WHERE YEAR(HireDate) IS NOT NULL
GROUP BY YEAR(HireDate)
ORDER BY employee_count DESC


/**************************************************************/
--Query --37
/*Does gender affect performance?*/
--From the insights we see that gender doesn't affect the performance
SELECT Gender, AVG(ManagerRate) average_manager_rate
FROM Employee e
JOIN Review r
ON r.EmployeeID = e.EmployeeID
WHERE Gender IN ('Male', 'Female') AND e.Attrition = 'No'
GROUP BY Gender


/**************************************************************/
--Query --34
/*What is the state which has the best employees?*/
--We see that all states have the same average employees rate, so there is not the best state
SELECT State, AVG(ManagerRate) average_manager_rate
FROM Employee e
JOIN Review r
ON r.EmployeeID = e.EmployeeID
WHERE State IS NOT NULL AND e.Attrition = 'No'
GROUP BY State


/**************************************************************/
--Query --26
/*What is the count of "yes" and"no" in overtime for each job role?*/
SELECT JobRole, COUNT(OverTime) yes_OverTime
FROM Employee
WHERE OverTime = 'Yes' AND Attrition = 'No'
GROUP BY JobRole
ORDER BY COUNT(OverTime) DESC

SELECT JobRole, COUNT(OverTime) no_OverTime
FROM Employee
WHERE OverTime = 'No' AND Attrition = 'No'
GROUP BY JobRole
ORDER BY COUNT(OverTime) DESC
