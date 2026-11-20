import sys
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))

from backend.database import init_db, get_db_connection
from backend.cbsl_scraper import sync_cbsl_rates

def main():
    print("Initializing production SQLite database schema...")
    init_db()
    conn = get_db_connection()
    try:
        print("Syncing official CBSL historical data from 2026-01-01 to 2026-11-19...")
        result = sync_cbsl_rates(
            conn,
            trigger_type="INITIAL_POPULATE",
            custom_start_date="2026-01-01",
            custom_end_date="2026-11-19"
        )
        print("Sync Result:", result)
        
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) as total_obs, COUNT(DISTINCT publication_date) as total_days FROM exchange_rates")
        row = cur.fetchone()
        print(f"Database populated with {row['total_obs']} total currency observations across {row['total_days']} official CBSL trading days.")
    finally:
        conn.close()

if __name__ == "__main__":
    main()
