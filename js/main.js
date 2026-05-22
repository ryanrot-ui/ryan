/* Cocha Korean Restaurant — Main JS */

const isTouch = window.matchMedia('(hover: none)').matches;

// Navbar scroll effect
const navbar = document.getElementById('navbar');
window.addEventListener('scroll', () => {
  navbar.classList.toggle('scrolled', window.scrollY > 60);
}, { passive: true });

// Mobile menu — iOS-safe scroll lock
const hamburger = document.getElementById('hamburger');
const navLinks  = document.getElementById('navLinks');

function lockScroll() {
  const scrollY = window.scrollY;
  document.body.style.position = 'fixed';
  document.body.style.top      = `-${scrollY}px`;
  document.body.style.width    = '100%';
  document.body.style.overflow = 'hidden';
}
function unlockScroll() {
  const scrollY = -parseInt(document.body.style.top || '0', 10);
  document.body.style.position = '';
  document.body.style.top      = '';
  document.body.style.width    = '';
  document.body.style.overflow = '';
  window.scrollTo(0, scrollY);
}

hamburger.addEventListener('click', () => {
  hamburger.classList.toggle('open');
  navLinks.classList.toggle('open');
  navLinks.classList.contains('open') ? lockScroll() : unlockScroll();
});
navLinks.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', () => {
    hamburger.classList.remove('open');
    navLinks.classList.remove('open');
    unlockScroll();
  });
});

// Active nav link on scroll
const sections = document.querySelectorAll('section[id]');
const navItems  = document.querySelectorAll('.nav-link');
window.addEventListener('scroll', () => {
  let current = '';
  sections.forEach(s => {
    if (window.scrollY >= s.offsetTop - 120) current = s.getAttribute('id');
  });
  navItems.forEach(link => {
    link.classList.toggle('active', link.getAttribute('href') === '#' + current);
  });
}, { passive: true });

// Menu tabs
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    const tab = btn.dataset.tab;
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById('tab-' + tab).classList.add('active');
    document.querySelectorAll('#tab-' + tab + ' .reveal').forEach(el => {
      el.classList.remove('visible');
      setTimeout(() => observer.observe(el), 10);
    });
  });
});

// Scroll reveal
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry, i) => {
    if (entry.isIntersecting) {
      setTimeout(() => entry.target.classList.add('visible'), i * 100);
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.08 });
document.querySelectorAll('.reveal, .reveal-left, .reveal-right, .reveal-scale, .reveal-slow')
  .forEach(el => observer.observe(el));

// Reservation form
const form = document.getElementById('reservationForm');
if (form) {
  const dateInput = document.getElementById('resDate');
  if (dateInput) {
    const today = new Date().toISOString().split('T')[0];
    dateInput.setAttribute('min', today);
  }
  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const btn = form.querySelector('button[type="submit"]');
    const isEn = document.documentElement.getAttribute('data-lang') === 'en';
    btn.textContent = isEn ? 'Reservation Confirmed ✓' : 'ご予約を受け付けました ✓';
    btn.style.background = '#2ecc71';
    btn.disabled = true;
    setTimeout(() => {
      btn.textContent = isEn ? 'Confirm Reservation' : '予約を確定する';
      btn.style.background = '';
      btn.disabled = false;
      form.reset();
    }, 4000);
  });
}

// Parallax on hero — desktop only (avoids jank on iOS)
if (!isTouch) {
  const heroBg = document.querySelector('.hero-bg');
  window.addEventListener('scroll', () => {
    if (heroBg && window.scrollY < window.innerHeight) {
      heroBg.style.transform = `translateY(${window.scrollY * 0.3}px)`;
    }
  }, { passive: true });
}

