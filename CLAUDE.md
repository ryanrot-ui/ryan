# Luxury Restaurant Demo Site — Design System & Build Guide

This repo is a reusable template for selling luxury restaurant demo websites.
Drop this file into a new project and Claude will build the same quality site for any restaurant.

---

## What this site is

A single-page static site (HTML + CSS + JS, no framework, no build step).
Deploys instantly via GitHub Pages.
Bilingual JP/EN with a language toggle.
All interactions are pure CSS/JS — no dependencies except Font Awesome and Google Fonts.

---

## File structure

```
index.html       — full site, one page
css/style.css    — all styles, ~1500 lines
js/main.js       — all interactions + full JP/EN translation array
```

---

## Design system

### Palette — dark luxury

```css
--bg:        #080604   /* near-black warm charcoal — page background */
--bg2:       #0f0c08   /* slightly lighter — alternate sections */
--bg3:       #171310   /* card hover state */
--bg4:       #1f1a13
--bg5:       #27211a

--gold:      #b8893a   /* primary accent — all gold elements */
--gold-lt:   #d4a85e   /* lighter gold — gradients, highlights */
--gold-dim:  rgba(184,137,58,0.08)   /* tinted backgrounds */
--gold-dim2: rgba(184,137,58,0.18)

--text:      #ede5d8   /* primary text — headings, important content */
--text2:     #a09080   /* secondary text — body copy */
--text3:     #5e5448   /* tertiary text — labels, captions, placeholders */

--border:    rgba(184,137,58,0.10)   /* subtle dividers */
--border-h:  rgba(184,137,58,0.30)   /* hover/active borders */
```

### Typography

```css
--serif: 'Cormorant Garamond', 'Noto Serif JP', Georgia, serif
--sans:  'DM Sans', 'Noto Sans JP', system-ui, sans-serif
```

Google Fonts import (paste in `<head>`):
```html
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;1,300;1,400&family=DM+Sans:wght@300;400;500&family=Noto+Sans+JP:wght@300;400;500&family=Noto+Serif+JP:wght@300;400;500&display=swap" rel="stylesheet">
```

Font Awesome (free CDN, paste in `<head>`):
```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
```

### Spacing

```css
--section: 140px   /* section top/bottom padding (100px @1100px, 80px @768px) */
--radius:  2px     /* border radius — intentionally near-square for luxury feel */
--ease:     cubic-bezier(0.25, 0.46, 0.45, 0.94)
--ease-out: cubic-bezier(0.16, 1, 0.3, 1)
```

---

## Site sections (in order)

1. **Navbar** — fixed, blurs on scroll, logo left + nav links + [lang toggle + hamburger] right
2. **Hero** — full-viewport, parallax bg, animated text entrance, scroll indicator
3. **Highlights** — 4-column grid of signature features (numbered cards)
4. **Menu** — tabbed (6 tabs), card grid with images + list view, CTA box
5. **About** — 2-col layout: overlapping images left, text + values right
6. **Gallery** — 12-col CSS grid masonry, 6 images, hover overlay
7. **Reviews** — 3 Google review cards, stars + rating tags + author
8. **Reservation** — split layout: info left, form right
9. **Contact** — 3 icon cards (address, phone, Instagram) + Google Maps embed
10. **Footer** — 4-col grid: brand, nav links ×2, social

---

## Key CSS patterns

### Reveal animations
Apply these classes to any element to animate it in on scroll:
```
.reveal          — fade up from 36px below (most elements)
.reveal-left     — fade in from left
.reveal-right    — fade in from right
.reveal-scale    — fade up + scale(0.97) (section headers)
.reveal-slow     — slower ambient fade (decorative elements)
.d1 .d2 .d3 .d4 .d5  — stagger delay utilities (0.08s increments)
```
JS uses `IntersectionObserver` at `threshold: 0.08` to trigger `.visible` class.

### Buttons
```html
<a href="#" class="btn btn-primary">Primary Gold</a>
<a href="#" class="btn btn-outline">Outline</a>
<a href="#" class="btn btn-primary btn-full">Full Width</a>
```

### Section header pattern
```html
<div class="section-header reveal-scale">
  <span class="section-tag">LABEL</span>  <!-- gold, uppercase, has ornament line -->
  <h2>Heading</h2>
  <p>Optional intro text</p>
</div>
```

### Menu list item (drinks / small plates)
```html
<div class="menu-list-item">
  <span>Item Name</span>
  <span class="price">¥1,000</span>
</div>
```
Has a gold left-bar `::before` that slides in on hover.

### Menu card item (with image)
```html
<div class="menu-item reveal">
  <div class="menu-item-img"><img src="..." alt="..." loading="lazy"/></div>
  <div class="menu-item-info">
    <div class="menu-item-header">
      <h4>Dish Name</h4>
      <span class="price">¥1,800</span>
    </div>
    <p>Description</p>
    <span class="tag">TAG</span>
  </div>
</div>
```

