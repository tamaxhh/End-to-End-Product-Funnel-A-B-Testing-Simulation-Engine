import pandas as pd
from sqlalchemy import create_engine

# 1. Database Credentials
USER = "root"
PASSWORD = "root12345"
HOST = "localhost"
PORT = "3306"
DATABASE = "product_analytics"

# 2. File and Target Table
CSV_PATH = r"C:\Users\TANVEER\Documents\Altamash\Funnel A_B testing\Data\Cleaned_data\cleaned_data.csv"
TABLE_NAME = "A_B_testing_data"

# 3. Create Connection Engine
engine = create_engine(f"mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}")

# 4. Load and Push Data
print("Reading CSV...")
df = pd.read_csv(CSV_PATH)

print(f"Loading {len(df)} rows into MySQL table '{TABLE_NAME}'...")
# if_exists='replace' creates/overwrites the table; use 'append' if the table already exists
df.to_sql(name=TABLE_NAME, con=engine, if_exists="replace", index=False, chunksize=10000)

print("Data loaded successfully!")