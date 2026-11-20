# HIPG Finance — Official CBSL Automated FX Rate App (Master `.md` Blueprint)

Use this complete specification file as a **ready-to-build blueprint** (for AI app builders like Google AI Studio Build, Cursor, Windsurf, or a developer) to build and run the **HIPG Finance Automated CBSL Foreign Exchange Rate Application** with **Daily, Weekly, Monthly, and Yearly** updates.

## 1. Project Objective & Architecture (Option A)

Build a reliable, auditable foreign exchange rate application for **Hambantota International Port Group (HIPG) Finance Department** using official **Central Bank of Sri Lanka (CBSL)** published exchange rates.

* **Frontend:** Responsive single-file dashboard (HTML + Tailwind CSS + Chart.js + SheetJS Excel Export) with corporate navy (`#002B49`), amber (`#f59e0b`), and emerald (`#10b981`) theme.

* **Desktop App Experience (Windows):** Launch in a frameless standalone app window (`msedge.exe --app=...`) with a custom `.ico` desktop shortcut (replacing the default browser icon), or deploy via **Netlify Drop** / **GitHub Pages** for zero-cost colleague access.

* **Backend Service:** Lightweight Python REST API (`http.server` / FastAPI + `beautifulsoup4`) with a configurable automated background scheduler (default: every 30 minutes on Sri Lanka business days, Mon–Fri, 08:30–18:00 SLST).

* **Database:** Relational database (**SQLite** locally or **Supabase / PostgreSQL** free tier in the cloud) to preserve verified historical records permanently.

* **Security:** Never hardcode API keys, passwords, or database credentials inside the frontend HTML file; use environment variables (`.env`) on the backend.

## 2. Official CBSL Data Sources & Server-Side Retrieval

CBSL does **not** provide a public JSON/REST API. The backend must retrieve rates directly from CBSL's official web pages and PHP lookup endpoints (without relying on a public CORS proxy as the primary mechanism):

