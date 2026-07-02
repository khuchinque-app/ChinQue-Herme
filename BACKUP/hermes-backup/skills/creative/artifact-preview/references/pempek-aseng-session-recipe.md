# Pempek Aseng Storefront — Full Session Recipe

**Date:** 2026-07-02
**Model:** deepseek/deepseek-v4-flash
**Provider:** nous

## Tasks in This Session

1. Logo revision (brand card HTML + screenshot)
2. Full storefront build (abandoned — user wanted edits, not rebuild)
3. Modify existing tittil.cloud/aseng storefront (the real task)

## Key Lessons — URL Delivery

The user is on the same VPS and CAN access served ports, BUT:
- **ALWAYS check UFW first** — `sudo ufw status verbose`. If the port isn't listed, add it: `sudo ufw allow <PORT>/tcp`
- **ALWAYS verify external access** — `curl http://<PUBLIC_IP>:<PORT>/<PATH>` must return 200
- **ALWAYS take a real browser screenshot** as proof before sending the URL
- **ALWAYS give the FULL URL** — `http://187.127.178.20:8888/path` — never partial
- If there's already a deployed site (tittil.cloud with nginx+PHP), use that — don't spin up random ports

The user's explicit instruction (priority 1):
> "before you give me the url YOU MUST web search first! screenshot that real life then sent to me complete url and the screen shot as report"

## Key Lessons — Modifying Existing Storefronts

When the user says "revise" or "modify" an existing site:
1. **DO NOT build a new page** — find and edit the existing code
2. Locate the project root (check running processes: `ps aux | grep php`)
3. The existing storefront at tittil.cloud/aseng lives at `/home/khuchinque/barang-pindahan/restaurat-ordering-php/aseng/`
4. It's served by PHP dev server on port 7500, reverse-proxied by nginx
5. `index.html` and `index.php` must stay in sync (they're identical copies)

## Edits Applied to Existing Site

| Edit | Detail |
|---|---|
| **Emoji → Logo** | All 9 emoji icons (🍜 🛵 🍔 🥟 🧋 🛒 👤 🎉 👋) replaced with brand logo as icon |
| **Greeting** | "Hi Zesan" → "hai customer" |
| **Delivery text** | "Free Delivery" → "Delivery" (removed "free") |
| **Hero badge** | 🍜 emoji → logo img inline |
| **Category bar** | All 4 category emoji → logo img |
| **Empty cart** | 🛒 → logo img |
| **Order confirm** | "Order Received! 🎉" → "Order Received!" |
| **Chat widget** | Fallback emoji + welcome 👋 removed |
| **Avatar fallback** | 👤 → logo img |

## Logo-as-Image Pattern

When replacing emoji/icon with the brand logo as universal icon:

```html
<img src="assets/logo.png" alt="" style="width:20px;height:20px;border-radius:50%;object-fit:cover">
```

Use consistent sizing per context:
- Nav/header: 36px
- Menu cards: 44px
- Category bar: 20px
- Contact/delivery: 40-48px
- Delivery banner: 22px
- Hero badge inline: 16px

## The "hai customer" Greeting (User Preference)

The user explicitly prefers "hai customer" as the storefront greeting. This is not a per-session choice — encode it.

## Infrastructure

- **Domain:** tittil.cloud → nginx → proxy_pass to 127.0.0.1:7500
- **PHP server:** `php -S 0.0.0.0:7500 -t . router.php` running from `/home/khuchinque/barang-pindahan/restaurat-ordering-php/`
- **Router:** Custom router.php serves static files + index.php/index.html for directories
- **Aseng path:** `/aseng/` serves from subdirectory with its own index.html + assets/
- **UFW:** Ports 22, 80, 443, 8443, 8642, 8888 (for dev) open