### Testimonial / Review card
```html
<div class="testimonial-card reveal">
  <div class="stars">★★★★★</div>
  <div class="review-ratings"><span>Food 5/5</span><span>Service 5/5</span></div>
  <p>Quote text here.</p>
  <div class="testimonial-author">
    <div class="author-avatar"><i class="fab fa-google"></i></div>
    <div><strong>Name</strong><span>Google Review · Visited</span></div>
  </div>
</div>
```
Give each translatable element an ID (e.g. `id="rv1-text"`) for the bilingual system.

---

## Bilingual JP/EN system

All translations live in `js/main.js` in a single array `t`:
```javascript
const t = [
  ['#css-selector', 'Japanese text', 'English text'],
  // ... one entry per translatable element
];
```

`applyLang(lang)` loops through `t` with `document.querySelector(sel)` and sets `el.innerHTML`.

Special cases handled separately inside `applyLang`:
- Hours spans (complex nested structure)
- Form placeholders (`el.placeholder`)
- Time select option (`option[value=""]`)
- Language toggle button label

The toggle button reads/writes `localStorage` key `cocha-lang` and sets `data-lang` attribute on `<html>`.

**To add a new translatable element:**
1. Give it a unique `id` in the HTML
2. Add `['#that-id', 'Japanese', 'English']` to the `t` array in `main.js`

**To skip translation for an element**, just don't add it to `t`. It stays in Japanese.

---

## JS features overview

| Feature | Where | Notes |
|---|---|---|
| Navbar blur on scroll | top of main.js | triggers at 60px |
| Gold scroll progress bar | top scroll handler | `#scrollProgress` |
| Mobile menu (iOS-safe) | lockScroll / unlockScroll | position:fixed trick |
| Active nav link | scroll handler | matches `section[id]` |
| Sliding tab indicator | `moveTabIndicator()` | measures `offsetLeft/Width` |
| Tab panel fade animation | CSS `@keyframes tabReveal` | plays on `.tab-panel.active` |
| Scroll reveal | `IntersectionObserver` | threshold 0.08, 100ms stagger |
| Hero parallax | scroll handler (desktop only) | 0.3× scroll speed |
| Reservation form | submit handler | 4s success state |
| Scroll-to-top button | scroll handler | shows after 600px |
| Language toggle | `applyLang()` + click handler | localStorage persistence |

---

## What to change for a new restaurant

### Required
- [ ] Restaurant name (nav logo, hero, page title, footer)
- [ ] Tagline / hero subtitle
- [ ] Hero background image URL (`.hero-bg` background-image in CSS or inline style)
- [ ] All menu items, prices, descriptions (in HTML + in `t` array for EN translations)
- [ ] Address, phone number, Instagram handle
- [ ] Google Maps embed URL (lat/lng in `src`)
- [ ] Review card content (names, text, ratings) + IDs `rv1-*`, `rv2-*`, `rv3-*`
- [ ] About section text + stats (e.g. `4.9 ★ / 287件`)
- [ ] All page `<title>` and meta description tags
- [ ] Cuisine type in highlights + About section

### Optional
- [ ] Swap `--gold: #b8893a` to a different accent color (e.g. `#c0392b` for red, `#2980b9` for blue)
- [ ] Change section count (can remove tabs/sections freely)
- [ ] Add/remove gallery images
- [ ] Adjust `--section` spacing for denser/airier layouts
- [ ] Swap serif font (Cormorant Garamond → Playfair Display, etc.)

### Keep as-is
- All CSS variables (just change values)
- All JS interaction code
- The bilingual system structure (just refill the `t` array)
- All animation classes (`.reveal`, `.reveal-scale`, etc.)

---

## Gallery image grid

The 12-column CSS grid layout:
```css
.gallery-item:nth-child(1) { grid-column: 1 / span 5;  grid-row: 1; }  /* wide */
.gallery-item:nth-child(2) { grid-column: 6 / span 4;  grid-row: 1; }  /* medium */
.gallery-item:nth-child(3) { grid-column: 10 / span 3; grid-row: 1; }  /* narrow */
.gallery-item:nth-child(4) { grid-column: 1 / span 3;  grid-row: 2; }  /* narrow */
.gallery-item:nth-child(5) { grid-column: 4 / span 5;  grid-row: 2; }  /* wide */
.gallery-item:nth-child(6) { grid-column: 9 / span 4;  grid-row: 2; }  /* medium */
```
Collapses to 2-col at 1100px, 1-col at 480px automatically.

---

## Deployment

GitHub Pages: set source branch to the working branch in repo Settings → Pages.
No build step needed. Push HTML/CSS/JS directly.
Live URL: `https://[org].github.io/[repo]`

---

## Quality checklist before presenting to client

- [ ] Hard-refresh the page (Ctrl+Shift+R) to clear cache after each push
- [ ] Test language toggle — ALL text should switch, including menu items and reviews
- [ ] Test on mobile (375px) — nav, form, gallery should all reflow cleanly
- [ ] Test reservation form submit — success state + 4s reset
- [ ] Verify address format is correct Japanese style (e.g. 新宿区百人町1-8-10)
- [ ] Verify Instagram URL opens correctly
- [ ] Verify Google Maps embed shows correct location
- [ ] Check all menu prices are in ¥ format with commas for thousands (¥1,500 not ¥1500)
