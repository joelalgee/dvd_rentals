# Sakila DVD Rental Database Investigation

Investigate a DVD Rental database, using SQL queries and Excel visualisation

## Summary

The Sakila DVD Rental database holds fictional information about a company that rents movie DVDs. In this project, I queried the Sakila DVD Rental database using SQL to answer the following questions:

1. Was there a relationship between count of family-friendly rental orders and overall rent duration quartile?
2. How did the two stores compare in their count of rental orders during every month for all the years we have data for?
3. How much did the top 10 customers pay per month in 2007?
4. How did the top 10 customers’ spending vary each month in 2007

Query results were visualised using Excel.

## Files

### slides.pdf

Pdf containing four slides which visualise the query results and answer the questions.

## Data

The database provided by Postgresql Tutorial can be downloaded from [this page](https://www.postgresqltutorial.com/postgresql-sample-database/).

## Queries

The queries used were as follows:

### Question 1
```
WITH quartile
AS (SELECT
  f.film_id,
  NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
FROM film f)

SELECT
  c.name category_name,
  q.standard_quartile,
  COUNT(f.film_id) AS film_count
FROM category c
JOIN film_category fc
  ON c.category_id = fc.category_id
  AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
JOIN film f
  ON fc.film_id = f.film_id
JOIN quartile q
  ON f.film_id = q.film_id
GROUP BY 1,
         2
ORDER BY 1, 2;
```

### Question 2
```
SELECT
  DATE_PART('month', r.rental_date) AS rental_month,
  DATE_PART('year', r.rental_date) AS rental_year,
  i.store_id,
  COUNT(r.rental_id)
FROM rental r
JOIN inventory i
  ON r.inventory_id = i.inventory_id
GROUP BY 1,
         2,
         3
ORDER BY 2, 1, 3;
```

### Question 3
```
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
LIMIT 10)

SELECT
  DATE_TRUNC('month', p.payment_date) AS pay_mon,
  c.full_name,
  COUNT(p.amount) AS payments_count,
  SUM(p.amount) AS payments_total
FROM top_customers c
JOIN payment p
  ON c.customer_id = p.customer_id
GROUP BY 1,
         2
ORDER BY 2, 1;
```

### Question 4
```
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
```

## Credits
The project, and parts of the code, were provided by [Udacity](https://www.udacity.com), as part of their [Programming for Data Science nanodegree](https://www.udacity.com/course/programming-for-data-science-nanodegree--nd104). The database was provided by [Postgresql Tutorial](https://www.postgresqltutorial.com/postgresql-sample-database/), a training website which helps people get started with PostgreSQL quickly and effectively.
