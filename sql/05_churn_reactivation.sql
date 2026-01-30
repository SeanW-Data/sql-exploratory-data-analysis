/* =========================================================
   05 — Churn & Reactivation Analysis
   Purpose: analyse customer retention, churn, and reactivation
            trends over time using monthly cohorts
   ========================================================= */

-- =========================================================
-- 1) Identify customer activity by month
-- =========================================================

WITH customer_month_activity AS (SELECT DISTINCT fs.customer_id,
                                                 DATE_TRUNC('month', dd.date)::date AS activity_month
                                 FROM fact_sales fs
                                          INNER JOIN dim_date dd
                                                     ON fs.date_id = dd.date_id),

-- =========================================================
-- 2) Add previous activity for churn logic
-- =========================================================

     customer_activity_with_lag AS (SELECT customer_id,
                                           activity_month,
                                           LAG(activity_month) OVER (
                                               PARTITION BY customer_id
                                               ORDER BY activity_month
                                               ) AS previous_activity_month
                                    FROM customer_month_activity),

-- =========================================================
-- 3) Classify customer status per month
-- =========================================================

     customer_status AS (SELECT activity_month,
                                customer_id,
                                CASE
                                    WHEN previous_activity_month IS NULL
                                        THEN 'new'
                                    WHEN previous_activity_month = activity_month - INTERVAL '1 month'
                                        THEN 'retained'
                                    ELSE 'reactivated'
                                    END AS customer_status
                         FROM customer_activity_with_lag)

-- =========================================================
-- 4) Monthly churn & retention summary
-- =========================================================

SELECT activity_month,
       COUNT(DISTINCT customer_id) AS active_customers,
       COUNT(DISTINCT customer_id) FILTER (WHERE customer_status = 'new') AS new_customers,
       COUNT(DISTINCT customer_id) FILTER (WHERE customer_status = 'retained') AS retained_customers,
       COUNT(DISTINCT customer_id) FILTER (WHERE customer_status = 'reactivated') AS reactivated_customers,
       (
           COUNT(DISTINCT customer_id)
               - COUNT(DISTINCT customer_id) FILTER (WHERE customer_status = 'retained')
           ) AS churned_customers
FROM customer_status
GROUP BY activity_month
ORDER BY activity_month;
