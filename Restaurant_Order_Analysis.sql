
/*# The situation

I've been just hired as a data analyst for the Taste of the world cafe. a restaurant that has diverse menu offerings and serves generous portions. 

# The Assignment:

I've been asked to dig into the customer data to see which menu items are doing well /not well and what the top customers seem to like the best.



# The objectives

1. Explore the menu_items table to get an idea of what's on the new menu
2. Explore the order_details table to get an idea of the data that's been collected
3. Use both tables to understand how customers are reacting to the new menu


*/










--OBJECTIVE 1 EXPLORE THE MENU ITEMS TABLE
SELECT * 
FROM menu_items



SELECT COUNT(*) 
FROM menu_items


--The most expensive item on the menu
SELECT item_name,price
FROM menu_items
WHERE price = (SELECT MAX(price) FROM menu_items)


--The least item on the menu
SELECT item_name,price
FROM menu_items
WHERE price = (SELECT MIN(price) FROM menu_items)


--How many dishes are in italian category?
SELECT category,COUNT(*) AS [number of dishes]
FROM menu_items
WHERE category = 'Italian'
GROUP BY category


--The max and min price of italian category
SELECT category,MIN(price) AS [Min price],MAX(price) AS [Max price]
FROM menu_items
WHERE category = 'italian'	
GROUP BY category


--the number of dishes of each category
SELECT category,COUNT(*) AS [number of dishes]
FROM menu_items
GROUP BY category


--what is the average price 
SELECT category,ROUND(AVG(price),2) AS [AVG price]
FROM menu_items
GROUP BY category



--OBJECTIVE 2 EXPLORE THE ORDERS TABLE 

-- show all orders
USE RestaurantDB
SELECT *
FROM order_details


--what is the date range of the table?
SELECT DATEDIFF(month,Min(order_date),Max(order_date)) AS [date range in months]
FROM order_details

--How many orders were made within this date range
SELECT COUNT(DISTINCT order_id) AS Num_of_orders
FROM order_details

--HOW many items were ordered within this date range?
SELECT COUNT(*) AS Num_of_items
FROM order_details

--Which order has the most number of items 
SELECT order_id , COUNT(item_id) AS num_of_items
FROM order_details
GROUP BY order_id
ORDER BY num_of_items DESC


--how many orders have more than 12 items?

WITH num_of_orders_peritem AS
(
SELECT order_id , COUNT(item_id) AS num_of_items
FROM order_details
GROUP BY order_id
HAVING COUNT(item_id) > 12

)

SELECT COUNT(*) AS num_of_orders_have_more_than_12_items
FROM num_of_orders_peritem



--OBJECTIVE 3 ANALYZE THE CUSTOMER BEHAVIOR
--Combine the menu items and order details table into single table
SELECT *
FROM order_details ordr
LEFT JOIN menu_items menu
ON ordr.item_id = menu.menu_item_id


--what were the least and most ordered items? what categories were they in ?

SELECT item_name, category,COUNT(*) AS num_of_orders
FROM order_details ordr
LEFT JOIN menu_items menu
ON ordr.item_id = menu.menu_item_id
GROUP BY item_name,category
ORDER BY  num_of_orders DESC

--What were the top 5 orders that spent the most money?

WITH total_price_tb AS
(
SELECT order_id, SUM(price) AS  total_price, ROW_NUMBER() OVER(ORDER BY SUM(price) DESC) AS RN
FROM order_details ordr
LEFT JOIN menu_items menu
ON ordr.item_id = menu.menu_item_id
GROUP BY order_id
HAVING  SUM(price)IS NOT NULL

)

SELECT order_id,total_price
FROM  total_price_tb
WHERE RN <=5

--View the details of the highest spend order . what insights can you gather from the result


WITH total_price_tb AS
(
SELECT order_id, SUM(price) AS  total_price, ROW_NUMBER() OVER(ORDER BY SUM(price) DESC) AS RN
FROM order_details ordr
LEFT JOIN menu_items menu
ON ordr.item_id = menu.menu_item_id
GROUP BY order_id
HAVING  SUM(price)IS NOT NULL

)
SELECT category , COUNT(item_id) AS num_of_items
FROM order_details ordr
LEFT JOIN menu_items menu
ON ordr.item_id = menu.menu_item_id
WHERE order_id =(SELECT  order_id FROM total_price_tb
				WHERE total_price = (SELECT MAX(total_price) FROM total_price_tb))
GROUP BY category




--View details of the top 5 highest spend orders. what insights can you gather from the result


WITH total_price_tb AS
(
SELECT order_id, SUM(price) AS  total_price, ROW_NUMBER() OVER(ORDER BY SUM(price) DESC) AS RN
FROM order_details ordr
LEFT JOIN menu_items menu
ON ordr.item_id = menu.menu_item_id
GROUP BY order_id
HAVING  SUM(price)IS NOT NULL

)
SELECT category , COUNT(item_id) AS num_of_items
FROM order_details ordr
LEFT JOIN menu_items menu
ON ordr.item_id = menu.menu_item_id
WHERE order_id IN  (SELECT order_id
				FROM  total_price_tb
				WHERE RN <=5)
GROUP BY category
ORDER BY num_of_items DESC

--The top orders are the italian dishes so we should put the italian food on our menu