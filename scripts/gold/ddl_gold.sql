/*
=======================================================
DDL Script: Create Business Layer Views in Gold schema
=======================================================
Script purpose:
	This script creates a views for the Gold layer in our DataWarehouse.
  This Gold layer represent business logic of the sales, products and customers data from both CRM & ERP systems
  There are 3 views: 2 Dimension (Customer & Product) & 1 Fact (Sales)
  Each view has data transformation and combines with data from Silver layer to product a clean, enriched and business ready dataset
	
Usage: 
  - These views can be query directly for analytics and reporting purposes.
*/

-- =======================================================
-- Create CUSTOMER views
-- =======================================================
IF OBJECT_ID ('gold.D_CUSTOMER_V','V') IS NOT NULL 
	DROP VIEW gold.D_CUSTOMER_V;
GO

CREATE VIEW gold.D_CUSTOMER_V AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) as CUSTOMER_KEY
	, ci.cst_id as CUSTOMER_ID
	, ci.cst_key as CUSTOMER_NUMBER
	, ci.cst_firstname as FIRST_NAME
	, ci.cst_lastname as LAST_NAME
	, ISNULL(la.country,'n/a') as COUNTRY
	, ci.cst_marital_status as MARITAL_STATUS
	, CASE WHEN cst_gndr != 'n/a' THEN cst_gndr 
			ELSE ISNULL(gen,'n/a') 
			END as GENDER
	, ca.bdate as BIRTHDATE
	, ci.cst_create_date as CREATE_DATE
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
		ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid
	WHERE 1=1 
	AND ci.cst_id is not NULL
; 
-- =======================================================
-- Create PRODUCT views
-- =======================================================
IF OBJECT_ID ('gold.D_PRODUCTS_V ','V') IS NOT NULL 
	DROP VIEW gold.D_PRODUCTS_V ;
GO

CREATE VIEW gold.D_PRODUCTS_V as
SELECT
			ROW_NUMBER() OVER (ORDER BY prd_start_dt, pi.prd_key) AS PRODUCT_KEY
			, pi.prd_id as PRODUCT_ID
			, pi.prd_key as PRODUCT_NUMBER 
			, pi.prd_nm as PRODUCT_NAME
			, pi.cat_id as CATEGORY_ID
			, pc.cat as CATEGORY
			, pc.subcat as  SUBCATEGORY
			, pc.maintenance AS MAINTENANCE
			, pi.prd_cost as PRODUCT_COST
			, pi.prd_line as PRODUCT_LINE
			, pi.prd_start_dt as START_DATE
			--, pi.prd_end_dt as END_DATE
		FROM silver.crm_prd_info pi
		LEFT JOIN silver.erp_px_cat_g1v2 pc
		on pi.cat_id = pc.id
		WHERE pi.prd_end_dt is NULL
;
-- =======================================================
-- Create SALES views
-- =======================================================
IF OBJECT_ID ('gold.F_SALE_V','V') IS NOT NULL 
	DROP VIEW gold.F_SALE_V ;
GO

CREATE VIEW gold.F_SALE_V AS
(
select 
	sls_ord_num as ORDER_NUMBER
	, sls_order_dt as ORDER_DATE
	, sls_ship_dt as SHIP_DATE
	, sls_due_dt as DUE_DATE
	, dc.CUSTOMER_KEY
	, dp.PRODUCT_KEY 
	, sls_quantity as QUANTITY
	, CAST(sls_price AS DECIMAL(10,2)) as UNIT_PRICE -- Removing dollar conversion 
	, CAST(sls_sales AS DECIMAL(10,2)) as SALE_VALUE -- Removing dollar conversion 
from silver.crm_sales_details sd
LEFT JOIN gold.D_PRODUCTS_V dp
ON sd.sls_prd_key = dp.PRODUCT_NUMBER
LEFT JOIN gold.D_CUSTOMER_V dc
ON sd.sls_cust_id = dc.CUSTOMER_ID
)
;
