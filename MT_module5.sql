/*
select * from Suppliers;	
select * from Details;
select * from Products;
select * from Supplies;
*/

--a
select p.productid 
from Products p
where p.productid in 
(
select productid 
from Supplies
where supplierid = 3
);

--b
select sr.supplierid, sr.name,  s.productid, s.quantity
from Supplies s
inner join  Suppliers sr ON (s.supplierid = sr.supplierid)
inner join 
(
select s.productid , avg(s.quantity) as avg_quantity
from Supplies s 
where s.detailid = 1
group by s.productid
) av ON (s.productid = av.productid)
where  s.detailid = 1
and s.quantity > av.avg_quantity;


--c
select d.detailid, d.name 
from Supplies s 
inner join Details d ON (s.detailid = d.detailid)
where s.productid IN
(select p.productid
 from Products p
 where p.city = 'London')
 ;

 --d
 select distinct sr.supplierid, sr.name
from Supplies s 
inner join Suppliers sr ON (s.supplierid = sr.supplierid)
where s.detailid IN 
(select d.detailid
 from Details d 
 where color ='Red'
);

--e
select d.detailid
from Details d 
where d.detailid IN 
(select s.detailid 
 from Supplies s 
 where s.supplierid = 2
 );

 --f
 select s.productid, avg(quantity) as avg_quantity
 from Supplies s 
 group by productid 
 Having avg(quantity) >
 (
 select max(s.quantity) as max_quantity
 from Supplies s
 where  s.productid = 1
 );

 --g
 select *
 from Details d
 where d.detailid not in 
 (
 select s.detailid 
 from Supplies s
 );
 ---------------------------------------------------------------------
 --CTE
 --1
 WITH 
  E1(N) AS (
            SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
            SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
            SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
           ),                          -- 1*10^1 or 10 rows
  E2(N) AS (SELECT 1 FROM E1 a, E1 b), -- 1*10^2 or 100 rows
  E4(N) AS (SELECT 1 FROM E2 a, E2 b)  -- 1*10^4 or 10,000 rows
  
 SELECT TOP (10000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4 
;

--2
--(10!)
WITH 
ct 
AS 
     (select 1 as n, 1 as factorial
	  union all
	  select n+1, (n+1)*factorial
	  from ct
	  where n<10
	  )
SELECT n, factorial 
FROM ct
WHERE n=10;


--3
WITH 
ct 
AS 
     (select 1 as l, 1 as n, 1 as fb
	  union all
	  select l+1, n+fb, n as fb
	  from ct
	  where l<20
	  )
SELECT l, n, fb 
FROM ct;
/*
l - recursive level, n - next number, fb - FibonacciNumber
*/

--4
WITH ct AS
          (select cast('2013-11-25' as date) as date_column
		   UNION ALL
		   select DATEADD (day, 1, ct.date_column) as date_column
		   from ct 
		   where ct.date_column < cast('2014-03-05' as date)
          ),
col as (
SELECT date_column, 
       cast(DATEADD(month, DATEDIFF(month, 0, date_column), 0) as date) AS StartOfMonth,
	   EOMONTH (date_column) as EndOfMonth	   
FROM ct 
),
res as (
SELECT distinct
       case when date_column = cast('2013-11-25' as date) then date_column else StartOfMonth end as StartDate,
       case when date_column = cast('2014-03-05' as date) then date_column else EndOfMonth end as EndDate
FROM col
)
SELECT *
FROM res 
WHERE StartDate >= cast('2013-11-25' as date)
AND EndDate <=cast('2014-03-05' as date)
option (maxrecursion 0) 
;
/*
That allows you to specify how often the CTE can recurse before generating an error. 
Maxrecursion 0 allows infinite recursion.
*/

--5
WITH ct AS
          (select cast(DATEADD(month, DATEDIFF(month, 0, SYSDATETIME()), 0) as date) as date_column
		   UNION ALL
		   select DATEADD (day, 1, ct.date_column) as date_column
		   from ct 
		   where ct.date_column < cast(EOMONTH(SYSDATETIME()) as date)
          ),
pt as (
       select date_column, DATENAME (WEEKDAY, date_column) as day_of_week
       from ct 
      ),
calendar as
     (
SELECT date_column,  (DATEPART(day,date_column)-1)/7 + 1 as weeknumber,
                    case when day_of_week = 'Monday' then date_column else null end as Monday,
                    case when day_of_week = 'Tuesday' then date_column else null end as Tuesday,
					case when day_of_week = 'Wednesday' then date_column else null end as Wednesday,
					case when day_of_week = 'Thursday' then date_column else null end as Thursday,
					case when day_of_week = 'Friday' then date_column else null end as Friday,
					case when day_of_week = 'Saturday' then date_column else null end as Saturday,
					case when day_of_week = 'Sunday' then date_column else null end as Sunday
FROM pt 
     )
select
weeknumber,
 max(Monday) Monday,
 max(Tuesday) Tuesday,
 max(Wednesday) Wednesday,
 max(Thursday) Thursday,
 max(Friday) Friday,
 max(Saturday) Saturday,
 max(Sunday) Sunday
from calendar  
group by weeknumber;


--6
--table Geography
select region_id, name 
from Geography  
where region_id = 1;

--7
WITH ct as 
          (select g.id, g.name, g.region_id
		   from Geography  g
		   where  region_id = 4 

		   UNION ALL

		   select g.id, g.name, g.region_id
		   from Geography g 
		   inner join ct ON (g.region_id = ct.id)
		   )
select *
from ct;

--8
WITH ct as 
          (select g.id, g.name, g.region_id, 0 as level
		   from Geography  g
		   where  region_id is null

		   UNION ALL

		   select g.id, g.name, g.region_id, ct.level+1
		   from Geography g 
		   inner join ct ON (g.region_id = ct.id)
		   )
select *
from ct;

--9
WITH ct as 
          (select g.id, g.name, g.region_id, 0 as level
		   from Geography  g
		   where  name = 'Lviv'

		   UNION ALL

		   select g.id, g.name, g.region_id, ct.level+1
		   from Geography g 
		   inner join ct ON (g.region_id = ct.id)
		   )
select *
from ct;

--10
WITH ct as 
          (select g.id, g.name, g.region_id,  CAST(CONCAT('/',g.name) as varchar) as path
		   from Geography  g
		   where  name = 'Lviv'

		   UNION ALL

		   select g.id, g.name, g.region_id, CAST(CONCAT(CONCAT(ct.path, '/'), g.name) as varchar) as path
		   from Geography g 
		   inner join ct ON (g.region_id = ct.id)
		   )
select *
from ct;

--11
WITH ct as 
          (select g.id, g.name, g.region_id,  0 as level, CAST(CONCAT('/',g.name) as varchar) as path
		   from Geography  g
		   where  name = 'Lviv'

		   UNION ALL

		   select g.id, g.name, g.region_id, ct.level+1, CAST(CONCAT(CONCAT(ct.path, '/'), g.name) as varchar) as path
		   from Geography g 
		   inner join ct ON (g.region_id = ct.id)
		   )
select *
from ct
where level>0;


 ---------------------------------------------------------------------

 --UNION, UNION ALL, EXCEPT, INTERSECT
 --1
 select * 
 from Suppliers
 where city = 'London'
 
 UNION ALL

  select * 
 from Suppliers
 where city = 'Paris'
 ;

 --2
 select city 
 from Suppliers

 UNION
 
 select distinct city 
 from Details 
 order by city
 ;


 --3
 select *
 from Suppliers 
 EXCEPT
 select *
 from Suppliers
 where city = 'London'
 ;

 --4
 select *
 from Products 
 where city IN  ('London','Paris')
 INTERSECT
  select *
 from Products 
 where city IN  ('Paris','Roma')
 ;

 --5
 select s.supplierid, s.detailid, s.productid
 from Supplies  s
 where s.supplierid IN 
 (select supplierid
  from Suppliers 
  where city = 'London')

  UNION
(
select s.supplierid, s.detailid, s.productid
 from Supplies  s
 where s.detailid IN 
 (select detailid 
  from Details
  where color = 'Green'
  )
EXCEPT
select s.supplierid, s.detailid, s.productid
 from Supplies  s
 where s.productid IN 
 (select productid 
  from Products
  where city = 'Paris'
  )
 ); 