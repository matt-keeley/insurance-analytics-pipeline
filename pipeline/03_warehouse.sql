CREATE OR REPLACE TABLE dwh_risk_segments AS
SELECT
    plan_type,
    network_tier,
    region,
    is_high_risk,
    COUNT(*) AS member_count,
    ROUND(AVG(annual_premium), 2) AS avg_premium,
    ROUND(SUM(annual_premium), 2) AS total_premium,
    ROUND(SUM(total_claims_paid), 2) AS total_claims,
    ROUND(AVG(avg_claim_amount), 2) AS avg_claim_amount,
    ROUND(SUM(underwriting_profit), 2) AS total_underwriting_profit,
    ROUND(SUM(total_claims_paid) / NULLIF(SUM(annual_premium), 0), 4) AS loss_ratio,
    ROUND(AVG(visits_last_year), 2) AS avg_visits,
    ROUND(AVG(hospitalizations_last_3yrs), 2) AS avg_hospitalizations
FROM stg_members
GROUP BY
    plan_type,
    network_tier,
    region,
    is_high_risk;

