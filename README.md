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

### 3. Customer RFM & Value Segmentation
Uses SQL Window Functions (`NTILE`) to segment customers based on order frequency and total monetary spend.

```sql
WITH CustomerMetrics AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        ROUND(SUM(p.payment_value), 2) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    customer_unique_id,
    order_count,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile
FROM CustomerMetrics
ORDER BY total_spent DESC;
```

---

### 📊 Sample Query Output / Key Results
The aggregated outputs of the analytical queries (compact summary tables stored as CSV files under the `outputs/` directory) highlight the scale of the dataset and key revenue drivers:

| Metric / Category | Summary / Insight |
| :--- | :--- |
| **Primary Output Files** | Located in [`outputs/`](./outputs/) (`monthly_revenue_output.csv`, `top_categories_output.csv`, etc.) |
| **Top Revenue Driver** | Health & Beauty (`beleza_saude`) and Watches & Gifts (`relogios_presentes`) leading overall sales volume |
| **Data Scope** | Cleaned aggregations derived from ~100k Brazilian e-commerce orders (2016–2018) |

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
