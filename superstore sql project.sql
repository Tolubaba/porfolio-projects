SELECT * FROM dbo.Orders$
SELECT CAST([order date] AS DATE) FROM dbo.Orders$
SELECT CAST([ship date] AS DATE) FROM dbo.Orders$

-- inorder to change the orderdate and shipdate format ftom datetime to date
ALTER TABLE orders$
 ADD neworderdate DATE
 --to make permanenet changes to the table by inserting values into the new column
 UPDATE Orders$
 SET neworderdate= CONVERT(DATE,[order date])
 -- to add for ship date
 ALTER TABLE orders$
 ADD newshipdate DATE
 --to make permanenet changes to the table by inserting values into the new column
 UPDATE Orders$
 SET newshipdate=CONVERT(DATE,[ship date])
 ---- to add a new column of   month
 SELECT DATENAME(MONTH,neworderdate) FROM dbo.Orders$
 ALTER TABLE orders$
 ADD [monthname] NVARCHAR(50)

 UPDATE Orders$
 SET [monthname]=DATENAME(MONTH,neworderdate)

 -- we want to delete the order date and ship date column inorder to clean our dataset
-- to ensure data integrity we can use transaction in sql inorder for us to undo incase 
BEGIN TRANSACTION tolu
ALTER TABLE orders$
DROP COLUMN [order date],[ship date]
-- inorder to undo just incase we  needs the column we use rollback transaction 
ROLLBACK TRANSACTION tolu
 

-- to chcek to see if the table has a duplicate by  checkig how mnay distinct values
 SELECT DISTINCT * FROM dbo.orders$
 
 -- lets remove duplicate inorder to perform proper analysis
 -- we use cte and row_number partitiion

 WITH ordercte AS
 (
 SELECT *,ROW_NUMBER() OVER( PARTITION BY [order id],[ship mode],[customer id],[sales rep],[product id],[neworderdate], profit,[location id],discount order by[product id]) row_num 
 FROM dbo.Orders$
 ) DELETE FROM ordercte WHERE row_num>1

-- lets create a tempoary table to join the tabels together
CREATE TABLE #tempoary
( orderid NVARCHAR(100),
customerid NVARCHAR(250),
orderdate DATE,
shipdate date,
productid NVARCHAR (250),
locationid NVARCHAR(250),
shipmode NVARCHAR(210),
profit INT
)
INSERT INTO #tempoary
SELECT [order id],[customer id],neworderdate,[newshipdate],[Product ID],[Location ID],[Ship Mode], profit 
FROM dbo.orders$

SELECT * FROM #tempoary
-- creating a secondary tempoary tabel two hold the first tempoary table and and a join to the product table
CREATE TABLE #tempoary2
( orderid NVARCHAR(100),
customerid NVARCHAR(250),
orderdate DATE,
shipdate DATE,
productid NVARCHAR (250),
locationid NVARCHAR(250),
shipmode NVARCHAR(210),
profit INT,
category NVARCHAR(50),
subcategory NVARCHAR(50)
)


INSERT INTO #tempoary2
SELECT orderid,customerid,orderdate,shipdate,productid,locationid,shipmode, profit ,category,[Sub-Category]
FROM dbo.#tempoary
JOIN  dbo.products$
ON
dbo.#tempoary.productid=dbo.products$.[product id]

SELECT * FROM #tempoary2

-- first we create a third tempoary table 
-- then  we combined 3 tables togethher using join inorder to make a table for analyses
-- the 3 tables combined includes location, #tempoary and customer table
 CREATE TABLE temmpoaryordertable1
 (orderid NVARCHAR(100),
 customerid  NVARCHAR(10),
 orderdate DATE,
 shipdate DATE,
 productid NVARCHAR(250),
 locationid NVARCHAR(250),
 shipmode NVARCHAR(210),
 profit INT,
 category NVARCHAR (50),
 subcategory NVARCHAR(50),
 [state] NVARCHAR(50),
 region NVARCHAR(60),
 )
 
 INSERT INTO temmpoaryordertable1
