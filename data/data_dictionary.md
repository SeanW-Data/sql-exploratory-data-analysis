# Data Dictionary – SQL EDA Tech Business Project

## Overview
This dataset represents transactional sales data for a fictional tech-based business across 2024–2025. 
The data is modelled using a star schema to support analytical queries on revenue, customer behaviour, seasonality, churn, and pricing.

---

## fact_sales
**Grain:** One row per sales transaction.

| Column | Description |
|------|------------|
| transaction_id | Unique identifier for each sales transaction |
| date_id | Foreign key linking to dim_date |
| customer_id | Foreign key linking to dim_customer |
| product_id | Foreign key linking to dim_product |
| quantity | Number of units or bundled items sold (may not always represent discrete units) |
| sales_amount | Total revenue for the transaction |

---

## dim_customer
**Grain:** One row per customer.

| Column | Description |
|------|------------|
| customer_id | Unique customer identifier |
| customer_name | Customer name |
| city | Customer city (nullable) |
| segment | Customer segment (Consumer, SMB, Enterprise) (nullable) |

---

## dim_product
**Grain:** One row per product.

| Column | Description |
|------|------------|
| product_id | Unique product identifier |
| product_name | Product name |
| category | Product category (e.g. SaaS Subscription, Hardware) |
| standard_price | List price for a single unit of the product |

---

## dim_date
**Grain:** One row per calendar date.

| Column | Description |
|------|------------|
| date_id | Surrogate key for date |
| date | Calendar date |
| day | Day of month |
| month | Month number |
| quarter | Quarter number |
| year | Calendar year |

---

## Notes & Assumptions
- `sales_amount` represents total transaction value, not unit price.
- `quantity` may represent bundled or contract-level quantities rather than discrete units.
- A small number of pricing outliers are intentionally included to support anomaly analysis.
- Records with missing `city` or `segment` values are excluded from segmentation and geographic analyses but retained for overall performance metrics.
