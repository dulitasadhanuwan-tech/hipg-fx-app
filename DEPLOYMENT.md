# HIPG FX App — GitHub Pages Free Web Hosting Guide

This guide explains how to host **HIPG FX App** as a **100% static web application** on **GitHub Pages** for free. Zero server configuration, zero monthly hosting fees, zero credit cards, and instant global access for colleagues.

---

## 1. Static Architecture Overview

The app is completely self-contained in static frontend files:
- **`index.html`** (Root file): Single-page responsive dashboard powered by Tailwind CSS, Chart.js, and SheetJS.
- **`data/cbsl_historical_data.js` & `data/cbsl_rates.json`**: Pre-loaded with verified 2026 CBSL historical daily observations across all 9 designated currencies.
- **`manifest.json` + `icon-192.png` / `icon-512.png` / `favicon.svg`**: Enables Progressive Web App (PWA) installation directly from Chrome, Edge, and mobile browsers.
- **Client-Side Storage**: In-browser `localStorage` database for verified rates, custom entries, and audit logs.
- **Fail-Safe Live Sync & Ingestion**:
  1. *Live Web CORS Bridge*: Ingests CBSL updates via public CORS bridges.
  2. *Smart Text Paste*: Paste raw text from CBSL's website; the app auto-extracts rates.
  3. *Direct Form Entry*: Audited manual entry with automated validation (checks positive rates, spread checks, prevents future dates).
  4. *JSON Backup / Restore*: Share database state with colleagues via one-click `.json` export and import.

---

## 2. Step-by-Step GitHub Pages Deployment (3 Minutes)

### Step 1: Create a GitHub Repository
1. Log in to [GitHub](https://github.com/) and click **New repository** (or visit [github.com/new](https://github.com/new)).
2. Name the repository `hipg-fx-app` (or any name you prefer).
3. Set visibility to **Public** (GitHub Pages is 100% free for public repositories) or **Private** (if your GitHub organization plan supports private Pages).
4. Do NOT initialize with a README, .gitignore, or license (we already have all files ready). Click **Create repository**.

### Step 2: Upload Files to the Repository

#### Option A: Using Git (Recommended)
Open a terminal inside this workspace (`c:\Users\HIPG-FIN\Documents\HIPG FX APP`):
```bash
git init
git add .
git commit -m "HIPG FX App - Static GitHub Pages Release"
git branch -M main
git remote add origin https://github.com/<your-username>/hipg-fx-app.git
git push -u origin main
```

#### Option B: Drag & Drop via Web Browser
1. In your newly created GitHub repository, click **uploading an existing file**.
2. Drag and drop all the files from the root list below (ensure `index.html` is at the root).
3. Click **Commit changes**.

### Step 3: Enable GitHub Pages
1. In your GitHub repository, click **Settings** (top right tab).
2. On the left sidebar, click **Pages** (under the "Code and automation" section).
3. Under **Build and deployment** → **Source**, ensure **Deploy from a branch** is selected.
4. Under **Branch**:
   - Select `main`
   - Select `/ (root)` folder
   - Click **Save**.
5. Wait ~60 seconds. Refresh the page until a green banner appears:
   > **"Your site is live at `https://<your-username>.github.io/hipg-fx-app/`"**

---

## 3. Exact Final Files to Upload to GitHub

Ensure these exact files are located at the root of your GitHub repository:

```text
hipg-fx-app/
├── index.html                  <-- Root web page (must be at the repository root)
├── manifest.json               <-- PWA Web App Manifest (for Chrome/Edge install)
├── favicon.svg                 <-- High-DPI vector corporate favicon
├── favicon.ico                 <-- Fallback browser icon
├── icon-192.png                <-- PWA launcher icon (192x192)
├── icon-512.png                <-- PWA splash icon (512x512)
├── DEPLOYMENT.md               <-- This guide
└── data/
    ├── cbsl_historical_data.js <-- Preloaded 2026 CBSL historical dataset (JS format)
    └── cbsl_rates.json         <-- Preloaded 2026 CBSL historical dataset (JSON format)
```

---

## 4. How Colleagues Can Install the App (Desktop & Mobile)

Once hosted on GitHub Pages:
- **Microsoft Edge (Windows)**: Open the link, click the **App available / Install** icon in the address bar (or menu `...` → **Apps** → **Install HIPG FX App**). It launches as a frameless, standalone desktop window with the official HIPG icon.
- **Google Chrome (Windows / Mac)**: Click the **Install** icon in the address bar to add it to the desktop or Start Menu.
- **Mobile (iOS Safari)**: Tap the **Share** button → **Add to Home Screen**.
- **Mobile (Android Chrome)**: Tap `...` → **Install app**.
