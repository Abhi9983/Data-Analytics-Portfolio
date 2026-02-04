-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

Select city_name,
round((population*0.25)/1000000,2) as coffee_consumers_in_millions, city_rank
from city
order by 2 desc;

-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select sum(total) as revenue
from sales
where extract(year from sale_date) = 2023 and
      extract(quarter from sale_date) = 4;

-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

Select p.product_name, count(s.product_id) as total_orders
from sales s
join products p
on p.product_id = s.product_id
group by 1
order by 2 desc;


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
-- city abd total sale
-- no cx in each these city

Select c.city_name, round(avg(s.total),2)as avg_city_per_tans
from sales s
join city c
join customers cs
on s.customer_id = cs.customer_id and
c.city_id = cs.city_id
group by 1
order by 2 desc;

Select c.city_name, sum(s.total) as total_rev,
count(distinct s.customer_id) as total_cx,
round(sum(s.total)/count(distinct s.customer_id),2) as avg_sales_cx
from sales s
join city c
join customers cs
on s.customer_id = cs.customer_id and
c.city_id = cs.city_id
group by 1
order by 2 desc;

- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

With consumer_table as (select city_name, population*0.25 as coffee_consumer
from city),
customer_table as (Select c.city_name, count(distinct cs.customer_id) as unique_cx
from sales s
join city c
join customers cs
on s.customer_id = cs.customer_id and
c.city_id = cs.city_id
group by 1)
select cu.city_name, cu.unique_cx, co.coffee_consumer
from customer_table cu
join consumer_table co on
cu.city_name = co.city_name;

-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

With ranked_products as (Select c.city_name, p.product_name, count(s.total) as total_sales,
dense_rank () Over(partition by c.city_name order by count(s.total) desc) as rn
from sales s
join products p
on s.product_id = p.product_id
join customers cs
on cs.customer_id = s.customer_id
join city c
on c.city_id = cs.city_id
group by 1, 2)
Select * from ranked_products
where rn <= 3;

-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

Select c.city_name, count(distinct cs.customer_id) as unique_cx
from sales s
join products p
on s.product_id = p.product_id
join customers cs
on cs.customer_id = s.customer_id
join city c
on c.city_id = cs.city_id
where p.product_id <= 14
group by 1;

-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
-- Conclusions

with avg_sales as (Select c.city_name,
count(distinct s.customer_id) as total_cx,
round(sum(s.total)/count(distinct s.customer_id),2) as avg_sales_cx
from sales s
join city c
join customers cs
on s.customer_id = cs.customer_id and
c.city_id = cs.city_id
group by 1
order by 3 desc)
select avs.city_name, avs.total_cx, avs.avg_sales_cx,
round(c.estimated_rent/avs.total_cx,2) as avg_rent_cx
from avg_sales avs
join city c on
avs.city_name = c.city_name;


-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

With cr_monthly_sales as (select c.city_name, month(s.sale_date) as month,  year(sale_date) as year, sum(s.total) as cr_month_sales
from sales s
join customers cs
on cs.customer_id = s.customer_id
join city c
on c.city_id = cs.city_id
group by 1,2,3
order by 1,3,2),
pr_monthly_sales as (Select city_name, month, year, cr_month_sales,
lag(cr_month_sales) over(partition by city_name order by year, month) as pr_month_sales 
from cr_monthly_sales)
Select city_name, month, year, cr_month_sales, pr_month_sales,
Round((cr_month_sales-pr_month_sales)/pr_month_sales*100, 2) as growth_ratio
from pr_monthly_sales;

-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

With ranked_city as (select c.city_id, c.city_name, c.estimated_rent as total_rent,
Round(c.population*0.25,0) as est_coffee_consumers, 
count(distinct cs.customer_id) as total_customers, 
sum(s.total) as total_sales,
dense_rank() over(order by sum(s.total) desc) as rn
from sales s
join city c
join customers cs
on s.customer_id = cs.customer_id and
c.city_id = cs.city_id
group by 1,2)
Select city_name, total_sales, total_rent, total_customers, est_coffee_consumers
from ranked_city
where rn <= 3;
