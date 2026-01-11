# data-analyst-assessment
# SaaS Growth & GTM Analytics – Data Analyst Take-Home Assessment

## Overview
This project analyzes growth, revenue, churn, and funnel performance for a B2B SaaS company using raw, intentionally imperfect data.  
The goal is to transform messy operational data into clear, actionable insights that leadership can use for decision-making.

The analysis focuses on:
- Revenue performance (MRR, ARR)
- Customer and revenue churn
- Funnel efficiency from Signup to Churn
- Acquisition channel effectiveness


---

## Tools Used
- **MySQL**: Data modeling, cleaning, metric calculations, funnel analysis
- **Python (pandas, numpy)**: Initial data exploration, validation, sanity checks
- **Power BI**: Visualization of revenue trends, funnel conversion, churn, and source breakdown
- **VS Code**: SQL development and execution

---

## Data Overview
The following raw datasets were provided:
- `customers.csv`: Customer profile and segmentation data
- `subscriptions.csv`: Subscription lifecycle and recurring revenue information
- `events.csv`: Funnel events and acquisition source data

The data intentionally contained:
- Duplicate records
- Missing values
- Inconsistent or repeated events
- Edge cases in subscription lifecycle

---

## Data Modeling Approach
A two-layer approach was used:

### Raw Tables
- `customer_data_raw`
- `subscriptions_raw`
- `events_raw`

These tables store the data **exactly as received**, without modification.

### Clean Tables
- `customer_clean`
- `subscriptions_clean`
- `events_clean`

Clean tables were created using transparent SQL logic with documented assumptions, making the analysis reproducible and auditable.

---

## Data Issues Identified & Assumptions
Key data issues and how they were handled:

- **Duplicate customers**  
  - Kept the earliest `signup_date` per `customer_id`

- **Duplicate subscription records**  
  - Incorporated steps to remove duplicated data if present using `subscription_id`, keeping the earliest valid record

- **Missing subscription end dates**  
  - Assumed `end_date IS NULL` indicates an active subscription

- **Repeated funnel events per customer**  
  - Kept the first occurrence of each event type per customer

All assumptions are documented directly in SQL comments and reflected consistently across metrics.

---

## Metric Definitions
- **MRR (Monthly Recurring Revenue)**  
  Sum of active monthly subscription amounts for all active subscriptions in a given month.

- **ARR (Annual Recurring Revenue)**  
  MRR × 12.

- **Customer Churn**  
  Customers active in the previous month but not active in the following month.

- **Revenue Churn**  
  Monthly recurring revenue lost due to customer churn.

- **ARPC (Average Revenue per Customer)**  
  MRR divided by the number of active customers in a given month.

---

## Funnel Analysis
The following funnel was constructed using event data:
- Signup --> Trial --> Activated --> Churned

### Funnel Construction Rules
- Each customer can appear **only once per funnel stage**
- For customers with multiple events of the same type, the **earliest event date** was used
- Funnel stages were **explicitly ordered** to ensure logical progression
- Customers may skip stages depending on data availability, reflecting real-world behavior

### Funnel Metrics
For each stage, the following were calculated:
- Number of unique customers
- Conversion rate from the previous stage
- Drop-off between stages

Conversion rates were calculated as:
- Customers reaching current stage ÷ customers in previous stage

## Dashboard Overview
The Power BI dashboard includes:
- **MRR trend over time**
- **Funnel conversion by stage**
- **Customer and revenue churn overview**
- **Acquisition source performance**

The dashboard is designed for clarity and insight rather than visual complexity.  
Screenshots and/or a live dashboard link are included in the `dashboard/` folder.

---

## Key Insights
- MRR growth is uneven and driven by a relatively small subset of customers.
- Significant drop-off occurs between Signup --> Trial and Trial --> Activated
- Acquisition channels differ greatly in quality, not just volume
- Churn occurs relatively soon after customers become paid, impacting revenue stability.
- Time to convert from Signup to Activated varies widely, indicating different customer journeys.

---

## Recommendations
- Improve early-stage activation
- Reallocate marketing investment toward high-quality acquisition sources

---

## Limitations
- Analysis is based on historical snapshot data and does not account for future behavior.
- Some assumptions (e.g., revenue periodicity) were required due to missing documentation.
- Cohort-based long-term retention was not fully explored due to scope constraints.

---

## How to Reproduce
1. Do the initial data validation - row counts and metrics checks using the Python notebook in `python/`.
2. Proceed with the table creation in MySQL using the provided - `01_table_creation.sql` table creation scripts in `sql/`.
3. Then Load the validated CSV files into MySQL using the same Python notebook in `python/`.
4. Run SQL files in numerical order:
   - `02_data_cleaning.sql`
   - `03_core_metrics.sql`
   - `04_funnel_analysis.sql`
   - `05_optional_analysis.sql`
5. Connect Power BI to the MySQL database and recreate visuals using the provided tables.

---

## Final Notes
This project was approached as a real-world analytics problem rather than a purely technical exercise.  
Trade-offs and assumptions were made explicitly, with a focus on clarity, business impact, and reproducibility.
