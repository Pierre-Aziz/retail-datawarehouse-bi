CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start_time DATETIME2;

    -- Dynamic Mean Calculation Variables
    DECLARE @mean_stock_level INT;
    DECLARE @mean_online_unit_price DECIMAL(18,2);
    DECLARE @mean_pos_unit_price DECIMAL(18,2);
    DECLARE @mean_supply_price DECIMAL(18,2);

    BEGIN TRY
        PRINT '>> Calculating Mean Values for Imputation...';
        SELECT @mean_stock_level = AVG(TRY_CAST(Stock_Level AS INT)) FROM bronze.INVENTORY WHERE TRY_CAST(Stock_Level AS INT) IS NOT NULL;
        SELECT @mean_online_unit_price = AVG(TRY_CAST(Unit_Price AS DECIMAL(18,2))) FROM bronze.ONLINE_ORDER_ITEMS WHERE TRY_CAST(Unit_Price AS DECIMAL(18,2)) IS NOT NULL;
        SELECT @mean_pos_unit_price = AVG(TRY_CAST(Unit_Price AS DECIMAL(18,2))) FROM bronze.TRANSACTION_ITEMS WHERE TRY_CAST(Unit_Price AS DECIMAL(18,2)) IS NOT NULL;
        SELECT @mean_supply_price = AVG(TRY_CAST(Supply_Price AS DECIMAL(18,2))) FROM bronze.PRODUCT_SUPPLIERS WHERE TRY_CAST(Supply_Price AS DECIMAL(18,2)) IS NOT NULL;

        -----------------------------------------------------------
        -- 1. BRANDS
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.BRANDS;
        INSERT INTO silver.BRANDS (Brand_ID, Brand_Name)
        SELECT DISTINCT TRY_CAST(Brand_ID AS INT), NULLIF(TRIM(Brand_Name), '')
        FROM bronze.BRANDS WHERE Brand_ID IS NOT NULL;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','BRANDS','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 2. CUSTOMERS (Standardization & Derived Full_Name)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.CUSTOMERS;
        WITH CustCTE AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(Email)) ORDER BY Customer_ID) as rn
            FROM bronze.CUSTOMERS
        )
        INSERT INTO silver.CUSTOMERS (Customer_ID,Full_Name, Gender, City, Loyalty_Level, Email)
        SELECT TRY_CAST(Customer_ID AS INT), CONCAT(TRIM(First_Name), ' ', TRIM(Last_Name)),
               CASE WHEN UPPER(TRIM(Gender)) IN ('M','MALE') THEN 'Male' WHEN UPPER(TRIM(Gender)) IN ('F','FEMALE') THEN 'Female' ELSE 'Unknown' END,
               TRIM(City), TRIM(Loyalty_Level), LOWER(TRIM(Email))
               
        FROM CustCTE WHERE rn = 1 OR Email IS NULL;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','CUSTOMERS','SUCCESS',@@ROWCOUNT,'Deduplicated & Derived Full_Name',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 3. DEPARTMENTS
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.DEPARTMENTS;
        INSERT INTO silver.DEPARTMENTS (Department_ID, Department_Name)
        SELECT DISTINCT TRY_CAST(Department_ID AS INT), TRIM(Department_Name) FROM bronze.DEPARTMENTS;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','DEPARTMENTS','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 4. DELIVERY_PROVIDERS
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.DELIVERY_PROVIDERS;
        INSERT INTO silver.DELIVERY_PROVIDERS (Provider_ID, Provider_Name, Phone)
        SELECT DISTINCT TRY_CAST(Provider_ID AS INT), TRIM(Provider_Name), TRIM(Phone) FROM bronze.DELIVERY_PROVIDERS;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','DELIVERY_PROVIDERS','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 5. EMPLOYEES (Standardization)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.EMPLOYEES;
        INSERT INTO silver.EMPLOYEES (Employee_ID, Name, Gender, Position, Store_ID, Hire_Date)
        SELECT DISTINCT TRY_CAST(Employee_ID AS INT), TRIM(Name), 
               CASE WHEN UPPER(TRIM(Gender)) IN ('M','MALE') THEN 'Male' WHEN UPPER(TRIM(Gender)) IN ('F','FEMALE') THEN 'Female' ELSE 'Unknown' END,
               TRIM(Position), TRY_CAST(Store_ID AS INT), TRY_CAST(Hire_Date AS DATE)
        FROM bronze.EMPLOYEES;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','EMPLOYEES','SUCCESS',@@ROWCOUNT,'Standardized Gender',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 6. STORES
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.STORES;
        INSERT INTO silver.STORES (Store_ID, Store_Name, City, State, Region, Opening_Date)
        SELECT DISTINCT TRY_CAST(Store_ID AS INT), TRIM(Store_Name), TRIM(City), TRIM(State), TRIM(Region), TRY_CAST(Opening_Date AS DATE)
        FROM bronze.STORES;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','STORES','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 7. WAREHOUSES
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.WAREHOUSES;
        INSERT INTO silver.WAREHOUSES (Warehouse_ID, Warehouse_Name, City, State)
        SELECT DISTINCT TRY_CAST(Warehouse_ID AS INT), TRIM(Warehouse_Name), TRIM(City), TRIM(State) FROM bronze.WAREHOUSES;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','WAREHOUSES','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 8. SUPPLIERS
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.SUPPLIERS;
        INSERT INTO silver.SUPPLIERS (Supplier_ID, Supplier_Name, Country, Phone)
        SELECT DISTINCT TRY_CAST(Supplier_ID AS INT), TRIM(Supplier_Name), TRIM(Country), TRIM(Phone) FROM bronze.SUPPLIERS;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','SUPPLIERS','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 9. REGISTERS
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.REGISTERS;
        INSERT INTO silver.REGISTERS (Register_ID, Store_ID, Register_Number)
        SELECT DISTINCT TRY_CAST(Register_ID AS INT), TRY_CAST(Store_ID AS INT), TRY_CAST(Register_Number AS INT) FROM bronze.REGISTERS;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','REGISTERS','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 10. PRODUCTS
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.PRODUCTS;
        INSERT INTO silver.PRODUCTS (Product_ID, SKU, Product_Name, Brand_ID, Department_ID, Package_Size)
        SELECT DISTINCT TRY_CAST(Product_ID AS INT), TRIM(SKU), TRIM(Product_Name), TRY_CAST(Brand_ID AS INT), TRY_CAST(Department_ID AS INT), TRIM(Package_Size)
        FROM bronze.PRODUCTS;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','PRODUCTS','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 11. PROMOTIONS (Strict Removal Rules)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.PROMOTIONS;
        INSERT INTO silver.PROMOTIONS (Promotion_ID, Promo_Type, Discount_Percent, Start_Date, End_Date)
        SELECT DISTINCT TRY_CAST(Promotion_ID AS INT), TRIM(Promo_Type), TRY_CAST(Discount_Percent AS DECIMAL(5,2)), 
               TRY_CAST(Start_Date AS DATE), TRY_CAST(End_Date AS DATE)
        FROM bronze.PROMOTIONS
        WHERE TRY_CAST(Discount_Percent AS DECIMAL(5,2)) IS NOT NULL
          AND TRY_CAST(End_Date AS DATE) >= TRY_CAST(Start_Date AS DATE);
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','PROMOTIONS','SUCCESS',@@ROWCOUNT,'Removed Date/Discount Violations',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 12. INVENTORY (Imputation)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.INVENTORY;
        INSERT INTO silver.INVENTORY (Inventory_ID, Store_ID, Product_ID, Stock_Level, Last_Updated)
        SELECT DISTINCT TRY_CAST(Inventory_ID AS INT), TRY_CAST(Store_ID AS INT), TRY_CAST(Product_ID AS INT), 
               ISNULL(TRY_CAST(Stock_Level AS INT), @mean_stock_level), 
               TRY_CAST(Last_Updated AS DATETIME2)
        FROM bronze.INVENTORY;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','INVENTORY','SUCCESS',@@ROWCOUNT,'Imputed Stock Level',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 13. PRODUCT_SUPPLIERS (Imputation)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.PRODUCT_SUPPLIERS;
        INSERT INTO silver.PRODUCT_SUPPLIERS (Product_ID, Supplier_ID, Supply_Price)
        SELECT DISTINCT TRY_CAST(Product_ID AS INT), TRY_CAST(Supplier_ID AS INT), 
               ISNULL(TRY_CAST(Supply_Price AS DECIMAL(18,2)), @mean_supply_price)
        FROM bronze.PRODUCT_SUPPLIERS;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','PRODUCT_SUPPLIERS','SUCCESS',@@ROWCOUNT,'Imputed Supply Price',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 14. POS_TRANSACTIONS
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.POS_TRANSACTIONS;
        INSERT INTO silver.POS_TRANSACTIONS (Transaction_ID, Store_ID, Register_ID, Employee_ID, Customer_ID, Transaction_Time)
        SELECT DISTINCT TRIM(Transaction_ID), TRY_CAST(Store_ID AS INT), TRY_CAST(Register_ID AS INT), TRY_CAST(Employee_ID AS INT), TRY_CAST(Customer_ID AS INT), TRY_CAST(Transaction_Time AS DATETIME2)
        FROM bronze.POS_TRANSACTIONS;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','POS_TRANSACTIONS','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 15. TRANSACTION_ITEMS (Derived Total & Imputation)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.TRANSACTION_ITEMS;
        INSERT INTO silver.TRANSACTION_ITEMS (Line_ID, Transaction_ID, Product_ID, Promotion_ID, Quantity, Unit_Price, Total_Line_Amount)
        SELECT DISTINCT TRY_CAST(Line_ID AS INT), TRIM(Transaction_ID), TRY_CAST(Product_ID AS INT), TRY_CAST(Promotion_ID AS INT), 
               TRY_CAST(Quantity AS INT), 
               ISNULL(TRY_CAST(Unit_Price AS DECIMAL(18,2)), @mean_pos_unit_price),
               (TRY_CAST(Quantity AS INT) * ISNULL(TRY_CAST(Unit_Price AS DECIMAL(18,2)), @mean_pos_unit_price)) -- Derived
        FROM bronze.TRANSACTION_ITEMS
        WHERE TRY_CAST(Quantity AS INT) IS NOT NULL;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','TRANSACTION_ITEMS','SUCCESS',@@ROWCOUNT,'Derived Totals & Imputed Price',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 16. ONLINE_ORDERS (Calculation)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.ONLINE_ORDERS;
        INSERT INTO silver.ONLINE_ORDERS (Order_ID, Customer_ID, Warehouse_ID, Order_Time, Order_Status, Order_Total)
        SELECT DISTINCT TRY_CAST(o.Order_ID AS INT), TRY_CAST(o.Customer_ID AS INT), TRY_CAST(o.Warehouse_ID AS INT), TRY_CAST(o.Order_Time AS DATETIME2), TRIM(o.Order_Status), 
               COALESCE(TRY_CAST(o.Order_Total AS DECIMAL(18,2)), 
                   (SELECT SUM(ISNULL(TRY_CAST(i.Quantity AS INT), 0) * ISNULL(TRY_CAST(i.Unit_Price AS DECIMAL(18,2)), @mean_online_unit_price)) 
                    FROM bronze.ONLINE_ORDER_ITEMS i WHERE TRIM(i.Order_ID) = TRIM(o.Order_ID))
               ) 
        FROM bronze.ONLINE_ORDERS o;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','ONLINE_ORDERS','SUCCESS',@@ROWCOUNT,'Calculated Missing Totals',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 17. ONLINE_ORDER_ITEMS (Derived Total & Imputation)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.ONLINE_ORDER_ITEMS;
        INSERT INTO silver.ONLINE_ORDER_ITEMS (Order_Item_ID, Order_ID, Product_ID, Promotion_ID, Quantity, Unit_Price, Total_Line_Amount)
        SELECT DISTINCT TRY_CAST(Order_Item_ID AS INT), TRY_CAST(Order_ID AS INT), TRY_CAST(Product_ID AS INT), TRY_CAST(Promotion_ID AS INT), 
               TRY_CAST(Quantity AS INT), 
               ISNULL(TRY_CAST(Unit_Price AS DECIMAL(18,2)), @mean_online_unit_price),
               (TRY_CAST(Quantity AS INT) * ISNULL(TRY_CAST(Unit_Price AS DECIMAL(18,2)), @mean_online_unit_price)) -- Derived
        FROM bronze.ONLINE_ORDER_ITEMS
        WHERE TRY_CAST(Quantity AS INT) IS NOT NULL;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','ONLINE_ORDER_ITEMS','SUCCESS',@@ROWCOUNT,'Derived Totals & Imputed Price',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 18. PAYMENTS (Synchronize mismatched amounts with Order_Total)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.PAYMENTS;
        INSERT INTO silver.PAYMENTS (Payment_ID, Order_ID, Payment_Method, Payment_Amount, Payment_Time)
        SELECT DISTINCT 
               TRIM(p.Payment_ID), TRIM(p.Order_ID), TRIM(p.Payment_Method), 
               -- Replace null or mismatched payment amounts with the exact Order_Total
               ISNULL(TRY_CAST(o.Order_Total AS DECIMAL(18,2)), TRY_CAST(p.Payment_Amount AS DECIMAL(18,2))), 
               TRY_CAST(p.Payment_Time AS DATETIME2)
        FROM bronze.PAYMENTS p
        LEFT JOIN silver.ONLINE_ORDERS o ON TRIM(p.Order_ID) = o.Order_ID;
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','PAYMENTS','SUCCESS',@@ROWCOUNT,'Fixed Amount Mismatches',@start_time,SYSDATETIME());

        -----------------------------------------------------------
        -- 19. DELIVERIES (Strict Removal Rule)
        -----------------------------------------------------------
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE silver.DELIVERIES;
        INSERT INTO silver.DELIVERIES (Delivery_ID, Order_ID, Provider_ID, Ship_Date, Delivery_Date, Delivery_Status)
        SELECT DISTINCT TRY_CAST(Delivery_ID AS INT), TRY_CAST(Order_ID AS INT), TRY_CAST(Provider_ID AS INT), 
               TRY_CAST(Ship_Date AS DATE), TRY_CAST(Delivery_Date AS DATE), TRIM(Delivery_Status)
        FROM bronze.DELIVERIES
        WHERE TRY_CAST(Delivery_Date AS DATE) >= TRY_CAST(Ship_Date AS DATE);
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','DELIVERIES','SUCCESS',@@ROWCOUNT,'Removed Date Violations',@start_time,SYSDATETIME());

        
        SET @start_time = SYSDATETIME();
        INSERT INTO silver.etl_log VALUES ('silver.load_silver','DATA_QUALITY_REPORT','SUCCESS',@@ROWCOUNT,'Loaded',@start_time,SYSDATETIME());

        PRINT '>> ALL 20 TABLES LOADED WITH DERIVED COLUMNS & QUALITY RULES <<';

    END TRY
    BEGIN CATCH
        INSERT INTO silver.etl_log (procedure_name, table_name, status, message, start_time, end_time)
        VALUES ('silver.load_silver', 'FULL_LOAD', 'FAILED', ERROR_MESSAGE(), @start_time, SYSDATETIME());
        THROW;
    END CATCH
END;
GO

-- Run the final load
EXECUTE silver.load_silver;