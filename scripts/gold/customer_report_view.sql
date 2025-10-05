/* 
===========================================================================
Customer Report
===========================================================================
Purpose:
	- This report consolidates the key customer metrics and behaviours

Steps:
	1. Base query joining the relevant tables (Sales & Customer)
	2. Aggregate data to produce customer metrics:
		- Total Sale
		- Total Quantity
		- Total Order
		- Lifespans(Months between order) 
		- Customer age group
		- Customer category group (VIP, Regular or New)
	3. Calculate KPIs:
		- Recency ( month since last purchase)
		- Avg order value
		- Avg mthly spend
*/

CREATE VIEW gold.customer_report As 
	WITH base as (
	--------------------------------------------
	--   1. Base query
	--------------------------------------------
		select 
		c.customer_key
		, c.FIRST_NAME
		, c.LAST_NAME
		, c.COUNTRY
		, c.GENDER
		, c.BIRTHDATE
		, s.PRODUCT_KEY
		, s.QUANTITY
		, s.SALE_VALUE
		, s.ORDER_DATE
		, s.ORDER_NUMBER
		from gold.F_SALE_V s
		left join gold.D_CUSTOMER_V c
		on s.CUSTOMER_KEY = c.CUSTOMER_KEY
	) 
	, customer_aggregation as (
	--------------------------------------------
	--   2. Aggregation querry:
	--		Metrics & KPI calculations
	--------------------------------------------
	select 
		CUSTOMER_KEY
		, FIRST_NAME+' '+LAST_NAME as CUSTOMER_NAME
		, BIRTHDATE as CUSTOMER_DOB
		, DATEDIFF(Year,BIRTHDATE,GETDATE()) as CUSTOMER_AGE
		, COUNTRY as CUSTOMER_LOCATION
		, SUM(SALE_VALUE) as TOTAL_SALE
		, COUNT(DISTINCT ORDER_NUMBER) as TOTAL_ORDER_VOLUME
		, COUNT(DISTINCT PRODUCT_KEY) as TOTAL_PRODUCTS
		, SUM(QUANTITY) as TOTAL_QUANTITY
		, MIN(ORDER_DATE) as FIRST_ORDER_DATE
		, MAX(ORDER_DATE) as LAST_ORDER_DATE
		, DATEDIFF(month,MIN(ORDER_DATE),MAX(ORDER_DATE)) as LIFESPANS
	from base
	GROUP BY 	CUSTOMER_KEY, FIRST_NAME+' '+LAST_NAME, BIRTHDATE, DATEDIFF(Year,BIRTHDATE,GETDATE()) , COUNTRY
	)
	--------------------------------------------
	--   3. Return results
	--------------------------------------------
	select 
		ca.* 
		, CASE WHEN CUSTOMER_AGE < 20 THEN 'Under 20'
				WHEN CUSTOMER_AGE BETWEEN 20 and 29 THEN 'Under 30'
				WHEN CUSTOMER_AGE BETWEEN 30 and 39 THEN 'Under 40'
				WHEN CUSTOMER_AGE BETWEEN 40 and 49 THEN 'Under 50'
				ELSE ' 50 and above'
		  END as AGE_GROUP
		, CASE WHEN LIFESPANS >= 12 AND TOTAL_SALE >= 5000 THEN 'VIP'
				WHEN LIFESPANS >12 AND TOTAL_SALE <5000 then 'Regular'
				ELSE 'New' 
		  END as CUSTOMER_CAGEGORY
		, DATEDIFF(month,ca.LAST_ORDER_DATE,GETDATE()) as RECENCY
		, TOTAL_SALE/TOTAL_ORDER_VOLUME as AVG_ORDER_VALUE
		, CASE WHEN LIFESPANS = 0 THEN TOTAL_SALE
				ELSE TOTAL_SALE/LIFESPANS
		  END AS AVG_MONTHLY_SPEND
	from customer_aggregation ca

;
