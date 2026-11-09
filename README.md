# 🛒 E-Commerce Customer & Revenue Analytics (SQL)

## 📌 Project Overview
An end-to-end SQL analytics project based on the **Olist Brazilian E-Commerce Dataset** (~100k orders). 
The goal of this project is to analyze monthly revenue growth, identify top product categories, and perform customer segmentation (RFM analysis) using SQL window functions.

---

## 📊 Key Business Questions & SQL Insights

### 1. Monthly Revenue & Order Volume Growth
Tracks order counts and delivered revenue month-over-month to evaluate business growth.

```sql
SELECT 
    strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month ASC;
```

---

### 2. Top-Performing Product Categories by Revenue
Identifies the highest-grossing product categories to highlight key revenue drivers and inventory priorities.

```sql
SELECT
	pr.product_category_name,
	COUNT(*) AS items_sold,
	COUNT(DISTINCT oi.order_id) AS num_orders,
	ROUND(SUM(oi.price), 2) AS category_revenue
FROM order_items oi
JOIN products pr ON oi.product_id = pr.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE pr.product_category_name IS NOT NULL
GROUP BY pr.product_category_name
ORDER BY category_revenue DESC
LIMIT 5;
```

---

### 3. Customer RFM Segmentation

Segments customers by **Recency, Frequency and Monetary value (RFM)** to show which customers drive revenue and which are at risk of churning. Uses CTEs and the window function `NTILE`.

**Method**
- **Recency:** days between a customer's last delivered order and the latest order in the dataset (the dataset ends in 2018, so "today" would label every customer as inactive). Scored 1–4 with `NTILE(4)`, where 4 = most recent.
- **Frequency:** number of delivered orders. Because ~97 % of customers ordered only once, quartiles are not meaningful here, so fixed tiers are used (1 order = 1, 2 orders = 2, 3+ orders = 3).
- **Monetary:** total payment value per customer. Scored 1–4 with `NTILE(4)`, where 4 = highest spend.
- Segments are derived from the scores: *Repeat customers*, *Top customers*, *Recent, low spend*, *At risk, high spend*, *Inactive*.

```sql
-- Core of the scoring step (full query: queries/03_rfm_segmentation.sql)
NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
CASE WHEN order_count >= 3 THEN 3
     WHEN order_count = 2  THEN 2
     ELSE 1 END                            AS f_score,
NTILE(4) OVER (ORDER BY total_spent ASC)   AS m_score
```
---

### 📊 Key Results
Scope: **delivered orders only** (96,477 orders, Oct 2016 – Aug 2018). All amounts in Brazilian reais (BRL). Full result tables are stored as CSV files in [`outputs/`](./outputs/).

#### 1. Monthly revenue & order volume

| Month | Orders | Revenue (BRL) |
| :--- | ---: | ---: |
| Jan 2017 | 750 | 127,546 |
| Nov 2017 (peak) | 7,289 | 1,153,528 |
| Jan 2018 | 7,069 | 1,078,607 |
| Aug 2018 | 6,351 | 985,414 |

- Monthly revenue grew roughly **8.5x** between January 2017 and January 2018, then levelled off at about BRL 1.0–1.15 M per month during 2018.
- November 2017 is the strongest month in both orders and revenue, which is consistent with Black Friday demand.
- Oct–Dec 2016 contain very few orders (Dec 2016: a single order), so early months should not be read as a trend.

#### 2. Top 5 product categories by revenue

Revenue = sum of item prices (excl. shipping).

| Category | Items sold | Orders | Revenue (BRL) |
| :--- | ---: | ---: | ---: |
| `beleza_saude` (Health & Beauty) | 9,670 | 8,836 | 1,258,681 |
| `relogios_presentes` (Watches & Gifts) | 5,991 | 5,624 | 1,205,006 |
| `cama_mesa_banho` (Bed, Bath & Table) | 11,115 | 9,417 | 1,036,989 |
| `esporte_lazer` (Sports & Leisure) | 8,641 | 7,720 | 988,049 |
| `informatica_acessorios` (Computer Accessories) | 7,827 | 6,689 | 911,954 |

- `relogios_presentes` ranks second in revenue with only 5,991 items sold: its revenue per item (~BRL 201) is about twice that of `beleza_saude` (~BRL 130).
- `cama_mesa_banho` sells the most items but ranks third in revenue (~BRL 93 per item).

#### 3. RFM customer segments

| Segment | Customers | Avg. spend (BRL) | Total revenue (BRL) | Revenue share |
| :--- | ---: | ---: | ---: | ---: |
| Top customers | 22,529 | 261.34 | 5,887,620 | 38.2 % |
| At risk, high spend | 21,682 | 264.30 | 5,730,484 | 37.2 % |
| Inactive | 23,745 | 63.84 | 1,515,988 | 9.8 % |
| Recent, low spend | 22,600 | 63.01 | 1,424,012 | 9.2 % |
| Repeat customers | 2,801 | 308.59 | 864,357 | 5.6 % |

- The two high-spend segments (about 47 % of customers) generate **~75 % of revenue**.
- **"At risk, high spend"** alone accounts for 37.2 % of revenue (21,682 customers who have not ordered recently): the most valuable target for retention campaigns.
- Only 3 % of customers (2,801) ordered more than once, but they have the highest average spend (BRL 309).

> **Note:** Revenue in queries 1 and 3 is based on `payment_value` (includes shipping and vouchers), while category revenue in query 2 uses item prices, so these figures are not directly comparable. Because `NTILE` creates equally sized groups, similar segment sizes reflect the method, not the business.

---

## 🚀 How to Run Locally
1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
2. Run `python scripts/setup_database.py` to populate `ecommerce.db`.
3. Open `ecommerce.db` using DB Browser for SQLite or DBeaver and execute queries from `/queries`.

---

## 🛠️ Tech Stack & Database Setup
- **Database Engine:** SQLite (ANSI SQL compatible)
- **Languages:** SQL, Python (Data Pipeline)
- **GUI & Tools:** DB Browser for SQLite, VS Code
