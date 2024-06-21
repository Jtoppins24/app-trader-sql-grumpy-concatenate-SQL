-- a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000.
    
-- - For example, an app that costs $2.00 will be purchased for $20,000.
    
-- - The cost of an app is not affected by how many app stores it is on. A $1.00 app on the Apple app store will cost the same as a $1.00 app on both stores. 
    
-- - If an app is on both stores, it's purchase price will be calculated based off of the highest app price between the two stores. 

-- b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app.
    
-- - An app that costs $200,000 will make the same per month as an app that costs $1.00. 

-- - An app that is on both app stores will make $10,000 per month. 

-- c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.
    
-- - An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

-- d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.


-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.

-- c. Submit a report based on your findings. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report. 

-- updated 2/18/2023



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

