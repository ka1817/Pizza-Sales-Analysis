SELECT * FROM public.pizza_types
SELECT * FROM public.orders
SELECT * FROM public.pizza_sizes
SELECT * FROM order_details
--------------------------------------------------------Basics-------------------------------------------------------------
--Retrive the total nuber of orders placedSELECT * FROM public.pizza_sizes
select count(order_id) as total_orders from orders
--Calculate the total revenue generated from pizza sales
select round(sum(price*quantity),2) as total_sales from pizza_sizes
join order_details on pizza_sizes.pizza_id = order_details.pizza_id
--Identify the highest priced pizza
SELECT pizza_types.name,pizza_sizes.price FROM public.pizza_sizes
join pizza_types on pizza_sizes.pizza_type_id = pizza_types.pizza_type_id
Order by pizza_sizes.price DESC
limit 1
--identify the most common pizza size ordered   
select pizza_sizes.size,count(order_details_id) as order_count
from pizza_sizes join order_details
on pizza_sizes.pizza_id = order_details.pizza_id
group by pizza_sizes.size
order by order_count DESC
--list the top 5 most ordered pizza types along with their quantities
select pizza_types.name,sum(order_details.quantity) as quantity from pizza_types
join pizza_sizes on pizza_types.pizza_type_id=pizza_sizes.pizza_type_id
join order_details on order_details.pizza_id=pizza_sizes.pizza_id
group by pizza_types.name
order by quantity DESC
limit 5
-------------------------------------------------------Intermediate---------------------------------------------------------
--Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,sum(order_details.quantity) as quantity from pizza_types
join pizza_sizes on pizza_types.pizza_type_id=pizza_sizes.pizza_type_id
join order_details on order_details.pizza_id=pizza_sizes.pizza_id
group by pizza_types.category
order by quantity DESC
limit 5
--Determine the distribution of orders by hour of the day
SELECT EXTRACT(HOUR FROM order_time) AS order_hour, COUNT(order_id) as order_count
FROM orders
GROUP BY order_hour
--join relavent tables to find the category wise distribution of pizzas.
select category,count(name) from pizza_types
group by category
--Group the orders by date and calculate the average number of pizzas order per day
select round(avg(quantity),2)  from
(SELECT orders.order_date,sum(order_details.quantity) as quantity from orders
join order_details on orders.order_id=order_details.order_id
group by orders.order_date) as order_quantity
--Determine top 3 most ordered pizza types based on revenue
select pizza_types.name, sum(pizza_sizes.price * order_details.quantity) as total_revenue from pizza_types
join pizza_sizes on pizza_types.pizza_type_id=pizza_sizes.pizza_type_id
join order_details on order_details.pizza_id = pizza_sizes.pizza_id
group by pizza_types.name
order by total_revenue desc
limit 3
------------------------------------------------Advance----------------------------------------------------------------
--Calculate the percentage contribution of each pizza type to total revenue
	
SELECT 
    pizza_types.category, 
    ROUND(
        (SUM(pizza_sizes.price * order_details.quantity) / 
        (SELECT SUM(order_details.quantity * pizza_sizes.price) 
         FROM order_details 
         JOIN pizza_sizes ON pizza_sizes.pizza_id = order_details.pizza_id)
        ) * 100, 
        2
    ) AS total_revenue
FROM 
    pizza_types
JOIN 
    pizza_sizes ON pizza_types.pizza_type_id = pizza_sizes.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizza_sizes.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    total_revenue DESC;

-- Analyze the cumulative revenue generated over time
select order_date,sum(revenue) over(order by order_date) as cum_revenue from
(select orders.order_date,sum(order_details.quantity * pizza_sizes.price) as revenue
from order_details join pizza_sizes
on order_details.pizza_id = pizza_sizes.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

--Determine the top 3 most ordered pizza_types based on revenue for each pizza category.
select name,revenue from
(select category,name,revenue,rank() over(partition by category order by revenue desc) as rn from
(SELECT pizza_types.category,pizza_types.name,sum((order_details.quantity)*pizza_sizes.price) as revenue 
FROM public.pizza_types join pizza_sizes
on pizza_types.pizza_type_id = pizza_sizes.pizza_type_id
join order_details
on order_details.pizza_id=pizza_sizes.pizza_id
group by pizza_types.category,pizza_types.name) as a) b
where rn <= 3;
















