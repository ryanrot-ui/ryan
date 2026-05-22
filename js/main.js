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

  // ── Signature menu items ──
  ['#tab-signature .menu-item:nth-child(1) h4', 'わら焼きサムギョプサル', 'Straw-Smoked Samgyeopsal'],
  ['#tab-signature .menu-item:nth-child(1) .menu-item-info > p', '藁で燻した豚バラを鉄板焼き。きのこ・もやし・玉ねぎ・ニラ和え・炒めキムチ・トルティーヤ付き。', 'Straw-smoked pork belly seared on a cast-iron griddle. Served with mushrooms, bean sprouts, onion, chive salad, stir-fried kimchi, and tortillas.'],
  ['#tab-signature .menu-item:nth-child(1) .tag', 'COCHA名物', 'COCHA Signature'],
  ['#tab-signature .menu-item:nth-child(2) h4', 'ナッコプセ', 'Nakkopsae'],
  ['#tab-signature .menu-item:nth-child(2) .menu-item-info > p', 'タコ・コプチャン・エビを旨辛ダレで炒め煮。専用ライスと一緒にどうぞ。', 'Octopus, beef tripe, and shrimp braised in a spicy sauce. Best enjoyed with the signature rice.'],
  ['#tab-signature .menu-item:nth-child(2) .tag', '辛口 · 人気No.1', 'Spicy · Most Popular'],
  ['#tab-signature .menu-item:nth-child(3) h4', 'COCHA UFOマーラーしゃぶ', 'COCHA UFO Maala Shabu-Shabu'],
  ['#tab-signature .menu-item:nth-child(3) .menu-item-info > p', '花びら状のお肉を麻辣スープでしゃぶしゃぶ。ピーナッツダレで味変も楽しめます。', 'Petal-arranged meat cooked in a numbing maala broth. Try with peanut sauce for an extra flavour dimension.'],
  ['#tab-signature .menu-item:nth-child(3) .tag', '中韓フュージョン', 'Korean-Chinese Fusion'],
  ['#tab-signature .menu-item:nth-child(4) h4', '&lt;15分&gt; ポッサム盛り合わせ', '&lt;15 min&gt; Bossam Platter'],
  ['#tab-signature .menu-item:nth-child(4) .menu-item-info > p', '15分待てば、いちばん美味しい蒸しポッサムがテーブルで完成。見て楽しい、待って美味しい一品。', 'Wait 15 minutes and the most delicious steamed bossam is finished right at your table — a showstopper worth the wait.'],
  ['#tab-signature .menu-item:nth-child(4) .tag', 'テーブル仕上げ', 'Table-Side Finish'],
  ['#tab-signature .menu-item:nth-child(5) h4', '富士山マーラー鍋', 'Mt. Fuji Maala Hot Pot'],
  ['#tab-signature .menu-item:nth-child(5) .menu-item-info > p', '富士山のように盛り付けられた迫力の麻辣鍋。グループのテーブルを彩る一品。', 'A dramatic maala hot pot piled high like Mt. Fuji — a centrepiece dish that delights the whole table.'],
  ['#tab-signature .menu-item:nth-child(5) .tag', '辛口 · グループ向け', 'Spicy · Great for Groups'],
  ['#tab-signature .menu-item:nth-child(6) h4', 'プレミアム薬膳ペクスク', 'Premium Herbal Peksuk'],
  ['#tab-signature .menu-item:nth-child(6) .menu-item-info > p', '名古屋コーチン × 韓国産丸ごとアワビ。厳選した漢方素材で仕上げたCOCHAのプレミアム薬膳料理。', 'Nagoya Cochin chicken × whole Korean abalone, finished with carefully selected herbal ingredients. A premium medicinal soup exclusive to COCHA.'],
  ['#tab-signature .menu-item:nth-child(6) .tag', '季節限定 · 要予約', 'Seasonal · Reservation Required'],

  // ── Lunch sets ──
  ['#tab-sets .menu-note', '<strong>11:00〜16:00（L.O. 15:30）</strong>のご提供。各セットはアラカルトより約1,000円お得。2〜3名様向け。', '<strong>Available 11:00–16:00 (L.O. 15:30).</strong> Sets are approx. ¥1,000 less than ordering à la carte. Serves 2–3 people.'],
  ['#tab-sets .menu-item:nth-child(1) h4', 'わら焼きサムギョプサル SET', 'Straw-Smoked Samgyeopsal SET'],
  ['#tab-sets .menu-item:nth-child(1) .menu-item-info > p', 'サムギョプサル + ミナリエビチヂミ + チゲ + おかず8種 + ライス×2 + サンチュセット', 'Samgyeopsal + Minari Shrimp Pajeon + Jjigae + 8 banchan + Rice ×2 + Sangchu Set'],
  ['#tab-sets .menu-item:nth-child(1) .tag', '一番人気', 'Most Popular'],
  ['#tab-sets .menu-item:nth-child(2) h4', 'ナッコプセ SET', 'Nakkopsae SET'],
  ['#tab-sets .menu-item:nth-child(2) .menu-item-info > p', 'ナッコプセ + 肉チヂミ + ケランチム + おかず8種 + 専用ライス×2', 'Nakkopsae + Meat Pajeon + Gyeran Jjim + 8 banchan + Signature Rice ×2'],
  ['#tab-sets .menu-item:nth-child(2) .tag', 'お得セット', 'Great Value'],
  ['#tab-sets .menu-item:nth-child(3) h4', 'マーラーしゃぶしゃぶ SET', 'Maala Shabu-Shabu SET'],
  ['#tab-sets .menu-item:nth-child(3) .menu-item-info > p', 'マーラーしゃぶ + クォバロウ + 卵チャーハン + おかず8種', 'Maala Shabu + Sweet &amp; Sour Pork + Egg Fried Rice + 8 banchan'],
  ['#tab-sets .menu-item:nth-child(3) .tag', '中韓フュージョン', 'Korean-Chinese Fusion'],
  ['#tab-sets .menu-item:nth-child(4) h4', 'プデチゲ SET', 'Budae Jjigae SET'],
  ['#tab-sets .menu-item:nth-child(4) .menu-item-info > p', 'プデチゲ + チャプチェ + ミナリエビチヂミ + おかず8種 + ライス×2 + ラーメンサリ', 'Budae Jjigae + Japchae + Minari Shrimp Pajeon + 8 banchan + Rice ×2 + Ramen Noodles'],
  ['#tab-sets .menu-item:nth-child(4) .tag', 'ボリューム満点', 'Hearty &amp; Filling'],
  ['#tab-sets .menu-item:nth-child(5) h4', 'ミナリ豚チュムロク SET', 'Minari Pork Chumuruk SET'],
  ['#tab-sets .menu-item:nth-child(5) .menu-item-info > p', 'ミナリチュムロク + ミナリ海鮮チヂミ + チゲ + おかず8種 + サンチュセット', 'Minari Chumuruk + Minari Seafood Pajeon + Jjigae + 8 banchan + Sangchu Set'],
  ['#tab-sets .menu-item:nth-child(5) .tag', 'さっぱり系', 'Light &amp; Fresh'],

  // ── À la carte — category titles ──
  ['#tab-plates .menu-category-section:nth-child(1) .menu-category-title', 'チヂミ', 'Pajeon (Korean Pancakes)'],
  ['#tab-plates .menu-category-section:nth-child(2) .menu-category-title', 'チキン', 'Chicken'],
  ['#tab-plates .menu-category-section:nth-child(3) .menu-category-title', '炒め物', 'Stir-Fry'],
  ['#tab-plates .menu-category-section:nth-child(4) .menu-category-title', '鍋・スープ', 'Hot Pot &amp; Soup'],
  ['#tab-plates .menu-category-section:nth-child(5) .menu-category-title', '一品料理', 'À la Carte Dishes'],
  ['#tab-plates .menu-category-section:nth-child(6) .menu-category-title', 'ご飯物', 'Rice Dishes'],
  // チヂミ items
  ['#tab-plates .menu-category-section:nth-child(1) .menu-list-item:nth-child(1) span:first-child', 'トリュフチーズじゃがいもチヂミ', 'Truffle Cheese Potato Pajeon'],
  ['#tab-plates .menu-category-section:nth-child(1) .menu-list-item:nth-child(2) span:first-child', 'ミナリ海鮮チヂミ', 'Minari Seafood Pajeon'],
  ['#tab-plates .menu-category-section:nth-child(1) .menu-list-item:nth-child(3) span:first-child', 'トウモロコシチヂミ', 'Corn Pajeon'],
  ['#tab-plates .menu-category-section:nth-child(1) .menu-list-item:nth-child(4) span:first-child', 'ミナリエビチヂミ', 'Minari Shrimp Pajeon'],
  ['#tab-plates .menu-category-section:nth-child(1) .menu-list-item:nth-child(5) span:first-child', '肉チヂミ', 'Meat Pajeon'],
  // チキン items
  ['#tab-plates .menu-category-section:nth-child(2) .menu-list-item:nth-child(1) span:first-child', 'COCHAチポレチキン', 'COCHA Chipotle Chicken'],
  ['#tab-plates .menu-category-section:nth-child(2) .menu-list-item:nth-child(2) span:first-child', 'マーラーヤンニョムチキン', 'Maala Yangnyeom Chicken'],
  ['#tab-plates .menu-category-section:nth-child(2) .menu-list-item:nth-child(3) span:first-child', 'ユーリンチー風チキン', 'Yurinchi-Style Chicken'],
  ['#tab-plates .menu-category-section:nth-child(2) .menu-list-item:nth-child(4) span:first-child', 'フライドチキン', 'Fried Chicken'],
  ['#tab-plates .menu-category-section:nth-child(2) .menu-list-item:nth-child(5) span:first-child', 'ゆず醤油チキン', 'Yuzu Soy Sauce Chicken'],
  // 炒め物 items
  ['#tab-plates .menu-category-section:nth-child(3) .menu-list-item:nth-child(1) span:first-child', 'チャプチェ', 'Japchae (Glass Noodles)'],
  ['#tab-plates .menu-category-section:nth-child(3) .menu-list-item:nth-child(2) span:first-child', 'チュクミ炒め', 'Stir-Fried Baby Octopus'],
  ['#tab-plates .menu-category-section:nth-child(3) .menu-list-item:nth-child(3) span:first-child', 'イカ炒め', 'Stir-Fried Squid'],
  ['#tab-plates .menu-category-section:nth-child(3) .menu-list-item:nth-child(4) span:first-child', 'チーズタッカルビ炒め', 'Cheese Tteokgalbi Stir-Fry'],
  ['#tab-plates .menu-category-section:nth-child(3) .menu-list-item:nth-child(5) span:first-child', '豚肉炒め', 'Stir-Fried Pork'],
  ['#tab-plates .menu-category-section:nth-child(3) .menu-list-item:nth-child(6) span:first-child', '豆苗炒め', 'Stir-Fried Pea Shoots'],
  ['#tab-plates .menu-category-section:nth-child(3) .menu-list-item:nth-child(7) span:first-child', 'トマト卵炒め', 'Tomato &amp; Egg Stir-Fry'],
  // 鍋・スープ items
  ['#tab-plates .menu-category-section:nth-child(4) .menu-list-item:nth-child(1) span:first-child', 'ニラもつ鍋', 'Garlic Chive Offal Hot Pot'],
  ['#tab-plates .menu-category-section:nth-child(4) .menu-list-item:nth-child(2) span:first-child', '特選ミナリコムタン', 'Premium Minari Gomtang (Bone Broth Soup)'],
  ['#tab-plates .menu-category-section:nth-child(4) .menu-list-item:nth-child(3) span:first-child', 'スンドゥブチゲ', 'Sundubu Jjigae (Soft Tofu Stew)'],
  ['#tab-plates .menu-category-section:nth-child(4) .menu-list-item:nth-child(4) span:first-child', 'キムチチゲ', 'Kimchi Jjigae (Kimchi Stew)'],
  ['#tab-plates .menu-category-section:nth-child(4) .menu-list-item:nth-child(5) span:first-child', '味噌チゲ', 'Doenjang Jjigae (Soybean Paste Stew)'],
  ['#tab-plates .menu-category-section:nth-child(4) .menu-list-item:nth-child(6) span:first-child', 'カニと卵スープ', 'Crab and Egg Soup'],
  // 一品料理 items
  ['#tab-plates .menu-category-section:nth-child(5) .menu-list-item:nth-child(1) span:first-child', '炙りユッケビビムカルグス', 'Seared Yukhoe Bibim Noodles'],
  ['#tab-plates .menu-category-section:nth-child(5) .menu-list-item:nth-child(2) span:first-child', 'ボッサムカルビビびん麺', 'Bossam Galbi Cold Noodles'],
  ['#tab-plates .menu-category-section:nth-child(5) .menu-list-item:nth-child(3) span:first-child', 'クォバロウ（酢豚）', 'Guo Bao Rou (Sweet &amp; Sour Pork)'],
  ['#tab-plates .menu-category-section:nth-child(5) .menu-list-item:nth-child(4) span:first-child', 'マーラーエビマヨ', 'Maala Shrimp Mayo'],
  ['#tab-plates .menu-category-section:nth-child(5) .menu-list-item:nth-child(5) span:first-child', 'BBQポークチーズフォンデュ', 'BBQ Pork Cheese Fondue'],
  ['#tab-plates .menu-category-section:nth-child(5) .menu-list-item:nth-child(6) span:first-child', '牛バラ巻き', 'Beef Short Rib Rolls'],
  ['#tab-plates .menu-category-section:nth-child(5) .menu-list-item:nth-child(7) span:first-child', '豆腐豚キムチ', 'Tofu Pork Kimchi'],
  ['#tab-plates .menu-category-section:nth-child(5) .menu-list-item:nth-child(8) span:first-child', '鉄板ミナリ豚トロ', 'Iron Plate Minari Pork Jowl'],
  ['#tab-plates .menu-category-section:nth-child(5) .menu-list-item:nth-child(9) span:first-child', 'ブンモジャトッポギセット', 'Bun Mo Ja Tteokbokki Set'],
  // ご飯物 items
  ['#tab-plates .menu-category-section:nth-child(6) .menu-list-item:nth-child(1) span:first-child', '卵炒飯', 'Egg Fried Rice'],
  ['#tab-plates .menu-category-section:nth-child(6) .menu-list-item:nth-child(2) span:first-child', '卵えび炒飯', 'Egg &amp; Shrimp Fried Rice'],
  ['#tab-plates .menu-category-section:nth-child(6) .menu-list-item:nth-child(3) span:first-child', 'キムチ炒飯', 'Kimchi Fried Rice'],
  ['#tab-plates .menu-category-section:nth-child(6) .menu-list-item:nth-child(4) span:first-child', 'セルフおにぎり', 'DIY Rice Balls'],

  // ── Drinks — category titles ──
  ['#tab-drinks .menu-category-section:nth-child(1) .menu-category-title', 'ビール', 'Beer'],
  ['#tab-drinks .menu-category-section:nth-child(2) .menu-category-title', '生サワー', 'Fresh Sours'],
  ['#tab-drinks .menu-category-section:nth-child(3) .menu-category-title', 'ハイボール', 'Highball'],
  ['#tab-drinks .menu-category-section:nth-child(4) .menu-category-title', '韓国酒', 'Korean Spirits'],
  ['#tab-drinks .menu-category-section:nth-child(5) .menu-category-title', 'プレミアムボトル', 'Premium Bottles'],
  ['#tab-drinks .menu-category-section:nth-child(6) .menu-category-title', 'ソフトドリンク', 'Soft Drinks'],
  // ビール items
  ['#tab-drinks .menu-category-section:nth-child(1) .menu-list-item:nth-child(1) span:first-child', 'プレミアムモルツ生ビール', 'Premium Malts Draft Beer'],
  ['#tab-drinks .menu-category-section:nth-child(1) .menu-list-item:nth-child(2) span:first-child', 'CASS 中瓶', 'CASS (medium bottle)'],
  ['#tab-drinks .menu-category-section:nth-child(1) .menu-list-item:nth-child(3) span:first-child', 'TERA 中瓶', 'TERA (medium bottle)'],
  ['#tab-drinks .menu-category-section:nth-child(1) .menu-list-item:nth-child(4) span:first-child', 'アサヒ 中瓶', 'Asahi (medium bottle)'],
  ['#tab-drinks .menu-category-section:nth-child(1) .menu-list-item:nth-child(5) span:first-child', 'チンタオ 小瓶', 'Tsingtao (small bottle)'],
  // 生サワー items
  ['#tab-drinks .menu-category-section:nth-child(2) .menu-list-item:nth-child(1) span:first-child', '生レモン・グレープフルーツ・マスカット', 'Fresh Lemon / Grapefruit / Muscat'],
  ['#tab-drinks .menu-category-section:nth-child(2) .menu-list-item:nth-child(2) span:first-child', '生パイナップル・イチゴ・キウイ', 'Fresh Pineapple / Strawberry / Kiwi'],
  ['#tab-drinks .menu-category-section:nth-child(2) .menu-list-item:nth-child(3) span:first-child', '生マンゴ・ミックスベリー', 'Fresh Mango / Mixed Berry'],
  // ハイボール items
  ['#tab-drinks .menu-category-section:nth-child(3) .menu-list-item:nth-child(1) span:first-child', '角ハイボール・ジンジャー・コーク', 'Kaku Highball / Ginger / Coke'],
  ['#tab-drinks .menu-category-section:nth-child(3) .menu-list-item:nth-child(2) span:first-child', 'AOハイボール', 'AO Highball'],
  ['#tab-drinks .menu-category-section:nth-child(3) .menu-list-item:nth-child(3) span:first-child', '白州ハイボール', 'Hakushu Highball'],
  ['#tab-drinks .menu-category-section:nth-child(3) .menu-list-item:nth-child(4) span:first-child', '山崎ハイボール', 'Yamazaki Highball'],
  // 韓国酒 items
  ['#tab-drinks .menu-category-section:nth-child(4) .menu-list-item:nth-child(1) span:first-child', 'チャミスル オリジナル', 'Chamisul Original'],
  ['#tab-drinks .menu-category-section:nth-child(4) .menu-list-item:nth-child(2) span:first-child', 'チャミスル各種（マスカット・グレフル・ピーチ・イチゴ・すもも）', 'Chamisul Flavours (Muscat / Grapefruit / Peach / Strawberry / Plum)'],
  ['#tab-drinks .menu-category-section:nth-child(4) .menu-list-item:nth-child(3) span:first-child', 'ジンロイズバック / セロゼロシューガ', 'Jinro Is Back / Zero-Zero Sugar'],
  ['#tab-drinks .menu-category-section:nth-child(4) .menu-list-item:nth-child(4) span:first-child', '生マッコリ', 'Fresh Makgeolli'],
  ['#tab-drinks .menu-category-section:nth-child(4) .menu-list-item:nth-child(5) span:first-child', 'ヌリンマウルマッコリ', 'Nulrin Maul Makgeolli'],
  ['#tab-drinks .menu-category-section:nth-child(4) .menu-list-item:nth-child(6) span:first-child', '一品眞露', 'Ippin Jinro'],
  // プレミアムボトル items
  ['#tab-drinks .menu-category-section:nth-child(5) .menu-list-item:nth-child(1) span:first-child', '山崎シングルモルト', 'Yamazaki Single Malt'],
  ['#tab-drinks .menu-category-section:nth-child(5) .menu-list-item:nth-child(2) span:first-child', '山崎 12年', 'Yamazaki 12 Year'],
  ['#tab-drinks .menu-category-section:nth-child(5) .menu-list-item:nth-child(3) span:first-child', '白州シングルモルト', 'Hakushu Single Malt'],
  ['#tab-drinks .menu-category-section:nth-child(5) .menu-list-item:nth-child(4) span:first-child', '響ブレンダードチョイス', 'Hibiki Blender\'s Choice'],
  ['#tab-drinks .menu-category-section:nth-child(5) .menu-list-item:nth-child(5) span:first-child', 'マッカラン 12年', 'The Macallan 12 Year'],
  ['#tab-drinks .menu-category-section:nth-child(5) .menu-list-item:nth-child(6) span:first-child', 'マッカラン 18年', 'The Macallan 18 Year'],
  ['#tab-drinks .menu-category-section:nth-child(5) .menu-list-item:nth-child(7) span:first-child', 'ジョニーウォーカー ブルーラベル', 'Johnnie Walker Blue Label'],
  ['#tab-drinks .menu-category-section:nth-child(5) .menu-list-item:nth-child(8) span:first-child', 'ヴーヴ クリコ / モエ / ドン ペリニヨン', 'Veuve Clicquot / Moët / Dom Pérignon'],
  // ソフトドリンク items
  ['#tab-drinks .menu-category-section:nth-child(6) .menu-list-item:nth-child(1) span:first-child', 'コーラ / ゼロコーラ / ジンジャーエール / サイダー', 'Cola / Zero Cola / Ginger Ale / Lemon Soda'],
  ['#tab-drinks .menu-category-section:nth-child(6) .menu-list-item:nth-child(2) span:first-child', 'ウーロン茶 / トウモロコシ茶 / ジャスミン茶', 'Oolong Tea / Corn Tea / Jasmine Tea'],
  ['#tab-drinks .menu-category-section:nth-child(6) .menu-list-item:nth-child(3) span:first-child', 'オレンジ / カルピス / 梨ジュース', 'Orange / Calpis / Pear Juice'],

  // ── Desserts ──
  ['#tab-desserts .menu-item:nth-child(1) h4', 'ティラミスビンス', 'Tiramisu Bingsu'],
  ['#tab-desserts .menu-item:nth-child(1) .menu-item-info > p', 'レビューでも話題のCOCHAオリジナルかき氷。ティラミス風の仕上がりで、食後の締めにちょうどいい。', 'A COCHA-original shaved ice that has gone viral online. Tiramisu-inspired flavours — the perfect way to end your meal.'],
  ['#tab-desserts .menu-item:nth-child(1) .tag', 'COCHA オリジナル', 'COCHA Original'],
  ['#tab-desserts .menu-item:nth-child(2) h4', 'いちごビンス', 'Strawberry Bingsu'],
  ['#tab-desserts .menu-item:nth-child(2) .menu-item-info > p', 'フレッシュいちごを使ったかき氷。ふわふわの氷と甘酸っぱいソースが好評。', 'Shaved ice made with fresh strawberries. The fluffy ice and sweet-tangy sauce are guest favourites.'],
  ['#tab-desserts .menu-item:nth-child(2) .tag', '定番人気', 'Fan Favourite'],
  ['#tab-desserts .menu-item:nth-child(3) h4', 'マンゴ / 白桃 / きなこビンス', 'Mango / White Peach / Kinako Bingsu'],
  ['#tab-desserts .menu-item:nth-child(3) .menu-item-info > p', '季節のビンス各種。甘さ控えめで食後にぴったり。', 'Seasonal bingsu varieties. Subtly sweet and perfect after a meal.'],
  ['#tab-desserts .menu-item:nth-child(3) .tag', '各種あり', 'Seasonal Selection'],

  // ── Nomi-hodai (All-You-Can-Drink) ──
  ['#tab-nomihoudai .menu-note', '<strong>2名様以上よりご利用いただけます。</strong>ご注文は卓上QRコードより。お時間はご注文時刻より計算いたします。', '<strong>Available for groups of 2 or more.</strong> Order via QR code at your table. Time starts from the first order.'],
  ['#tab-nomihoudai .menu-category-section:nth-child(2) .menu-category-title', '飲み放題コース', 'All-You-Can-Drink Courses'],
  ['#tab-nomihoudai .menu-category-section:nth-child(2) .menu-list-item:nth-child(1) > div > span', 'スタンダード 90分飲み放題', 'Standard 90-min All-You-Can-Drink'],
  ['#tab-nomihoudai .menu-category-section:nth-child(2) .menu-list-item:nth-child(1) .plan-note', '生ビール · 生サワー全種 · 角ハイボール · チャミスル · 生マッコリ · ソフトドリンク', 'Draft beer · Fresh sours (all flavours) · Kaku Highball · Chamisul · Fresh makgeolli · Soft drinks'],
  ['#tab-nomihoudai .menu-category-section:nth-child(2) .menu-list-item:nth-child(2) > div > span', 'プレミアム 120分飲み放題', 'Premium 120-min All-You-Can-Drink'],
  ['#tab-nomihoudai .menu-category-section:nth-child(2) .menu-list-item:nth-child(2) .plan-note', 'スタンダード全品 ＋ CASS/TERA · ヌリンマウル生マッコリ · フルーツチャミスル各種', 'Everything in Standard + CASS/TERA · Nulrin Maul makgeolli · Flavoured chamisul'],
  ['#tab-nomihoudai .menu-category-section:nth-child(3) .menu-category-title', 'セット割引（飲み放題120分込み）', 'Set Discounts (incl. 120-min All-You-Can-Drink)'],
  ['#tab-nomihoudai .menu-category-section:nth-child(3) .menu-list-item:nth-child(1) span:first-child', 'わら焼きサムギョプサルSET ＋ 120分飲み放題', 'Straw-Smoked Samgyeopsal SET + 120-min All-You-Can-Drink'],
  ['#tab-nomihoudai .menu-category-section:nth-child(3) .menu-list-item:nth-child(2) span:first-child', 'ナッコプセSET ＋ 120分飲み放題', 'Nakkopsae SET + 120-min All-You-Can-Drink'],
  ['#tab-nomihoudai .menu-category-section:nth-child(3) .menu-list-item:nth-child(3) span:first-child', 'マーラーしゃぶしゃぶSET ＋ 120分飲み放題', 'Maala Shabu-Shabu SET + 120-min All-You-Can-Drink'],
  ['#tab-nomihoudai .menu-category-section:nth-child(3) .menu-list-item:nth-child(4) span:first-child', 'プデチゲSET ＋ 120分飲み放題', 'Budae Jjigae SET + 120-min All-You-Can-Drink'],
  ['#tab-nomihoudai .menu-category-section:nth-child(3) .menu-list-item:nth-child(5) span:first-child', 'ミナリ豚チュムロクSET ＋ 120分飲み放題', 'Minari Pork Chumuruk SET + 120-min All-You-Can-Drink'],
  ['#tab-nomihoudai .nomi-note p', '※ ラストオーダーは終了15分前  ／  延長は30分ごとに¥500  ／  お一人様でのご利用はご遠慮ください', '※ Last order 15 min before end &nbsp;/&nbsp; ¥500 per 30-min extension &nbsp;/&nbsp; Not available for solo diners'],
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
    toggle.innerHTML = lang === 'en'
      ? '<i class="fas fa-globe"></i> 日本語'
      : '<i class="fas fa-globe"></i> EN';
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
