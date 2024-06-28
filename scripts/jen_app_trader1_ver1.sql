-- ### App Trader

-- APP TRADER spending: flat rate (dependent upon the cost of the app in the store(s), could be as low as $10k) + monthly rate (depends on where the app is located, could be $1000 per app OR $1000 for apps that are in both stores)
-- Ratings come into account when thinking about HOW LONG the app will be profitable for APP TRADER --> may want to go for APPS with higher initial ratings, to project their longer shelf life 
-- Will need to balance the initial cost, ongoing cost, and the profits ($5,000 per month regardless of the initial cost)
-- want apps that check these boxes: in both stores so that the monthly cost is low[achieved with the initial inner join on the 2 tables], want the lowest flat possible, longest shelf life 
-- 4th of July?????

--query to find apps that are on both stores, looking at them by average rating to start narrowing down what might be a good buy
-- why are there 2 names for certain apps??? --> appears to be the same info just duplicated for no reason 
-- CASE WHEN (arithmetic to show the cost/benefit analysis)
-- top 10 apps spell out AMANDA???
-- need to convert certain columns data type so that they can be used together and compared (rating, review_count)

SELECT DISTINCT(name), ROUND(ROUND(apple.rating + play.rating)/2, 1) as avg_rating, apple.price AS apple_price, play.price AS play_price
FROM app_store_apps AS apple
JOIN play_store_apps AS play
USING(name)
WHERE apple.price = 0
	AND play.price = '0'
ORDER BY avg_rating DESC;

-- apps with the lowest flat rate (10k) AND appear in both stores
-- want to layer in the lifespan of the apps (+ the profit over the course of that lifespan) --> these might be subqueries in the select statements 
-- layer in the initial costs

SELECT 
	DISTINCT(name), 
	ROUND(ROUND(apple.rating + play.rating)/2, 1) as avg_rating, 
	apple.price AS apple_price, 
	CAST(TRIM('$' FROM play.price) AS numeric) AS play_price
FROM app_store_apps AS apple
JOIN play_store_apps AS play
USING(name)
WHERE apple.price BETWEEN 0 AND 1
	AND CAST(TRIM('$' FROM play.price) AS numeric) BETWEEN 0 AND 1
ORDER BY avg_rating DESC;

SELECT CAST(TRIM('$' FROM price) AS numeric) AS play_price
FROM play_store_apps;
--need to trim the $ off the decimals first, then cast as numeric

--FIGURING OUT THE COST OF THE APPS [flat rate (10k) +monthly rate ($1000)]

--FIGURING OUT THE LIFESPAN 
--avg rating * 2 + 1 

-- WITH AS to help separate this nonsense
SELECT 
	DISTINCT(name), 
	ROUND(ROUND(apple.rating + play.rating)/2, 1) as avg_rating, 
	-- apple.price AS apple_price, 
	-- CAST(TRIM('$' FROM play.price) AS numeric) AS play_price,
	(CASE 
		WHEN apple.price > (CAST(TRIM('$' FROM play.price) AS numeric)) THEN apple.price
		ELSE (CAST(TRIM('$' FROM play.price) AS numeric))
	END) AS price,
-- MAX apple price / play price situation so that we can use it in the subsequent case when statement
	-- CASE WHEN price BETWEEN 0 AND 1 THEN 10000
	-- ELSE 'no'
	-- END) AS cost 
	(ROUND(ROUND(apple.rating + play.rating)/2, 1) * 2 + 1) AS lifespan
-- SELECT ADDITONALLY: SUBQUERIES TO SHOW THE COST OF THE APPS, POTENTIAL PROFIT 	
FROM app_store_apps AS apple
JOIN play_store_apps AS play
USING(name)
-- WHERE apple.price BETWEEN 0 AND 1
-- 	AND CAST(TRIM('$' FROM play.price) AS numeric) BETWEEN 0 AND 1
ORDER BY price DESC;

-- WITH AS to help separate this nonsense
SELECT 
	DISTINCT(name), 
	ROUND(ROUND(apple.rating + play.rating)/2, 1) as avg_rating, 
	-- apple.price AS apple_price, 
	-- CAST(TRIM('$' FROM play.price) AS numeric) AS play_price,
	(CASE 
		WHEN apple.price > (CAST(TRIM('$' FROM play.price) AS numeric)) THEN apple.price
		ELSE (CAST(TRIM('$' FROM play.price) AS numeric))
	END) AS price,
-- MAX apple price / play price situation so that we can use it in the subsequent case when statement
	-- CASE WHEN price BETWEEN 0 AND 1 THEN 10000
	-- ELSE 'no'
	-- END) AS cost 
	(ROUND(ROUND(apple.rating + play.rating)/2, 1) * 2 + 1) AS lifespan
-- SELECT ADDITONALLY: SUBQUERIES TO SHOW THE COST OF THE APPS, POTENTIAL PROFIT 	
FROM app_store_apps AS apple
JOIN play_store_apps AS play
USING(name)
ORDER BY price DESC;

SELECT*
FROM app_store_apps;

SELECT*
FROM play_store_apps;
-- might want to use install_count as a potential argument for why you should choose something 
-- content_rating? could go for the Everyone 

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

--rating 0 --> 1 year
--rating 0.5 --> 2 years 
--rating 1 --> 3 years
--rating 1.5 -->4 hours
--rating 2 --> 5 years 
--rating 2.5 --> 6 years 
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.


-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.

-- c. Submit a report based on your findings. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report. 

-- updated 2/18/2023