| Rate Type | Official CBSL Portal Page | Direct PHP Form & Results Endpoint | 
| ----- | ----- | ----- | 
| **Overview & Summary** | [CBSL Exchange Rates (`node/146`)](https://www.cbsl.gov.lk/en/node/146) | `https://www.cbsl.gov.lk/en/node/146` | 
| **Indicative Exchange Rate** | [CBSL Daily Indicative (`node/145`)](https://www.cbsl.gov.lk/en/node/145) | Form: [exrates.php](https://www.cbsl.gov.lk/cbsl_custom/exrates/exrates.php) → Results: `exrates_results.php` | 
| **TT Buying & TT Selling Rates** | [CBSL Daily Buy & Sell (`node/242`)](https://www.cbsl.gov.lk/en/node/242) | Form: [exratestt.php](https://www.cbsl.gov.lk/cbsl_custom/exratestt/exratestt.php) → Results: `exrates_resultstt.php` | 

### Exact `POST` Form Parameters for Live Same-Day Retrieval

Because `node/146` can lag behind same-day releases, the backend must `POST` directly to `exrates_resultstt.php` and `exrates_results.php` with:

* `drange=1`

* `txtsdate=YYYY-MM-DD` (7 days prior to target date)

* `txtedate=YYYY-MM-DD` (current Colombo business date)

* `currency[]` for each of the 9 currencies (`AUD`, `CAD`, `CHF`, `RMB`/`CNY`, `EUR`, `GBP`, `JPY`, `SGD`, `USD`)

* `submit=Submit`

## 3. Nine Designated Currencies & Three Separate Rate Types

Retain these exact **9 currencies** (4-decimal precision):

| Code | Currency Name | CBSL TT Label | CBSL Indicative Label | 
| ----- | ----- | ----- | ----- | 
| `USD` | United States Dollar | United States Dollar | US Dollar | 
| `EUR` | Euro | Euro | Euro | 
| `GBP` | British Pound Sterling | British Pound | Sterling Pound | 
| `AUD` | Australian Dollar | Australian Dollar | Australian Dollar | 
| `CAD` | Canadian Dollar | Canadian Dollar | Canadian Dollar | 
| `CNY` | Chinese Yuan (Renminbi) | Renminbi | Chinese Yuan (Renminbi) | 
| `JPY` | Japanese Yen | Yen | Japanese Yen | 
| `SGD` | Singapore Dollar | Singapore Dollar | Singapore Dollar | 
| `CHF` | Swiss Franc | Swiss Franc | Swiss Franc | 

*(Note: Exclude "Chinese Yuan (Offshore)" so it never collides with onshore `CNY` / Renminbi.)*

For each currency and publication date, retrieve and store **three separate values**:

1. **Indicative Exchange Rate** (`indicative_rate`)

2. **TT Buying Rate** (`tt_buying_rate`)

3. **TT Selling Rate** (`tt_selling_rate`)

## 4. Strict Financial Accuracy & Internal Control Rules

1. **Zero Estimation or Carry-Forward:**

   * Never estimate official rates or calculate TT Buying/Selling by multiplying Indicative rates by historical ratios.

   * Never copy yesterday's rates and label them as today's official rates.

   * Never generate dummy or sample historical data as official CBSL records.

2. **Explicit Status Messages:**

   * If today's rates have not yet been published by CBSL: display **`Awaiting CBSL Publication`** and clearly label the latest available rate with its **actual previous business day publication date**.

   * If retrieval fails (offline or CBSL unreachable): display **`Data Retrieval Failed – Last Successful Update: [Date/Time]`** and preserve all previously verified records untouched.

   * If a specific rate type is not published for a currency on a given date: store `NULL` in the database and display **`Not Available`** in the UI and Excel export.

3. **Validation Checks Before Saving:**

   * Valid `YYYY-MM-DD` publication date (never a future date).

   * Currency code must be in the 9-currency whitelist.

   * All numeric rates must be `> 0` and within plausible currency bounds.

   * If both TT Buying and TT Selling exist, `tt_buying_rate < tt_selling_rate` must hold.

   * Enforce `UNIQUE(publication_date, currency_code)` to prevent duplicate rows.

## 5. Daily, Weekly, Monthly & Yearly Calculation Methodology

All period rollups must be computed strictly from **actual daily published CBSL observations** stored in the database (never filling weekends/holidays with repeated rates):

| Horizon View | Calculation Formula & Rules | Required Display Fields | 
| ----- | ----- | ----- | 
| **Daily View** | Exact CBSL published observation for the selected date (no averaging). | Publication Date, Indicative, TT Buying, TT Selling, Inverse (`1 / Indicative`), Verification Status | 
| **Weekly View** | Group actual daily observations by ISO week (`YYYY-Www`). `Average = SUM(observations) / n` | Period Label, Observation Count (`n`), Average Indicative/Buy/Sell, Opening, Closing, High, Low | 
| **Monthly View** | Group actual daily observations by calendar month (`YYYY-MM`). `Average = SUM(observations) / n` | Month Label, Observation Count (`n`), Average Indicative/Buy/Sell, Opening, Closing, High, Low | 
| **Yearly View** | Group actual daily observations by calendar year (`FY YYYY`) and quarter (`YYYY-Q1..Q4`). `Average = SUM(observations) / n` | Year/Quarter Label, Observation Count (`n`), Average Indicative/Buy/Sell, Opening, Closing, High, Low | 

Always visually distinguish **Official CBSL Published Records** from **Calculated Averages (`n=... obs`)** and **Missing/Unavailable Data**.

## 6. Relational Database Schema (`schema.sql`)

```
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

```

## 7. Required UI Features & Export Capabilities

* **Data Quality & Internal Controls Banner:** Displays current Colombo business date (`SLST`), latest official CBSL publication date, last successful backend sync timestamp, `9/9` currency coverage, and any missing rate warnings.

* **Multi-Horizon Rollup Strip:** 4 clickable cards showing **Daily (Official)**, **Weekly Avg (`n` obs)**, **Monthly Avg (`n` obs)**, and **Yearly Avg (`n` obs)** side-by-side.

* **Interactive Controls:** Currency selector (9 currencies), Horizon tabs (`Daily`, `Weekly`, `Monthly`, `3 Months`, `6 Months`, `Yearly`), Daily Date selector, configurable auto-sync interval dropdown, and **`Sync Live CBSL Rates Now`** button.

* **Charts & 9-Currency Board:** 3-line Chart.js trend graph (TT Buying, TT Selling, Spot Indicative) and clickable 9-currency comparison matrix.

* **Multi-Sheet Excel Export (`.xlsx`):** Exports `Executive Summary`, `DAILY`, `WEEKLY`, `MONTHLY`, `YEARLY`, and `All_9_CBSL_Currencies` tabs with exact observation counts (`n`) and `"Not Available"` for missing values.

* **Methodology & Audit Log Modal:** Plain-English explanation of formulas plus live retrieval audit trail table.

* **Zero-Cost Colleague Sharing:** Copy-ready Teams/WhatsApp/Email briefing generator and one-click Windows Desktop shortcut/icon installer.

## 8. 12-Scenario Verification Checklist

Before releasing any update, verify all 12 scenarios pass:

 1. Successful retrieval of all 9 official CBSL currencies (Indicative, TT Buy, TT Sell).

 2. Missing rate type for a currency displays `"Not Available"` without estimation.

 3. Current day not yet published displays `"Awaiting CBSL Publication"` and shows previous business day's date.

 4. Backend unavailable displays `"Data Retrieval Failed – Last Successful Update: [Date/Time]"`.

 5. Internet unavailable logs failure without overwriting valid cached history.

 6. Duplicate retrieval of the same publication date is skipped (`0` duplicate rows).

 7. New daily update preserves all prior historical records unchanged.

 8. Instant on-demand sync (`Sync Live CBSL Rates Now`) updates audit log and dynamic toast.

 9. Scheduled background sync runs automatically at configurable intervals.

10. Multi-sheet Excel export downloads cleanly with accurate observation counts.

11. Daily, Weekly, Monthly, and Yearly arithmetic averages match `SUM / n` manually.

12. Invalid/negative/inverted-spread/future-dated payloads are rejected by validation controls.