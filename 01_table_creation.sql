create DATABASE if NOT EXISTS emergence_assess;
use emergence_assess;

CREATE TABLE IF NOT EXISTS customer_data_raw(
    customer_id VARCHAR(50),
    signup_date DATE,
    segment VARCHAR(50),
    country VARCHAR(50),
    is_enterprise VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS subscriptions_raw(
    subscription_id VARCHAR(50),
    customer_id VARCHAR(50),
    start_date DATE,
    end_date DATE,
    monthly_price DECIMAL(10,2),
    status NVARCHAR(50)
);

CREATE TABLE IF NOT EXISTS events_raw(
    event_id VARCHAR(50),
    customer_id VARCHAR(50),
    event_type VARCHAR(50),
    event_date DATE,
    source VARCHAR(50)
);

SHOW TABLES;

SELECT count(*) FROM customer_data_raw;

SELECT count(*) FROM subscriptions_raw;

SELECT count(*) FROM events_raw;



-- RAW CSV files imported from python using SQL Alchemy

-- Header rows ignored

-- No preprocessing done before load