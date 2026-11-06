# Retail Data Warehouse & BI — Medallion Architecture on SQL Server

An end-to-end omnichannel retail warehouse: 20 raw CSV source tables ingested through Bronze,
Silver and Gold layers into a **galaxy schema** with two fact tables and four conformed
dimensions, surfaced through a four-page Power BI suite with DAX KPIs and strategic targets.

**Stack:** Microsoft SQL Server · T-SQL · Stored Procedures · Kimball dimensional modelling · Power BI · DAX

---

## About this project

This was a project for Business Intelligence & Analytics (BINF 602) at the German
International University.

## Architecture

```
20 CSV source tables (CRM / ERP extracts)
        │
        ▼
  BRONZE   raw landing zone · NVARCHAR(MAX) mirrors source · BULK INSERT
           truncate-and-insert · bronze.load_log audit table
        │
        ▼
  SILVER   typed, deduplicated, business-validated single source of truth
           TRY_CAST · TRIM · dedup via ROW_NUMBER · derived columns
           silver.etl_log with per-table row counts and timings
        │
        ▼
  GOLD     galaxy schema · 9 dimensions · 2 fact tables · IDENTITY surrogate keys
        │
        ▼
  POWER BI 4 dashboards · DAX measures · targets · cross-page slicers
```

### Row counts through the pipeline

| Layer | Tables | Rows |
|---|---|---|
| Bronze | 20 | 46,851 |
| Silver | 20 | 46,742 |
| Gold | 11 | 28,310 |

The Bronze → Silver drop of 109 rows is entirely deliberate: 12 duplicate customers (matched
on normalised email), 12 deliveries where delivery date preceded ship date, 8 promotions with
an end date before the start date or a missing discount, 30 online order items and 50
transaction items missing a quantity. Every removal is logged in `silver.etl_log` with its
rule name and row count.

## Data model

![Galaxy schema](docs/data_model.jpg)

Two business processes share four conformed dimensions, which is what makes this a galaxy
schema rather than two unrelated stars — the same `DIM_PRODUCT` row means the same thing
whether you reach it from a till receipt or a web order, so cross-channel comparison is valid.

| | Grain | Dimensions |
|---|---|---|
| `FACT_STORE_SALES` | one row per transaction line | Date, Store, Product, Customer, Employee, Promotion |
| `FACT_ONLINE_SALES` | one row per order line | Date, Customer, Product, Warehouse, Promotion, Order Status, Payment Method |

**Conformed:** Date · Customer · Product · Promotion

Both facts are held at transaction-line grain with no pre-aggregation, so any rollup the
business asks for later is still available.

## Silver layer transformations

| Table | Rule applied |
|---|---|
| CUSTOMERS | Deduplicated on `LOWER(TRIM(Email))` via `ROW_NUMBER()`; derived `Full_Name` |
| EMPLOYEES, CUSTOMERS | Gender codes harmonised (`M`/`Male` → `Male`) |
| PROMOTIONS | Rows removed where `End_Date < Start_Date` or discount missing |
| DELIVERIES | Rows removed where `Delivery_Date < Ship_Date` |
| INVENTORY | Missing `Stock_Level` imputed with the dataset mean |
| TRANSACTION_ITEMS, ONLINE_ORDER_ITEMS | Missing `Unit_Price` imputed with channel mean; `Total_Line_Amount` derived |
| ONLINE_ORDERS | Missing `Order_Total` recalculated by summing its order items |
| PAYMENTS | Missing payment amounts resolved against the parent order |

All casting uses `TRY_CAST`, so malformed source values become NULL instead of aborting the
load. Deriving `Total_Line_Amount` in Silver rather than in DAX means Power BI reads a stored
column instead of recomputing a product across every row at query time.

## Dashboards

Four pages, each aimed at a specific persona rather than a generic overview.

### Executive Omnichannel Overview
![Executive overview](Dashboard/01_executive_overview.png)
Channel split, combined revenue and quantity against target, YoY growth, monthly trend by
channel, revenue by city.

### Store Operations Performance
![Store operations](Dashboard/02_store_operations.png)
Revenue against target, average unit price, departmental revenue, transactions by weekday,
per-store ranking, and an employee leaderboard using `RANKX` over all employees.

### Product & Promotion Insights
![Product and promotion](Dashboard/03_product_promotion.png)
Best-selling product, brand, category and promotion as dynamic `TOPN` measures; discount depth
versus revenue by promotion type; a store-versus-online revenue matrix by department.

### Online Sales & Fulfillment
![Online fulfillment](Dashboard/04_online_fulfillment.png)
AOV and cancellation rate against thresholds, the fulfillment pipeline from delivered to
returned, warehouse volume versus cancellation rate, payment mix by loyalty tier.

**Targets** are modelled rather than guessed: store revenue at last year × 1.10, online at
× 1.15 (digital expected to outgrow physical), quantity at × 1.05 so revenue growth can be
checked against real volume rather than price rises, and cancellation rate capped at 5% as an
operational tolerance.

## Known issues and what I'd change

The SQL here is the code as submitted, unmodified. Reviewing it afterwards surfaced a number
of things I would fix before this ran anywhere real. Listing them is more useful than quietly
patching them, and each is reproducible from the audit output in the project report.

