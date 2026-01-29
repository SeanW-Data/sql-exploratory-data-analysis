-- Understanding each tables schema and previewing data for each table
-- to ensure data types are correct and values are what we expect to see

SELECT column_name,
       data_type,
       is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'fact_sales'
ORDER BY ordinal_position;

SELECT *
FROM fact_sales
LIMIT 10;

SELECT column_name,
       data_type,
       is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'dim_customer'
ORDER BY ordinal_position;

SELECT *
FROM dim_customer
LIMIT 10;

SELECT column_name,
       data_type,
       is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'dim_product'
ORDER BY ordinal_position;

SELECT *
FROM dim_product
LIMIT 10;

SELECT column_name,
       data_type,
       is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'dim_date'
ORDER BY ordinal_position;

SELECT *
FROM dim_date
LIMIT 10;


-- Identify missing & duplicate values in each table
--Missing
SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE sales_amount IS NULL) AS missing_sales,
       COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
       COUNT(*) FILTER (WHERE transaction_id IS NULL) AS missing_orders
FROM fact_sales;

SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE standard_price IS NULL) AS missing_price,
       COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
       COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_products
FROM dim_product;

SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE date IS NULL) AS missing_dates,
       COUNT(*) FILTER (WHERE date_id IS NULL) AS missing_date_ids
FROM dim_date;

SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE customer_name IS NULL) AS missing_name,
       COUNT(*) FILTER (WHERE city IS NULL) AS missing_city,
       COUNT(*) FILTER (WHERE segment IS NULL) AS missing_segment,
       COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customers
FROM dim_customer;

-- Duplicates
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

-- Orphaned foreign keys check to check data model integrity
SELECT COUNT(*) AS orphan_customer_rows
FROM fact_sales fs
         LEFT JOIN dim_customer dc ON fs.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;

SELECT COUNT(*) AS orphan_customer_rows
FROM fact_sales fs
         LEFT JOIN dim_customer dc ON fs.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;

SELECT COUNT(*) AS orphan_date_rows
FROM fact_sales fs
         LEFT JOIN dim_date dd ON fs.date_id = dd.date_id
WHERE dd.date_id IS NULL;





