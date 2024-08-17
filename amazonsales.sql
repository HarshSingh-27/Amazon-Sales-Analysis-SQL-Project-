use amazon; -- Database ---
-- table name -> salesdata ---

SELECT * FROM salesdata; 
------------------------------------------------ DATA WRANGLING ------------------------------------------------
-- Check for NULL values in the table--
SELECT * FROM salesdata WHERE Invoice_ID IS NULL
    OR Branch IS NULL
    OR City IS NULL
    OR Customer_type IS NULL
    OR Gender IS NULL
    OR Product_line IS NULL
    OR Unit_Price IS NULL
    OR Quantity IS NULL
    OR Tax_5percentage IS NULL
    OR DATE IS NULL
    OR TIME IS NULL
    OR Total IS NULL
    OR Payment IS NULL
    OR cogs IS NULL
    OR Gross_Margin_percentage IS NULL
    OR gross_income IS NULL
    OR Rating IS NULL;

-- NO null values are present in salesdata----

--------------------------------------- FEATURE ENGINEERING -------------------------------------------------

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Add the timeofday column
ALTER TABLE salesdata ADD COLUMN timeofday VARCHAR(20);

-- Update the timeofday column
UPDATE salesdata
SET timeofday = CASE
    WHEN TIME(Time) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    ELSE 'Evening'
END
WHERE Time IS NOT NULL;

-- Add the dayname column
ALTER TABLE salesdata ADD COLUMN dayname VARCHAR(20);

-- Update the dayname column
UPDATE salesdata
SET dayname = DAYNAME(Date)
WHERE Date IS NOT NULL;

-- Add the monthname column
ALTER TABLE salesdata ADD COLUMN monthname VARCHAR(20);

-- Update the monthname column
UPDATE salesdata
SET monthname = MONTHNAME(Date)
WHERE Date IS NOT NULL;

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

SELECT * FROM salesdata;

---------------------------------------- EDA -----------------------------------------------------------------
-- Q1 What is the count of distinct cities in the dataset?

SELECT COUNT(DISTINCT City) AS distinct_cities FROM salesdata;

-- Q2 For each branch, what is the corresponding city?

SELECT Branch, City FROM salesdata GROUP BY Branch, City;

-- Q3 What is the count of distinct product lines in the dataset?

SELECT COUNT(DISTINCT Product_line) AS distinct_product_lines FROM salesdata;

-- Q4 Which payment method occurs most frequently?

SELECT Payment, COUNT(*) AS frequency FROM salesdata GROUP BY Payment ORDER BY frequency DESC LIMIT 1;

-- Q5 Which product line has the highest sales?

SELECT Product_line, round(SUM(Total),2) AS total_sales FROM salesdata GROUP BY Product_line
 ORDER BY total_sales DESC LIMIT 1;

-- Q6 How much revenue is generated each month?

SELECT monthname, round(SUM(Total),2) AS revenue FROM salesdata GROUP BY monthname ORDER BY revenue DESC;

-- Q7 In which month did the cost of goods sold reach its peak?

SELECT monthname, round(SUM(cogs),2) AS total_cogs FROM salesdata GROUP BY monthname
 ORDER BY total_cogs DESC LIMIT 1;

-- Q8 Which product line generated the highest revenue?

SELECT Product_line, round(SUM(Total),2) AS total_revenue FROM salesdata GROUP BY
 Product_line ORDER BY total_revenue DESC LIMIT 1;

-- Q9 In which city was the highest revenue recorded?

SELECT City, SUM(Total) AS total_revenue FROM salesdata GROUP BY City ORDER BY total_revenue DESC LIMIT 1;

-- Q10 Which product line incurred the highest Value Added Tax?

SELECT Product_line, round(SUM(Tax_5percentage),2) AS total_tax FROM salesdata 
GROUP BY Product_line ORDER BY total_tax DESC LIMIT 1;

-- Q11 For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

SET @avg_sales = (SELECT AVG(Total) FROM salesdata);
SELECT product_line, Total, 
IF(Total > @avg_sales, 'Good', 'Bad') as Performance
FROM salesdata;

