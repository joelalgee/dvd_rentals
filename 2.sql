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