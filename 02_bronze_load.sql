
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start_time DATETIME;
    PRINT '>> Starting Full Bronze Load...';

    BEGIN TRY
        -- 1. BRANDS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.BRANDS;
        BULK INSERT bronze.BRANDS FROM 'C:\SQLData\bi_full_dataset\BRANDS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.BRANDS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.BRANDS), 'SUCCESS');

        -- 2. CUSTOMERS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.CUSTOMERS;
        BULK INSERT bronze.CUSTOMERS FROM 'C:\SQLData\bi_full_dataset\CUSTOMERS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.CUSTOMERS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.CUSTOMERS), 'SUCCESS');

        
        -- 4. DELIVERIES
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.DELIVERIES;
        BULK INSERT bronze.DELIVERIES FROM 'C:\SQLData\bi_full_dataset\DELIVERIES.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.DELIVERIES', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.DELIVERIES), 'SUCCESS');

        -- 5. DELIVERY_PROVIDERS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.DELIVERY_PROVIDERS;
        BULK INSERT bronze.DELIVERY_PROVIDERS FROM 'C:\SQLData\bi_full_dataset\DELIVERY_PROVIDERS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.DELIVERY_PROVIDERS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.DELIVERY_PROVIDERS), 'SUCCESS');

        -- 6. DEPARTMENTS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.DEPARTMENTS;
        BULK INSERT bronze.DEPARTMENTS FROM 'C:\SQLData\bi_full_dataset\DEPARTMENTS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.DEPARTMENTS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.DEPARTMENTS), 'SUCCESS');

        -- 7. EMPLOYEES
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.EMPLOYEES;
        BULK INSERT bronze.EMPLOYEES FROM 'C:\SQLData\bi_full_dataset\EMPLOYEES.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.EMPLOYEES', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.EMPLOYEES), 'SUCCESS');

        -- 8. INVENTORY
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.INVENTORY;
        BULK INSERT bronze.INVENTORY FROM 'C:\SQLData\bi_full_dataset\INVENTORY.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.INVENTORY', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.INVENTORY), 'SUCCESS');

        -- 9. ONLINE_ORDER_ITEMS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.ONLINE_ORDER_ITEMS;
        BULK INSERT bronze.ONLINE_ORDER_ITEMS FROM 'C:\SQLData\bi_full_dataset\ONLINE_ORDER_ITEMS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.ONLINE_ORDER_ITEMS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.ONLINE_ORDER_ITEMS), 'SUCCESS');

        -- 10. ONLINE_ORDERS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.ONLINE_ORDERS;
        BULK INSERT bronze.ONLINE_ORDERS FROM 'C:\SQLData\bi_full_dataset\ONLINE_ORDERS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.ONLINE_ORDERS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.ONLINE_ORDERS), 'SUCCESS');

        -- 11. PAYMENTS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.PAYMENTS;
        BULK INSERT bronze.PAYMENTS FROM 'C:\SQLData\bi_full_dataset\PAYMENTS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.PAYMENTS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.PAYMENTS), 'SUCCESS');

        -- 12. POS_TRANSACTIONS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.POS_TRANSACTIONS;
        BULK INSERT bronze.POS_TRANSACTIONS FROM 'C:\SQLData\bi_full_dataset\POS_TRANSACTIONS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.POS_TRANSACTIONS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.POS_TRANSACTIONS), 'SUCCESS');

        -- 13. PRODUCT_SUPPLIERS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.PRODUCT_SUPPLIERS;
        BULK INSERT bronze.PRODUCT_SUPPLIERS FROM 'C:\SQLData\bi_full_dataset\PRODUCT_SUPPLIERS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.PRODUCT_SUPPLIERS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.PRODUCT_SUPPLIERS), 'SUCCESS');

        -- 14. PRODUCTS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.PRODUCTS;
        BULK INSERT bronze.PRODUCTS FROM 'C:\SQLData\bi_full_dataset\PRODUCTS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.PRODUCTS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.PRODUCTS), 'SUCCESS');

        -- 15. PROMOTIONS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.PROMOTIONS;
        BULK INSERT bronze.PROMOTIONS FROM 'C:\SQLData\bi_full_dataset\PROMOTIONS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.PROMOTIONS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.PROMOTIONS), 'SUCCESS');

        -- 16. REGISTERS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.REGISTERS;
        BULK INSERT bronze.REGISTERS FROM 'C:\SQLData\bi_full_dataset\REGISTERS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.REGISTERS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.REGISTERS), 'SUCCESS');

        -- 17. STORES
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.STORES;
        BULK INSERT bronze.STORES FROM 'C:\SQLData\bi_full_dataset\STORES.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.STORES', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.STORES), 'SUCCESS');

        -- 18. SUPPLIERS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.SUPPLIERS;
        BULK INSERT bronze.SUPPLIERS FROM 'C:\SQLData\bi_full_dataset\SUPPLIERS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.SUPPLIERS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.SUPPLIERS), 'SUCCESS');

        -- 19. TRANSACTION_ITEMS
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.TRANSACTION_ITEMS;
        BULK INSERT bronze.TRANSACTION_ITEMS FROM 'C:\SQLData\bi_full_dataset\TRANSACTION_ITEMS.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.TRANSACTION_ITEMS', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.TRANSACTION_ITEMS), 'SUCCESS');

        -- 20. WAREHOUSES
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.WAREHOUSES;
        BULK INSERT bronze.WAREHOUSES FROM 'C:\SQLData\bi_full_dataset\WAREHOUSES.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
        INSERT INTO bronze.load_log (table_name, start_time, end_time, rows_inserted, status) VALUES ('bronze.WAREHOUSES', @start_time, GETDATE(), (SELECT COUNT(*) FROM bronze.WAREHOUSES), 'SUCCESS');

        PRINT '>> Bronze Load Completed Successfully!';
    END TRY
    BEGIN CATCH
        PRINT '>> ERROR: ' + ERROR_MESSAGE();
        INSERT INTO bronze.load_log (table_name, start_time, end_time, status, error_message) 
        VALUES ('BATCH_PROCESS_FAILED', @start_time, GETDATE(), 'FAILED', ERROR_MESSAGE());
    END CATCH
END
GO

USE DataWarehouse;
GO
EXEC bronze.load_bronze;
SELECT * FROM bronze.load_log;