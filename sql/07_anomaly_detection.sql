/* =========================================================
   07 — Anomaly Detection (Pricing Outliers)
   Purpose:
   Identify anomalous transactions where realised unit price
   is extremely higher than the product listing price.

   Output:
   - This file surfaces the transaction_id values to exclude
     in pricing analysis (see 06_pricing_analysis.sql).

   Approach:
   1) Inspect top unit prices to confirm potential outliers
   2) Flag "extreme" unit prices where unit_price > 5x listing price
   3) Keep only extremes that occur once for a product (likely data error)
   ========================================================= */


/* =========================================================
   Q1) What are the highest unit prices in the dataset?
       (Quick scan to validate outliers exist)
   ========================================================= */
SELECT fs.transaction_id,
       dc.segment,
       dp.product_name,
       fs.quantity,
       fs.sales_amount,
       fs.sales_amount / NULLIF(fs.quantity, 0) AS unit_price,
       dp.standard_price AS listing_price
FROM fact_sales AS fs
         INNER JOIN dim_product AS dp
                    ON fs.product_id = dp.product_id
         INNER JOIN dim_customer AS dc
                    ON fs.customer_id = dc.customer_id
WHERE fs.sales_amount IS NOT NULL
ORDER BY unit_price DESC
LIMIT 20;


/* =========================================================
   Q2) Which transactions have an extreme unit price vs listing price?
       Rule: unit_price > 5 * listing_price

       Then filter to likely anomalies by keeping products where
       the extreme case occurs only once.
   ========================================================= */
WITH priced_sales AS (SELECT fs.transaction_id,
                             fs.product_id,
                             dp.product_name,
                             fs.sales_amount / NULLIF(fs.quantity, 0) AS unit_price,
                             dp.standard_price AS listing_price,
                             COUNT(*) FILTER (
                                 WHERE (fs.sales_amount / NULLIF(fs.quantity, 0)) > dp.standard_price * 5
                                 ) OVER (PARTITION BY fs.product_id) AS extreme_txn_count_for_product
                      FROM fact_sales AS fs
                               INNER JOIN dim_product AS dp
                                          ON fs.product_id = dp.product_id
                      WHERE fs.sales_amount IS NOT NULL)
SELECT transaction_id,
       product_id,
       product_name,
       unit_price,
       listing_price,
       extreme_txn_count_for_product
FROM priced_sales
WHERE unit_price > listing_price * 5
  AND extreme_txn_count_for_product = 1
ORDER BY unit_price DESC;



/* =========================================================
   Result:
   The following transaction_ids were identified as extreme, one-off
   pricing outliers and are excluded in the "clean" version of
   06_pricing_analysis.sql:

   - 1187
   - 53
   - 475
   ========================================================= */

/* =========================================================
Q3) What is the impact of excluding the flagged anomalies?
    Show BEFORE vs AFTER:
    - overall unit price distribution (avg/max)
    - affected products only (avg/max)
========================================================= */

-- -----------------------------
-- Q3A) Overall impact (all products)
-- -----------------------------
WITH base AS (SELECT fs.transaction_id,
                     fs.product_id,
                     fs.sales_amount / NULLIF(fs.quantity, 0) AS unit_price
              FROM fact_sales AS fs
              WHERE fs.sales_amount IS NOT NULL),
     overall_before_after AS (SELECT 'BEFORE (all transactions)' AS scenario,
                                     ROUND(AVG(unit_price), 2) AS avg_unit_price,
                                     ROUND(MAX(unit_price), 2) AS max_unit_price
                              FROM base

                              UNION ALL

                              SELECT 'AFTER (exclude anomalies)' AS scenario,
                                     ROUND(AVG(unit_price), 2) AS avg_unit_price,
                                     ROUND(MAX(unit_price), 2) AS max_unit_price
                              FROM base
                              WHERE transaction_id NOT IN (1187, 53, 475))
SELECT *
FROM overall_before_after
ORDER BY scenario;


-- -----------------------------
-- Q3B) Product-level impact (only products affected by anomalies)
-- -----------------------------
WITH base AS (SELECT fs.transaction_id,
                     fs.product_id,
                     dp.product_name,
                     fs.sales_amount / NULLIF(fs.quantity, 0) AS unit_price
              FROM fact_sales AS fs
                       INNER JOIN dim_product AS dp
                                  ON fs.product_id = dp.product_id
              WHERE fs.sales_amount IS NOT NULL),
     affected_products AS (SELECT DISTINCT product_id
                           FROM base
                           WHERE transaction_id IN (1187, 53, 475)),
     before_after_by_product AS (SELECT b.product_id,
                                        b.product_name,
                                        'BEFORE' AS scenario,
                                        ROUND(AVG(b.unit_price), 2) AS avg_unit_price,
                                        ROUND(MAX(b.unit_price), 2) AS max_unit_price,
                                        COUNT(*) AS txn_count
                                 FROM base AS b
                                          INNER JOIN affected_products AS ap
                                                     ON b.product_id = ap.product_id
                                 GROUP BY 1, 2, 3

                                 UNION ALL

                                 SELECT b.product_id,
                                        b.product_name,
                                        'AFTER' AS scenario,
                                        ROUND(AVG(b.unit_price), 2) AS avg_unit_price,
                                        ROUND(MAX(b.unit_price), 2) AS max_unit_price,
                                        COUNT(*) AS txn_count
                                 FROM base AS b
                                          INNER JOIN affected_products AS ap
                                                     ON b.product_id = ap.product_id
                                 WHERE b.transaction_id NOT IN (1187, 53, 475)
                                 GROUP BY 1, 2, 3)
SELECT product_id,
       product_name,
       scenario,
       avg_unit_price,
       max_unit_price,
       txn_count
FROM before_after_by_product
ORDER BY product_name,
         scenario;




-- SQL queries written by Sean Worrall for EDA project
