import duckdb
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH  = os.path.join(BASE_DIR, '..', 'database', 'insurance.duckdb')

con = duckdb.connect(DB_PATH)

# Run staging
with open(os.path.join(BASE_DIR, '02_staging.sql'), 'r') as f:
    con.execute(f.read())

print("Staging complete")

# Run warehouse
with open(os.path.join(BASE_DIR, '03_warehouse.sql'), 'r') as f:
    con.execute(f.read())
print("Warehouse complete")

# Run analytics
with open(os.path.join(BASE_DIR, '04_analytics.sql'), 'r') as f:
    con.execute(f.read())
print("Analytics complete")

# Export report tables to CSV for dashboard
EXPORT_DIR = os.path.join(BASE_DIR, '..', 'exports')
os.makedirs(EXPORT_DIR, exist_ok=True)

report_tables = [
    'rpt_loss_by_region',
    'rpt_loss_by_product',
    'rpt_chronic_cost_driver',
    'rpt_risk_segment_summary',
]

for table in report_tables:
    df = con.execute(f"SELECT * FROM {table}").fetchdf()
    df.to_csv(os.path.join(EXPORT_DIR, f"{table}.csv"), index=False)
    print(f"  Exported {table} ({len(df)} rows)")

print("Export complete")
