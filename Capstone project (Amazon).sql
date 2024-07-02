select * from capstoneproject.amazon;
SELECT * FROM amazon
WHERE `Invoice ID` IS NOT NULL OR
      Branch IS NOT NULL OR
      City IS NOT NULL OR
      `Customer type` IS NOT NULL OR
      Gender IS NOT NULL OR
      `Product line` IS NOT NULL OR
      `Unit price` IS NOT NULL OR
      Quantity IS NOT NULL OR
      `Tax 5%` IS NOT NULL OR
      Total IS NOT NULL OR
      `Date` IS NOT NULL OR 
      `Time` IS NOT NULL OR
      Payment IS NOT NULL OR
      cogs IS NOT NULL OR
      `gross margin percentage` IS NOT NULL OR
      `gross income` IS NOT NULL  OR
      Rating IS NOT NULL;

UPDATE amazon
SET `Date` = STR_TO_DATE('1/5/2019', '%m/%d/%Y')
WHERE `Date` = '1/5/2019';

ALTER TABLE amazon
MODIFY COLUMN `Invoice ID` VARCHAR(30),
MODIFY COLUMN Branch VARCHAR(5),
MODIFY COLUMN City VARCHAR(30),
MODIFY COLUMN `Customer type` VARCHAR(30),
MODIFY COLUMN Gender VARCHAR(10),
MODIFY COLUMN `Product line` VARCHAR(100),
MODIFY COLUMN `Unit price` DECIMAL(10, 2),
MODIFY COLUMN Quantity INT,
MODIFY COLUMN `Tax 5%` FLOAT(6, 4),
MODIFY COLUMN Total DECIMAL(10, 2),
MODIFY COLUMN `Date` DATE,
MODIFY COLUMN `Time` TIMESTAMP,
MODIFY COLUMN Payment DECIMAL(10, 2),
MODIFY COLUMN cogs DECIMAL(10, 2),
MODIFY COLUMN `gross margin percentage` FLOAT(11, 9),
MODIFY COLUMN `gross income` DECIMAL(10, 2),
MODIFY COLUMN Rating FLOAT(2, 1);

-- FEATURE ENGINEERING
ALTER TABLE amazon
ADD COLUMN Time_Of_Day varchar(20);

ALTER TABLE amazon
ADD COLUMN Day_Name varchar(20);

ALTER TABLE amazon
ADD COLUMN Month_Name varchar(20);

select * from amazon;
-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Update the Time_Of_Day column
UPDATE amazon
SET Time_Of_Day = CASE
    WHEN TIME(`Time`) BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(`Time`) BETWEEN '12:00:00' AND '16:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END;

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

UPDATE amazon
SET Day_Name = CASE DAYOFWEEK(STR_TO_DATE(`Date`, '%m/%d/%Y'))
    WHEN 1 THEN 'Sun'
    WHEN 2 THEN 'Mon'
    WHEN 3 THEN 'Tue'
    WHEN 4 THEN 'Wed'
    WHEN 5 THEN 'Thu'
    WHEN 6 THEN 'Fri'
    WHEN 7 THEN 'Sat'
END;

select * from amazon;

UPDATE amazon
SET Month_Name = CASE MONTH(STR_TO_DATE(`Date`, '%m/%d/%Y'))
    WHEN 1 THEN 'Jan'
    WHEN 2 THEN 'Feb'
    WHEN 3 THEN 'Mar'
    WHEN 4 THEN 'Apr'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'Jun'
    WHEN 7 THEN 'Jul'
    WHEN 8 THEN 'Aug'
    WHEN 9 THEN 'Sep'
    WHEN 10 THEN 'Oct'
    WHEN 11 THEN 'Nov'
    WHEN 12 THEN 'Dec'
END;

-- BUSINESS QUESTION
-- 1.What is the count of distinct cities in the dataset?
select distinct city 
from amazon;

-- 2.For each branch, what is the corresponding city?
select distinct Branch,City 
from amazon;

-- 3.What is the count of distinct product lines in the dataset?
select 'Product line' from amazon;
SELECT COUNT(DISTINCT `Product line`) AS DistinctProductLinesCount
FROM amazon;
SELECT distinct `Product line`
FROM amazon;

-- 4.Which payment method occurs most frequently?
select distinct Payment 
from amazon;

-- 5.Which product line has the highest sales?
SELECT `Product line` AS Product_Line, ROUND(SUM(Total), 2) AS Highest_Sales
FROM amazon
GROUP BY `Product line`
ORDER BY Highest_Sales DESC
LIMIT 1;



-- 6. How much revenue is generated each month?
SELECT Month_Name AS Month, ROUND(SUM(Total), 2) AS Total_Sales
FROM amazon
GROUP BY Month_Name
ORDER BY Total_Sales DESC;


-- 7.In which month did the cost of goods sold reach its peak?
SELECT Month_Name, ROUND(SUM(Total), 2) AS Total_Sales
FROM amazon
GROUP BY Month_Name
ORDER BY Total_Sales DESC
LIMIT 1;

-- 8.Which product line generated the highest revenue?
SELECT `Product line` AS Product_Line, ROUND(SUM(Total), 2) AS Highest_Sales
FROM amazon
GROUP BY `Product line`
ORDER BY Highest_Sales DESC
LIMIT 1;





