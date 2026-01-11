USE emergence_assess;

-- Monthly calendar

DROP TABLE IF EXISTS months;

WITH RECURSIVE months AS (
    SELECT DATE_FORMAT(MIN(start_date), '%Y-%m-01') AS month_start
    FROM subscriptions_clean

    UNION ALL

    SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM months
    WHERE month_start < (
        SELECT DATE_FORMAT(MAX(COALESCE(end_date, CURRENT_DATE)), '%Y-%m-01')
        FROM subscriptions_clean
    )
)
SELECT * FROM months;


-- Monthly MRR

DROP TABLE IF EXISTS monthly_mrr;

CREATE TABLE monthly_mrr AS
WITH RECURSIVE months AS (
    SELECT DATE_FORMAT(MIN(start_date), '%Y-%m-01') AS month_start
    FROM subscriptions_clean

    UNION ALL

    SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM months
    WHERE month_start < (
        SELECT DATE_FORMAT(MAX(COALESCE(end_date, CURRENT_DATE)), '%Y-%m-01')
        FROM subscriptions_clean
    )
),
active_subs AS (
    SELECT
        m.month_start,
        s.subscription_id,
        s.customer_id,
        s.monthly_price
    FROM months m
    JOIN subscriptions_clean s
      ON s.start_date <= LAST_DAY(m.month_start)
     AND (s.end_date IS NULL OR s.end_date >= m.month_start)
)
SELECT
    month_start,
    SUM(monthly_price) AS mrr
FROM active_subs
GROUP BY month_start
ORDER BY month_start;

select * from monthly_mrr


-- Annual ARR

DROP TABLE IF EXISTS arr;

CREATE TABLE arr AS
SELECT
    month_start,
    mrr * 12 AS arr
FROM monthly_mrr;

SELECT * FROM arr;


-- Customer churn

DROP TABLE IF EXISTS customer_churn;

CREATE TABLE customer_churn AS
WITH customer_months AS (
    SELECT DISTINCT
        m.month_start,
        s.customer_id
    FROM monthly_mrr m
    JOIN subscriptions_clean s
      ON s.start_date <= LAST_DAY(m.month_start)
     AND (s.end_date IS NULL OR s.end_date >= m.month_start)
),
churned AS (
    SELECT
        prev.month_start AS churn_month,
        COUNT(DISTINCT prev.customer_id) AS churned_customers
    FROM customer_months prev
    LEFT JOIN customer_months curr
      ON prev.customer_id = curr.customer_id
     AND curr.month_start = DATE_ADD(prev.month_start, INTERVAL 1 MONTH)
    WHERE curr.customer_id IS NULL
    AND prev.month_start < (
        SELECT DATE_SUB(MAX(month_start), INTERVAL 1 MONTH)
        FROM customer_months)
    GROUP BY prev.month_start
)
SELECT * FROM churned;

SELECT * FROM customer_churn;


-- Revenue churn

DROP TABLE IF EXISTS revenue_churn;

CREATE TABLE revenue_churn AS
WITH customer_mrr AS (
    SELECT
        m.month_start,
        s.customer_id,
        SUM(s.monthly_price) AS customer_mrr
    FROM monthly_mrr m
    JOIN subscriptions_clean s
      ON s.start_date <= LAST_DAY(m.month_start)
     AND (s.end_date IS NULL OR s.end_date >= m.month_start)
    GROUP BY m.month_start, s.customer_id
),
churned_mrr AS (
    SELECT
        prev.month_start AS churn_month,
        SUM(prev.customer_mrr) AS churned_mrr
    FROM customer_mrr prev
    LEFT JOIN customer_mrr curr
      ON prev.customer_id = curr.customer_id
     AND curr.month_start = DATE_ADD(prev.month_start, INTERVAL 1 MONTH)
    WHERE curr.customer_id IS NULL
    GROUP BY prev.month_start
)
SELECT * FROM churned_mrr;

SELECT * FROM revenue_churn;


-- ARPC per month

DROP TABLE IF EXISTS arpc;

CREATE TABLE arpc AS
SELECT
    m.month_start,
    m.mrr / COUNT(DISTINCT s.customer_id) AS arpc
FROM monthly_mrr m
JOIN subscriptions_clean s
  ON s.start_date <= LAST_DAY(m.month_start)
 AND (s.end_date IS NULL OR s.end_date >= m.month_start)
GROUP BY m.month_start, m.mrr;

SELECT * from arpc;



SELECT * FROM monthly_mrr;
SELECT * FROM arr;
SELECT * FROM customer_churn;
SELECT * FROM revenue_churn;
SELECT * from arpc;