// Custom cursor — desktop only
if (!isTouch) {
  const cursor    = document.getElementById('cursor');
  const cursorDot = document.getElementById('cursorDot');
  if (cursor && cursorDot) {
    let mouseX = 0, mouseY = 0, cursorX = 0, cursorY = 0;

    document.addEventListener('mousemove', e => {
      mouseX = e.clientX;
      mouseY = e.clientY;
      cursorDot.style.left = mouseX + 'px';
      cursorDot.style.top  = mouseY + 'px';
    });

    (function animateCursor() {
      cursorX += (mouseX - cursorX) * 0.10;
      cursorY += (mouseY - cursorY) * 0.10;
      cursor.style.left = cursorX + 'px';
      cursor.style.top  = cursorY + 'px';
      requestAnimationFrame(animateCursor);
    })();

    document.querySelectorAll('a, button, .menu-item, .gallery-item, .highlight-card, .tab-btn').forEach(el => {
      el.addEventListener('mouseenter', () => { cursor.classList.add('hover');    cursorDot.classList.add('hover'); });
      el.addEventListener('mouseleave', () => { cursor.classList.remove('hover'); cursorDot.classList.remove('hover'); });
    });

    document.addEventListener('mouseleave', () => { cursor.style.opacity = '0'; cursorDot.style.opacity = '0'; });
    document.addEventListener('mouseenter', () => { cursor.style.opacity = '1'; cursorDot.style.opacity = '1'; });
  }
}

// Stagger delays for grid items
document.querySelectorAll('.highlights-grid, .gallery-grid, .menu-grid, .testimonials-grid').forEach(grid => {
  grid.querySelectorAll('.reveal, .reveal-scale').forEach((el, i) => {
    el.style.transitionDelay = (i * 0.10) + 's';
  });
});

