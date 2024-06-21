WITH cte AS (
	SELECT DISTINCT(name),
	ROUND(ROUND(apple.rating + play.rating)/2, 1) as avg_rating,
	(CAST(TRIM('$' FROM play.price) AS numeric)) AS play_price	
	FROM play_store_apps AS play
	JOIN app_store_apps AS apple
	USING(name)
	),
	
	cte_2 AS (
	SELECT name,
	(cte.avg_rating * 2 + 1) AS lifespan,
	(CASE
		WHEN apple.price > cte.play_price THEN apple.price
		ELSE play_price
	END) AS app_price
	FROM cte
	JOIN app_store_apps AS apple
	USING(name)
	),
	
	cte_3 AS(
	SELECT
	name, CASE WHEN cte_2.app_price BETWEEN 0 AND 1 THEN 10000
	ELSE cte_2.app_price *10000
	END AS purchase_price
	FROM cte_2
	),
	cte_4 AS(
	SELECT name,
	(cte_2.lifespan*12) * 10000 AS total_revenue,
	(cte_2.lifespan*12) * 1000 + cte_3.purchase_price AS total_cost
	FROM cte_2
	JOIN cte_3
	USING(name)
	)
	
SELECT
	DISTINCT(name),
	cte.avg_rating,
	cte_2.app_price :: money,
	cte_3.purchase_price :: money,
	1000 :: money AS monthly_cost,
	(cte_2.lifespan*12) :: int AS lifespan_in_months,
	10000 :: money AS monthly_revenue,
	9000 :: money AS contribution_margin,
	cte_4.total_revenue :: money,
	cte_4.total_cost :: money,
	(cte_4.total_revenue - cte_4.total_cost) :: money AS profit,
	ROUND((cte_2.app_price * 10000) / 9000, 1)  AS payback_in_months
FROM app_store_apps AS apple
JOIN play_store_apps AS play
USING(name)
JOIN cte
	USING(name)
JOIN cte_2
	USING(name)
JOIN cte_3
	USING(name)
JOIN cte_4
	USING(name)
ORDER BY avg_rating DESC;