
/*========================================================
  1) CREATE SILVER SCHEMA
========================================================*/
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END;
GO

/*========================================================
  2) CREATE LOG TABLE
========================================================*/
IF OBJECT_ID('silver.etl_log', 'U') IS NOT NULL
    DROP TABLE silver.etl_log;
GO

CREATE TABLE silver.etl_log (
    log_id           INT IDENTITY(1,1) PRIMARY KEY,
    procedure_name   VARCHAR(100),
    table_name       VARCHAR(100),
    status           VARCHAR(20),
    rows_affected    INT NULL,
    message          VARCHAR(1000) NULL,
    start_time       DATETIME2,
    end_time         DATETIME2
);
GO

/*========================================================
  3) CREATE 20 SILVER TABLES
  SAME TABLE NAMES + SAME COLUMN NAMES
========================================================*/

IF OBJECT_ID('silver.BRANDS', 'U') IS NOT NULL DROP TABLE silver.BRANDS;
CREATE TABLE silver.BRANDS (
    Brand_ID         INT,
    Brand_Name       VARCHAR(100)
);
GO

IF OBJECT_ID('silver.CUSTOMERS', 'U') IS NOT NULL DROP TABLE silver.CUSTOMERS;
CREATE TABLE silver.CUSTOMERS (
    Customer_ID      INT,
    Full_Name        VARCHAR(255),
    Gender           VARCHAR(20),
    City             VARCHAR(100),
    Loyalty_Level    VARCHAR(50),
    Email            VARCHAR(255)
);
GO


IF OBJECT_ID('silver.DELIVERIES', 'U') IS NOT NULL DROP TABLE silver.DELIVERIES;
CREATE TABLE silver.DELIVERIES (
    Delivery_ID      INT,
    Order_ID         INT,
    Provider_ID      INT,
    Ship_Date        DATE,
    Delivery_Date    DATE,
    Delivery_Status  VARCHAR(50)
);
GO

IF OBJECT_ID('silver.DELIVERY_PROVIDERS', 'U') IS NOT NULL DROP TABLE silver.DELIVERY_PROVIDERS;
CREATE TABLE silver.DELIVERY_PROVIDERS (
    Provider_ID      INT,
    Provider_Name    VARCHAR(150),
    Phone            VARCHAR(50)
);
GO

IF OBJECT_ID('silver.DEPARTMENTS', 'U') IS NOT NULL DROP TABLE silver.DEPARTMENTS;
CREATE TABLE silver.DEPARTMENTS (
    Department_ID    INT,
    Department_Name  VARCHAR(100)
);
GO

IF OBJECT_ID('silver.EMPLOYEES', 'U') IS NOT NULL DROP TABLE silver.EMPLOYEES;
CREATE TABLE silver.EMPLOYEES (
    Employee_ID      INT,
    Name             VARCHAR(200),
    Gender           VARCHAR(20),
    Position         VARCHAR(100),
    Store_ID         INT,
    Hire_Date        DATE
);
GO

IF OBJECT_ID('silver.INVENTORY', 'U') IS NOT NULL DROP TABLE silver.INVENTORY;
CREATE TABLE silver.INVENTORY (
    Inventory_ID     INT,
    Store_ID         INT,
    Product_ID       INT,
    Stock_Level      INT,
    Last_Updated     DATETIME2
);
GO

IF OBJECT_ID('silver.ONLINE_ORDER_ITEMS', 'U') IS NOT NULL DROP TABLE silver.ONLINE_ORDER_ITEMS;
CREATE TABLE silver.ONLINE_ORDER_ITEMS (
    Order_Item_ID    INT,
    Order_ID         INT,
    Product_ID       INT,
    Promotion_ID     INT,
    Quantity         INT,
    Unit_Price       DECIMAL(18,2),
    Total_Line_Amount DECIMAL(18,2)
);
GO

IF OBJECT_ID('silver.ONLINE_ORDERS', 'U') IS NOT NULL DROP TABLE silver.ONLINE_ORDERS;
CREATE TABLE silver.ONLINE_ORDERS (
    Order_ID         INT,
    Customer_ID      INT,
    Warehouse_ID     INT,
    Order_Time       DATETIME2,
    Order_Status     VARCHAR(50),
    Order_Total      DECIMAL(18,2)
);
GO

