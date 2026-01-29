-- Seasonality

-- Which periods spike in sales?
SELECT *
FROM (SELECT dd.year,
             dd.month,
             dd.quarter,
             COUNT(transaction_id) AS total_orders,
             ROW_NUMBER() OVER (PARTITION BY dd.year ORDER BY COUNT(transaction_id) DESC) AS order_row
      FROM fact_sales AS fs
               INNER JOIN dim_date AS dd
                          ON dd.date_id = fs.date_id
      GROUP BY dd.year, dd.month, dd.quarter
      ORDER BY dd.year, total_orders DESC) AS orders_date
WHERE order_row IN (1, 2, 3, 4, 5);

-- Are some products more seasonal?
WITH product_qtr AS (SELECT dp.product_name,
                            dd.year,
                            dd.quarter,
                            SUM(fs.quantity) AS units_sold
                     FROM fact_sales fs
                              INNER JOIN dim_date dd
                                         ON fs.date_id = dd.date_id
                              INNER JOIN dim_product dp
                                         ON fs.product_id = dp.product_id
                     GROUP BY dp.product_name, dd.year, dd.quarter),
     qtr_ranked AS (SELECT *,
                           RANK() OVER (
                               PARTITION BY product_name
                               ORDER BY units_sold DESC
                               ) AS qtr_rank,
                           AVG(units_sold) OVER (
                               PARTITION BY product_name
                               ) AS avg_qtr_units
                    FROM product_qtr)
SELECT product_name,
       year,
       quarter,
       units_sold AS peak_qtr_units,
       ROUND(avg_qtr_units, 2) AS avg_qtr_units,
       ROUND(
               units_sold / NULLIF(avg_qtr_units, 0),
               2
       ) AS seasonality_score
FROM qtr_ranked
WHERE qtr_rank = 1
ORDER BY seasonality_score DESC;
