-- Understand Revenue Performance (Top sales, most valuable customer segment, revenue growth over time)

-- Top Sales
SELECT dp.product_name,
       dp.category,
       SUM(sales_amount) AS total_revenue
FROM fact_sales AS fs
         INNER JOIN dim_product AS dp
                    ON fs.product_id = dp.product_id
WHERE fs.transaction_id NOT IN (1187, 53, 475)
GROUP BY dp.product_name, dp.category
ORDER BY total_revenue DESC
LIMIT 10;

-- Most valuable Consumer segments
SELECT dc.segment,
       SUM(sales_amount) AS total_revenue
FROM fact_sales AS fs
         INNER JOIN dim_customer AS dc
                    ON fs.customer_id = dc.customer_id
WHERE fs.transaction_id NOT IN (1187, 53, 475)
  AND dc.segment IS NOT NULL
GROUP BY dc.segment
ORDER BY total_revenue DESC;

-- Are revenues growing over time (Year, Month, Quarter)
-- Year
SELECT dd.year,
       SUM(sales_amount) AS total_revenue
FROM fact_sales AS fs
         INNER JOIN dim_date AS dd
                    ON fs.date_id = dd.date_id
GROUP BY dd.year
ORDER BY dd.year;

-- Month
SELECT dd.year,
       dd.month,
       SUM(sales_amount) AS total_revenue
FROM fact_sales AS fs
         INNER JOIN dim_date AS dd
                    ON fs.date_id = dd.date_id
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month;

-- Quarter
SELECT dd.year,
       dd.quarter,
       SUM(sales_amount) AS total_revenue
FROM fact_sales AS fs
         INNER JOIN dim_date AS dd
                    ON fs.date_id = dd.date_id
GROUP BY dd.year, dd.quarter
ORDER BY dd.year, dd.quarter;