IF OBJECT_ID('silver.PAYMENTS', 'U') IS NOT NULL DROP TABLE silver.PAYMENTS;
CREATE TABLE silver.PAYMENTS (
    Payment_ID       INT,
    Order_ID         INT,
    Payment_Method   VARCHAR(50),
    Payment_Amount   DECIMAL(18,2),
    Payment_Time     DATETIME2
);
GO

IF OBJECT_ID('silver.POS_TRANSACTIONS', 'U') IS NOT NULL DROP TABLE silver.POS_TRANSACTIONS;
CREATE TABLE silver.POS_TRANSACTIONS (
    Transaction_ID   NVARCHAR(50),
    Store_ID         INT,
    Register_ID      INT,
    Employee_ID      INT,
    Customer_ID      INT,
    Transaction_Time DATETIME2
);
GO

IF OBJECT_ID('silver.PRODUCT_SUPPLIERS', 'U') IS NOT NULL DROP TABLE silver.PRODUCT_SUPPLIERS;
CREATE TABLE silver.PRODUCT_SUPPLIERS (
    Product_ID       INT,
    Supplier_ID      INT,
    Supply_Price     DECIMAL(18,2)
);
GO

IF OBJECT_ID('silver.PRODUCTS', 'U') IS NOT NULL DROP TABLE silver.PRODUCTS;
CREATE TABLE silver.PRODUCTS (
    Product_ID       INT,
    SKU              VARCHAR(100),
    Product_Name     VARCHAR(255),
    Brand_ID         INT,
    Department_ID    INT,
    Package_Size     VARCHAR(50)
);
GO

IF OBJECT_ID('silver.PROMOTIONS', 'U') IS NOT NULL DROP TABLE silver.PROMOTIONS;
CREATE TABLE silver.PROMOTIONS (
    Promotion_ID       INT,
    Promo_Type         VARCHAR(100),
    Discount_Percent   DECIMAL(10,2),
    Start_Date         DATE,
    End_Date           DATE
);
GO

IF OBJECT_ID('silver.REGISTERS', 'U') IS NOT NULL DROP TABLE silver.REGISTERS;
CREATE TABLE silver.REGISTERS (
    Register_ID      INT,
    Store_ID         INT,
    Register_Number  INT
);
GO

IF OBJECT_ID('silver.STORES', 'U') IS NOT NULL DROP TABLE silver.STORES;
CREATE TABLE silver.STORES (
    Store_ID         INT,
    Store_Name       VARCHAR(150),
    City             VARCHAR(100),
    State            VARCHAR(50),
    Region           VARCHAR(50),
    Opening_Date     DATE
);
GO

IF OBJECT_ID('silver.SUPPLIERS', 'U') IS NOT NULL DROP TABLE silver.SUPPLIERS;
CREATE TABLE silver.SUPPLIERS (
    Supplier_ID      INT,
    Supplier_Name    VARCHAR(150),
    Country          VARCHAR(100),
    Phone            VARCHAR(50)
);
GO

IF OBJECT_ID('silver.TRANSACTION_ITEMS', 'U') IS NOT NULL DROP TABLE silver.TRANSACTION_ITEMS;
CREATE TABLE silver.TRANSACTION_ITEMS (
    Line_ID          INT,
    Transaction_ID   NVARCHAR(50),
    Product_ID       INT,
    Promotion_ID     INT,
    Quantity         INT,
    Unit_Price       DECIMAL(18,2),
    Total_Line_Amount DECIMAL(18,2)
);
GO

IF OBJECT_ID('silver.WAREHOUSES', 'U') IS NOT NULL DROP TABLE silver.WAREHOUSES;
CREATE TABLE silver.WAREHOUSES (
    Warehouse_ID     INT,
    Warehouse_Name   VARCHAR(150),
    City             VARCHAR(100),
    State            VARCHAR(50)
);
GO

