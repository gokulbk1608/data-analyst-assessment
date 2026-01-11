USE emergence_assess

-- Assumptions

-- - event_type contains values mapping to funnel stages
-- - Naming may not be perfect, so we map explicitly
-- - If a customer has multiple events for a stage, keeping the earliest


-- Normalize funnel stages

DROP TABLE IF EXISTS funnel_events;

CREATE TABLE funnel_events AS 
WITH mapped_events AS (
    SELECT
        customer_id,
        event_date,
        source,
        CASE
            WHEN LOWER(event_type) = 'signup' THEN 'Signup'
            WHEN LOWER(event_type) = 'trial_start' THEN 'Trial Start'
            WHEN LOWER(event_type) = 'activated' THEN 'Activated'
            WHEN LOWER(event_type) = 'churned' THEN 'Churned'
        END AS funnel_stage
    FROM events_clean
    WHERE LOWER(event_type) IN ('signup', 'trial_start', 'activated', 'churned')
),
ranked AS (
    SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY customer_id, funnel_stage ORDER BY event_date ASC) AS rn
    FROM mapped_events
)
SELECT 
    customer_id,
    funnel_stage,
    event_date,
    source
    FROM ranked
    WHERE rn = 1
    ORDER BY customer_id, event_date ASC;

SELECT * FROM  funnel_events

SELECT funnel_stage, COUNT(DISTINCT customer_id)
FROM funnel_events
GROUP BY funnel_stage
ORDER BY COUNT(*) DESC;


-- Funnel order

DROP TABLE IF EXISTS funnel_ordered;

CREATE TABLE funnel_ordered AS
SELECT
    customer_id,
    funnel_stage,
    event_date,
    source,
    CASE funnel_stage
        WHEN 'Signup' THEN 1
        WHEN 'Trial Start' THEN 2
        WHEN 'Activated' THEN 3
        WHEN 'Churned' THEN 4
    END AS stage_order
FROM funnel_events;

SELECT * FROM funnel_ordered


-- Funnel conversion

DROP TABLE IF EXISTS funnel_summary;

CREATE TABLE funnel_summary AS
SELECT
    stage_order,
    funnel_stage,
    COUNT(DISTINCT customer_id) AS customers,
    LAG(COUNT(DISTINCT customer_id)) OVER (ORDER BY stage_order) AS previous_stage_customers,
    ROUND(
        COUNT(DISTINCT customer_id) /
        LAG(COUNT(DISTINCT customer_id)) OVER (ORDER BY stage_order),
        2
    ) AS conversion_rate
FROM funnel_ordered
GROUP BY stage_order, funnel_stage
ORDER BY stage_order;

SELECT * FROM funnel_summary


-- Funnel by source

DROP TABLE IF EXISTS funnel_by_source;

CREATE TABLE funnel_by_source AS
SELECT
    source, funnel_stage, stage_order, COUNT(DISTINCT(customer_id)) AS customers FROM funnel_ordered
    GROUP BY source, funnel_stage, stage_order
    ORDER BY source, stage_order

SELECT * FROM funnel_by_source