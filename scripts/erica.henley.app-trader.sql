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
	USING (name)
	)
	
SELECT
	DISTINCT(name),
	cte.avg_rating,
	cte_2.app_price,
	CASE WHEN cte_2.app_price BETWEEN 0 AND 1 THEN 10000
	ELSE cte_2.app_price *10000
	END AS purchase_price,
-- purchase price defined as the initial cost to buy the rights based on the in-app price (max_in_app_price * 10k)
-- case statement here to make sure that we get 10ks for the 0-->1s
	1000 AS monthly_cost,
-- monthly cost defined as the cost to continue the rights to app, should all be 10k bec we limited to only apps on both stores
	cte_2.lifespan,
-- lifespan defined as the projected length the app will be popular/relevant based on its avg rating
-- might want to add an additional column or change this one to months so that it plays well with the payback column
	cte_2.lifespan*12 AS lifespan_in_months,
	10000 AS monthly_revenue,
--monthly_revenue defined as $10k per month bc it collects 5k per app
	9000 AS contribution_margin,
-- contribution margin defined as the revenue - monthly cost (starts to indicate how quickly we will break even or how much profit is being contributed back per month to pack back the initial investment), again the same bc we have the same revenue and monthly cost for all apps joined in this table
	'monthly_revenue * lifespan' AS total_revenue,
	'monthly_cost * lifespan + purchase_price'AS total_cost,
	'total_revenue - total_cost' AS profit,
	(ROUND((cte_2.app_price * 10000) / 9000), 1) AS payback_in_months
-- payback defined as the purchase price/initial cost DIVIDED BY the contribution margin --> tells us exactly when we will break even
-- might need to fix this column so it's not a record but an integer or numeric data type....
FROM app_store_apps AS apple
JOIN play_store_apps AS play
USING(name)
JOIN cte
	USING(name)
JOIN cte_2
	USING(name)
ORDER BY cte.avg_rating DESC;