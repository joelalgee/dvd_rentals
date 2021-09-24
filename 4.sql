WITH top_customers
AS (SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS full_name,
  SUM(p.amount)
FROM customer c
JOIN payment p
  ON c.customer_id = p.customer_id
GROUP BY 1,
         2
ORDER BY 3 DESC
LIMIT 10),

monthly_payments
AS (SELECT
  DATE_TRUNC('month', p.payment_date) AS pay_mon,
  c.full_name,
  COUNT(p.amount) AS payments_count,
  SUM(p.amount) AS payments_total
FROM top_customers c
JOIN payment p
  ON c.customer_id = p.customer_id
GROUP BY 1,
         2
ORDER BY 2, 1)

SELECT
  *,
  payments_total - LAG(payments_total) OVER (PARTITION BY full_name ORDER BY pay_mon) AS difference
FROM monthly_payments;