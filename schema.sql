-- HIPG Finance CBSL FX Rate Application Database Schema
-- Strict Relational SQLite Schema

CREATE TABLE IF NOT EXISTS currency_metadata (
    currency_code VARCHAR(3) PRIMARY KEY,
    currency_name VARCHAR(100) NOT NULL,
    decimal_precision INTEGER NOT NULL DEFAULT 4,
    is_active INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS exchange_rates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    publication_date VARCHAR(10) NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    indicative_rate NUMERIC(12, 4) NULL,
    tt_buying_rate NUMERIC(12, 4) NULL,
    tt_selling_rate NUMERIC(12, 4) NULL,
    verification_status VARCHAR(50) NOT NULL DEFAULT 'Officially Published',
    cbsl_indicative_source VARCHAR(255) NULL,
    cbsl_tt_source VARCHAR(255) NULL,
    retrieved_at_utc VARCHAR(30) NOT NULL,
    updated_at_utc VARCHAR(30) NOT NULL,
    FOREIGN KEY (currency_code) REFERENCES currency_metadata(currency_code),
    UNIQUE(publication_date, currency_code),
    CHECK (indicative_rate IS NULL OR indicative_rate > 0),
    CHECK (tt_buying_rate IS NULL OR tt_buying_rate > 0),
    CHECK (tt_selling_rate IS NULL OR tt_selling_rate > 0),
    CHECK (tt_buying_rate IS NULL OR tt_selling_rate IS NULL OR tt_buying_rate < tt_selling_rate)
);

CREATE TABLE IF NOT EXISTS sync_audit_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sync_timestamp_utc VARCHAR(30) NOT NULL,
    sync_timestamp_slst VARCHAR(30) NOT NULL,
    trigger_type VARCHAR(20) NOT NULL,
    retrieval_status VARCHAR(30) NOT NULL,
    target_date_slst VARCHAR(10) NOT NULL,
    latest_published_date VARCHAR(10) NULL,
    currencies_updated INTEGER NOT NULL DEFAULT 0,
    currencies_missing_rates TEXT NULL,
    cbsl_sources_queried TEXT NOT NULL,
    message TEXT NOT NULL,
    error_details TEXT NULL
);

-- Index for fast time-series queries
CREATE INDEX IF NOT EXISTS idx_exchange_rates_pubdate ON exchange_rates(publication_date);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_curr_pubdate ON exchange_rates(currency_code, publication_date);
