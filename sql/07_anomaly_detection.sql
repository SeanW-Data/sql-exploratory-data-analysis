-- Identify operational anomalies
-- Do outliers represent:
-- Bulk deals?

SELECT fs.transaction_id,
       dc.segment,
       dp.product_name,
       fs.quantity,
       fs.sales_amount,
       fs.sales_amount / NULLIF(fs.quantity, 0) AS unit_price,
       dp.standard_price
FROM fact_sales fs
         INNER JOIN dim_product dp ON fs.product_id = dp.product_id
         INNER JOIN dim_customer dc ON fs.customer_id = dc.customer_id
WHERE fs.sales_amount IS NOT NULL
ORDER BY unit_price DESC
LIMIT 20;

-- From the results we can see there could be outliers
-- Next I will remove exceptionally high values that appear once
WITH priced_sales AS (SELECT fs.transaction_id,
                             fs.product_id,
                             dp.product_name,
                             fs.sales_amount / NULLIF(fs.quantity, 0) AS unit_price,
                             dp.standard_price,
                             COUNT(*) OVER (PARTITION BY fs.product_id) AS product_txn_count
                      FROM fact_sales fs
                               JOIN dim_product dp
                                    ON fs.product_id = dp.product_id
                      WHERE fs.sales_amount IS NOT NULL)
SELECT *
FROM priced_sales
WHERE unit_price > standard_price * 5
  AND product_txn_count = 1;

-- Now to count extreme one of transaction occurrences and not products
WITH priced_sales AS (SELECT fs.transaction_id,
                             fs.product_id,
                             dp.product_name,
                             fs.sales_amount / NULLIF(fs.quantity, 0) AS unit_price,
                             dp.standard_price,
                             COUNT(*) FILTER (
                                 WHERE fs.sales_amount / NULLIF(fs.quantity, 0) > dp.standard_price * 5
                                 ) OVER (PARTITION BY fs.product_id) AS extreme_txn_count
                      FROM fact_sales fs
                               JOIN dim_product dp
                                    ON fs.product_id = dp.product_id
                      WHERE fs.sales_amount IS NOT NULL)
SELECT *
FROM priced_sales
WHERE unit_price > standard_price * 5
  AND extreme_txn_count = 1;
-- transaction_id 1187, 53 & 475 contain one of extreme price changes