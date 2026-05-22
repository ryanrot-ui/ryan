/* Ashikaru 足軽 Massage Salon — Main JS */

const isTouch = window.matchMedia('(hover: none)').matches;

// Navbar scroll + progress bar + scroll-to-top
const navbar    = document.getElementById('navbar');
const progress  = document.getElementById('scrollProgress');
const scrollTop = document.getElementById('scrollTop');
window.addEventListener('scroll', () => {
  const scrolled = window.scrollY;
  const maxScroll = document.documentElement.scrollHeight - window.innerHeight;
  navbar.classList.toggle('scrolled', scrolled > 60);
  if (progress) progress.style.width = (scrolled / maxScroll * 100) + '%';
  if (scrollTop) scrollTop.classList.toggle('visible', scrolled > 600);
}, { passive: true });

if (scrollTop) {
  scrollTop.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
}

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

// Sliding tab indicator
function moveTabIndicator(btn) {
  const indicator = document.getElementById('tabIndicator');
  if (!indicator || !btn) return;
  indicator.style.left  = btn.offsetLeft + 'px';
  indicator.style.width = btn.offsetWidth + 'px';
}

// Course tabs
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    const tab = btn.dataset.tab;
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById('tab-' + tab).classList.add('active');
    moveTabIndicator(btn);
    document.querySelectorAll('#tab-' + tab + ' .reveal').forEach(el => {
      el.classList.remove('visible');
      setTimeout(() => observer.observe(el), 10);
    });
  });
});

// Init indicator on active tab
const initTabBtn = document.querySelector('.tab-btn.active');
if (initTabBtn) {
  const indicator = document.getElementById('tabIndicator');
  if (indicator) {
    indicator.style.transition = 'none';
    moveTabIndicator(initTabBtn);
    requestAnimationFrame(() => { indicator.style.transition = ''; });
  }
}

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
    btn.textContent = isEn ? 'Booking Confirmed ✓' : 'ご予約を受け付けました ✓';
    btn.style.background = '#2ecc71';
    btn.disabled = true;
    setTimeout(() => {
      btn.textContent = isEn ? 'Confirm Booking' : '予約を確定する';
      btn.style.background = '';
      btn.disabled = false;
      form.reset();
    }, 4000);
  });
}