-- 9.In which city was the highest revenue recorded?
SELECT city AS City_Name, ROUND(SUM(Total), 2) AS Total_Revenue
FROM amazon
GROUP BY city
ORDER BY Total_Revenue DESC
LIMIT 1;


-- 10 Which product line incurred the highest Value Added Tax?
select `Product line`,round(sum(`Tax 5%`),2) from amazon
group by `Product line`
order by round(sum(`Tax 5%`),2) desc
limit 1;

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select avg(Total) from amazon;

with avg_sale_cte as(
     select avg(Total) as avg_total
     from amazon
)

select  
      `Product line`, 
       Total,  
       case
            when Total>(select avg_total from avg_sale_cte)then 'Good'
            when Total<(select avg_total from avg_sale_cte) then 'Bad'
            else 'Average'
	   end as performance
from amazon;

-- 12. Identify the branch that exceeded the average number of products sold.
WITH Branch_Sales AS (
    SELECT
        Branch,
        SUM(Quantity) AS Total_Quantity
    FROM
        amazon
    GROUP BY
        Branch
),
Average_Sales AS (
    SELECT
        AVG(Total_Quantity) AS Average_Quantity
    FROM
        Branch_Sales
)
SELECT
    bs.Branch,
    bs.Total_Quantity
FROM
    Branch_Sales bs,
    Average_Sales avg_sales
WHERE
    bs.Total_Quantity > avg_sales.Average_Quantity;


SELECT * FROM amazon;

-- 13.Which product line is most frequently associated with each gender?
-- Get the most frequently associated product line for females
WITH Gender_ProductLine_Count AS (
    SELECT
        Gender,
        `Product Line`,
        COUNT(*) AS Count_Product_Line
    FROM
        amazon
    GROUP BY
        Gender, `Product Line`
),
Max_Gender_ProductLine AS (
    SELECT
        Gender,
        MAX(Count_Product_Line) AS Max_Count
    FROM
        Gender_ProductLine_Count
    GROUP BY
        Gender
)
SELECT
    gpl.Gender,
    gpl.`Product Line`,
    gpl.Count_Product_Line
FROM
    Gender_ProductLine_Count gpl
JOIN
    Max_Gender_ProductLine mgpl
ON
    gpl.Gender = mgpl.Gender AND gpl.Count_Product_Line = mgpl.Max_Count;

-- 14. Calculate the average rating for each product line.

select `Product line`,
        avg(Rating) as avg_rate
from amazon
group by `Product line`
order by avg_rate
limit 1;

-- 15.Count the sales occurrences for each time of day on every weekday.
SELECT
    Day_Name,
    Time_Of_Day,
    COUNT(*) AS Sales_Occurrences
FROM
    amazon
GROUP BY
    Day_Name,
    Time_Of_Day
ORDER BY
    Day_Name,
    Time_Of_Day;
-- 16.Identify the customer type contributing the highest revenue
select * from amazon;

select `Customer type`,
		round(sum(Total),2) as revenue
from amazon
group by `Customer type`
order by revenue desc
limit 1;

-- 17.Determine the city with the highest VAT percentage.
select City,
       round(sum(`Tax 5%`),2) as VAT
from amazon
group by City
order by VAT DESC
limit 1;

-- 18. Identify the customer type with the highest VAT payments

select `Customer type`,
        round(sum(`Tax 5%`),2) as VAT
from amazon
group by `Customer type`
order by VAT DESC
limit 1;

-- 19.What is the count of distinct customer types in the dataset?



SELECT COUNT(DISTINCT `Customer type`) AS unique_customer_types
FROM amazon;

-- 20.What is the count of distinct payment methods in the dataset?

SELECT COUNT(DISTINCT `Payment`) AS unique_payment_types
FROM amazon;

-- 21. Which customer type occurs most frequently?
Select `Customer type`, count(*) as frequency
from amazon
group by `Customer type` 
order by frequency 
limit 1;
-- 22.Identify the customer type with the highest purchase frequency.
Select `Customer type`, round(sum(Total),2) as purchase_frequency
from amazon
group by `Customer type` 
order by purchase_frequency desc
limit 1;
select * from amazon;

-- 23. Determine the predominant gender among customers.

select Gender,count(*) as prodominance
from amazon
group by Gender
order by prodominance desc
limit 1;

-- 24.Examine the distribution of genders within each branch.
select Branch,Gender,count(*) as counts
from amazon
group by Branch,Gender
order by Branch,counts desc;

-- 25.Identify the time of day when customers provide the most ratings.
select Time_Of_Day,count(Rating) as highest_rating
from amazon
group by Time_Of_Day
order by highest_rating desc;

-- 26. Determine the time of day with the highest customer ratings for each branch.

select Branch,Time_Of_Day,count(Rating) as high_customer_rating
from amazon 
group by Branch,Time_Of_Day
order by Branch, high_customer_rating desc;

-- 27.Identify the day of the week with the highest average ratings.
 
 select Day_Name,round(avg(Rating),2) as avg_rating
 from amazon
 group by Day_Name
 order by avg_rating desc;
 
 -- 28.Determine the day of the week with the highest average ratings for each branch.

 select Branch,Day_Name,round(avg(Rating),2) as avg_rating
 from amazon
 group by Branch, Day_Name
 order by Branch,avg_rating desc;  