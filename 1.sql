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