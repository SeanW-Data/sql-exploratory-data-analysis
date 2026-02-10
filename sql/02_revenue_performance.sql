/* =========================================================
   02 — Revenue Performance Analysis
   Purpose: analyse overall revenue trends, key revenue
            drivers, and performance across products,
            customer segments, and time.
   ========================================================= */

-- =========================================================
-- 1) Overall revenue performance
-- =========================================================

SELECT SUM(sales_amount) AS total_revenue,
       COUNT(transaction_id) AS total_orders,
       SUM(quantity) AS total_units_sold
FROM fact_sales
WHERE sales_amount IS NOT NULL;


-- =========================================================
-- 2) Revenue by product
-- =========================================================

SELECT dp.product_name,
       SUM(fs.sales_amount) AS total_revenue,
       COUNT(fs.transaction_id) AS total_orders,
       SUM(fs.quantity) AS total_units_sold
FROM fact_sales fs
         INNER JOIN dim_product dp
                    ON fs.product_id = dp.product_id
WHERE fs.sales_amount IS NOT NULL
GROUP BY dp.product_name
ORDER BY total_revenue DESC;


-- =========================================================
-- 3) Revenue by customer segment
-- =========================================================

SELECT dc.segment,
       SUM(fs.sales_amount) AS total_revenue,
       COUNT(fs.transaction_id) AS total_orders
FROM fact_sales fs
         INNER JOIN dim_customer dc
                    ON fs.customer_id = dc.customer_id
WHERE fs.sales_amount IS NOT NULL
  AND dc.segment IS NOT NULL
GROUP BY dc.segment
ORDER BY total_revenue DESC;


-- =========================================================
-- 4) Revenue by year
-- =========================================================

SELECT dd.year,
       SUM(fs.sales_amount) AS total_revenue,
       COUNT(fs.transaction_id) AS total_orders
FROM fact_sales fs
         INNER JOIN dim_date dd
                    ON fs.date_id = dd.date_id
WHERE fs.sales_amount IS NOT NULL
GROUP BY dd.year
ORDER BY dd.year;


-- =========================================================
-- 5) Monthly revenue trend
-- =========================================================

SELECT dd.year,
       dd.month,
       SUM(fs.sales_amount) AS total_revenue,
       COUNT(fs.transaction_id) AS total_orders
FROM fact_sales fs
         INNER JOIN dim_date dd
                    ON fs.date_id = dd.date_id
WHERE fs.sales_amount IS NOT NULL
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month;


-- =========================================================
-- 6) Quarterly revenue trend
-- =========================================================

SELECT dd.year,
       dd.quarter,
       SUM(fs.sales_amount) AS total_revenue,
       COUNT(fs.transaction_id) AS total_orders
FROM fact_sales fs
         INNER JOIN dim_date dd
                    ON fs.date_id = dd.date_id
WHERE fs.sales_amount IS NOT NULL
GROUP BY dd.year, dd.quarter
ORDER BY dd.year, dd.quarter;



-- SQL queries written by Sean Worrall for EDA project
