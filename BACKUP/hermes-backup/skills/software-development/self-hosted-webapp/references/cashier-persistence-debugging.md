# Cashier System Data Persistence Debugging

## Use Case
A PHP-based cashier/ordering system that uses SQLite for persistence but orders aren't saving across browser sessions or devices. The system has a hybrid architecture: **localStorage** (browser) + **SQLite** (server) + **API bridge** (PHP endpoint).

## Data Flow Architecture

```
User Action → DOM manipulation (add/move/delete elements)
    → saveData() serializes innerHTML of all containers
        → localStorage.setItem('appData', JSON)
        → fetch(api.php?action=save_state) → SQLite app_state table
    ├── processOrder()  → creates order in historyContainer
    ├── moveToFinished() → moves to finishedContainer + fires save_finished_order API
    ├── removeHistory()  → archiveDeletedItem() → localStorage + report_deleted_order API
    └── toggleCheck() / toggleArchive() → modifies DOM classes + saveData()
```

## Diagnostic Steps

### 1. Identify the persistence chain

Read these files in order:

```bash
# 1. The main entry point (index.php) — loads index.html and injects status bar
cat path/to/cashier/index.php

# 2. Database connection
cat path/to/cashier/db.php
# Check: tables created (finished_orders, deleted_orders, app_state)
# Check: PDO error mode (ERRMODE_EXCEPTION recommended)
# Check: DB file path (is it writable?)

# 3. API endpoint — read all endpoints
cat path/to/cashier/static/js/api.php
# Check for: save_state, load_state, save_finished_order, report_deleted_order, save_order_no

# 4. Main JS — find moveToFinished, processOrder, removeHistory, saveData, loadData
# Search for specific functions
grep -n "function moveToFinished\|function processOrder\|function saveData\|function removeHistory\|archiveDeletedItem" path/to/script.js

# 5. History page — how it loads/reads data
cat path/to/cashier/history.php
```

### 2. Trace a complete order lifecycle

**Order created (processOrder):**
- Creates DOM element via `createHistoryItem()` → stores `htmlContent`, `plainText`, `total`, `customerName`, `customerAddress`, `notes` as `data-*` attributes on the element
- Appends to `historyContainer`
- Calls `saveData()` which serializes innerHTML → localStorage + `api.php?action=save_state`

**Order moved to finished (moveToFinished):**
- Moves DOM element to `finishedContainer`
- Calls `saveData()`
- Fires `fetch(api.php?action=save_finished_order)` with order data
- **Common bug**: The JS often reads `item.querySelector('.customer-name')?.textContent` instead of `item.dataset.customerName`. The `.customer-name` class may not exist in the HTML. Always use `item.dataset.*` for data attributes.

**Order deleted (removeHistory):**
- Calls `reportAdminAction()` (which fires `report_deleted_order` API)
- Calls `archiveDeletedItem()` which saves to localStorage + fires `report_deleted_order` API
- Both may fire — check for double-save

### 3. Common Persistence Bugs

| Bug | Symptom | Fix |
|-----|---------|-----|
| `moveToFinished` uses `querySelector` for name/address | name/address saved as empty strings | Use `item.dataset.customerName` and `item.dataset.customerAddress` |
| `moveToFinished` omits `plainText`/`htmlContent` | Receipt data missing in DB | Add `plainText: item.dataset.plainText, htmlContent: item.dataset.htmlContent` to the API body |
| `save_finished_order` in api.php doesn't save `html_content` | History shows "No receipt data available" | Update the INSERT query to include `html_content` and `plain_text` columns |
| Only localStorage has data, SQLite tables are empty | Works on one browser, fails on another | Check that ALL mutations (create, finish, delete) fire a server API call, not just saveData() |
| `app_state` table has data but `finished_orders` doesn't | saveData() works but finish/delete callbacks don't fire | The `app_state` table stores raw HTML snapshots (used by loadData for cross-tab sync). The `finished_orders` table stores structured order records. They serve different purposes. |
| `history.php` loads from localStorage first, then falls back to DB | If localStorage has stale data, it overrides the server | Clear localStorage or deploy fix that forces server-side reads |

### 4. The Fix Pattern

```javascript
// BEFORE (broken — name/address via querySelector, no plainText/htmlContent)
function moveToFinished(id) {
    const item = document.getElementById(`hist-${id}`);
    const name = item.querySelector('.customer-name')?.textContent || '';
    const address = item.querySelector('.address')?.textContent || '';
    fetch('./api.php?action=save_finished_order', {
        method: 'POST',
        body: JSON.stringify({orderNo, customerName: name, address, total, isAba})
    });
}

// AFTER (fixed — uses dataset, includes all fields)
function moveToFinished(id) {
    const item = document.getElementById(`hist-${id}`);
    const name = item.dataset.customerName || '';
    const address = item.dataset.customerAddress || '';
    const plainText = item.dataset.plainText || '';
    const htmlContent = item.dataset.htmlContent || '';
    fetch('./api.php?action=save_finished_order', {
        method: 'POST',
        body: JSON.stringify({
            orderNo, customerName: name, address, total, isAba,
            plainText, htmlContent
        })
    });
}
```

### 5. Verification

```bash
# After deploying the fix, create → finish an order, then check the DB
sqlite3 path/to/cashier/database.db "SELECT order_no, customer_name, total, length(plain_text), length(html_content) FROM finished_orders ORDER BY id DESC LIMIT 5;"
```

Expected: `customer_name` is populated, `length(plain_text)` > 0, `length(html_content)` > 0.

Also verify that `history.php` shows the receipt data when localStorage is cleared or on a different browser.
