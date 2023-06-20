--SQL Advance Case Study
CREATE DATABASE db_SQLCaseStudies

--Q1--BEGIN 
select State 
from FACT_TRANSACTIONS f
join DIM_LOCATION l on l.IDLocation=f.IDLocation
where Date between '01-01-2005' and getdate();

--Q1--END

--Q2--BEGIN
	
select top 1
state from DIM_LOCATION l
inner join FACT_TRANSACTIONS f on f.IDLocation=l.IDLocation
inner join DIM_MODEL m on m.IDModel=f.IDModel
inner join DIM_MANUFACTURER a on a.IDManufacturer=m.IDManufacturer
where Manufacturer_Name='Samsung'
group by State
order by sum(Quantity) desc;

--Q2--END

--Q3--BEGIN      
select Model_Name, State,count(IDCustomer)[no_of_transactions],ZipCode from DIM_LOCATION l
inner join FACT_TRANSACTIONS f on l.IDLocation=f.IDLocation
inner join DIM_MODEL c on f.IDModel=c.IDModel
group by State,ZipCode,Model_Name;

--Q3--END

--Q4--BEGIN
select top 1
Unit_price
from DIM_MODEL
order by Unit_price asc;

--Q4--END

--Q5--BEGIN
select Model_Name,AVG(Unit_price)[Average_price] from DIM_MODEL m
inner join DIM_MANUFACTURER d on m.IDManufacturer=d.IDManufacturer
where Manufacturer_Name in 
(
select top 5
Manufacturer_Name from FACT_TRANSACTIONS f
inner join DIM_MODEL m on f.IDModel=m.IDModel
inner join DIM_MANUFACTURER d on m.IDManufacturer=d.IDManufacturer
group by Manufacturer_Name
order by sum(Quantity))
group by Model_Name
order by AVG(Unit_price);

--Q5--END

--Q6--BEGIN
select Customer_Name, AVG(TotalPrice)[Average_amount] from FACT_TRANSACTIONS f
inner join DIM_CUSTOMER c on f.IDCustomer=c.IDCustomer
where YEAR(Date)='2009'
group by Customer_Name
having AVG(TotalPrice)>500;
--Q6--END
	
--Q7--BEGIN  
select model from
(select top 5 DIM_MODEL.Model_Name as model from DIM_MODEL
inner join FACT_TRANSACTIONS
on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
group by DIM_MODEL.Model_Name,
year(FACT_TRANSACTIONS.date)
having(year(FACT_TRANSACTIONS.date)='2008')
order by SUM(FACT_TRANSACTIONS.Quantity)desc)as a

INTERSECT

select model from
(select top 5 DIM_MODEL.Model_Name as model from DIM_MODEL
inner join FACT_TRANSACTIONS
on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
group by DIM_MODEL.Model_Name,
YEAR(FACT_TRANSACTIONS.date)
having (year(FACT_TRANSACTIONS.date)='2009')
order by SUM(FACT_TRANSACTIONS.Quantity)desc)as b

INTERSECT

select model from
(select top 5 DIM_MODEL.Model_Name as model from DIM_MODEL
inner join FACT_TRANSACTIONS
on DIM_MODEL.IDModel=FACT_TRANSACTIONS.IDModel
group by DIM_MODEL.Model_Name,
YEAR(FACT_TRANSACTIONS.date)
having (year(FACT_TRANSACTIONS.date)='2010')
order by SUM(FACT_TRANSACTIONS.Quantity)desc)as c

--Q7--END	
--Q8--BEGIN
with cte1 as (
select 
Manufacturer_Name from DIM_MANUFACTURER m
inner join DIM_MODEL d on m.IDManufacturer=d.IDManufacturer
inner join FACT_TRANSACTIONS f on d.IDModel=f.IDModel
where YEAR(Date)=2009
group by Manufacturer_Name
order by sum(TotalPrice) desc
offset 1 row 
fetch next 1 row only),
cte2 as (
select
Manufacturer_Name from DIM_MANUFACTURER m
inner join DIM_MODEL d on m.IDManufacturer=d.IDManufacturer
inner join FACT_TRANSACTIONS f on d.IDModel=f.IDModel
where YEAR(Date)=2010
group by Manufacturer_Name
order by sum(TotalPrice) desc
offset 1 row 
fetch next 1 row only)

select * from cte1
union 
select * from cte2;

--Q8--END
--Q9--BEGIN
select Manufacturer_Name from DIM_MANUFACTURER m
inner join DIM_MODEL d on m.IDManufacturer=d.IDManufacturer
inner join FACT_TRANSACTIONS f on d.IDModel=f.IDModel
where YEAR(Date)= '2010'
except
select Manufacturer_Name from DIM_MANUFACTURER m
inner join DIM_MODEL d on m.IDManufacturer=d.IDManufacturer
inner join FACT_TRANSACTIONS f on d.IDModel=f.IDModel
where YEAR(Date)= '2009';

--Q9--END

--Q10--BEGIN
	
select a.Customer_Name,a.year,a.Avg_Price,a.Avg_Quantity,

case 
when b.year is not null 
then format (convert(decimal(8,2),(a.Avg_Price-b.Avg_Price))/convert(decimal(8,2),b.Avg_Price),'p') else null
end as 'Yearly_%_Change'

from
(select Customer_Name,YEAR(Date) as year,AVG(TotalPrice) as Avg_Price, AVG(Quantity) as Avg_Quantity from FACT_TRANSACTIONS f
left join DIM_CUSTOMER c on f.IDCustomer=c.IDCustomer
where f.IDCustomer in (select top 100 IDCustomer from FACT_TRANSACTIONS
group by IDCustomer
order by SUM(TotalPrice)desc)
group by c.Customer_Name,YEAR(f.Date)
)a

left join

(select Customer_Name,YEAR(Date) as year,AVG(TotalPrice) as Avg_Price, AVG(Quantity) as Avg_Quantity from FACT_TRANSACTIONS f
left join DIM_CUSTOMER c on f.IDCustomer=c.IDCustomer
where f.IDCustomer in (select top 100 IDCustomer from FACT_TRANSACTIONS
group by IDCustomer
order by SUM(TotalPrice)desc)
group by c.Customer_Name,YEAR(f.Date)
)b
on a.Customer_Name=b.Customer_Name and b.year=a.year-1
--Q10--END
	