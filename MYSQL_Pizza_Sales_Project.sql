
 -- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


 -- 2. Calculate the total revenue generated from pizza sales.


SELECT 
    ROUND(SUM(d.quantity * p.price), 0) AS pizza_sales
FROM
    order_details d
        JOIN
    pizzas p ON d.pizza_id = p.pizza_id;
    
    
    
    
-- 3. Identify the highest-priced pizza.

SELECT 
    t.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types t ON p.pizza_type_id = t.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

;
-- 4. Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(o.order_details_id) AS size_count
FROM
    order_details o
        JOIN
    pizzas AS p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY size_count DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    t.name, COUNT(o.quantity) AS total_quantity
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY t.name
ORDER BY total_quantity DESC
LIMIT 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    t.category, COUNT(o.quantity) AS total_quantity
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY t.category
ORDER BY total_quantity DESC;

-- 7.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS per_hour,
    COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY per_hour
ORDER BY total_orders DESC;
-- 8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered
FROM
    (SELECT 
        (o.order_date) AS order_date, SUM(d.quantity) AS quantity
    FROM
        orders o
    JOIN order_details d ON o.order_id = d.order_id
    GROUP BY o.order_date) AS order_quantity;
-- 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    t.name, ROUND(SUM(p.price * o.quantity), 0) AS total_revenue
FROM
    pizzas p
        JOIN
    pizza_types t ON p.pizza_type_id = t.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY t.name
ORDER BY total_revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    t.category,
    ROUND(SUM(p.price * o.quantity) / (SELECT 
                    ROUND(SUM(p.price * o.quantity), 2)
                FROM
                    order_details o
                        JOIN
                    pizzas p ON o.pizza_id = p.pizza_id) * 100,
            0) AS total_sales
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
        JOIN
    pizza_types t ON p.pizza_type_id = t.pizza_type_id
GROUP BY t.category
    order by total_sales desc;
    
-- 12. Analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over(order by order_date) as cumulative_revenue
from
(select o.order_date,sum(d.quantity*p.price) as revenue
from pizzas p join order_details d on d.pizza_id=p.pizza_id
join orders o on d.order_id=o.order_id
group by o.order_date)as sales;



-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,category,revenue,rnk from
(select category,name, revenue,
rank() over(partition by category order by revenue desc) as rnk from
(select t.category,t.name,sum(d.quantity*p.price) as revenue
from pizzas p join pizza_types t on p.pizza_type_id=t.pizza_type_id
join order_details d on p.pizza_id=d.pizza_id
group by t.category,t.name) as a) as b
where rnk = 1;