### Correctness

**Payment amounts are overwritten rather than repaired.** Silver resolves payments with
`ISNULL(o.Order_Total, p.Payment_Amount)`. Because `ISNULL` returns its first argument
whenever that argument is not null, the order total wins on every row where it exists — so
genuine payment amounts are replaced wholesale, and partial payments, overpayments and
refunds all collapse to the order total. The intent was to fall back to the order total only
when the payment amount is missing, which is the arguments the other way round.

**37 sales lines are lost between Silver and Gold.** The `FACT_STORE_SALES` load inner-joins
to the customer, employee and date dimensions, so any line whose parent transaction has an
unmatched key is dropped. The audit shows 14,912 rows in `silver.TRANSACTION_ITEMS` against
14,875 in the fact table. There is no error and no log entry; store revenue is simply
understated. The Kimball fix is unknown-member rows (key 0) in each dimension plus left
joins, so the fact row count is conserved and orphans stay visible and countable.

**Surrogate keys climb on every reload.** `gold.load_gold` clears tables with `DELETE`, which
does not reset `IDENTITY`. Reloading identical data repeatedly leaves `DIM_CUSTOMER` keys
starting in the tens of thousands, so the same source row gets a different key on each run.
`DBCC CHECKIDENT ... RESEED` after the deletes solves it (`TRUNCATE` is blocked by the
foreign keys).

**The date dimension is built from observed dates.** `DIM_DATE` comes from `SELECT DISTINCT`
over the fact sources and happens to produce a complete 731-day calendar only because this
dataset contains a transaction on every day of 2024–2025. A single quiet day would leave a
gap, and `SAMEPERIODLASTYEAR` returns wrong results against a gapped date table without
raising anything. A date dimension should be generated as a contiguous calendar, independent
of whether business occurred.

**Bronze ingestion is fragile.** `BULK INSERT` runs without `FORMAT = 'CSV'` or `FIELDQUOTE`,
so a comma inside a quoted field shifts every following column; and `ROWTERMINATOR = '\n'`
leaves a trailing carriage return on the last column of each row under Windows CRLF, which
then fails `TRY_CAST` in Silver and becomes NULL.

**No load reconciliation.** Nothing compares Silver and Gold row counts after the fact load,
which is why the 37 missing rows went unnoticed. A load that reports success while dropping
rows is the failure mode worth guarding against first.

### Analytical

**Revenue figures include imputed prices.** 300 transaction items and 120 online order items
have no unit price in the source. Silver fills them with the channel mean and derives
`Total_Line_Amount` from it, so part of reported revenue is estimated rather than observed.
Mean imputation preserves the row count but invents money and compresses variance; carrying
an `is_imputed` flag through to the facts would let consumers exclude or quantify it.

**A Silver cleaning rule breaks Gold referential integrity.** Removing the 8 invalid
promotions leaves transaction lines referencing promotions that no longer exist, producing
1,664 null promotion keys in `FACT_STORE_SALES` and 710 in `FACT_ONLINE_SALES`. Every
promotion analysis silently excludes those lines.

**The same measure reports different values across dashboard pages.** The Executive page has
2025 selected in its date slicer and shows combined revenue of 2.05M; the Product & Promotion
matrix has no date filter and totals 4.07M. Both are correct for their filter context, but
neither page says so, and someone comparing two tabs sees revenue nearly double. Filter state
needs to be visible on every page, or driven by a shared slicer.

**One target measure is not what the dictionary says.** The Store Operations gauge shows a
target of 2.93M, exactly the unfiltered all-time store revenue rather than last year × 1.10.

**No slowly-changing dimensions.** All dimensions are Type 1 overwrites, so a customer moving
city or an employee changing position rewrites history, and trends are reported against
current attributes rather than those in force at the time of sale.

## What I'd build next

Beyond the fixes above:

- Incremental loading keyed on a watermark, instead of a full truncate-and-insert of all 20 tables on every run.
- Type 2 SCD on `DIM_CUSTOMER` and `DIM_EMPLOYEE` so attribute history survives.
- Non-clustered indexes on the fact foreign keys; the fact tables are currently heaps with none.
- A `FACT_DELIVERY` table — delivery and provider data is cleaned in Silver but never reaches Gold, so fulfillment timing can't be analysed.

## Repository structure

```
.
├── sql/
│   ├── bronze/   01_bronze_ddl.sql · 02_bronze_load.sql
│   ├── silver/   01_silver_ddl.sql · 02_silver_load.sql
│   └── gold/     01_gold_ddl.sql   · 02_gold_load.sql
├── dashboard/    four page screenshots
├── docs/         data_model.jpg
└── README.md
```

Run order: bronze DDL → bronze load → silver DDL → silver load → gold DDL → gold load. Each
load script ends by executing its own procedure.

Source CSVs are not included. The `BULK INSERT` statements in the bronze load point at
`C:\SQLData\bi_full_dataset\` and need editing for a different location; the SQL Server
service account also needs read access to that directory.

---

**Pierre Ashraf** — B.Sc. Business Informatics, German International University
[LinkedIn](https://linkedin.com/in/pierreaziz21)
