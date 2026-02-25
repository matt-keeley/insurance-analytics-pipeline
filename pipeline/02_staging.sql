CREATE OR REPLACE TABLE stg_members AS

WITH deduplicated AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY (SELECT NULL)) AS row_num
    FROM raw_members
),

cleaned AS (
    SELECT * REPLACE (
        LOWER(TRIM(region)) AS region,
        CAST(
            REPLACE(CAST(annual_premium AS VARCHAR), '$', '')
            AS FLOAT
        ) AS annual_premium,
        CASE WHEN age < 0 OR age > 130 THEN NULL ELSE age END AS age
    )
    FROM deduplicated 
    WHERE row_num = 1
)

SELECT *,
    ROUND(total_claims_paid / NULLIF(annual_premium, 0), 4) AS loss_ratio,
    ROUND(annual_premium - total_claims_paid, 2) AS underwriting_profit,
    age IS NULL AS flag_invalid_age
FROM cleaned