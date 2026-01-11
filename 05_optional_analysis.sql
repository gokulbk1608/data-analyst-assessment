-- Revenue analysis by acquisition source : Which channels actually bring money, not just signups?
-- Insight: Identifies channels driving actual revenue

DROP TABLE IF EXISTS revenue_analysis;

CREATE TABLE revenue_analysis AS
SELECT
    e.source,
    COUNT(DISTINCT s.customer_id) AS paying_customers,
    SUM(s.monthly_price) AS total_mrr,
    ROUND(SUM(s.monthly_price) / COUNT(DISTINCT s.customer_id), 2) AS avg_mrr_per_customer
FROM subscriptions_clean s
JOIN events_clean e
  ON s.customer_id = e.customer_id
WHERE LOWER(e.event_type) = 'activated'
GROUP BY e.source
ORDER BY total_mrr DESC;

SELECT * FROM revenue_analysis;


-- Time to Convert Analysis : How long does it take to go from signup → paid?

DROP TABLE IF EXISTS time_to_convert;

CREATE TABLE time_to_convert AS
SELECT
    fe.customer_id,
    DATEDIFF(
        MAX(CASE WHEN funnel_stage = 'Activated' THEN event_date END),
        MAX(CASE WHEN funnel_stage = 'Signup' THEN event_date END)
    ) AS days_to_convert
FROM funnel_events fe
GROUP BY fe.customer_id
HAVING days_to_convert IS NOT NULL;

SELECT * FROM time_to_convert