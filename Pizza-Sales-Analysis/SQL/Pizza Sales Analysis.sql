-- ============================================
-- PIZZA SALES ANALYSIS
-- Tools: MySQL
-- Dataset: Pizza Sales
-- ============================================


-- ============================================
-- 1. DATABASE & TABLE STRUCTURE
-- ============================================

CREATE DATABASE IF NOT EXISTS pizza_sales;
USE pizza_sales;

CREATE TABLE city (
  city_id INT PRIMARY KEY,
  city_name VARCHAR(15),
  population BIGINT,
  estimated_rent FLOAT,
  city_rank INT
);

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(25),
  city_id INT,
  CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(35),
  price FLOAT
);

CREATE TABLE sales (
  sale_id INT PRIMARY KEY,
  sale_date DATE,
  product_id INT,
  customer_id INT,
  total FLOAT,
  rating INT,
  CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
  CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


-- ============================================
-- 2. EXPLORATORY DATA ANALYSIS (EDA)
-- ============================================

-- Total Revenue
SELECT SUM(total) AS total_revenue
FROM sales;

-- Total Orders
SELECT COUNT(sale_id) AS total_orders
FROM sales;

-- Revenue by Product
SELECT p.product_name,
       COUNT(s.sale_id) AS total_orders
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC;

-- Revenue by City
SELECT c.city_name,
       SUM(s.total) AS total_sales
FROM sales s
JOIN customers cs ON s.customer_id = cs.customer_id
JOIN city c ON cs.city_id = c.city_id
GROUP BY c.city_name
ORDER BY total_sales DESC;


-- ============================================
-- 3. TIME-BASED ANALYSIS
-- ============================================

-- Monthly Sales by City
SELECT c.city_name,
       MONTH(s.sale_date) AS month,
       YEAR(s.sale_date) AS year,
       SUM(s.total) AS monthly_sales
FROM sales s
JOIN customers cs ON s.customer_id = cs.customer_id
JOIN city c ON cs.city_id = c.city_id
GROUP BY c.city_name, year, month
ORDER BY c.city_name, year, month;

-- Monthly Growth Rate
WITH monthly_sales AS (
    SELECT c.city_name,
           MONTH(s.sale_date) AS month,
           YEAR(s.sale_date) AS year,
           SUM(s.total) AS sales
    FROM sales s
    JOIN customers cs ON s.customer_id = cs.customer_id
    JOIN city c ON cs.city_id = c.city_id
    GROUP BY c.city_name, year, month
),
growth_calc AS (
    SELECT *,
           LAG(sales) OVER (PARTITION BY city_name ORDER BY year, month) AS prev_month_sales
    FROM monthly_sales
)
SELECT city_name,
       month,
       year,
       sales,
       prev_month_sales,
       ROUND((sales - prev_month_sales) / prev_month_sales * 100, 2) AS growth_percentage
FROM growth_calc;


-- ============================================
-- 4. CUSTOMER & MARKET ANALYSIS
-- ============================================

-- Average Sales per Customer by City
SELECT c.city_name,
       COUNT(DISTINCT s.customer_id) AS total_customers,
       ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sales_per_customer
FROM sales s
JOIN customers cs ON s.customer_id = cs.customer_id
JOIN city c ON cs.city_id = c.city_id
GROUP BY c.city_name
ORDER BY avg_sales_per_customer DESC;

-- Estimated Coffee Consumers (25% of population)
SELECT city_name,
       ROUND(population * 0.25) AS estimated_coffee_consumers
FROM city;


-- ============================================
-- 5. MARKET POTENTIAL ANALYSIS (TOP 3 CITIES)
-- ============================================

WITH ranked_city AS (
    SELECT c.city_name,
           SUM(s.total) AS total_sales,
           c.estimated_rent AS total_rent,
           COUNT(DISTINCT s.customer_id) AS total_customers,
           ROUND(c.population * 0.25) AS estimated_coffee_consumers,
           DENSE_RANK() OVER (ORDER BY SUM(s.total) DESC) AS rn
    FROM sales s
    JOIN customers cs ON s.customer_id = cs.customer_id
    JOIN city c ON cs.city_id = c.city_id
    GROUP BY c.city_name, c.population, c.estimated_rent
)
SELECT city_name,
       total_sales,
       total_rent,
       total_customers,
       estimated_coffee_consumers
FROM ranked_city
WHERE rn <= 3;


-- ============================================
-- 6. VIEWS FOR DASHBOARD / POWER BI
-- ============================================

CREATE OR REPLACE VIEW vw_sales_base AS
SELECT s.sale_id,
       s.sale_date,
       s.total,
       s.rating,
       p.product_name,
       c.city_name
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN customers cs ON s.customer_id = cs.customer_id
JOIN city c ON cs.city_id = c.city_id;

