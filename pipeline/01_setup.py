import duckdb
import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH  = os.path.join(BASE_DIR, '..', 'database', 'insurance.duckdb')
CSV_PATH = os.path.join(BASE_DIR, '..', 'data', 'messy_data.csv')

con = duckdb.connect(DB_PATH)
con.execute(f"""
            CREATE TABLE IF NOT EXISTS raw_members AS
            SELECT * FROM read_csv_auto('{CSV_PATH}')
""")
