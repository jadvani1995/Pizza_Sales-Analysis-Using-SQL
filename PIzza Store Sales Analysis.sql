create database pizzahut;

select * from orders
select * from order_details



--Q.1]Retrieve the total number of orders placed.
select COUNT(order_id) as Total_orders from orders

--Q.2]Calculate the total revenue generated from pizza sales.
    select
ROUND(sum(order_details.quantity * pizzas.price),2) as Total_sales
	from order_details join pizzas
	on pizzas.pizza_id = order_details.pizza_id

--Q.3]Identify the highest-priced pizza.
select top 1 pizza_types.name,pizzas.price
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc

--Q.4]Identify the most common pizza size ordered.
select pizzas.size, COUNT(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by order_count desc

--
ALTER TABLE order_details
ALTER COLUMN quantity int not null ;
--


--Q.5]List the top 5 most ordered pizza types along with their quantities.
select top 5 pizza_types.name, SUM(order_details.quantity)as qyt from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on 
order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by qyt desc

--Q.6]Join the necessary tables to find the total quantity of each pizza category ordered. 
select  pizza_types.category, SUM(order_details.quantity)as qyt from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on 
order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by qyt desc

--Q.7]Determine the distribution of orders by hour of the day.
select DATEPART(HOUR,time) as hour,COUNT(order_id) as order_count from orders
group by DATEPART(HOUR,time)

--Q.8]Join relevant tables to find the category-wise distribution of pizzas.
select category, COUNT(name) from pizza_types
group by category;

--Q.9]Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(Qty) from
(select orders.date, SUM(order_details.quantity) as Qty
from orders join order_details
on orders.order_id=order_details.order_id
group by orders.date) as order_quantity;

--Q.10]Determine the top 3 most ordered pizza types based on revenue.
select top 3 pizza_types.name, SUM(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id= pizza_types.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name 
order by revenue desc

--Q.11]Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round(SUM(order_details.quantity * pizzas.price)/ (select
ROUND(sum(order_details.quantity * pizzas.price),2) as Total_sales
	from order_details join pizzas
	on pizzas.pizza_id = order_details.pizza_id) *100,2) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id= pizza_types.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category 
order by revenue desc

--Q.12]Analyze the cumulative revenue generated over time.
select date,
sum(revenue) over(order by date)  as cum_rev from
(select orders.date, SUM(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.date) as sales;

--Q.13]Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as RN
from 
(select pizza_types.category,pizza_types.name,
SUM(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id= pizza_types.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as A) as B
where RN <=3;
