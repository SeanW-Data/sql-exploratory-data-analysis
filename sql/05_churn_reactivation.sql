/* Do customers churn (1-month period), or re-appear over time?
- Active customers: bought this month
- Retained customers: bought this month and last month
- Churned customers: bought last month but not this month
- New customers: first-ever purchase is this month
- Reactivated customers: bought this month, didn’t buy last month, but had bought before (i.e., came back) */

WITH customer_months AS (SELECT DISTINCT fs.customer_id,
                                         DATE_TRUNC('month', dd.date)::date AS month
                         FROM fact_sales fs
                                  INNER JOIN dim_date dd
                                             ON fs.date_id = dd.date_id),
     first_month AS (SELECT customer_id, MIN(month) AS first_month
                     FROM customer_months
                     GROUP BY customer_id),
     labeled AS (SELECT cm.customer_id,
                        cm.month,
                        (cm.month - INTERVAL '1 month')::date AS prev_month,
                        EXISTS (SELECT 1
                                FROM customer_months cm2
                                WHERE cm2.customer_id = cm.customer_id
                                  AND cm2.month = (cm.month - INTERVAL '1 month')::date) AS was_active_prev_month,
                        fm.first_month
                 FROM customer_months cm
                          INNER JOIN first_month fm USING (customer_id)),
     monthly AS (SELECT month,
                        COUNT(*) FILTER (WHERE was_active_prev_month) AS retained_customers,
                        COUNT(*) FILTER (WHERE NOT was_active_prev_month
                            AND month = first_month) AS new_customers,
                        COUNT(*) FILTER (WHERE NOT was_active_prev_month
                            AND month > first_month) AS reactivated_customers,
                        COUNT(*) AS active_customers
                 FROM labeled
                 GROUP BY month),
     churned AS (SELECT (cm.month + INTERVAL '1 month')::date AS month,
                        COUNT(*) AS churned_customers
                 FROM customer_months cm
                          LEFT JOIN customer_months cm2
                                    ON cm2.customer_id = cm.customer_id
                                        AND cm2.month = (cm.month + INTERVAL '1 month')::date
                 WHERE cm2.customer_id IS NULL
                 GROUP BY 1)
SELECT mo.month,
       mo.active_customers,
       mo.retained_customers,
       COALESCE(ch.churned_customers, 0) AS churned_customers,
       mo.new_customers,
       mo.reactivated_customers
FROM monthly mo
         LEFT JOIN churned ch USING (month)
ORDER BY mo.month;
