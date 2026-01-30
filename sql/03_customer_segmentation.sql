/* =========================================================
   03 — Customer Segmentation Analysis
   Purpose: analyse customer behaviour by segment, location,
            and product category to identify demand patterns
   ========================================================= */

-- =========================================================
-- 1) Orders by customer segment
-- =========================================================

SELECT dc.segment,
       COUNT(fs.transaction_id) AS total_orders,
       SUM(fs.quantity) AS total_units
FROM fact_sales fs
         INNER JOIN dim_customer dc
                    ON fs.customer_id = dc.customer_id
WHERE dc.segment IS NOT NULL
GROUP BY dc.segment
ORDER BY total_orders DESC;


-- =========================================================
-- 2) Orders by city
-- =========================================================

SELECT dc.city,
       COUNT(fs.transaction_id) AS total_orders
FROM fact_sales fs
         INNER JOIN dim_customer dc
                    ON fs.customer_id = dc.customer_id
WHERE dc.city IS NOT NULL
GROUP BY dc.city
ORDER BY total_orders DESC;


-- =========================================================
-- 3) Orders by segment and product category
-- =========================================================

SELECT dc.segment,
       dp.category,
       COUNT(fs.transaction_id) AS total_orders,
       SUM(fs.quantity) AS total_units
FROM fact_sales fs
         INNER JOIN dim_customer dc
                    ON fs.customer_id = dc.customer_id
         INNER JOIN dim_product dp
                    ON fs.product_id = dp.product_id
WHERE dc.segment IS NOT NULL
GROUP BY dc.segment, dp.category
ORDER BY dc.segment, total_orders DESC;


-- =========================================================
-- 4) Top product category per segment
-- =========================================================

SELECT segment,
       category,
       total_orders
FROM (SELECT dc.segment,
             dp.category,
             COUNT(fs.transaction_id) AS total_orders,
             RANK() OVER (
                 PARTITION BY dc.segment
                 ORDER BY COUNT(fs.transaction_id) DESC
                 ) AS category_rank
      FROM fact_sales fs
               INNER JOIN dim_customer dc
                          ON fs.customer_id = dc.customer_id
               INNER JOIN dim_product dp
                          ON fs.product_id = dp.product_id
      WHERE dc.segment IS NOT NULL
      GROUP BY dc.segment, dp.category) ranked_categories
WHERE category_rank = 1
ORDER BY segment;