// =====================
// LANGUAGE TOGGLE
// =====================
const t = [
  // Nav
  ['#navLinks li:nth-child(1) a', 'トップ', 'Home'],
  ['#navLinks li:nth-child(2) a', 'メニュー', 'Menu'],
  ['#navLinks li:nth-child(3) a', '店舗紹介', 'About'],
  ['#navLinks li:nth-child(4) a', 'アクセス', 'Access'],
  ['#navLinks li:nth-child(5) a', 'ご予約', 'Reserve'],
  // Hero
  ['.hero-tagline', '新大久保 — 韓国中国融合料理', 'Shin-Okubo, Tokyo — Korean &amp; Chinese Fusion'],
  ['.hero-title-sub', 'コチャ', 'Cocha'],
  ['.hero-subtitle', 'わら焼き、ナッコプセ、マーラーしゃぶ。<br>飲んで、食べて、語り合う夜をここで。', 'Straw-smoked pork, nakkopsae, maala shabu-shabu.<br>Drink, eat, and linger into the night.'],
  ['.hero-ctas a:nth-child(1)', 'ご予約はこちら', 'Make a Reservation'],
  ['.hero-ctas a:nth-child(2)', 'メニューを見る', 'View Menu'],
  ['.hero-badges .badge:nth-child(1) span:last-child', '飲み放題あり', 'All-You-Can-Drink'],
  ['.hero-badges .badge:nth-child(2) span:last-child', 'QRオーダー', 'QR Ordering'],
  // Highlights
  ['.highlight-card:nth-child(1) h3', 'わら焼きサムギョプサル', 'Straw-Smoked Samgyeopsal'],
  ['.highlight-card:nth-child(1) p', '藁の香りをまとわせた豚バラを鉄板で焼き上げる、COCHAでしか味わえない一皿。きのこ・もやし・炒めキムチと共にどうぞ。', 'Pork belly infused with straw smoke, seared on a cast-iron griddle — a dish only COCHA can offer. Served with mushrooms, bean sprouts, and stir-fried kimchi.'],
  ['.highlight-card:nth-child(2) h3', 'ナッコプセ', 'Nakkopsae'],
  ['.highlight-card:nth-child(2) p', 'タコ・コプチャン・エビを旨辛ダレで煮込む韓国の定番鍋料理。専用ライスと一緒に、最後の一滴まで楽しめます。', 'Octopus, beef tripe, and shrimp braised in a spicy sauce — a beloved Korean hot pot. Enjoy every last drop with the signature rice.'],
  ['.highlight-card:nth-child(3) h3', 'UFOマーラーしゃぶ', 'UFO Maala Shabu-Shabu'],
  ['.highlight-card:nth-child(3) p', '花びら状に並べた肉を、しびれる麻辣スープでしゃぶしゃぶ。ピーナッツダレをつけると、また違う旨みが広がります。', 'Petal-arranged meat swirled in a numbing maala broth. Dip in peanut sauce for a whole new dimension of flavour.'],
  ['.highlight-card:nth-child(4) h3', '充実のドリンク', 'Drinks'],
  ['.highlight-card:nth-child(4) p', 'チャミスル・マッコリ・生サワー・ハイボール・プレミアムウイスキーまで幅広く取り揃え。飲み放題コースは¥1,500〜。サムギョプサルSET込みで¥4,299/人。', 'Chamisul, makgeolli, fresh sours, highballs, and premium whisky. All-you-can-drink courses from ¥1,500. Samgyeopsal set with drinks from ¥4,299/person.'],
  // Menu header + tabs
  ['#menu .section-header .section-tag', 'MENU', 'MENU'],
  ['#menu .section-header h2', 'メニュー', 'Menu'],
  ['#menu .section-header p', 'ランチセットからディナーまで、韓国と中国の味が一つのテーブルに。', 'From lunch sets to late-night dining — Korean and Chinese flavours at one table.'],
  ['.menu-tabs .tab-btn:nth-child(1)', 'おすすめ', 'Signature'],
  ['.menu-tabs .tab-btn:nth-child(2)', 'ランチセット', 'Lunch Sets'],
  ['.menu-tabs .tab-btn:nth-child(3)', '一品料理', 'À la Carte'],
  ['.menu-tabs .tab-btn:nth-child(4)', 'ドリンク', 'Drinks'],
  ['.menu-tabs .tab-btn:nth-child(5)', 'デザート', 'Desserts'],
  ['.menu-tabs .tab-btn:nth-child(6)', '飲み放題', 'All-You-Can-Drink'],
  ['.menu-cta p', 'メインには全8種のおかず（バンチャン）が付きます。テーブルでのQRオーダーで、スムーズにご注文いただけます。', 'All mains include 8 kinds of banchan (Korean side dishes). Order conveniently via QR code at your table.'],
  ['.menu-cta .btn', 'ご予約はこちら', 'Make a Reservation'],
  // About
  ['#about .section-tag', 'ABOUT', 'ABOUT'],
  ['#about .about-content h2', 'COCHAについて', 'About COCHA'],
  ['.about-lead', '新大久保に新しい味わいを。韓国料理と中国料理の融合──それがCOCHAのスタイルです。', 'A new flavour for Shin-Okubo. Korean cuisine meets Chinese cuisine — that is the COCHA way.'],
  ['.about-content > p:nth-child(4)', '藁で燻したサムギョプサル、しびれるマーラーしゃぶしゃぶ、鮮度抜群のナッコプセ。どれも、ここでしか食べられない一皿です。おかず8種・QRオーダー・飲み放題コースも充実。グループでのお食事・飲み会・記念日にも、ぜひご利用ください。', 'Straw-smoked samgyeopsal, tingling maala shabu-shabu, ultra-fresh nakkopsae — every dish is exclusive to COCHA. 8-dish banchan, QR ordering, and all-you-can-drink courses. Perfect for groups, parties, and celebrations.'],
  ['.about-values .value:nth-child(1) span', '韓国中国融合料理', 'Korean-Chinese fusion cuisine'],
  ['.about-values .value:nth-child(2) span', 'わら焼きサムギョプサル', 'Straw-smoked samgyeopsal'],
  ['.about-values .value:nth-child(3) span', '飲み放題コースあり', 'All-you-can-drink courses available'],
  ['.about-values .value:nth-child(4) span', 'QRコードで簡単注文', 'Easy QR code ordering'],
  ['.about-values .value:nth-child(5) span', 'K-POPだけじゃない、いい音楽', 'Good music beyond just K-POP'],
  ['.about-content .btn', 'ご予約はこちら', 'Make a Reservation'],
  // Gallery
  ['.gallery-section .section-tag', 'GALLERY', 'GALLERY'],
  ['.gallery-section h2', '料理ギャラリー', 'Gallery'],
  ['.gallery-item:nth-child(1) .gallery-overlay span', 'ナッコプセ', 'Nakkopsae'],
  ['.gallery-item:nth-child(1) .gallery-overlay em', 'タコ · コプチャン · エビ', 'Octopus · Tripe · Shrimp'],
  ['.gallery-item:nth-child(2) .gallery-overlay span', '店内', 'Interior'],
  ['.gallery-item:nth-child(2) .gallery-overlay em', '新大久保 · 東京', 'Shin-Okubo · Tokyo'],
  ['.gallery-item:nth-child(3) .gallery-overlay span', 'ユッケ', 'Yukhoe'],
  ['.gallery-item:nth-child(3) .gallery-overlay em', '生牛肉 · 卵黄 · アボカド', 'Raw beef · Egg yolk · Avocado'],
  ['.gallery-item:nth-child(4) .gallery-overlay span', 'わら焼きサムギョプサル', 'Straw-Smoked Samgyeopsal'],
  ['.gallery-item:nth-child(4) .gallery-overlay em', 'COCHA名物', 'COCHA Signature'],
  ['.gallery-item:nth-child(5) .gallery-overlay span', 'ティラミスビンス', 'Tiramisu Bingsu'],
  ['.gallery-item:nth-child(5) .gallery-overlay em', 'オリジナルデザート', 'COCHA Original Dessert'],
  ['.gallery-item:nth-child(6) .gallery-overlay span', 'チャミスル・生サワー', 'Chamisul &amp; Fresh Sours'],
  ['.gallery-item:nth-child(6) .gallery-overlay em', '韓国酒各種', 'Korean spirits selection'],
  // Reviews
  ['.testimonials-section .section-tag', 'REVIEWS', 'REVIEWS'],
  ['.testimonials-section h2', 'お客様の声', 'Guest Reviews'],
  // Reservation
  ['#reservation .section-tag', 'RESERVATION', 'RESERVATION'],
  ['#reservation .reservation-info h2', 'ご予約', 'Reservations'],
  ['#reservation .reservation-info > p', 'ご予約はフォームまたはお電話にて承ります。当日のお席は空き状況によりご案内いたします。', 'Reserve via the form or by phone. Walk-ins are welcome subject to availability.'],
  ['.info-items .info-item:nth-child(2) strong', '電話', 'Phone'],
  ['.info-items .info-item:nth-child(3) strong', '住所', 'Address'],
  ['label[for="firstName"]', 'お名前（姓）', 'Last Name'],
  ['label[for="lastName"]', 'お名前（名）', 'First Name'],
  ['label[for="resDate"]', 'ご来店日', 'Visit Date'],
  ['label[for="resTime"]', 'ご来店時間', 'Visit Time'],
  ['label[for="guests"]', '人数', 'Party Size'],
  ['label[for="phone"]', '電話番号', 'Phone Number'],
  ['label[for="notes"]', 'ご要望・アレルギー等', 'Requests &amp; Allergies'],
  ['#reservationForm button[type="submit"]', '予約を確定する', 'Confirm Reservation'],
  // Contact
  ['#contact .section-tag', 'ACCESS', 'ACCESS'],
  ['#contact h2', 'アクセス', 'Access'],
  ['.contact-grid .contact-card:nth-child(1) h4', '住所', 'Address'],
  ['.contact-grid .contact-card:nth-child(1) .link', '地図を開く', 'Open Map'],
  ['.contact-grid .contact-card:nth-child(2) h4', '電話', 'Phone'],
  ['.contact-grid .contact-card:nth-child(2) .link', '電話をかける', 'Call Us'],
  ['.contact-grid .contact-card:nth-child(3) h4', 'Instagram', 'Instagram'],
  ['.contact-grid .contact-card:nth-child(3) p', '最新情報・新メニュー・<br>キャンペーンはこちらから。', 'Latest news, new dishes,<br>and campaigns.'],
  ['.contact-grid .contact-card:nth-child(3) .link', 'フォローする @cocha_shinjuku', 'Follow @cocha_shinjuku'],
  // Footer
  ['.footer-brand p', '新大久保の韓国中国融合料理。<br>わら焼き、鍋、マーラー、飲み放題。', 'Korean-Chinese fusion in Shin-Okubo.<br>Straw-smoked BBQ, hot pot, maala, and more.'],
  ['.footer-grid > :nth-child(2) h5', 'ページ', 'Pages'],
  ['.footer-grid > :nth-child(3) h5', '営業時間', 'Opening Hours'],
  ['.footer-social h5', 'フォローする', 'Follow Us'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(1) a', 'トップ', 'Home'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(2) a', 'メニュー', 'Menu'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(3) a', '店舗紹介', 'About'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(4) a', 'ご予約', 'Reserve'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(5) a', 'アクセス', 'Access'],
  ['.footer-grid > :nth-child(3) ul li:nth-child(1)', '月〜木・日 10:00〜翌1:00', 'Mon–Thu &amp; Sun  10:00–1:00'],
  ['.footer-grid > :nth-child(3) ul li:nth-child(2)', '金・土 10:00〜翌5:00', 'Fri–Sat  10:00–5:00'],
  ['.footer-bottom p', '© 2026 COCHA — コチャ 新大久保. All rights reserved.', '© 2026 COCHA — Shin-Okubo, Tokyo. All rights reserved.'],
];

function applyLang(lang) {
  t.forEach(([sel, ja, en]) => {
    const el = document.querySelector(sel);
    if (el) el.innerHTML = lang === 'en' ? en : ja;
  });

  // Hours spans (complex structure — handle separately)
  const hourSpans = document.querySelectorAll('.info-items .info-item:first-child div span');
  if (hourSpans[0]) hourSpans[0].textContent = lang === 'en' ? 'Mon–Thu & Sun  10:00–1:00 (L.O. 0:00)' : '月〜木・日 10:00〜翌1:00（L.O. 翌0:00）';
  if (hourSpans[1]) hourSpans[1].textContent = lang === 'en' ? 'Fri–Sat  10:00–5:00 (L.O. 4:00)' : '金・土 10:00〜翌5:00（L.O. 翌4:00）';

  // Hours label
  const hoursLabel = document.querySelector('.info-items .info-item:first-child strong');
  if (hoursLabel) hoursLabel.textContent = lang === 'en' ? 'Opening Hours' : '営業時間';

  // Placeholders
  const phs = {
    firstName: ['山田', 'Yamada'],
    lastName:  ['太郎', 'Taro'],
    notes:     ['アレルギー、記念日のご利用、お席のご希望など', 'Allergies, special occasions, seating preferences, etc.'],
  };
  Object.entries(phs).forEach(([id, [ja, en]]) => {
    const el = document.getElementById(id);
    if (el) el.placeholder = lang === 'en' ? en : ja;
  });

  // Time select first option
  const timeOpt = document.querySelector('#resTime option[value=""]');
  if (timeOpt) timeOpt.textContent = lang === 'en' ? 'Select a time' : '時間を選ぶ';

  // Toggle button label
  const toggle = document.getElementById('langToggle');
  if (toggle) {
    toggle.textContent = lang === 'en' ? 'JA' : 'EN';
    toggle.setAttribute('aria-label', lang === 'en' ? '日本語に切り替え' : 'Switch to English');
  }

  document.documentElement.setAttribute('data-lang', lang);
  localStorage.setItem('cocha-lang', lang);
}

const langToggleBtn = document.getElementById('langToggle');
if (langToggleBtn) {
  langToggleBtn.addEventListener('click', () => {
    applyLang(document.documentElement.getAttribute('data-lang') === 'en' ? 'ja' : 'en');
  });
}

// Restore saved language preference
const savedLang = localStorage.getItem('cocha-lang');
if (savedLang === 'en') applyLang('en');
