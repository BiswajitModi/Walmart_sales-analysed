select*from walmart;
--drop table walmart;
select count (*) from walmart;
select 
      payment_method,
    count(*)
	from walmart
group by payment_method;
select 
     count (distinct branch)
from walmart;
select max(quantity) from walmart;
select min(quantity) from walmart;

--Business problems
--Q1) Find different payment method and number of transactions, number of quantity sold
select 
      payment_method,
    count(*) as no_of_payments,
	sum(quantity) as no_of_qoantity_sold
	from walmart
group by payment_method;

--Q2) Identify the highest-rated category in each branch, displaying the branch, category
select *
from
(
select 
      branch,
      category,
	avg (rating) as avg_rating,
	rank() over(partition by branch order by avg(rating) desc) as rank 
	from walmart
group by 1,2
)
where rank = 1

--Q3) Identify the busiest day for each branch based on the number of transactions
select *
from
(
SELECT 
   branch,
   to_char(to_date(date, 'DD/MM/YY') , 'Day')  as day_name,
   count(*) as no_of_transactions,
   rank() over(partition by branch order by count(*) desc) as rank
FROM walmart
group by 1,2 
)
where rank = 1
	
	
--Q4) Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

select 
      payment_method,
    sum(quantity) as no_of_quantity_sold
	from walmart
group by payment_method;


--Q5) Determine the average, minimum, and maximum rating of products for each city. 
--List the city, average_rating, min_rating and max_rating.

select 
      city,
	  category,
	  min(rating) as min_rating,
	  max(rating) as max_rating,
	  avg (rating) as avg_rating
	  from walmart
group by 1,2


--Q8 categorize sales into 3 groups MORNINg, AFTERNOON, EVENING.
--Find out each of the shift and number of invoices

select
    branch,
  case 
      when extract(hour from(time::time)) < 12 then 'Morning'
      when extract (hour from(time::time)) between 12 and 17 then 'Afternoon'
	  else 'Evening'
	  end day_time,
	  count (*)
from walmart
group by 1,2
order by 1,3 desc


--Q9) Identify 5 branch with highest decrease ratio in 
--revenue compare to last year(current year 2023 and last year 2022)
--revenue decrease ratio (rdr == last_rev-cr_rev/rev*100
select *,
extract (year from to_date(date, 'DD/MM/YY'))  as formated_date

( 
-- 2022 sales

with revenue_2022
as
(
select
     branch,
	 sum(total) as revenue
from walmart
 where extract (year from to_date(date, 'DD/MM/YY')) = 2022
group by 1
),

revenue_2023
as
(
select
     branch,
	 sum(total) as revenue
from walmart
 where extract (year from to_date(date, 'DD/MM/YY')) = 2023
group by 1
)

select 
      ls.branch,
	  ls.revenue as last_year_revenue,
	  cs.revenue as cr_year_revenue,
	  Round(
	      (ls.revenue - cs.revenue)::numeric/
	      ls.revenue::numeric*100,
	      2) as rev_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where 
     ls.revenue > cs.revenue
order by 4 desc
limit 5
