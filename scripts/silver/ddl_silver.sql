/*
=======================================================
Create Silver tables in DataWarehouse database to store data coming from Bronze tables
=======================================================
Script purpose:
	This script creasts a new 'silver' tables database with checking for existing
	If the data table exists, it is dropped and recreated. 
	
WARNING:
	Running this script will drop the 'silver' tables if they exist.
	All data in the database will be permanenetly deleted. Proceed with caution
	and ensure you have proper backups before running this script.

*/

-- CRM tables
IF OBJECT_ID ('silver.crm_cust_info','U') IS NOT NULL 
	DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
cst_id	INT
, cst_key VARCHAR(20)
, cst_firstname VARCHAR(20)
, cst_lastname VARCHAR(20)
, cst_marital_status VARCHAR(20)
, cst_gndr VARCHAR(20)
, cst_create_date DATE
, dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_prd_info','U') IS NOT NULL 
	DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
prd_id INT
, cat_id VARCHAR(20)
, prd_key VARCHAR(20)
, prd_nm VARCHAR(50)
, prd_cost 	INT
, prd_line	VARCHAR(20)
, prd_start_dt	DATE
, prd_end_dt DATE
, dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_sales_details','U') IS NOT NULL 
	DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
sls_ord_num VARCHAR(20)
, sls_prd_key VARCHAR(20)
, sls_cust_id  NVARCHAR(20) 
, sls_order_dt DATE
, sls_ship_dt DATE
, sls_due_dt DATE
, sls_sales	INT
, sls_quantity	INT
, sls_price INT
, dwh_create_date DATETIME2 DEFAULT GETDATE()
);


-- ERP tables

IF OBJECT_ID ('silver.erp_cust_az12','U') IS NOT NULL 
	DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
CID	NVARCHAR(20)
, BDATE DATE
, GEN VARCHAR(20)
, dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_loc_a101 ','U') IS NOT NULL 
	DROP TABLE silver.erp_loc_a101 ;
GO

CREATE TABLE silver.erp_loc_a101 (
CID NVARCHAR(20)
, COUNTRY VARCHAR(20)
, dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_px_cat_g1v2','U') IS NOT NULL 
	DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
ID NVARCHAR(20)
, CAT VARCHAR(50)
, SUBCAT VARCHAR(50)
, MAINTENANCE VARCHAR(20) 
, dwh_create_date DATETIME2 DEFAULT GETDATE()
);
