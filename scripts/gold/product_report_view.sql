/* 
===========================================================================
Product Report
===========================================================================
Purpose:
	- This report consolidates the key product metrics and behaviours

Steps:
	1. Base query joining the relevant tables (Sales & Product)
	2. Aggregate data to produce product metrics:
		- Total Sale
		- Total Quantity
		- Total Order
		- Total Customers
		- Lifespans(Months between order) 
		-  product category group (VIP, Regular or New)
	3. Calculate KPIs:
		- Recency ( month since last purchase)
		- Avg order value
		- Avg mthly spend
*/

CREATE VIEW gold.product_report As 
	WITH base as (
	--------------------------------------------
	--   1. Base query
	--------------------------------------------
		select 
		p.PRODUCT_KEY
		, p.PRODUCT_NAME
		, p.PRODUCT_LINE
		, p.PRODUCT_NUMBER
		, p.CATEGORY
		, p.SUBCATEGORY
		, s.QUANTITY
		, s.SALE_VALUE
		, s.ORDER_DATE
		, s.ORDER_NUMBER
		, s.CUSTOMER_KEY
		from gold.F_SALE_V s
		left join gold.D_PRODUCTS_V p
		on s.PRODUCT_KEY = p.PRODUCT_KEY
	) 
	, product_aggregation as (
	--------------------------------------------
	--   2. Aggregation querry:
	--		Metrics & KPI calculations
	--------------------------------------------
	select 
		PRODUCT_KEY
		, PRODUCT_NAME
		, PRODUCT_LINE
		, SUM(SALE_VALUE) as TOTAL_SALE
		, COUNT(DISTINCT ORDER_NUMBER) as TOTAL_ORDER_VOLUME
		, COUNT(DISTINCT CUSTOMER_KEY) as TOTAL_CUSTOMER
		, SUM(QUANTITY) as TOTAL_QUANTITY
		, MIN(ORDER_DATE) as FIRST_ORDER_DATE
		, MAX(ORDER_DATE) as LAST_ORDER_DATE
		, DATEDIFF(month,MIN(ORDER_DATE),MAX(ORDER_DATE)) as LIFESPANS
	from base
	GROUP BY PRODUCT_KEY, PRODUCT_NAME, PRODUCT_LINE
	)
	--------------------------------------------
	--   3. Return results
	--------------------------------------------
	select 
		pa.* 
		, CASE WHEN TOTAL_SALE >= 50000 THEN 'High Performers'
				WHEN TOTAL_SALE > 10000 then 'Mid-Range'
				ELSE 'Low Performers' 
		  END as PRODUCT_CAGEGORY
		, DATEDIFF(month,pa.LAST_ORDER_DATE,GETDATE()) as RECENCY
		, CASE WHEN TOTAL_ORDER_VOLUME = 0 THEN 0 
				ELSE TOTAL_SALE/TOTAL_ORDER_VOLUME 
		  END as AVG_ORDER_REVENUE
		, CASE WHEN LIFESPANS = 0 THEN TOTAL_SALE
				ELSE TOTAL_SALE/LIFESPANS
		  END AS AVG_MONTHLY_REVENUE
	from product_aggregation pa

;