-- Q12 Identify the branch that exceeded the average number of products sold.

SELECT Branch, COUNT(*) AS total_products_sold FROM salesdata GROUP BY Branch 
HAVING total_products_sold > (SELECT AVG(total_products_sold) 
FROM (SELECT Branch, COUNT(*) AS total_products_sold FROM salesdata GROUP BY Branch) AS subquery);


-- Q13  Which product line is most frequently associated with each gender?

SELECT Gender, Product_line, COUNT(*) AS frequency FROM salesdata
GROUP BY Gender, Product_line ORDER BY Gender, frequency DESC;

-- Q14 Calculate the average rating for each product line.

SELECT Product_line, round(AVG(Rating),1) AS avg_rating FROM salesdata
 GROUP BY Product_line ORDER BY avg_rating DESC;

-- Q15 Count the sales occurrences for each time of day on every weekday.

SELECT dayname, timeofday, COUNT(*) AS sales_count FROM salesdata
 GROUP BY dayname, timeofday ORDER BY dayname, timeofday;

-- Q16 Identify the customer type contributing the highest revenue.

SELECT Customer_type, round(SUM(Total),2) AS total_revenue FROM salesdata 
GROUP BY Customer_type ORDER BY total_revenue DESC LIMIT 1;

-- Q17 Determine the city with the highest VAT percentage.

SELECT City, round((SUM(Tax_5percentage) / SUM(Total)) * 100,2) AS vat_percentage
 FROM salesdata GROUP BY City ORDER BY vat_percentage DESC LIMIT 1;

-- Q18 Identify the customer type with the highest VAT payments.

SELECT Customer_type, round(SUM(Tax_5percentage),2) AS total_vat FROM salesdata
GROUP BY Customer_type ORDER BY total_vat DESC LIMIT 1;

-- Q19 What is the count of distinct customer types in the dataset?

SELECT COUNT(DISTINCT Customer_type) AS distinct_customer_types FROM salesdata;

-- Q20 What is the count of distinct payment methods in the dataset?

SELECT COUNT(DISTINCT Payment) AS distinct_payment_methods FROM salesdata;

-- Q21 Which customer type occurs most frequently?

SELECT Customer_type, COUNT(*) AS frequency FROM salesdata 
GROUP BY Customer_type ORDER BY frequency DESC LIMIT 1;

-- Q22 Identify the customer type with the highest purchase frequency.
SELECT Customer_type, COUNT(*) AS purchase_frequency FROM salesdata 
GROUP BY Customer_type ORDER BY purchase_frequency DESC LIMIT 1;

-- Q23 Determine the predominant gender among customers.

SELECT Gender, COUNT(*) AS frequency FROM salesdata GROUP BY Gender ORDER BY frequency DESC LIMIT 1;

-- Q24 Examine the distribution of genders within each branch.

SELECT Branch, Gender, COUNT(*) AS frequency FROM salesdata 
GROUP BY Branch, Gender ORDER BY Branch, frequency DESC;

-- Q25 Identify the time of day when customers provide the most ratings.

SELECT timeofday, COUNT(*) AS rating_count FROM salesdata 
WHERE Rating IS NOT NULL GROUP BY timeofday ORDER BY rating_count DESC LIMIT 1;

-- Q26 Determine the time of day with the highest customer ratings for each branch.

SELECT Branch, timeofday, round(AVG(Rating),2) AS avg_rating FROM salesdata
 WHERE Rating IS NOT NULL GROUP BY Branch, timeofday ORDER BY Branch, avg_rating DESC;

-- Q27 Identify the day of the week with the highest average ratings.

SELECT dayname, round(AVG(Rating),2) AS avg_rating FROM salesdata
 WHERE Rating IS NOT NULL GROUP BY dayname ORDER BY avg_rating DESC LIMIT 1;

-- Q28 Determine the day of the week with the highest average ratings for each branch.
SELECT Branch, dayname, round(AVG(Rating),2) AS avg_rating FROM salesdata 
WHERE Rating IS NOT NULL GROUP BY Branch, dayname ORDER BY Branch, avg_rating DESC;






 


