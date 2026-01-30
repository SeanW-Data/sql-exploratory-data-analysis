/* =========================================================
   01 — Data Validation (PostgreSQL)
   Purpose: validate schema, completeness, uniqueness, and
            referential integrity for the star schema tables
   ========================================================= */

-- =========================================================
-- 1) Schema review (columns + types + nullability)
-- =========================================================

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'fact_sales'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'dim_customer'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'dim_product'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'dim_date'
ORDER BY ordinal_position;


-- =========================================================
-- 2) Quick data preview (sanity check)
-- =========================================================

SELECT *
FROM fact_sales
LIMIT 10;
SELECT *
FROM dim_customer
LIMIT 10;
SELECT *
FROM dim_product
LIMIT 10;
SELECT *
FROM dim_date
LIMIT 10;


-- =========================================================
-- 3) Missing values profiling
-- =========================================================

SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE sales_amount IS NULL) AS missing_sales_amount,
       COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
       COUNT(*) FILTER (WHERE transaction_id IS NULL) AS missing_transaction_ids
FROM fact_sales;

SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE standard_price IS NULL) AS missing_standard_price,
       COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
       COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_ids
FROM dim_product;

SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE date IS NULL) AS missing_date,
       COUNT(*) FILTER (WHERE date_id IS NULL) AS missing_date_ids
FROM dim_date;

SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE customer_name IS NULL) AS missing_customer_name,
       COUNT(*) FILTER (WHERE city IS NULL) AS missing_city,
       COUNT(*) FILTER (WHERE segment IS NULL) AS missing_segment,
       COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_ids
FROM dim_customer;


-- =========================================================
-- 4) Duplicate checks (primary keys)
-- =========================================================

SELECT COUNT(*) AS all_records,
       COUNT(DISTINCT transaction_id) AS distinct_transaction_ids,
       COUNT(*) - COUNT(DISTINCT transaction_id) AS duplicate_transaction_ids
FROM fact_sales;

SELECT COUNT(*) AS all_records,
       COUNT(DISTINCT product_id) AS distinct_product_ids,
       COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_product_ids
FROM dim_product;

SELECT COUNT(*) AS all_records,
       COUNT(DISTINCT date_id) AS distinct_date_ids,
       COUNT(*) - COUNT(DISTINCT date_id) AS duplicate_date_ids
FROM dim_date;

SELECT COUNT(*) AS all_records,
       COUNT(DISTINCT customer_id) AS distinct_customer_ids,
       COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_customer_ids
FROM dim_customer;


-- =========================================================
-- 5) Referential integrity (orphan foreign keys)
-- =========================================================

SELECT COUNT(*) AS orphan_customer_rows
FROM fact_sales fs
         LEFT JOIN dim_customer dc ON fs.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;

SELECT COUNT(*) AS orphan_product_rows
FROM fact_sales fs
         LEFT JOIN dim_product dp ON fs.product_id = dp.product_id
WHERE dp.product_id IS NULL;

SELECT COUNT(*) AS orphan_date_rows
FROM fact_sales fs
         LEFT JOIN dim_date dd ON fs.date_id = dd.date_id
WHERE dd.date_id IS NULL;
