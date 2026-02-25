-- 1. Loss ratio by region
CREATE OR REPLACE TABLE rpt_loss_by_region AS
WITH base AS (
    SELECT
        region,
        SUM(member_count) AS member_count,
        ROUND(SUM(total_premium), 2) AS total_premium,
        ROUND(SUM(total_claims), 2) AS total_claims,
        ROUND(SUM(total_underwriting_profit), 2) AS total_underwriting_profit,
        ROUND(SUM(total_claims) / NULLIF(SUM(total_premium), 0), 4) AS loss_ratio
    FROM dwh_risk_segments
    GROUP BY region
)
SELECT
    *,
    RANK() OVER (ORDER BY loss_ratio DESC) AS loss_ratio_rank
FROM base;


-- 2. Loss ratio by plan type x network tier
CREATE OR REPLACE TABLE rpt_loss_by_product AS
WITH base AS (
    SELECT
        plan_type,
        network_tier,
        SUM(member_count) AS member_count,
        ROUND(SUM(total_premium), 2) AS total_premium,
        ROUND(SUM(total_claims), 2) AS total_claims,
        ROUND(SUM(total_underwriting_profit), 2) AS total_underwriting_profit,
        ROUND(SUM(total_claims) / NULLIF(SUM(total_premium), 0), 4) AS loss_ratio
    FROM dwh_risk_segments
    GROUP BY plan_type, network_tier
)
SELECT
    *,
    RANK() OVER (ORDER BY loss_ratio DESC) AS loss_ratio_rank
FROM base;


-- 3. Cost escalation by chronic condition count
CREATE OR REPLACE TABLE rpt_chronic_cost_driver AS
WITH base AS (
    SELECT
        chronic_count,
        COUNT(*) AS member_count,
        ROUND(SUM(total_claims_paid) / NULLIF(SUM(annual_premium), 0), 4) AS loss_ratio,
        ROUND(AVG(total_claims_paid), 2) AS avg_claims_paid,
        ROUND(AVG(underwriting_profit), 2) AS avg_underwriting_profit,
        ROUND(AVG(visits_last_year), 2) AS avg_visits,
        ROUND(AVG(hospitalizations_last_3yrs), 2) AS avg_hospitalizations,
        ROUND(AVG(medication_count), 2) AS avg_medications
    FROM stg_members
    GROUP BY chronic_count
),
with_lag AS (
    SELECT
        *,
        LAG(loss_ratio) OVER (ORDER BY chronic_count) AS prev_loss_ratio
    FROM base
)
SELECT
    *,
    ROUND(loss_ratio - prev_loss_ratio, 4) AS loss_ratio_step_up,
    ROUND(
        (loss_ratio - prev_loss_ratio) / NULLIF(prev_loss_ratio, 0),
        4
    ) AS loss_ratio_pct_increase
FROM with_lag
ORDER BY chronic_count;


-- 4. High-risk vs low-risk financial summary
CREATE OR REPLACE TABLE rpt_risk_segment_summary AS
SELECT
    CASE WHEN is_high_risk = 1 THEN 'High Risk' ELSE 'Low Risk' END AS risk_segment,
    SUM(member_count) AS member_count,
    ROUND(SUM(total_premium), 2) AS total_premium,
    ROUND(SUM(total_claims), 2) AS total_claims,
    ROUND(SUM(total_underwriting_profit), 2) AS total_underwriting_profit,
    ROUND(SUM(total_claims) / NULLIF(SUM(total_premium), 0), 4) AS loss_ratio,
    ROUND(AVG(avg_premium), 2) AS avg_premium_per_member,
    ROUND(AVG(avg_claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(avg_visits), 2) AS avg_visits,
    ROUND(AVG(avg_hospitalizations), 2) AS avg_hospitalizations,
    ROUND(
        (SUM(total_claims) - SUM(total_premium)) / NULLIF(SUM(member_count), 0),
        2
    ) AS underwriting_loss_per_member
FROM dwh_risk_segments
GROUP BY is_high_risk;


