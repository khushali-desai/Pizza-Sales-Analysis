use pizza_sales;

select * from pizza_types;

select * from pizzas;

select * from orders;

select * from order_details;

#Retrieve the total number of orders placed.
select count(order_id) from order_details;

#Calculate the total revenue generated from pizza sales.
select round(sum(od.quantity*p.price),2) from pizzas as p 
inner join order_details od
on p.pizza_id =od.pizza_id;

#Identify the highest-priced pizza.
select * from pizzas
order by price desc
limit 1;

#Identify the most common pizza size ordered.
select p.size,count(od.order_details_id) as pizza_count
from pizzas p
inner join order_details od
on p.pizza_id=od.pizza_id
group by p.size 
order by pizza_count desc;

#List the top 5 most ordered pizza types along with their quantities.
select p.pizza_type_id,pt.name,count(od.quantity) as qt
from order_details od
inner join pizzas p
on p.pizza_id=od.pizza_id
inner join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by  p.pizza_type_id,pt.name
order by qt desc 
limit 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category,count(od.quantity) from pizza_types pt
inner join pizzas p
on pt.pizza_type_id=p.pizza_type_id
inner join order_details od 
on od.pizza_id=p.pizza_id
group by pt.category
order by count(od.quantity) desc;

#Determine the distribution of orders by hour of the day.
select hour(time),count(order_id) from orders
group by hour(time)
order by count(order_id) desc;

#Join relevant tables to find the category-wise distribution of pizzas.
select count(o.order_id),pt.category from pizza_types pt
inner join pizzas p
on p.pizza_type_id=pt.pizza_type_id 
inner join order_details o
on o.pizza_id=p.pizza_id
group by pt.category
order by count(o.order_id) desc;

#Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(qt) from 
(select o.date,sum(od.quantity) as qt from orders o
inner join order_details od
on o.order_id=od.order_id
group by o.date)as sum_quntity;

#Determine the top 3 most ordered pizza types based on revenue
select pt.name,sum(od.quantity*p.price) as revenue from pizza_types pt
inner join pizzas p 
on pt.pizza_type_id=p.pizza_type_id
inner join order_details od
on p.pizza_id=od.pizza_id
group by pt.name
order by revenue desc
limit 3;

#Calculate the percentage contribution of each pizza type to total revenue.
select pt.category,round(sum(od.quantity*p.price)/ (select round(sum(od.quantity*p.price),2)
as total_sales from order_details od
inner join pizzas p
on p.pizza_id=od.pizza_id) *100,2) as revanue 
from pizza_types pt
inner join pizzas p  
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.category
order by revanue desc;

#Analyze the cumulative revenue generated over time.
select date,sum(revanue) over(order by date) as cum_revanue
from
(select o.date,sum(p.price*od.quantity)as revanue 
from order_details od
inner join pizzas p
on p.pizza_id=od.pizza_id
inner join orders o
 on o.order_id=od.order_id 
group by o.date) as daily_sales;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select pizza_type_id,name,category,revanue
from
(select pizza_type_id,name,category,revanue,rank() over(partition by category order by revanue desc) as rn
from 
(
select sum(od.quantity*p.price) as revanue,
pt.pizza_type_id,pt.name,pt.category 
from pizzas p
inner join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
inner join order_details od
on od.pizza_id=p.pizza_id
group by pt.pizza_type_id,pt.name,pt.category) as total_revanue) as b
where rn <=3;






