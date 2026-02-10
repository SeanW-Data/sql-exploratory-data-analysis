/* =========================================================
   04 — Seasonality Analysis
   Purpose: identify time-based demand patterns and determine
            whether certain products exhibit seasonal behaviour
   ========================================================= */

-- =========================================================
-- 1) Overall seasonality by year
-- =========================================================

SELECT dd.year,
       COUNT(fs.transaction_id) AS total_orders,
       SUM(fs.quantity) AS total_units
FROM fact_sales fs
         INNER JOIN dim_date dd
                    ON fs.date_id = dd.date_id
GROUP BY dd.year
ORDER BY dd.year;


-- =========================================================
-- 2) Monthly seasonality (overall)
-- =========================================================

SELECT dd.year,
       dd.month,
       COUNT(fs.transaction_id) AS total_orders,
       SUM(fs.quantity) AS total_units
FROM fact_sales fs
         INNER JOIN dim_date dd
                    ON fs.date_id = dd.date_id
GROUP BY dd.year, dd.month
ORDER BY total_orders DESC;


-- =========================================================
-- 3) Quarterly seasonality (overall)
-- =========================================================

SELECT dd.year,
       dd.quarter,
       COUNT(fs.transaction_id) AS total_orders,
       SUM(fs.quantity) AS total_units
FROM fact_sales fs
         INNER JOIN dim_date dd
                    ON fs.date_id = dd.date_id
GROUP BY dd.year, dd.quarter
ORDER BY total_orders DESC;


-- =========================================================
-- 4) Product-level seasonality
--    (peak quarter vs average quarter)
-- =========================================================

WITH product_quarterly AS (SELECT dp.product_name,
                                  dd.year,
                                  dd.quarter,
                                  COUNT(fs.transaction_id) AS total_orders
                           FROM fact_sales fs
                                    INNER JOIN dim_product dp
                                               ON fs.product_id = dp.product_id
                                    INNER JOIN dim_date dd
                                               ON fs.date_id = dd.date_id
                           GROUP BY dp.product_name, dd.year, dd.quarter),
     product_seasonality AS (SELECT product_name,
                                    year,
                                    quarter,
                                    total_orders,
                                    AVG(total_orders) OVER (
                                        PARTITION BY product_name
                                        ) AS avg_quarterly_orders
                             FROM product_quarterly)
SELECT product_name,
       year,
       quarter,
       total_orders,
       ROUND(total_orders / NULLIF(avg_quarterly_orders, 0), 2) AS seasonality_index
FROM product_seasonality
ORDER BY seasonality_index DESC;




-- SQL queries written by Sean Worrall for EDA project
