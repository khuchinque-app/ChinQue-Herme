# PHP Restaurant Site — Menu Image Wiring + Cart Footer Fix

Wiring actual food photos into a PHP/SQLite restaurant ordering system where menu items have `image: null` in the DB. Applicable to sites with a `MenuItem` SQLite table, JS-rendered menu grid, and shared `style.css` across sibling sites.

## The Pattern

1. **Check what exists** — photos may already be in `assets/images/pempek/` or `asset-img/` but never wired to the DB
2. **Find the DB** — `data/restaurant.db` with `MenuItem` table having an `image` TEXT column
3. **Map images by category** — write category-based SQL UPDATEs that assign image paths based on the item's category name (Pempek, Pcs, Mains, Sides, Drinks)
4. **Cycle through available images** — if 3 pempek photos for 22 pempek items, distribute them: pempek_01.jpg → first group, pempek_02.jpg → second, pempek_03.jpg → rest
5. **Verify** — refresh site, check menu cards now show food photos instead of 🍲 placeholder

## SQL Pattern

```sql
-- Get all items for a restaurant with their categories
SELECT mi.id, mi.name, c.name as category, mi.image 
FROM MenuItem mi
JOIN Category c ON mi.categoryId = c.id
JOIN Restaurant r ON mi.restaurantId = r.id
WHERE r.slug = 'aseng'
ORDER BY c.name, mi.name;

-- Assign images by category
UPDATE MenuItem SET image='assets/images/pempek/pempek_01.jpg', updatedAt=datetime('now')
WHERE id IN (
  SELECT mi.id FROM MenuItem mi
  JOIN Category c ON mi.categoryId = c.id
  JOIN Restaurant r ON mi.restaurantId = r.id
  WHERE r.slug = 'aseng' AND c.name = 'Pempek'
  AND mi.name LIKE 'Adaan%'
);
```

## Image Directory Layout

```
restaurant/
├── assets/
│   └── images/
│       └── pempek/
│           ├── pempek_01.jpg    # Pempek category items
│           ├── pempek_02.jpg
│           ├── pempek_03.jpg
│           ├── drink_01.jpg     # Drinks category items
│           ├── mains_01.jpg     # Mains category items
│           ├── mains_02.jpg
│           ├── mains_03.jpg
│           ├── siomay_01.jpg    # Sides category items
│           └── soup_01.jpg      # Soup/Mains items
└── asset-img/                   # Alternative image dir (foodpanda-style exports)
    ├── fp_3930xxx.jpg           # High-res food photos
    └── logo_foodpanda.jpg
```

## Cart Footer Button Positioning Fix

When the cart drawer's "Order Now" button sits too low, blocking or being blocked by form fields and the Telegram link:

### Fix: Tighten Footer Spacing

```css
/* Reduce footer padding */
.drawer-footer {
  padding: 0.75rem 1.25rem 0.85rem;   /* was 1.25rem all sides */
}

/* Tighter form groups */
.form-group {
  margin-bottom: 0.45rem;              /* was 0.75rem */
}

/* Tighter Telegram link */
.telegram-link {
  margin-bottom: 0.35rem;              /* was 0.5rem */
}
```

### Applying to Sibling Sites

If both sites (e.g. Aseng + Tittil) use identical `style.css` files:
```bash
diff site1/assets/style.css site2/assets/style.css  # verify identical
cp site1/assets/style.css site2/assets/style.css     # copy fix
```

No changes needed in `theme.css` — theme files only override colors/backgrounds, not padding/margin.