// Parallax on hero — desktop only
if (!isTouch) {
  const heroBg = document.querySelector('.hero-bg');
  window.addEventListener('scroll', () => {
    if (heroBg && window.scrollY < window.innerHeight) {
      heroBg.style.transform = `translateY(${window.scrollY * 0.3}px)`;
    }
  }, { passive: true });
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
  ['#navLinks li:nth-child(2) a', 'コース', 'Courses'],
  ['#navLinks li:nth-child(3) a', '店舗紹介', 'About'],
  ['#navLinks li:nth-child(4) a', 'アクセス', 'Access'],
  ['#navLinks li:nth-child(5) a', 'ご予約', 'Book'],
  // Hero
  ['.hero-tagline', '新宿区大久保 — フット&ボディマッサージ', 'Shinjuku Okubo, Tokyo — Foot &amp; Body Massage'],
  ['.hero-title-sub', '足軽', 'Ashikaru'],
  ['.hero-subtitle', '深夜も、早朝も。24時間いつでも、<br>あなたの疲れた心と体を癒します。', 'Morning, midnight, or anywhere between.<br>We are here for your body, any hour.'],
  ['.hero-ctas a:nth-child(1)', 'ご予約はこちら', 'Book Now'],
  ['.hero-ctas a:nth-child(2)', 'コースを見る', 'View Courses'],
  ['.hero-badges .badge:nth-child(1) span:last-child', '24時間営業', 'Open 24 Hours'],
  ['.hero-badges .badge:nth-child(2) span:last-child', '完全個室', 'Private Rooms'],
  // Highlights
  ['.highlight-card:nth-child(1) h3', '24時間・年中無休', 'Open 24 Hours, 365 Days'],
  ['.highlight-card:nth-child(1) p', '深夜・早朝・祝日もご利用可能。仕事帰り、旅のお疲れに、いつでもお立ち寄りください。新宿のど真ん中で365日お待ちしています。', 'Available late night, early morning, and holidays. Drop in any time after work or on your travels. We are open 365 days in the heart of Shinjuku.'],
  ['.highlight-card:nth-child(2) h3', 'フット&ボディ専門', 'Foot &amp; Body Specialists'],
  ['.highlight-card:nth-child(2) p', '足裏反射区療法から全身リラクゼーションまで。熟練セラピストが、あなたの疲れの箇所に合わせた施術をご提供します。', 'From foot reflexology to full-body relaxation. Our skilled therapists tailor every session to exactly where you need it most.'],
  ['.highlight-card:nth-child(3) h3', '新宿・大久保駅近', 'Near Okubo &amp; Shinjuku Stations'],
  ['.highlight-card:nth-child(3) p', '大久保駅から徒歩5分、新宿駅からも好アクセス。完全個室で、周りを気にせずゆっくりとご利用いただけます。', '5 minutes on foot from Okubo Station, easy access from Shinjuku. Fully private rooms so you can relax without a care.'],
  ['.highlight-card:nth-child(4) h3', '各種キャッシュレス対応', 'Cashless Payments Accepted'],
  ['.highlight-card:nth-child(4) p', 'PayPay・楽天Pay・クレジットカードなど各種決済に対応。現金はもちろん、スマートフォン決済でスムーズにお支払いいただけます。', 'PayPay, Rakuten Pay, credit cards, and cash — we accept them all for a smooth, hassle-free checkout.'],
  // Menu/Course header + tabs
  ['#menu .section-header .section-tag', 'COURSE', 'COURSE'],
  ['#menu .section-header h2', 'コース・料金', 'Courses &amp; Pricing'],
  ['#menu .section-header p', 'お体の状態に合わせて、最適なコースをお選びください。', 'Choose the course that best suits your body\'s needs.'],
  ['.menu-tabs .tab-btn:nth-child(1)', 'フットマッサージ', 'Foot Massage'],
  ['.menu-tabs .tab-btn:nth-child(2)', 'ボディマッサージ', 'Body Massage'],
  ['.menu-tabs .tab-btn:nth-child(3)', 'コンビネーション', 'Combination'],
  ['.menu-tabs .tab-btn:nth-child(4)', 'オプション', 'Add-Ons'],
  ['.menu-cta p', '初めてのご来店の方も、お気軽にご相談ください。お体の状態に合わせて最適なコースをご提案いたします。', 'First time visitors are always welcome. Our staff will help you find the perfect course for your body.'],
  ['.menu-cta .btn', 'ご予約はこちら', 'Book Now'],
  // Foot tab
  ['#tab-foot .menu-note', '<strong>足裏反射区療法（中国式足揉み）</strong>足裏の反射区を丁寧に刺激し、全身の血行促進・疲労回復を促します。施術は専用の個室にて行います。', '<strong>Foot Reflexology (Chinese-style)</strong> Targeted stimulation of reflex zones on the sole to boost circulation and relieve fatigue throughout the body. All sessions are held in private rooms.'],
  ['#tab-foot .menu-item:nth-child(1) h4', 'フットマッサージ 30分', 'Foot Massage 30 min'],
  ['#tab-foot .menu-item:nth-child(1) .menu-item-info > p', '足裏の主要反射区を重点的にほぐします。ちょっとした疲れ取りに最適なショートコース。', 'Focused work on the key reflex zones of the sole. The ideal short course for a quick refresh.'],
  ['#tab-foot .menu-item:nth-child(1) .tag', 'お試し', 'Try It'],
  ['#tab-foot .menu-item:nth-child(2) h4', 'フットマッサージ 60分', 'Foot Massage 60 min'],
  ['#tab-foot .menu-item:nth-child(2) .menu-item-info > p', '足裏全体・ふくらはぎ・すねまで丁寧にほぐします。1日の疲れをしっかりとケアする人気コース。', 'Full sole, calf, and shin treatment. Our most popular course for unwinding after a long day.'],
  ['#tab-foot .menu-item:nth-child(2) .tag', '人気No.1', 'Most Popular'],
  ['#tab-foot .menu-item:nth-child(3) h4', 'フットマッサージ 90分', 'Foot Massage 90 min'],
  ['#tab-foot .menu-item:nth-child(3) .menu-item-info > p', '足全体から膝上まで丁寧にケア。慢性的な疲れや浮腫みにお悩みの方に特におすすめです。', 'Care from the full foot up past the knee. Particularly recommended for those dealing with chronic fatigue or swelling.'],
  ['#tab-foot .menu-item:nth-child(3) .tag', 'じっくりケア', 'Deep Care'],
  ['#tab-foot .menu-item:nth-child(4) h4', 'フットマッサージ 120分', 'Foot Massage 120 min'],
  ['#tab-foot .menu-item:nth-child(4) .menu-item-info > p', '最も丁寧な足の施術。足裏から太ももまで全体をほぐし、深いリラクゼーションへと導きます。', 'Our most thorough foot treatment. From the sole to the upper thigh, guiding you into the deepest relaxation.'],
  ['#tab-foot .menu-item:nth-child(4) .tag', 'プレミアム', 'Premium'],
  // Body tab
  ['#tab-body .menu-note', '<strong>全身リラクゼーション</strong>背中・肩・腰・首など全身の筋肉をほぐします。長時間のデスクワークや立ち仕事でお疲れの方に。施術は専用の個室にて行います。', '<strong>Full-Body Relaxation</strong> Easing the muscles of the back, shoulders, lower back, and neck. Ideal for those tired from long hours at a desk or on their feet. All sessions in private rooms.'],
  ['#tab-body .menu-item:nth-child(1) h4', 'ボディマッサージ 30分', 'Body Massage 30 min'],
  ['#tab-body .menu-item:nth-child(1) .menu-item-info > p', '背中・肩を中心にほぐすショートコース。肩こりや背中の張りに効果的です。', 'A focused short course targeting the back and shoulders. Effective for shoulder stiffness and upper-back tension.'],
  ['#tab-body .menu-item:nth-child(1) .tag', '肩こり解消', 'Shoulder Relief'],
  ['#tab-body .menu-item:nth-child(2) h4', 'ボディマッサージ 60分', 'Body Massage 60 min'],
  ['#tab-body .menu-item:nth-child(2) .menu-item-info > p', '上半身全体をしっかりとケア。背中・肩・首・腕まで丁寧にほぐします。人気の定番コース。', 'Full upper-body care covering the back, shoulders, neck, and arms. Our classic, popular course.'],
  ['#tab-body .menu-item:nth-child(2) .tag', '定番人気', 'Classic'],
  ['#tab-body .menu-item:nth-child(3) h4', 'ボディマッサージ 90分', 'Body Massage 90 min'],
  ['#tab-body .menu-item:nth-child(3) .menu-item-info > p', '全身をくまなくケア。背中・肩・首・腰・臀部まで、深部の筋肉までほぐします。', 'Head-to-toe care reaching the back, shoulders, neck, lower back, and glutes — down to the deep muscle layer.'],
  ['#tab-body .menu-item:nth-child(3) .tag', '全身ケア', 'Full Body'],
  ['#tab-body .menu-item:nth-child(4) h4', 'ボディマッサージ 120分', 'Body Massage 120 min'],
  ['#tab-body .menu-item:nth-child(4) .menu-item-info > p', '最上級のボディケア体験。時間をかけて全身をほぐし、心身ともに深い癒しへと導きます。', 'The ultimate body care experience. Unhurried, thorough work that leads body and mind into profound rest.'],
  ['#tab-body .menu-item:nth-child(4) .tag', '最上級', 'Premium'],
  // Combo tab
  ['#tab-combo .menu-note', '<strong>フット+ボディのセットコース</strong>足裏から全身まで、組み合わせることでより深いリラクゼーション効果が得られます。個別に頼むよりもお得なコンビネーション価格です。', '<strong>Foot + Body Set Courses</strong> Combining both treatments delivers a deeper relaxation effect from sole to spine. Priced better than booking each separately.'],
  ['#tab-combo .menu-item:nth-child(1) h4', 'コンビネーション 60分', 'Combination 60 min'],
  ['#tab-combo .menu-item:nth-child(1) .menu-item-info > p', 'フットマッサージ30分 + 肩・首ほぐし30分。足から上半身まで効率よくケアします。', 'Foot massage 30 min + shoulder &amp; neck work 30 min. Efficient head-to-toe care in one session.'],
  ['#tab-combo .menu-item:nth-child(1) .tag', 'お得コース', 'Great Value'],
  ['#tab-combo .menu-item:nth-child(2) h4', 'コンビネーション 90分', 'Combination 90 min'],
  ['#tab-combo .menu-item:nth-child(2) .menu-item-info > p', 'フットマッサージ45分 + ボディマッサージ45分。足裏から背中まで全身を丁寧にほぐします。', 'Foot massage 45 min + body massage 45 min. Thorough care from sole to back.'],
  ['#tab-combo .menu-item:nth-child(2) .tag', '大人気', 'Fan Favourite'],
  ['#tab-combo .menu-item:nth-child(3) h4', 'コンビネーション 120分', 'Combination 120 min'],
  ['#tab-combo .menu-item:nth-child(3) .menu-item-info > p', 'フットマッサージ60分 + ボディマッサージ60分。最上級の全身リラクゼーション体験。', 'Foot massage 60 min + body massage 60 min. The ultimate full-body relaxation experience.'],
  ['#tab-combo .menu-item:nth-child(3) .tag', '贅沢コース', 'Luxury Course'],
  // Options tab
  ['#tab-options .menu-note', '<strong>いずれのコースにも追加可能です。</strong>施術前またはご予約時にお伝えください。スタッフにご相談いただければ最適な組み合わせをご提案します。', '<strong>Add-ons available with any course.</strong> Let us know before your session or at the time of booking. Our staff will suggest the best combination.'],
  ['#tab-options .menu-category-section:nth-child(2) .menu-category-title', 'オプション追加', 'Add-On Options'],
  ['#tab-options .menu-category-section:nth-child(2) .menu-list-item:nth-child(1) span:first-child', 'ヘッド&ネックマッサージ（15分）', 'Head &amp; Neck Massage (15 min)'],
  ['#tab-options .menu-category-section:nth-child(2) .menu-list-item:nth-child(2) span:first-child', 'アロマオイルトリートメント', 'Aroma Oil Treatment'],
  ['#tab-options .menu-category-section:nth-child(2) .menu-list-item:nth-child(3) span:first-child', 'ホットストーンセラピー', 'Hot Stone Therapy'],
  ['#tab-options .menu-category-section:nth-child(2) .menu-list-item:nth-child(4) span:first-child', 'ディープティシュー（深部集中）', 'Deep Tissue (Intensive)'],
  ['#tab-options .menu-category-section:nth-child(3) .menu-category-title', 'その他のサービス', 'Other Services'],
  ['#tab-options .menu-category-section:nth-child(3) .menu-list-item:nth-child(1) span:first-child', 'カップル同時施術（2名様同時）', 'Couples Session (2 persons)'],
  ['#tab-options .menu-category-section:nth-child(3) .menu-list-item:nth-child(2) span:first-child', '延長 30分', 'Extension 30 min'],
  ['#tab-options .menu-category-section:nth-child(3) .menu-list-item:nth-child(3) span:first-child', '着替え・タオル', 'Change &amp; Towel'],
  ['#tab-options .menu-category-section:nth-child(3) .menu-list-item:nth-child(4) span:first-child', 'ドリンクサービス（施術後）', 'Post-Session Drink'],
  ['#tab-options .menu-category-section:nth-child(4) .menu-category-title', 'お支払い方法', 'Payment Methods'],
  // About
  ['#about .section-tag', 'ABOUT', 'ABOUT'],
  ['#about .about-content h2', '足軽について', 'About Ashikaru'],
  ['.about-lead', '「足が軽くなれば、心も軽くなる。」——それが足軽のコンセプトです。', '"When your feet feel light, so does your heart." That is the spirit of Ashikaru.'],
  ['.about-content > p:nth-child(4)', '新宿区大久保のフット&ボディマッサージ専門サロン「足軽」では、熟練セラピストが一人ひとりのお体の状態に合わせた施術をご提供しています。中国伝統の足裏反射区療法をベースに、全身のリラクゼーションまで幅広くケアいたします。24時間365日営業なので、仕事帰りや深夜でもいつでもご利用いただけます。', 'At Ashikaru, a foot and body massage specialist in Shinjuku\'s Okubo neighbourhood, our skilled therapists tailor every session to the individual. Rooted in traditional Chinese foot reflexology, we offer care across a full spectrum of relaxation treatments. Open 24 hours, 365 days — including after late shifts and in the small hours.'],
  ['.about-values .value:nth-child(1) span', '24時間・年中無休営業', 'Open 24 hours, 365 days'],
  ['.about-values .value:nth-child(2) span', '完全個室・プライベート空間', 'Fully private treatment rooms'],
  ['.about-values .value:nth-child(3) span', '熟練セラピストによる本格施術', 'Skilled therapists, authentic technique'],
  ['.about-values .value:nth-child(4) span', 'PayPay・楽天Payなどキャッシュレス対応', 'PayPay, Rakuten Pay &amp; all major cards'],
  ['.about-values .value:nth-child(5) span', '大久保駅から徒歩5分・新宿駅からも好アクセス', '5 min from Okubo Station · easy from Shinjuku'],
  ['.about-content .btn', 'ご予約はこちら', 'Book Now'],
  // Gallery
  ['.gallery-section .section-tag', 'GALLERY', 'GALLERY'],
  ['.gallery-section h2', 'サロンギャラリー', 'Salon Gallery'],
  ['.gallery-item:nth-child(1) .gallery-overlay span', 'フットマッサージ', 'Foot Massage'],
  ['.gallery-item:nth-child(1) .gallery-overlay em', '足裏反射区療法', 'Foot Reflexology'],
  ['.gallery-item:nth-child(2) .gallery-overlay span', '個室施術ルーム', 'Private Treatment Room'],
  ['.gallery-item:nth-child(2) .gallery-overlay em', '完全プライベート空間', 'Fully Private Space'],
  ['.gallery-item:nth-child(3) .gallery-overlay span', 'ホットストーン', 'Hot Stone'],
  ['.gallery-item:nth-child(3) .gallery-overlay em', 'オプション施術', 'Optional Add-On'],
  ['.gallery-item:nth-child(4) .gallery-overlay span', 'ボディマッサージ', 'Body Massage'],
  ['.gallery-item:nth-child(4) .gallery-overlay em', '全身リラクゼーション', 'Full-Body Relaxation'],
  ['.gallery-item:nth-child(5) .gallery-overlay span', 'くつろぎの空間', 'Relaxing Atmosphere'],
  ['.gallery-item:nth-child(5) .gallery-overlay em', '落ち着いた雰囲気', 'Calm &amp; Tranquil'],
  ['.gallery-item:nth-child(6) .gallery-overlay span', 'フットケア', 'Foot Care'],
  ['.gallery-item:nth-child(6) .gallery-overlay em', '丁寧な施術', 'Attentive Treatment'],
  // Reviews
  ['.testimonials-section .section-tag', 'REVIEWS', 'REVIEWS'],
  ['.testimonials-section h2', 'お客様の声', 'Guest Reviews'],
  ['#rv1-tag1', 'フット 5/5', 'Foot 5/5'],
  ['#rv1-tag2', 'サービス 5/5', 'Service 5/5'],
  ['#rv1-tag3', '清潔感 5/5', 'Cleanliness 5/5'],
  ['#rv1-text', '「仕事帰りに立ち寄りました。深夜でも清潔感があって、スタッフの方がとても親切です。フット60分コースを受けましたが、足の疲れがすっきりと取れました。価格も納得できます。また必ず来ます。」', '"Stopped in on the way home from work. Even at midnight, everything was spotless and the staff were genuinely kind. Took the 60-min foot course and my feet felt brand new after. Great value too — I\'ll definitely be back."'],
  ['#rv1-name', '田中 美佳', 'Tanaka Mika'],
  ['#rv1-sub', 'Googleレビュー · 来店済み', 'Google Review · Visited'],
  ['#rv2-tag1', 'ボディ 5/5', 'Body 5/5'],
  ['#rv2-tag2', '施術 5/5', 'Treatment 5/5'],
  ['#rv2-tag3', '立地 5/5', 'Location 5/5'],
  ['#rv2-text', '「24時間対応というのが本当に助かります。夜勤明けに来られるのはここくらいです。セラピストの技術も高く、慢性的な肩こりや腰の痛みが施術後にかなり楽になりました。個室なので安心して受けられます。」', '"The 24-hour availability is a lifesaver — this is pretty much the only place I can come after a night shift. The therapists are highly skilled; my chronic shoulder and lower-back pain eased noticeably after the session. Love the private rooms."'],
  ['#rv2-name', '山田 誠', 'Yamada Makoto'],
  ['#rv2-sub', 'Googleレビュー · 地元のガイド', 'Google Review · Local Guide'],
  ['#rv3-tag1', '初来店', 'First Visit'],
  ['#rv3-tag2', 'コンビ 90分', 'Combo 90 min'],
  ['#rv3-text', '「初めての利用でしたが、スタッフの方が丁寧に施術内容を説明してくださいました。コンビネーション90分コースを試したところ、終わった後の体の軽さが全然違います。大久保駅から近くて便利です。おすすめ！」', '"My first visit, and the staff walked me through everything patiently. Tried the 90-min combination course and the difference in how my body felt afterwards was remarkable. Very convenient — just a short walk from Okubo Station. Highly recommended!"'],
  ['#rv3-name', '朴 志英', 'Park Ji-young'],
  ['#rv3-sub', 'Googleレビュー · 新宿区在住', 'Google Review · Shinjuku Resident'],
  // Reservation / Booking
  ['#reservation .section-tag', 'BOOKING', 'BOOKING'],
  ['#reservation .reservation-info h2', 'ご予約', 'Book a Session'],
  ['#reservation .reservation-info > p', 'ご予約はフォームまたはお電話にて承ります。当日のご予約もお気軽にどうぞ。', 'Reserve via this form or by phone. Same-day bookings are always welcome.'],
  ['.info-items .info-item:nth-child(1) strong', '営業時間', 'Hours'],
  ['.info-items .info-item:nth-child(2) strong', '電話', 'Phone'],
  ['.info-items .info-item:nth-child(3) strong', '住所', 'Address'],
  ['label[for="firstName"]', 'お名前（姓）', 'Last Name'],
  ['label[for="lastName"]', 'お名前（名）', 'First Name'],
  ['label[for="resDate"]', 'ご来店日', 'Visit Date'],
  ['label[for="resTime"]', 'ご来店時間', 'Visit Time'],
  ['label[for="guests"]', 'ご希望コース', 'Preferred Course'],
  ['label[for="phone"]', '電話番号', 'Phone Number'],
  ['label[for="notes"]', 'ご要望・気になる箇所など', 'Requests &amp; Areas of Concern'],
  ['#reservationForm button[type="submit"]', '予約を確定する', 'Confirm Booking'],
  // Contact
  ['#contact .section-tag', 'ACCESS', 'ACCESS'],
  ['#contact h2', 'アクセス', 'Access'],
  ['.contact-grid .contact-card:nth-child(1) h4', '住所', 'Address'],
  ['.contact-grid .contact-card:nth-child(1) p', '〒169-0072<br>東京都新宿区大久保<br>1-17-3 305号室', '〒169-0072<br>305, 1 Chome-17-3 Okubo<br>Shinjuku City, Tokyo 169-0072'],
  ['.contact-grid .contact-card:nth-child(1) .link', '地図を開く', 'Open Map'],
  ['.contact-grid .contact-card:nth-child(2) h4', '電話', 'Phone'],
  ['.contact-grid .contact-card:nth-child(2) .link', '電話をかける', 'Call Us'],
  ['.contact-grid .contact-card:nth-child(3) h4', '営業時間', 'Hours'],
  ['.contact-grid .contact-card:nth-child(3) p', '24時間営業<br>年中無休', 'Open 24 Hours<br>365 Days a Year'],
  ['.contact-grid .contact-card:nth-child(3) .link', '今すぐ予約する', 'Book Now'],
  // Footer
  ['.footer-brand p', '新宿区大久保のフット&ボディマッサージ。<br>24時間営業・完全個室・各種決済対応。', 'Foot &amp; body massage in Shinjuku Okubo.<br>Open 24 hrs · Private rooms · All payments accepted.'],
  ['.footer-grid > :nth-child(2) h5', 'ページ', 'Pages'],
  ['.footer-grid > :nth-child(3) h5', '営業時間・アクセス', 'Hours &amp; Access'],
  ['.footer-social h5', 'お支払い', 'Payment'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(1) a', 'トップ', 'Home'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(2) a', 'コース', 'Courses'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(3) a', '店舗紹介', 'About'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(4) a', 'ご予約', 'Book'],
  ['.footer-grid > :nth-child(2) ul li:nth-child(5) a', 'アクセス', 'Access'],
  ['.footer-bottom p', '© 2026 足軽 Ashikaru — 新宿区大久保. All rights reserved.', '© 2026 Ashikaru 足軽 — Shinjuku, Tokyo. All rights reserved.'],
];

function applyLang(lang) {
  t.forEach(([sel, ja, en]) => {
    const el = document.querySelector(sel);
    if (el) el.innerHTML = lang === 'en' ? en : ja;
  });

  // Hours in reservation section
  const hourSpan = document.querySelector('.info-items .info-item:first-child div span');
  if (hourSpan) hourSpan.textContent = lang === 'en' ? 'Open 24 hours, 365 days a year' : '24時間営業（年中無休）';

  // Placeholders
  const phs = {
    firstName: ['山田', 'Yamada'],
    lastName:  ['太郎', 'Taro'],
    notes:     ['肩こり・腰痛・お体で気になる箇所など、なんでもお気軽にどうぞ', 'Shoulder stiffness, lower back pain, any areas of concern — feel free to share.'],
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
  localStorage.setItem('ashikaru-lang', lang);
}

const langToggleBtn = document.getElementById('langToggle');
if (langToggleBtn) {
  langToggleBtn.addEventListener('click', () => {
    applyLang(document.documentElement.getAttribute('data-lang') === 'en' ? 'ja' : 'en');
  });
}

// Restore saved language preference
const savedLang = localStorage.getItem('ashikaru-lang');
if (savedLang === 'en') applyLang('en');
