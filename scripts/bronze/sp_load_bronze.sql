/*
=======================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=======================================================
Script purpose:
	This Stored Procedures loads data into the 'bronze' tables from external csv files'
  It performs the following actions:
    - Truncate data from existing tables
    - Load data using 'BULK INSERT' command from csv files into 'bronze' tables

Parameters:
   None.
   This SP does not accept any parameters or return any values
   
Using example:
  EXEC bronze.load_bronze;

=======================================================
*/

CREATE or ALTER PROCEDURE bronze.load_bronze AS
BEGIN  
	DECLARE @start_batch_time DATETIME, @end_batch_time DATETIME
	DECLARE @start_time DATETIME, @end_time DATETIME

	SET @start_batch_time = GETDATE();
	BEGIN TRY
		PRINT '=====================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=====================================';

		PRINT '-------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-------------------------------------';

		-- Insert data into CRM tables from CSV files
		
		TRUNCATE TABLE bronze.crm_cust_info
		SET @start_time = GETDATE();
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\JD\Documents\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')

		TRUNCATE TABLE bronze.crm_prd_info
		SET @start_time = GETDATE();
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\JD\Documents\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')

		TRUNCATE TABLE bronze.crm_sales_details
		SET @start_time = GETDATE();
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\JD\Documents\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')
		

				-- Insert data into ERP tables from CSV files

		PRINT '-------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-------------------------------------';
		TRUNCATE TABLE bronze.erp_cust_az12
		SET @start_time = GETDATE();
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\JD\Documents\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')

		TRUNCATE TABLE bronze.erp_loc_a101
		SET @start_time = GETDATE();
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\JD\Documents\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')

		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		SET @start_time = GETDATE();
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\JD\Documents\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as VARCHAR) + ' seconds')
		PRINT ('-------------')

	END TRY
	BEGIN CATCH 
		PRINT ('=============================================');
		PRINT ('ERROR OCCURED DURING LOADING BRONE LAYER');
		PRINT ('Error_message' + ERROR_MESSAGE());
		PRINT ('Error_number' + CAST(ERROR_NUMBER() as VARCHAR));
		PRINT ('Error_state' + ERROR_STATE());
		PRINT ('=============================================');
	END CATCH 
	SET @end_batch_time = GETDATE();

	PRINT ('=============================================');
	PRINT ('Batch Start Time:'+ CAST(@start_batch_time as VARCHAR));
	PRINT ('=============================================');
	PRINT ('>> Bronze BATCH Load Duration: ' + CAST(DATEDIFF(second, @start_batch_time, @end_batch_time) as VARCHAR) + ' seconds')
	PRINT ('=============================================');
	PRINT ('Batch End Time:'+ CAST(@end_batch_time as VARCHAR));
	PRINT ('=============================================');

END
