/* =========================================================================
   PART 1: ENVIRONMENT SETUP
========================================================================= */
-- 1. Create the Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    CREATE DATABASE DataWarehouse;
END
GO

USE DataWarehouse;
GO

-- 2. Create the Bronze Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze');
END
GO

-- 3. Create the Audit Log Table
IF OBJECT_ID('bronze.load_log', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.load_log (
        load_id        INT IDENTITY(1,1) PRIMARY KEY,
        table_name     NVARCHAR(100),
        start_time     DATETIME,
        end_time       DATETIME,
        rows_inserted  INT,
        status         NVARCHAR(20),
        error_message  NVARCHAR(MAX)
    );
END
GO

/* =========================================================================
   PART 2: CREATE BRONZE TABLES (All set to NVARCHAR(MAX) to mirror source)
========================================================================= */

DROP TABLE IF EXISTS bronze.BRANDS;
CREATE TABLE bronze.BRANDS (Brand_ID NVARCHAR(MAX), Brand_Name NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.CUSTOMERS;
CREATE TABLE bronze.CUSTOMERS (Customer_ID NVARCHAR(MAX), First_Name NVARCHAR(MAX), Last_Name NVARCHAR(MAX), Gender NVARCHAR(MAX), City NVARCHAR(MAX), Loyalty_Level NVARCHAR(MAX), Email NVARCHAR(MAX));


DROP TABLE IF EXISTS bronze.DELIVERIES;
CREATE TABLE bronze.DELIVERIES (Delivery_ID NVARCHAR(MAX), Order_ID NVARCHAR(MAX), Provider_ID NVARCHAR(MAX), Ship_Date NVARCHAR(MAX), Delivery_Date NVARCHAR(MAX), Delivery_Status NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.DELIVERY_PROVIDERS;
CREATE TABLE bronze.DELIVERY_PROVIDERS (Provider_ID NVARCHAR(MAX), Provider_Name NVARCHAR(MAX), Phone NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.DEPARTMENTS;
CREATE TABLE bronze.DEPARTMENTS (Department_ID NVARCHAR(MAX), Department_Name NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.EMPLOYEES;
CREATE TABLE bronze.EMPLOYEES (Employee_ID NVARCHAR(MAX), Name NVARCHAR(MAX), Gender NVARCHAR(MAX), Position NVARCHAR(MAX), Store_ID NVARCHAR(MAX), Hire_Date NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.INVENTORY;
CREATE TABLE bronze.INVENTORY (Inventory_ID NVARCHAR(MAX), Store_ID NVARCHAR(MAX), Product_ID NVARCHAR(MAX), Stock_Level NVARCHAR(MAX), Last_Updated NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.ONLINE_ORDER_ITEMS;
CREATE TABLE bronze.ONLINE_ORDER_ITEMS (Order_Item_ID NVARCHAR(MAX), Order_ID NVARCHAR(MAX), Product_ID NVARCHAR(MAX), Promotion_ID NVARCHAR(MAX), Quantity NVARCHAR(MAX), Unit_Price NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.ONLINE_ORDERS;
CREATE TABLE bronze.ONLINE_ORDERS (Order_ID NVARCHAR(MAX), Customer_ID NVARCHAR(MAX), Warehouse_ID NVARCHAR(MAX), Order_Time NVARCHAR(MAX), Order_Status NVARCHAR(MAX), Order_Total NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.PAYMENTS;
CREATE TABLE bronze.PAYMENTS (Payment_ID NVARCHAR(MAX), Order_ID NVARCHAR(MAX), Payment_Method NVARCHAR(MAX), Payment_Amount NVARCHAR(MAX), Payment_Time NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.POS_TRANSACTIONS;
CREATE TABLE bronze.POS_TRANSACTIONS (Transaction_ID NVARCHAR(MAX), Store_ID NVARCHAR(MAX), Register_ID NVARCHAR(MAX), Employee_ID NVARCHAR(MAX), Customer_ID NVARCHAR(MAX), Transaction_Time NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.PRODUCT_SUPPLIERS;
CREATE TABLE bronze.PRODUCT_SUPPLIERS (Product_ID NVARCHAR(MAX), Supplier_ID NVARCHAR(MAX), Supply_Price NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.PRODUCTS;
CREATE TABLE bronze.PRODUCTS (Product_ID NVARCHAR(MAX), SKU NVARCHAR(MAX), Product_Name NVARCHAR(MAX), Brand_ID NVARCHAR(MAX), Department_ID NVARCHAR(MAX), Package_Size NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.PROMOTIONS;
CREATE TABLE bronze.PROMOTIONS (Promotion_ID NVARCHAR(MAX), Promo_Type NVARCHAR(MAX), Discount_Percent NVARCHAR(MAX), Start_Date NVARCHAR(MAX), End_Date NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.REGISTERS;
CREATE TABLE bronze.REGISTERS (Register_ID NVARCHAR(MAX), Store_ID NVARCHAR(MAX), Register_Number NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.STORES;
CREATE TABLE bronze.STORES (Store_ID NVARCHAR(MAX), Store_Name NVARCHAR(MAX), City NVARCHAR(MAX), State NVARCHAR(MAX), Region NVARCHAR(MAX), Opening_Date NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.SUPPLIERS;
CREATE TABLE bronze.SUPPLIERS (Supplier_ID NVARCHAR(MAX), Supplier_Name NVARCHAR(MAX), Country NVARCHAR(MAX), Phone NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.TRANSACTION_ITEMS;
CREATE TABLE bronze.TRANSACTION_ITEMS (Line_ID NVARCHAR(MAX), Transaction_ID NVARCHAR(MAX), Product_ID NVARCHAR(MAX), Promotion_ID NVARCHAR(MAX), Quantity NVARCHAR(MAX), Unit_Price NVARCHAR(MAX));

DROP TABLE IF EXISTS bronze.WAREHOUSES;
CREATE TABLE bronze.WAREHOUSES (Warehouse_ID NVARCHAR(MAX), Warehouse_Name NVARCHAR(MAX), City NVARCHAR(MAX), State NVARCHAR(MAX));
GO