SELECT orderid,customerid,orderdate,shipdate,productid,locationid,shipmode, profit ,category,subcategory,[state],Region
FROM dbo.#tempoary2
JOIN
dbo.location$
ON
location$.[location id]=#tempoary2.locationid
JOIN
customers$
ON
#tempoary2.customerid=customers$.[customer id]

-----------------------
SELECT* FROM temmpoaryordertable1


 --- to see which month had the higest order
SELECT  [monthname],COUNT([orderid]) AS total FROM dbo.Orders$
GROUP BY [monthname]
ORDER BY 2 DESC

 SELECT * FROM Orders$
 -- for us to decide the ship mode that brought in most profit
 SELECT SUM( profit) AS totalsumprofit,[ship mode] FROM dbo.Orders$
 GROUP BY [Ship Mode]
 ORDER BY totalsumprofit DESC
 -- to see the distinct number of sales rep
 SELECT DISTINCT ([sales rep]) FROM dbo.Orders$
 -- to see the amount of profit each sale rep made
 SELECT SUM(profit) AS totalsumprofit,[sales rep] FROM dbo.Orders$
 GROUP BY [Sales Rep]
 -- we can alternatively use  order by totalsumprofit instead of 1 same works the same
 ORDER BY 1 DESC

-- to join orders table with loaction table we use the join statement
SELECT * FROM dbo.Location$


-- lets use a dervied table and joins to some calculations
-- to get the sum of profit by state and sorting from highest to lowest
DECLARE @locationorder TABLE(STATE NVARCHAR(50),city NVARCHAR(50),region NVARCHAR(50),profit INT)
INSERT INTO @locationorder
SELECT STATE,city,region,profit
FROM dbo.Orders$
JOIN
dbo.Location$
on dbo.Orders$.[Location ID]=dbo.Location$.[Location ID]
SELECT STATE,SUM(profit) AS totalsumprofit FROM @locationorder
GROUP BY STATE
ORDER BY 2 DESC


----- lets use cte and pivotable to do some analzing with joins
--- we usae pivotablle and common tabel expression

WITH cte (productname,category ,profit ) AS
(
SELECT [product name],category,profit FROM dbo.orders$
JOIN dbo.products$ 
ON
dbo.orders$.[product id]=dbo.products$.[product id]
)
-- we isnull incase null values comes u to replace null with 0
SELECT Productname, ISNULL (Furniture,0) AS Furniture, ISNULL([Office supplies],0) AS [Office Suplies], ISNULL (Technology,0) AS Technology
FROM(SELECT productname,category,profit
FROM cte )
AS purchasetable
PIVOT
( SUM(profit) FOR category IN (Furniture,[Office Supplies],Technology) )
AS PIVOTTABLE

--- A subqieery to help get the information of customer  with the hihest profit
SELECT * FROM dbo.orders$
WHERE   profit =(SELECT MAX(profit) FROM dbo.orders$) 

SELECT  * FROM temmpoaryordertable1
-- to get the region with the higest order
SELECT region, COUNT(orderid) FROM dbo.temmpoaryordertable1 GROUP BY region

-- to view the relation of number or orders with profit
SELECT region ,SUM(profit) AS totalprofit, COUNT(orderid) AS totalorder FROM dbo. temmpoaryordertable1 
GROUP BY region


-- to view the total number of order in relation to ship mode and profit
SELECT shipmode, COUNT (DISTINCT(orderid)) AS totalorders, SUM(profit) AS totalprofit FROM dbo.temmpoaryordertable1
GROUP BY shipmode

-- to get thr top states with the higest order and profit
SELECT TOP 10 STATE, COUNT(ORDERID) AS totalcount, SUM(profit) AS totalprofit FROM DBO.temmpoaryordertable1 
GROUP BY STATE ORDER BY 2 DESC

---  a stored procedure that helps us to get the information of a person anytime 
CREATE PROCEDURE sporders
@state NVARCHAR(100),
@customerid NVARCHAR(50)
AS
BEGIN
SELECT * FROM temmpoaryordertable1 WHERE [state]=@state and customerid=@customerid
END
-- how to execute a stored procedure
sporders 'florida','dc-12850'



