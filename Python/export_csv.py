import pandas as pd
from sqlalchemy import create_engine

# Database credentials
USER = "root"
PASSWORD = "root12345"
HOST = "localhost"
PORT = "3306"
DATABASE = "product_analytics"
OUTPUT_FILE = r"C:\Users\TANVEER\Documents\Altamash\Funnel A_B testing\Data\SQL_Query_Results\session_metrics.csv"

# Connect
engine = create_engine(f"mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}")

query = """
SELECT 
    user_session,
    user_id,
    session_start,
    session_duration_seconds,
    viewed,
    added_to_cart,
    purchased,
    revenue,
    product_count
FROM product_analytics.session_metrics
ORDER BY session_start DESC;
"""

print("Starting export to CSV in chunks...")

# Stream in 100k chunks to keep memory usage minimal
chunk_size = 100_000
first_chunk = True

with engine.connect().execution_options(stream_results=True) as conn:
    for i, chunk in enumerate(pd.read_sql_query(query, conn, chunksize=chunk_size)):
        chunk.to_csv(
            OUTPUT_FILE, 
            mode='w' if first_chunk else 'a', 
            header=first_chunk, 
            index=False
        )
        first_chunk = False
        print(f"Exported {(i + 1) * chunk_size:,} rows...")

print(f"Export complete! Saved to: {OUTPUT_FILE}")