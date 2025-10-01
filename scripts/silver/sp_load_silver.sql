/*
=======================================================
Insert data into SILVER tables after Data Cleansing from BRONZE tables
=======================================================
Script purpose:
	This script update data in Silver tables based on their equivalent Bronze counterparts.
	Significant data transformation to cleanse, standardise and remove/handle null was performed on each table.
	Data from the table is truncated and re-inserted is dropped and recreated. 
	
Parameters:
   None.
   This SP does not accept any parameters or return any values
   
Using example:
  EXEC silver.load_silver;
*/


CREATE or ALTER PROCEDURE silver.load_silver AS
BEGIN  
	DECLARE @start_batch_time DATETIME, @end_batch_time DATETIME
	DECLARE @start_time DATETIME, @end_time DATETIME

	SET @start_batch_time = GETDATE();
	BEGIN TRY
		PRINT '=====================================';
		PRINT 'Loading Silver Layer';
		PRINT '=====================================';

		PRINT '-------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-------------------------------------';

		-- Insert data into Silver CRM from Bronze CRM tables with cleansing
		
		PRINT '>> Loading silver.crm_cust_info Tables';
		TRUNCATE TABLE silver.crm_cust_info;
		SET @start_time = GETDATE();
		WITH rank AS (
			SELECT 
				*
				, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_past
			FROM bronze.crm_cust_info
			) 
		, clean AS (
			SELECT  
				[cst_id]
			  , [cst_key]
			  , TRIM([cst_firstname]) as cst_firstname
			  , TRIM([cst_lastname]) as cst_lastname
			  , CASE WHEN UPPER([cst_marital_status]) = 'S' THEN 'Single'
					 WHEN UPPER([cst_marital_status]) = 'M' THEN 'Married'
					 ELSE 'n/a' end as cst_marital_status
			  , CASE WHEN UPPER([cst_gndr]) = 'F' THEN 'Female'
					 WHEN UPPER([cst_gndr]) = 'M' THEN 'Male'
					 ELSE 'n/a' end as cst_gndr
			  , [cst_create_date]
			FROM rank 
			WHERE flag_past = '1'
		)
		INSERT INTO silver.crm_cust_info (
				[cst_id]
			  ,[cst_key]
			  ,[cst_firstname]
			  ,[cst_lastname]
			  ,[cst_marital_status]
			  ,[cst_gndr]
			  ,[cst_create_date]    
		)
		SELECT * FROM clean;
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')

		PRINT ('-------------');
		PRINT '>> Loading silver.crm_prd_info Tables';
		TRUNCATE TABLE silver.crm_prd_info;
		SET @start_time = GETDATE();
		INSERT INTO silver.crm_prd_info (
			prd_id 
			, cat_id
			, prd_key
			, prd_nm
			, prd_cost
			, prd_line
			, prd_start_dt
			, prd_end_dt
		) 
		SELECT 
			 [prd_id]
			  , REPLACE(LEFT(prd_key,5),'-','_') as cat_id
			  , TRIM(SUBSTRING(prd_key,7,LEN(prd_key))) as prd_key
			  , [prd_nm]
			  , ISNULL([prd_cost], 0) as prd_cost
			  , CASE UPPER(TRIM(prd_line))
					 WHEN 'S' THEN 'Sport'
					 WHEN 'M' THEN 'Mountain'
					 WHEN 'R' THEN 'Road'
					 WHEN 'T' THEN 'Touring'
					 ELSE 'n/a' END as prd_line
			  , CAST([prd_start_dt] AS DATE) as prd_start_dt
			  , DATEADD(day,-1,LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) as prd_end_dt
		FROM bronze.crm_prd_info
		ORDER BY prd_id ASC;
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')
		
		PRINT '>> Loading silver.crm_sales_details Tables';
		TRUNCATE TABLE silver.crm_sales_details;
		SET @start_time = GETDATE();
		INSERT INTO silver.crm_sales_details (
			sls_ord_num 
			, sls_prd_key
			, sls_cust_id
			, sls_order_dt
			, sls_ship_dt
			, sls_due_dt
			, sls_sales
			, sls_quantity
			, sls_price
		)
		SELECT 
			sls_ord_num
			, sls_prd_key
			, sls_cust_id
			, CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_order_dt as VARCHAR) as DATE) 
			  END as sls_order_dt
		    , CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_ship_dt as VARCHAR) as DATE) 
			  END as sls_ship_dt
			, CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_due_dt as VARCHAR) as DATE) 
			  END as sls_due_dt
			, CASE WHEN sls_sales is NULL or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
					ELSE sls_sales 
			  END as sls_sales
			, sls_quantity
			, CASE WHEN sls_price is NULL or sls_price <= 0  THEN ABS(sls_sales) / NULLIF(sls_quantity, 0) 
					ELSE sls_price 
			  END as sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')

		PRINT '-------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-------------------------------------';

		PRINT '>> Loading silver.erp_cust_az12 Tables';
		TRUNCATE TABLE silver.erp_cust_az12;
		SET @start_time = GETDATE();
		INSERT INTO silver.erp_cust_az12 (
				CID
				, BDATE
				, GEN
			)
			SELECT 
				CASE WHEN LEN(CID) >10 THEN RIGHT(CID, 10)
						ELSE CID 
				END as CID
				, CASE WHEN BDATE > GETDATE() THEN NULL 
						ELSE BDATE
				END as BDATE
				, CASE GEN 
						WHEN 'F' THEN 'Female'
						WHEN 'M' THEN 'Male'
						WHEN '' THEN 'n/a'
						ELSE ISNULL(GEN,'n/a')
				  END as GEN
			FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')
		
		PRINT '>> Loading silver.erp_loc_a101 Tables';
		TRUNCATE TABLE silver.erp_loc_a101;
		SET @start_time = GETDATE();
		INSERT INTO silver.erp_loc_a101(
				CID
				, COUNTRY
			)
			SELECT 
				REPLACE(CID,'-','') as CID
				, CASE COUNTRY 
						WHEN 'US' THEN 'United States'
						WHEN 'USA' THEN 'United States'
						WHEN '' THEN 'n/a'
						WHEN 'DE' THEN 'Germany'
						ELSE ISNULL(COUNTRY,'n/a')
					END as COUNTRY
			FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')

		PRINT '>> Loading silver.erp_px_cat_g1v2 Tables';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		SET @start_time = GETDATE();
		INSERT INTO silver.erp_px_cat_g1v2(
				ID
				, CAT
				, SUBCAT
				, MAINTENANCE
			)
			SELECT 
				ID
				, CAT
				, SUBCAT
				, MAINTENANCE
			FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')
	END TRY
	
	BEGIN CATCH 
		PRINT ('=============================================');
		PRINT ('ERROR OCCURED DURING LOADING SILVER LAYER');
		PRINT ('Error_message' + ERROR_MESSAGE());
		PRINT ('Error_number' + CAST(ERROR_NUMBER() as VARCHAR));
		PRINT ('Error_state' + ERROR_STATE());
		PRINT ('=============================================');
	END CATCH 
	SET @end_batch_time = GETDATE();

	PRINT ('=============================================');
	PRINT ('Batch Start Time:'+ CAST(@start_batch_time as VARCHAR));
	PRINT ('=============================================');
	PRINT ('>> Silver BATCH Load Duration: ' + CAST(DATEDIFF(second, @start_batch_time, @end_batch_time) as VARCHAR) + ' seconds')
	PRINT ('=============================================');
	PRINT ('Batch End Time:'+ CAST(@end_batch_time as VARCHAR));
	PRINT ('=============================================');

END
