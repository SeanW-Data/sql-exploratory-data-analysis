-- Do any segments pay more than others? If so, for which products?
SELECT dc.segment,
       ROUND(AVG(fs.sales_amount / NULLIF(fs.quantity, 0) - dp.standard_price), 2) AS avg_diff_from_list
FROM fact_sales fs
         INNER JOIN dim_customer dc ON fs.customer_id = dc.customer_id
         INNER JOIN dim_product dp ON fs.product_id = dp.product_id
WHERE dc.segment IS NOT NULL
  AND fs.transaction_id NOT IN (1187, 53, 475)
GROUP BY dc.segment;

-- Product difference
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
                           AND fs.transaction_id NOT IN (1187, 53, 475)
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