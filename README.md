# Insurance Portfolio Risk Analysis
Tech Stack: Python, SQL, DuckDB, Looker Studio

## Project Overview
This project is primarily a pipeline engineering exercise, built to demonstrate the end-to-end workflow of a data analyst: raw data ingestion, multi-stage SQL transformation, and a layered warehouse architecture. A synthetic insurance portfolio of 100,000 members serves as the domain, with a Looker Studio dashboard used to communicate findings.

## Data Source
Synthetic insurance member dataset generated to simulate real-world data. The dataset covers member demographics, health profile, plan details, and claims history, and is contaminated with messy data via duplicate rows among other injections in the Jupyter file to more closely simulate real-world data.

Source: [Kaggle — Medical Insurance Cost Prediction](https://www.kaggle.com/datasets/mohankrishnathalla/medical-insurance-cost-prediction/discussion/615310)

## Project Structure
**pipeline/**
- `01_setup.py` — loads raw CSV into DuckDB as raw_members
- `02_staging.sql` — cleans and deduplicates into stg_members
- `03_warehouse.sql` — aggregates into dwh_risk_segments
- `04_analytics.sql` — report tables for dashboard consumption
- `pipeline.py` — orchestrates all steps and CSV export

**Other**
- `insurance_analysis.ipynb` — data generation notebook
- `data/` — raw source data (not tracked in git)
- `database/` — DuckDB file (not tracked in git)
- `exports/` — generated CSVs for dashboard (not tracked in git)

## Methodology

**Data Ingestion & Cleaning**
- Loaded raw CSV into DuckDB and created a staging layer to clean and standardise the data
- Deduplicated on `person_id` using `ROW_NUMBER()` window function
- Stripped currency symbols from premium columns, trimmed whitespace from region, and flagged invalid ages
- Calculated `loss_ratio` and `underwriting_profit` at the member level

**Warehouse Layer**
- Aggregated the staging table into a warehouse model grouped by plan type, network tier, region, and risk flag
- Loss ratio recalculated at the aggregate level (`SUM(claims) / SUM(premium)`)

**Analytical Queries**
- Built four report tables to power the dashboard
- Exported results to CSV for Looker Studio consumption

**Dashboard**
- Single-page Looker Studio dashboard communicating the mispricing story end-to-end
- Establishes that underpricing is portfolio-wide and largely independent of region and plan type — loss ratios are elevated across all segments
- Identifies chronic condition count and risk status as the primary cost drivers — loss ratio escalates sharply with each additional chronic condition, regardless of geography or product

***[View the Live Dashboard](https://lookerstudio.google.com/reporting/c191017b-80af-4479-9108-c2abf65ce12d)***


## Output
- An automated data pipeline that simulates a raw, messy CSV through initial creation, staging, warehouse, and analytics layers into dashboard-ready exports
- Portfolio-level loss ratio of 2.43 — claims exceed premiums by $79.6M across all segments
- High-risk members generate an underwriting loss per member more than 3x that of low-risk members
- Loss ratio does not vary meaningfully by network tier or region

## Development Notes
Built with Claude as an AI coding assistant, used for SQL review and pipeline design decisions.

