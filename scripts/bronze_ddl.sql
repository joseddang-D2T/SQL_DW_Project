/*
=======================================================
Create BRONZE tables in DataWarehouse database to store data coming from CRM & ERP systems
=======================================================
Script purpose:
	This script creasts a new 'bronze' tables database with checking for existing
	If the database exists, it is dropped and recreated. 
	Tee script also create 3 schemas within the database: 'bronze', 'silver' and 'gold'

WARNING:
	Running this script will drop the entire 'DataWareHouse' database it it exists.
	All data in the database will be permanenetly deleted. Proceed with caution
	and ensure you have proper backups before running this script.

*/


-- CRM tables
IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL 
	DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
cst_id	INT
, cst_key VARCHAR(20)
, cst_firstname VARCHAR(20)
, cst_lastname VARCHAR(20)
, cst_marital_status VARCHAR(5)
, cst_gndr VARCHAR(5)
, cst_create_date DATE
);

IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL 
	DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
prd_id INT
, prd_key VARCHAR(20)
, prd_nm VARCHAR(50)
, prd_cost 	INT
, prd_line	VARCHAR(20)
, prd_start_dt	DATE
, prd_end_dt DATE
);

IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL 
	DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
sls_ord_num VARCHAR(20)
, sls_prd_key VARCHAR(20)
, sls_cust_id  NVARCHAR(20) 
, sls_order_dt VARCHAR(20) 
, sls_ship_dt VARCHAR(20) 
, sls_due_dt VARCHAR(20) 
, sls_sales	INT
, sls_quantity	INT
, sls_price INT
);


-- ERP tables

IF OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL 
	DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
CID	NVARCHAR(20)
, BDATE DATE
, GEN VARCHAR(20)
);

IF OBJECT_ID ('bronze.erp_loc_a101 ','U') IS NOT NULL 
	DROP TABLE bronze.erp_loc_a101 ;
GO

CREATE TABLE bronze.erp_loc_a101 (
CID NVARCHAR(20)
, COUNTRY VARCHAR(20)
);

IF OBJECT_ID ('bronze.erp_px_cat_g1v2','U') IS NOT NULL 
	DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
ID NVARCHAR(20)
, CAT VARCHAR(50)
, SUBCAT VARCHAR(50)
, MAINTENANCE VARCHAR(20) 
);
