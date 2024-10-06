select COUNT(customer_id) as customers_count from customers;
-- Данный запрос считает общее количество всех покупателей.

select
    e.first_name || ' ' || e.last_name as seller, --Вывод имени и фамилии 
    COUNT(s.sales_id) as operations, --Количество проведенных сделок
    --Подсчет общей суммы продаж с округлением в меньшую сторону
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by seller -- Группировка по продовцам
order by income desc --Сортитровка по выручке в порядке убывания
limit 10; --топ 10
--Данный запрос находит 10 продацов с наибольшей выручкой.
--Выводит ФИ продавцов, общее количество продаж для каждого продовца
-- и сумарную выручку продавца за все время.

with tab as (
    select AVG(s.quantity * p.price) as total_avg
    from sales as s
    inner join products as p
        on s.product_id = p.product_id
) --нахожу среднюю выручку по всем продовцам используя CTE

select
    e.first_name || ' ' || e.last_name as seller,
    -- Вычисление средней выручки
    FLOOR(AVG(s.quantity * p.price)) as average_income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    seller
having (select total_avg from tab) > AVG(s.quantity * p.price)
-- Условие по которому выводим данные, используя having и подзапрос
order by average_income asc;


--Данный запрос выводит тех продавцов и их среднюю выручку за сделку ,
-- у кого она меньше средней общей выручки за сделку по всем продовцам


with tab as (
    select
        case                  --Задаем каждому возрастную группу
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
order by age_category; --Группируем и сортируем по возрастной категории.

-- Данный запрос выводит количество человек в определенных возрастных группах.
select
    -- Вывод даты в формате год-м
    TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
    -- считаем количество уникальных покупателей
    COUNT(distinct s.customer_id) as total_customers,
    SUM(s.quantity * p.price) as income
from sales as s
inner join products as p
    on s.product_id = p.product_id
group by selling_month
order by selling_month; -- группируем и сортируем по дате

-- Запрос выводит количество уникальных покупателей и выручку по месяцам.

with tab as (
    select
        s.sale_date, -- ФИ покупателя
        s.customer_id,
        p.price, -- ФИ продавца
        CONCAT(c.first_name, ' ', c.last_name) as customer,
        -- Сортировка покупок по дате
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
where price = 0 and row_nmb = 1 -- Первая покупка акционная
order by customer_id; -- Сортировка по id

-- Запрос предоставляет информацию о покупателях,
-- первая покупка которых была в ходе проведения акций
