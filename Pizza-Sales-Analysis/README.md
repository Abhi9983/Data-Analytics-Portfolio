**Overview**



This project analyzes pizza sales data to understand overall business performance, customer behavior, and product trends. SQL was used to clean, transform, and analyze the data, and Power BI was used to build an interactive dashboard for reporting and insights.



The objective of this project is to answer common business questions such as:

* How much revenue is generated?
* Which pizzas and categories perform best?
* How sales vary over time and across cities
* Which cities show higher market potential



**Tools Used**



**SQL (MySQL)** – data cleaning, aggregation, analysis, and views

**Power BI** – data modeling, DAX measures, and dashboard creation



**Dataset Description**

The dataset contains pizza sales transaction data with the following key tables:

* **orders** – order date and time
* **order\_details** – pizzas ordered and quantities
* **pizzas – pizza** size and price
* **pizza\_types** – pizza name and category
* **city / customers / sales** – customer and location details



**Analysis Process**



**1. Data Preparation (SQL)**

* Created database and tables
* Checked data consistency and relationships
* Joined multiple tables to create a consolidated sales view
* Calculated revenue using quantity and price



**2. Exploratory Data Analysis**

* Total revenue and total orders
* Sales distribution by pizza category and size
* Top-selling pizzas by quantity and revenue
* City-wise sales performance



**3. Time-Based Analysis**

* Monthly sales trends
* Month-over-month sales growth using window functions
* Order distribution by hour of the day



**4. Market \& Customer Analysis**

* Average sales per customer
* Estimated coffee consumers using population data
* Market potential analysis to identify top-performing cities



**5. Views for Reporting**

* Created SQL views to simplify Power BI integration
* Used views as a clean data source for dashboards



**Power BI Dashboard**



**The Power BI dashboard presents:**

* Key KPIs (Total Revenue, Orders, Average Sales)
* Sales trends by month and time
* Category and product performance
* City-wise comparison
* Interactive filters and slicers for exploration
