select * from dbo.Orders$
select cast([order date] as date) from dbo.Orders$
select cast([ship date] as date) from dbo.Orders$
-- inorder to change the orderdate and shipdate format ftom datetime to date

alter table orders$
 add neworderdate date
 --to make permanenet changes to the table by inserting values into the new column
 update Orders$
 set neworderdate= convert(date,[order date])
 -- to add for ship date
 alter table orders$
 add newshipdate date
 --to make permanenet changes to the table by inserting values into the new column
 update Orders$
 set newshipdate=convert(date,[ship date])
 ---- to add a new column of   month
 select DATENAME(MONTH,neworderdate) from dbo.Orders$
 alter table orders$
 add [monthname] nvarchar(50)

 update Orders$
 set [monthname]=datename(month,neworderdate

 -- we want to delete the order date and ship date column inorder to clean our dataset
-- to ensure data integrity we can use transaction in sql inorder for us to undo incase 
begin transaction tolu
alter table orders$
drop column [order date],[ship date]
-- to check if the column was dropped
select * from dbo.Orders$
-- inorder to undo just incase we  needs the column we use rollback transaction 
rollback transaction tolu
 

-- to chcek to see if the table has a duplicate by  checkig how mnay distinct values
 select distinct * from dbo.orders$
 
 -- lets remove duplicate inorder to perform proper analysis
 -- we use cte and row_number partitiion

 with  ordercte as
 (
 select *,ROW_NUMBER() over( partition by [order id],[ship mode],[customer id],[sales rep],[product id],[neworderdate], profit,[location id],discount order by[product id]) row_num 
 from dbo.Orders$
 ) delete from ordercte where row_num>1

-- lets create a tempoary table to join the tabels together
create table #tempoary
( orderid nvarchar(100),
customerid nvarchar(250),
orderdate date,
shipdate date,
productid nvarchar (250),
locationid nvarchar(250),
shipmode nvarchar(210),
profit int
)
insert into #tempoary
select [order id],[customer id],neworderdate,[newshipdate],[Product ID],[Location ID],[Ship Mode], profit 
from dbo.orders$

select * from #tempoary
-- creating a secondary tempoary tabel two hold the first tempoary table and and a join to the product table
create table #tempoary2
( orderid nvarchar(100),
customerid nvarchar(250),
orderdate date,
shipdate date,
productid nvarchar (250),
locationid nvarchar(250),
shipmode nvarchar(210),
profit int,
category nvarchar(50),
subcategory nvarchar(50)
)


insert into #tempoary2
select orderid,customerid,orderdate,shipdate,productid,locationid,shipmode, profit ,category,[Sub-Category]
from dbo.#tempoary
join  dbo.products$
on
dbo.#tempoary.productid=dbo.products$.[product id]

select * from #tempoary2

-- first we create a third tempoary table 
-- then  we combined 3 tables togethher using join inorder to make a table for analyses
-- the 3 tables combined includes location, #tempoary and customer table
 create table temmpoaryordertable1
 (orderid nvarchar(100),
 customerid nvarchar(10),
 orderdate date,
 shipdate date,
 productid nvarchar(250),
 locationid nvarchar(250),
 shipmode nvarchar(210),
 profit int,
 category nvarchar (50),
 subcategory nvarchar(50),
 [state] nvarchar(50),
 region nvarchar(60),
 )
 
 insert into temmpoaryordertable1
select orderid,customerid,orderdate,shipdate,productid,locationid,shipmode, profit ,category,subcategory,[state],Region
from dbo.#tempoary2
join
dbo.location$
on
location$.[location id]=#tempoary2.locationid
join
customers$
on
#tempoary2.customerid=customers$.[customer id]

-----------------------
select * from temmpoaryordertable1


 --- to see which month had the higest order
select [monthname],COUNT([orderid]) as total from dbo.Orders$
group by [monthname]
order by 2 desc

 select * from Orders$
 -- for us to decide the ship mode that brought in most profit
 select sum( profit) as totalsumprofit,[ship mode] from dbo.Orders$
 group by [Ship Mode]
 order by totalsumprofit desc
 -- to see the distinct number of sales rep
 select distinct([sales rep]) from dbo.Orders$
 -- to see the amount of profit each sale rep made
 select sum(profit) as totalsumprofit,[sales rep] from dbo.Orders$
 group by [Sales Rep]
 -- we can alternatively use  order by totalsumprofit instead of 1 same works the same
 order by 1 desc

-- to join orders table with loaction table we use the join statement
select * from dbo.Location$


-- lets use a dervied table and joins to some calculations
-- to get the sum of profit by state and sorting from highest to lowest
declare @locationorder table(state nvarchar(50),city nvarchar(50),region nvarchar(50),profit int)
insert into @locationorder
select state,city,region,profit
from dbo.Orders$
join
dbo.Location$
on dbo.Orders$.[Location ID]=dbo.Location$.[Location ID]
select state,sum(profit) as totalsumprofit from @locationorder
group by state
order by 2 desc


----- lets use cte and pivotable to do some analzing with joins
--- we usae pivotablle and common tabel expression

with cte (productname,category ,profit ) as
(
select [product name],category,profit from dbo.orders$
join dbo.products$ 
on 
dbo.orders$.[product id]=dbo.products$.[product id]
)
-- we isnull incase null values comes u to replace null with 0
select Productname, isnull (Furniture,0) as Furniture, isnull([Office supplies],0) as [Office Suplies], isnull (Technology,0) as Technology
from(select productname,category,profit
from cte )
as purchasetable
pivot
( sum(profit) for category IN (Furniture,[Office Supplies],Technology) )
AS PIVOTTABLE

--- A subqieery to help get the information of customer  with the hihest profit
select * from dbo.orders$
where   profit =(select max(profit) from dbo.orders$) 

select * from temmpoaryordertable1
-- to get the region with the higest order
select region, count(orderid) from dbo.temmpoaryordertable1 group by region

-- to view the relation of number or orders with profit
select region ,sum(profit) as totalprofit, count(orderid) as totalorder from dbo. temmpoaryordertable1  group by region


-- to view the total number of order in relation to ship mode and profit
select shipmode, count(distinct(orderid)) as totalorders, sum(profit) as totalprofit from dbo.temmpoaryordertable1 group by shipmode

-- to get thr top states with the higest order and profit
select top 10 state, count(ORDERID)as totalcount, sum(profit) as totalprofit FROM DBO.temmpoaryordertable1 group by state order by 2 desc

---  a stored procedure that helps us to get the information of a person anytime 
create procedure sporders
@state nvarchar(100),
@customerid nvarchar(50)
as
begin
select * from temmpoaryordertable1 where [state]=@state and customerid=@customerid
end
-- how to execute a stored procedure
sporders 'florida','dc-12850'



