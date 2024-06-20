SELECT*
FROM app_store_apps;

SELECT*
FROM play_store_apps;

-- Your team has been hired by a new company called App Trader to help them explore and gain insights from apps that are made available through the Apple App Store and Android Play Store. App Trader is a broker that purchases the rights to apps from developers in order to market the apps and offer in-app purchase. 
-- analog: so they are the ones who show ads in, say, Duolingo?

-- Unfortunately, the data for Apple App Store apps and Android Play Store Apps is located in separate tables with no referential integrity.

-- #### 2. Assumptions

-- Based on research completed prior to launching App Trader as a company, you can assume the following:

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

-- App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.

-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.

-- c. Submit a report based on your findings. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report. 

-- updated 2/18/2023

-- WITH AS to help separate this nonsense
SELECT 
	DISTINCT(name), 
	ROUND(ROUND(apple.rating + play.rating)/2, 1) as avg_rating, 
	(CASE 
		WHEN apple.price > (CAST(TRIM('$' FROM play.price) AS numeric)) THEN apple.price
		ELSE (CAST(TRIM('$' FROM play.price) AS numeric))
	END) AS max_in_app_price,
	((CASE 
		WHEN apple.price > (CAST(TRIM('$' FROM play.price) AS numeric)) THEN apple.price
		ELSE (CAST(TRIM('$' FROM play.price) AS numeric))
	END) * 10000) AS purchase_price,
	-- CASE WHEN (CASE 
	-- 			WHEN apple.price > (CAST(TRIM('$' FROM play.price) AS numeric)) THEN apple.price
	-- 			ELSE (CAST(TRIM('$' FROM play.price) AS numeric))
	-- 	END) BETWEEN 0 AND 1 THEN 10000
	-- ELSE '000'
	-- END AS purchase_price,
-- purchase price defined as the initial cost to buy the rights based on the in-app price (10k * in_app_price) --> do we need a case statement here? Can we not just do a calculation?
-- utilized the CASE WHEN from in_app_price to calc the monthly cost above, should clean this up potentially with a CTE statement?
-- seem to be having an issue of data type when giving it an else, not sure what we might want to pop in there
-- when it's time to filter out returns where the in_app_price is too high, we need to fix/remember this part 
	1000 AS monthly_cost,
-- monthly cost defined as the cost to continue the rights to app, should all be 10k bec we limited to only apps on both stores
	(ROUND(ROUND(apple.rating + play.rating)/2, 1) * 2 + 1) AS lifespan,
	10000 AS revenue,
--revenue defined as $10k per month bc of 2 apps
	'contribution margin',
-- contribution margin defined as the revenue - monthly cost (starts to indicate how quickly we will break even)
	'payback'
-- payback defined as the purchase price/initial cost DIVIDED BY the contribution margin --> tells us exactly when we will break even
FROM app_store_apps AS apple
JOIN play_store_apps AS play
USING(name);





-- WITH AS to help separate this nonsense
SELECT 
	DISTINCT(name), 
	ROUND(ROUND(apple.rating + play.rating)/2, 1) as avg_rating, 
	(CASE 
		WHEN apple.price > (CAST(TRIM('$' FROM play.price) AS numeric)) THEN apple.price
		ELSE (CAST(TRIM('$' FROM play.price) AS numeric))
	END) AS max_in_app_price,
	((CASE 
		WHEN apple.price > (CAST(TRIM('$' FROM play.price) AS numeric)) THEN apple.price
		ELSE (CAST(TRIM('$' FROM play.price) AS numeric))
	END) * 10000) AS purchase_price,
-- purchase price defined as the initial cost to buy the rights based on the in-app price (max_in_app_price * 10k)
	1000 AS monthly_cost,
-- monthly cost defined as the cost to continue the rights to app, should all be 10k bec we limited to only apps on both stores
	(ROUND(ROUND(apple.rating + play.rating)/2, 1) * 2 + 1) AS lifespan,
-- lifespan defined as the projected length the app will be popular/relevant based on its avg rating
-- might want to add an additional column or change this one to months so that it plays well with the payback column 
	10000 AS revenue,
--revenue defined as $10k per month bc it collects 5k per app
	9000 AS contribution_margin,
-- contribution margin defined as the revenue - monthly cost (starts to indicate how quickly we will break even or how much profit is being contributed back per month to pack back the initial investment), again the same bc we have the same revenue and monthly cost for all apps joined in this table
	(ROUND(((CASE 
		WHEN apple.price > (CAST(TRIM('$' FROM play.price) AS numeric)) THEN apple.price
		ELSE (CAST(TRIM('$' FROM play.price) AS numeric))
	END) * 10000) / 9000), 1) AS payback_in_months
-- payback defined as the purchase price/initial cost DIVIDED BY the contribution margin --> tells us exactly when we will break even
-- might need to fix this column so it's not a record but an integer or numeric data type.... 
FROM app_store_apps AS apple
JOIN play_store_apps AS play
USING(name)
ORDER BY purchase_price DESC;