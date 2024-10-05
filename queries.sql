INSERT INTO "select to_char(s.sale_date,'YYYY-MM') as selling_month, -- Вывод даты в формате год-м
count(distinct s.customer_id) as total_customers, -- считаем количество уникальных покупателей
floor(sum(s.quantity * p.price)) as income
from sales as s
inner join products p 
on s.product_id = p.product_id 
group by selling_month 
order by selling_month" (selling_month,total_customers,income) VALUES
	 ('1992-09',226,2618930332),
	 ('1992-10',230,8358113698),
	 ('1992-11',228,8031353737),
	 ('1992-12',229,7708189846);
