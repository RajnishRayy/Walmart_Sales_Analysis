-- Created database
CREATE DATABASE IF NOT EXISTS walmartSales;


-- Created tables
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- -------------------------- Feature Engineering -----------------------------------------
-- Added column Time_of_day
SELECT time,
(CASE 
WHEN `time` BETWEEN "00:00:00" AND "12:00:00"  THEN "Morning"
WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
ELSE "Evening"
END
) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20); 
UPDATE sales 
SET time_of_day = (
 CASE 
     WHEN `time` BETWEEN "00:00:00" AND "12:00:00"  THEN "Morning"
     WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
	 ELSE "Evening"
END
);

-- Added column day_name
SELECT 
    date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20); 
UPDATE sales 
SET day_name = DAYNAME(date);

-- Added column month_name
SELECT 
     date,
     monthname(date) AS month_name
FROM sales;
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales 
SET month_name = monthname(date);

-- -------------------------------- Generic Questions --------------------------------------
-- 1) How many unique cities does the data have?
SELECT 
     DISTINCT(city) 
FROM sales;

-- 2) In which city is each branch?
SELECT 
     DISTINCT city, branch 
FROM sales;

-- -------------------------------- Product Questions --------------------------------------
-- 1) How many unique product lines does the data have?
SELECT 
    COUNT( DISTINCT product_line ) AS Unique_products
FROM sales;

-- 2) What is most common payment method?
SELECT payment,
     COUNT(payment) AS cnt
FROM sales
GROUP BY payment
ORDER BY cnt DESC
LIMIT 1 ;

-- 3) What is the most selling product_line?
SELECT product_line,
     COUNT(product_line) AS cnt 
FROM sales 
GROUP BY product_line
ORDER BY cnt DESC 
LIMIT 1;

-- 4) What is the total revenue by month?
SELECT month_name,
	ROUND(SUM(total)) as total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5) What month has largest cogs?
SELECT month_name,
     ROUND(SUM(cogs)) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;

-- 6) What product_line had the largest revenue?
SELECT product_line,
     ROUND(SUM(total)) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- 7) What is the city with largest revenue?
SELECT city,
	ROUND(SUM(total)) AS total_revenue
FROM sales 
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- 8) What product_line had the largest VAT?
SELECT product_line,
     ROUND(SUM(tax_pct)) AS total_tax
FROM sales
GROUP BY product_line
ORDER BY total_tax DESC 
LIMIT 1;

-- 9) Fetch each product_line and add a column to those product_line showing "good","bad". Good if its greater than average sales

   SELECT product_line,
        CASE WHEN AVG(quantity) > (SELECT AVG(quantity) FROM sales) THEN "GOOD"
        ELSE "BAD"
        END AS performance
	FROM SALES
    GROUP BY product_line;

-- 10) Which branch sold more products than average product sold?
SELECT branch,
     SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity)FROM sales);

-- 11) What is the most common product_line by gender?
SELECT gender,product_line,
     COUNT(gender) AS gender_cnt
FROM sales
GROUP BY gender,product_line
ORDER BY gender_cnt DESC;

-- 12) What is the average rating of each product_line?
SELECT product_line,
ROUND(AVG(rating),1) AS avg_rating
FROM sales 
GROUP BY product_line
ORDER BY avg_rating DESC;
   
-- -------------------------------- Sales Questions -----------------------------------------    
-- 1) Number of sales made in each time of the day per weekday?
SELECT time_of_day,
	 COUNT(invoice_id) AS number_sales
FROM sales
GROUP BY time_of_day;

-- 2) Which of the customer types brings the most revenue?
SELECT customer_type,
    ROUND(SUM(total)) AS total_revenue
FROM sales 
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- 3) Which city has the largest tax percentage ?
SELECT city ,
     ROUND(AVG(tax_pct),2) AS tax_pct
FROM sales
GROUP BY city
ORDER BY tax_pct DESC;

-- 4) Which customer type pays the most in TAX?
SELECT customer_type,
	ROUND(AVG(tax_pct),2) AS tax_pct
FROM sales
GROUP BY customer_type
ORDER BY tax_pct DESC;

-- ---------------------------CUSTOMER QUESTIONS----------------------------------------------
-- 1) How many unique customer types does the data have?
SELECT DISTINCT customer_type,
              COUNT(invoice_id) AS cnt
FROM sales
GROUP BY customer_type;

-- 2) How many unique payment method does the data have?
SELECT DISTINCT payment
FROM sales;

-- 3) What is the most common customer type?
SELECT customer_type,
	 COUNT(invoice_id) AS cnt
FROM sales
GROUP BY customer_type
ORDER BY cnt DESC;

-- 4) Which customer type buys the most?
SELECT customer_type,
     SUM(total) AS total_rev
FROM sales
GROUP BY customer_type
ORDER BY total_rev DESC;

-- 5) What is the gender of most of the customers?
SELECT gender,
     COUNT(gender) AS cnt
FROM sales 
GROUP BY gender
ORDER BY cnt DESC;

-- 6) What is the gender distribution per branch?
SELECT branch,gender,
     COUNT(gender) AS cnt
FROM sales 
GROUP BY branch,gender
ORDER BY branch;

-- 7) Which time of the day do customers give most ratings?
SELECT time_of_day,
      ROUND(AVG(rating),2) AS average_rating
FROM sales
GROUP BY time_of_day
ORDER BY average_rating DESC;

-- 8) Which time of the day do customers give most ratings per branch?
SELECT time_of_day,branch,
      ROUND(AVG(rating),2) AS average_rating
FROM sales
GROUP BY time_of_day,branch
ORDER BY branch;

-- 9) Which day of the week has the best avg ratings?
SELECT day_name,
     ROUND(AVG(rating),2) AS average_rating
FROM sales
GROUP BY day_name
ORDER BY average_rating DESC;

-- 10) Which day of the week has the best avg ratings per branch?
SELECT day_name,branch,
     ROUND(AVG(rating),2) AS average_rating
FROM sales
GROUP BY day_name,branch
ORDER BY average_rating DESC;
