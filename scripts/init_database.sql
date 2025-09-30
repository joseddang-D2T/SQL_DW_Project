-- Create Data Warehouse
/*
=======================================================
Create Database and Schemas
=======================================================
Script purpose:
	This script creasts a new database with checking for existing
	If the database exists, it is dropped and recreated. 
	Tee script also create 3 schemas within the database: 'bronze', 'silver' and 'gold'

WARNING:
	Running this script will drop the entire 'DataWareHouse' database it it exists.
	All data in the database will be permanenetly deleted. Proceed with caution
	and ensure you have proper backups before running this script.
*/


USE master;
GO

-- Drop and create the 'DataWarehouse' database

IF EXISTS (select 1 from sys.databases where name = 'DataWarehouse') 
BEGIN 
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse
END;
GO 

-- Create DataWarehouse database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create 3 schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
