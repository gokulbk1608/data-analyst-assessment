USE emergence_assess;

-- customers_clean

-- Assumptions:
-- - customer_id uniquely identifies a customer
-- - if duplicates exist, keeping the earliest created_at

DROP TABLE IF EXISTS customer_clean;

CREATE TABLE customer_clean AS 
WITH ranked_cust AS (
    SELECT *,
    ROW_NUMBER() OVER ( PARTITION BY customer_id ORDER BY signup_date ASC) AS rn
    FROM customer_data_raw
)
SELECT customer_id, signup_date, segment, country, is_enterprise FROM ranked_cust WHERE rn=1 ;

select count(*) from customer_clean;
select count(*) from customer_data_raw;


-- subscriptions_clean

-- Assumptions:
-- - subscription_id uniquely identifies a subscription
-- - duplicates removed
-- - end_date NULL indicates active subscription

DROP TABLE IF EXISTS subscriptions_clean;

CREATE TABLE subscriptions_clean AS
WITH ranked_subs AS (
    SELECT *,
    ROW_NUMBER() OVER ( PARTITION BY subscription_id ORDER BY start_date ASC ) AS rn
    FROM subscriptions_raw
    WHERE monthly_price > 0
)
SELECT subscription_id, customer_id, start_date, end_date, monthly_price, status
FROM ranked_subs
WHERE rn = 1;

SELECT COUNT(*) FROM subscriptions_raw;
SELECT COUNT(*) FROM subscriptions_clean;


-- events_clean

-- Assumptions:
-- - Multiple events per customer allowed
-- - Keeping first occurrence of each event type per customer

DROP TABLE IF EXISTS events_clean;

CREATE TABLE events_clean AS
WITH ranked_events AS (
    SELECT *, ROW_NUMBER() OVER ( PARTITION BY customer_id, event_type ORDER BY event_date ASC ) AS rn
    FROM events_raw
)
SELECT
    event_id,
    customer_id,
    event_type,
    event_date,
    source
FROM ranked_events
WHERE rn = 1 ORDER BY event_id;

SELECT COUNT(*) FROM events_clean;
SELECT COUNT(*) FROM events_raw;


