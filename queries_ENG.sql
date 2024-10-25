select COUNT(customer_id) as customers_count from customers;
-- This query counts the total number of all customers.

select
    e.first_name || ' ' || e.last_name as seller, -- Outputs the first and last name 
    COUNT(s.sales_id) as operations, -- The number of completed transactions
    -- Calculates the total sales amount rounded down
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by seller -- Grouping by sellers
order by income desc -- Sorting by revenue in descending order
limit 10; -- Top 10
-- This query finds the 10 sellers with the highest revenue.
-- It outputs the full names of the sellers, the total number of sales for each seller,
-- and the total revenue of each seller over all time.

with tab as (
    select AVG(s.quantity * p.price) as total_avg
    from sales as s
    inner join products as p
        on s.product_id = p.product_id
) -- Finding the average revenue across all sellers using CTE

select
    e.first_name || ' ' || e.last_name as seller,
    -- Calculating the average revenue
    FLOOR(AVG(s.quantity * p.price)) as average_income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    seller
having (select total_avg from tab) > AVG(s.quantity * p.price)
-- Condition for outputting data, using having and a subquery
order by average_income asc;

-- This query outputs those sellers and their average revenue per transaction,
-- whose average revenue is less than the overall average revenue per transaction across all sellers.

with tab as (
    select
        case                  -- Defining each age group
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            when age > 40 then '40+'
        end as age_category
    from customers
)

select
    age_category,
    COUNT(age_category) as age_count
from tab
group by age_category
order by age_category; -- Grouping and sorting by age category.

-- This query outputs the number of people in specific age groups.
select
    -- Outputting the date in year-month format
    TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
    -- Counting the number of unique customers
    COUNT(distinct s.customer_id) as total_customers,
    SUM(s.quantity * p.price) as income
from sales as s
inner join products as p
    on s.product_id = p.product_id
group by selling_month
order by selling_month; -- Grouping and sorting by date

-- This query outputs the number of unique customers and revenue by month.

with tab as (
    select
        s.sale_date, -- Customer's full name
        s.customer_id,
        p.price, -- Seller's full name
        CONCAT(c.first_name, ' ', c.last_name) as customer,
        -- Sorting purchases by date
        CONCAT(e.first_name, ' ', e.last_name) as seller,
        ROW_NUMBER()
            over (partition by s.customer_id order by s.sale_date)
        as row_nmb
    from sales as s
    inner join products as p
        on s.product_id = p.product_id
    inner join customers as c
        on s.customer_id = c.customer_id
    inner join employees as e
        on s.sales_person_id = e.employee_id
)

select
    customer,
    sale_date,
    seller
from tab
where price = 0 and row_nmb = 1 -- The first purchase was promotional
order by customer_id; -- Sorting by ID

-- This query provides information about customers,
-- whose first purchase was during a promotional event.

