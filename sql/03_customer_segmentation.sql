-- Analyse customer behaviour
-- Which cities and segments order the most

-- City
SELECT dc.city,
       COUNT(transaction_id) AS total_orders
FROM fact_sales AS fs
         INNER JOIN dim_customer AS dc
                    ON fs.customer_id = dc.customer_id
WHERE dc.city IS NOT NULL
GROUP BY dc.city
ORDER BY total_orders DESC;

-- Segment
SELECT dc.segment,
       COUNT(transaction_id) AS total_orders
FROM fact_sales AS fs
         INNER JOIN dim_customer AS dc
                    ON fs.customer_id = dc.customer_id
WHERE dc.segment IS NOT NULL
GROUP BY dc.segment
ORDER BY total_orders DESC;

-- Do any segments pay more than others? If so, for which products?
-- WITH POTENTIAL OUTLIERS
SELECT dc.segment,
       ROUND(AVG(fs.sales_amount / NULLIF(fs.quantity, 0) - dp.standard_price), 2) AS avg_diff_from_list
FROM fact_sales fs
         INNER JOIN dim_customer dc ON fs.customer_id = dc.customer_id
         INNER JOIN dim_product dp ON fs.product_id = dp.product_id
WHERE dc.segment IS NOT NULL
GROUP BY dc.segment;

-- Product difference
-- WITH POTENTIAL OUTLIERS
WITH priced_products AS (SELECT dc.segment,
                                dp.product_name,
                                AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) AS avg_unit_price,
                                dp.standard_price AS listing_price,
                                AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price AS diff_from_list,
                                (AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price)
                                    / dp.standard_price * 100 AS pct_diff_from_list,
                                RANK() OVER (
                                    PARTITION BY dc.segment
                                    ORDER BY AVG(fs.sales_amount / NULLIF(fs.quantity, 0)) - dp.standard_price DESC
                                    ) AS product_rank
                         FROM fact_sales fs
                                  INNER JOIN dim_customer dc ON fs.customer_id = dc.customer_id
                                  INNER JOIN dim_product dp ON fs.product_id = dp.product_id
                         WHERE dc.segment IS NOT NULL
                         GROUP BY dc.segment, dp.product_name, dp.standard_price)

SELECT segment,
       product_name,
       avg_unit_price,
       listing_price,
       diff_from_list,
       pct_diff_from_list
FROM priced_products
WHERE product_rank <= 3
ORDER BY segment, product_rank;


-- Do certain Customer segments buy certain product types?
SELECT *
FROM (SELECT dc.segment,
             dp.category,
             COUNT(transaction_id) AS total_orders,
             SUM(quantity) AS total_quantity,
             ROW_NUMBER() OVER (
                 PARTITION BY dc.segment
                 ORDER BY COUNT(transaction_id) DESC
                 ) AS category_rank
      FROM fact_sales AS fs
               INNER JOIN dim_customer AS dc
                          ON fs.customer_id = dc.customer_id
               INNER JOIN dim_product AS dp
                          ON fs.product_id = dp.product_id
      WHERE dc.segment IS NOT NULL
        AND dp.category IS NOT NULL
      GROUP BY dc.segment, dp.category
      ORDER BY dc.segment, category_rank) AS order_rank
WHERE category_rank = 1;
