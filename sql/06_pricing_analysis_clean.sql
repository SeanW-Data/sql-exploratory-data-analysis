/* =========================================================
   06 — Pricing Analysis
   Purpose:
   Compare realised unit prices against product listing prices
   to understand pricing behaviour by customer segment and product.

   Note on anomalies:
   - This file presents results BOTH including and excluding
     anomalous transactions.
   - Anomalous transaction_ids were identified separately in:
     07_anomaly_detection.sql
   ========================================================= */


/* =========================================================
   SECTION A — Pricing analysis INCLUDING anomalous transactions
   (Raw view of the data)
   ========================================================= */

-- Q1 A) Do different customer segments pay more or less than
--      the listing price on average (including anomalies)?
SELECT dc.segment,
       ROUND(
               AVG((fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price),
               2
       ) AS avg_diff_from_list
FROM fact_sales AS fs
         INNER JOIN dim_customer AS dc
                    ON fs.customer_id = dc.customer_id
         INNER JOIN dim_product AS dp
                    ON fs.product_id = dp.product_id
WHERE dc.segment IS NOT NULL
GROUP BY dc.segment
ORDER BY avg_diff_from_list DESC;


-- Q2 A) Which products deviate most from the listing price
--      within each customer segment (including anomalies)?
WITH priced_products_raw AS (SELECT dc.segment,
                                    dp.product_name,
                                    AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) AS avg_unit_price,
                                    dp.standard_price AS listing_price,
                                    AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price AS diff_from_list,
                                    (
                                        (AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price)
                                            / NULLIF(dp.standard_price, 0)
                                        ) * 100 AS pct_diff_from_list,
                                    RANK() OVER (
                                        PARTITION BY dc.segment
                                        ORDER BY (AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price) DESC
                                        ) AS product_rank
                             FROM fact_sales AS fs
                                      INNER JOIN dim_customer AS dc
                                                 ON fs.customer_id = dc.customer_id
                                      INNER JOIN dim_product AS dp
                                                 ON fs.product_id = dp.product_id
                             WHERE dc.segment IS NOT NULL
                             GROUP BY dc.segment,
                                      dp.product_name,
                                      dp.standard_price)
SELECT segment,
       product_name,
       avg_unit_price,
       listing_price,
       diff_from_list,
       pct_diff_from_list
FROM priced_products_raw
WHERE product_rank <= 3
ORDER BY segment,
         product_rank;



/* =========================================================
   SECTION B — Pricing analysis EXCLUDING anomalous transactions
   (Cleaned view)
   Anomalies identified in: 07_anomaly_detection.sql
   ========================================================= */

-- Q1 B) Do different customer segments pay more or less than
--      the listing price on average (excluding anomalies)?
SELECT dc.segment,
       ROUND(
               AVG((fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price),
               2
       ) AS avg_diff_from_list
FROM fact_sales AS fs
         INNER JOIN dim_customer AS dc
                    ON fs.customer_id = dc.customer_id
         INNER JOIN dim_product AS dp
                    ON fs.product_id = dp.product_id
WHERE dc.segment IS NOT NULL
  AND fs.transaction_id NOT IN (1187, 53, 475)
GROUP BY dc.segment
ORDER BY avg_diff_from_list DESC;


-- Q2 B) Which products deviate most from the listing price
--      within each customer segment (excluding anomalies)?
WITH priced_products_clean AS (SELECT dc.segment,
                                      dp.product_name,
                                      AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) AS avg_unit_price,
                                      dp.standard_price AS listing_price,
                                      AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price AS diff_from_list,
                                      (
                                          (AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price)
                                              / NULLIF(dp.standard_price, 0)
                                          ) * 100 AS pct_diff_from_list,
                                      RANK() OVER (
                                          PARTITION BY dc.segment
                                          ORDER BY (AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price) DESC
                                          ) AS product_rank
                               FROM fact_sales AS fs
                                        INNER JOIN dim_customer AS dc
                                                   ON fs.customer_id = dc.customer_id
                                        INNER JOIN dim_product AS dp
                                                   ON fs.product_id = dp.product_id
                               WHERE dc.segment IS NOT NULL
                                 AND fs.transaction_id NOT IN (1187, 53, 475)
                               GROUP BY dc.segment,
                                        dp.product_name,
                                        dp.standard_price)
SELECT segment,
       product_name,
       avg_unit_price,
       listing_price,
       diff_from_list,
       pct_diff_from_list
FROM priced_products_clean
WHERE product_rank <= 3
ORDER BY segment,
         product_rank;





-- SQL queries written by Sean Worrall for EDA project
