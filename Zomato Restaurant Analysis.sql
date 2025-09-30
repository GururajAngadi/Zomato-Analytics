CREATE DATABASE zomato_data;
USE zomato_data;

select * from zomato_main;
select * from zomato_DATE;
select * from zomato_CURRENCY;
select * from zomato_COUNTRY;

#Q1. BUILD DATA MODEL

-- Link Main to Country
SELECT * FROM ZOMATO_main m
JOIN ZOMATO_country c ON m.Countrycode = c.CountryId;

-- Link Main to Currency
SELECT * FROM ZOMATO_main m
JOIN ZOMATO_currency cu ON m.Currency = cu.Currency;

-- Link Main to Date
SELECT * FROM ZOMATO_main m
JOIN ZOMATO_date d ON m.DateKey = d.Date_Key_Opening;


SELECT 
    m.*,
    c.CountryId,
    cu.Currency,
    d.Date_Key_Opening
FROM ZOMATO_main m
JOIN ZOMATO_country c ON m.CountryCode = c.CountryId
JOIN ZOMATO_currency cu ON m.Currency = cu.Currency
JOIN ZOMATO_date d ON m.DateKey = d.Date_Key_Opening
LIMIT 10000;

#Q2. Build a Calendar Table

SELECT 
    Date_Key_Opening,
    YEAR(Date_Key_Opening) AS Year,
    MONTH(Date_Key_Opening) AS MonthNo,
    MONTHNAME(Date_Key_Opening) AS MonthFullName,
    CONCAT('Q', QUARTER(Date_Key_Opening)) AS Quarter,
    DATE_FORMAT(Date_Key_Opening, '%Y-%b') AS YearMonth,
    WEEKDAY(Date_Key_Opening) + 1 AS WeekdayNo,
    DAYNAME(Date_Key_Opening) AS WeekdayName,
    CASE 
        WHEN MONTH(Date_Key_Opening) >= 4 THEN MONTH(Date_Key_Opening) - 3
        ELSE MONTH(Date_Key_Opening) + 9
    END AS FinancialMonth,
    CASE
        WHEN MONTH(Date_Key_Opening) BETWEEN 4 AND 6 THEN 'FQ-1'
        WHEN MONTH(Date_Key_Opening) BETWEEN 7 AND 9 THEN 'FQ-2'
        WHEN MONTH(Date_Key_Opening) BETWEEN 10 AND 12 THEN 'FQ-3'
        ELSE 'FQ-4'
    END AS FinancialQuarter
FROM ZOMATO_date;

#Q3. Convert Average_Cost_for_two to USD

SELECT
  RestaurantName,
  Average_Cost_for_two,
  ROUND(Average_Cost_for_two / 83, 2) AS AvgCost_USD
FROM ZOMATO_main;

#Q4. Number of Restaurants by City and Country

SELECT 
    c.Countryname,
    m.City,
    COUNT(*) AS NumRestaurants
FROM ZOMATO_main m
JOIN ZOMATO_country c ON m.CountryCode = c.CountryID
GROUP BY c.Countryname, m.City
ORDER BY NumRestaurants DESC;

#Q5.Restaurants Opened by Year, Quarter, Month

SELECT 
    YEAR(d.Date_Key_Opening) AS Opening_Year,
    CONCAT('Q', QUARTER(d.Date_Key_Opening)) AS Opening_Quarter,
    MONTHNAME(d.Date_Key_Opening) AS Opening_Month,
    COUNT(*) AS Number_of_Restaurants
FROM ZOMATO_main m
JOIN ZOMATO_date d ON m.DateKey = d.Date_Key_Opening
GROUP BY 
    Opening_Year,
    Opening_Quarter,
    Opening_Month
ORDER BY 
    Opening_Year,
    FIELD(Opening_Quarter, 'Q1', 'Q2', 'Q3', 'Q4');


# Q6. Count of Restaurants by Average Ratings

SELECT 
    Rating,
    COUNT(*) AS NumRestaurants
FROM ZOMATO_main
GROUP BY Rating
ORDER BY Rating ASC;


#Q7. Buckets by Average Price

SELECT 
    CASE 
        WHEN Average_Cost_for_two < 100 THEN '< ₹100'
        WHEN Average_Cost_for_two BETWEEN 100 AND 299 THEN '₹100–₹299'
        WHEN Average_Cost_for_two BETWEEN 300 AND 599 THEN '₹300–₹599'
        WHEN Average_Cost_for_two BETWEEN 600 AND 999 THEN '₹600–₹999'
        ELSE '₹1000+'
    END AS PriceBucket,
    COUNT(*) AS NumRestaurants
FROM ZOMATO_main
GROUP BY PriceBucket
order by PriceBucket asc;

#Q8. % of Restaurants with Table Booking

SELECT 
    Has_Table_booking,
    COUNT(*) AS Count_of_Restaurants,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ZOMATO_main), 2) AS Percentage
FROM ZOMATO_main
GROUP BY Has_Table_booking;

#Q9. % of Restaurants with Online Delivery

SELECT 
    Has_Online_delivery,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ZOMATO_main) AS Percentage
FROM ZOMATO_main
GROUP BY Has_Online_delivery; 

# Q10. KPIs for Cuisines, City, Rating

# Top 10 Most Common Cuisines:

SELECT 
    Cuisines,
    COUNT(*) AS Count
FROM ZOMATO_main
GROUP BY Cuisines
ORDER BY Count DESC
LIMIT 10;

# Average Rating by City:

SELECT 
    City,
    ROUND(AVG(Rating), 2) AS AvgRating
FROM ZOMATO_main
GROUP BY City
ORDER BY AvgRating DESC
LIMIT 10;
