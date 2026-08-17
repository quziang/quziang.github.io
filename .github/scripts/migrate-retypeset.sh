#!/usr/bin/env bash
set -euxo pipefail

THEME_SHA='a636b6d393be714cab52d3fc4baddd3f3905f701'

mkdir -p /tmp/quziang-assets
cp assets/ucas-emblem.svg /tmp/quziang-assets/ucas-emblem.svg
cp assets/nefu-emblem.svg /tmp/quziang-assets/nefu-emblem.svg

rm -rf /tmp/retypeset site
git clone https://github.com/radishzzz/astro-theme-retypeset.git /tmp/retypeset
git -C /tmp/retypeset checkout "$THEME_SHA"
mkdir -p site
rsync -a --exclude '.git/' /tmp/retypeset/ site/

mkdir -p site/public/assets
cp /tmp/quziang-assets/ucas-emblem.svg site/public/assets/ucas-emblem.svg
cp /tmp/quziang-assets/nefu-emblem.svg site/public/assets/nefu-emblem.svg

python3 - <<'PY'
from pathlib import Path
import re

config = Path('site/src/config.ts')
s = config.read_text(encoding='utf-8')

exact = [
    ("title: 'Retypeset'", "title: 'quziang'"),
    ("subtitle: 'Revive the beauty of typography'", "subtitle: 'University of Chinese Academy of Sciences · Master\\'s Student'"),
    ("description: 'Retypeset is a static blog theme based on the Astro framework. Inspired by Typography, Retypeset establishes a new visual standard and reimagines the layout of all pages, creating a reading experience reminiscent of paper books, reviving the beauty of typography. Details in every sight, elegance in every space.'", "description: 'quziang — personal blog'"),
    ("author: 'radishzz'", "author: 'quziang'"),
    ("url: 'https://retypeset.radishzz.cc'", "url: 'https://quziang.github.io'"),
    ("moreLocales: ['en', 'es', 'ja', 'ru', 'zh-tw']", "moreLocales: ['en']"),
    ("twitterID: '@radishzz_'", "twitterID: ''"),
    ("google: 'AUCrz5F1e5qbnmKKDXl2Sf8u6y0kOpEO1wLs6HMMmlM'", "google: ''"),
    ("bing: '64708CD514011A7965C84DDE1D169F87'", "bing: ''"),
    ("umamiAnalyticsID: 'dab0e4b9-9cbf-43c3-af60-b09d3b545c38'", "umamiAnalyticsID: ''"),
    ("imageHostURL: 'image.radishzz.cc'", "imageHostURL: ''"),
    ("customUmamiAnalyticsJS: 'https://views.radishzz.cc/script.js'", "customUmamiAnalyticsJS: ''"),
    ("startYear: 2025", "startYear: 2026"),
]
for old, new in exact:
    if old not in s:
        raise SystemExit(f'missing expected config fragment: {old}')
    s = s.replace(old, new, 1)

s, n = re.subn(
    r"(comment:\s*\{\s*// enable comment system\s*\n\s*)enabled: true,",
    r"\1enabled: false,",
    s,
    count=1,
)
if n != 1:
    raise SystemExit('failed to disable comments')

s, n = re.subn(
    r"links: \[.*?\n\s*\],\n\s*// year of website start",
    """links: [
      {
        name: 'RSS',
        url: '/atom.xml',
      },
      {
        name: 'GitHub',
        url: 'https://github.com/quziang',
      },
    ],
    // year of website start""",
    s,
    count=1,
    flags=re.S,
)
if n != 1:
    raise SystemExit('failed to personalize footer links')
config.write_text(s, encoding='utf-8')

ui = Path('site/src/i18n/ui.ts')
text = ui.read_text(encoding='utf-8')

def patch_locale(source, locale, title, subtitle, description):
    pattern = rf"(  '{re.escape(locale)}': \{{\n)(.*?)(\n  \}},)"
    match = re.search(pattern, source, flags=re.S)
    if not match:
        raise SystemExit(f'locale block not found: {locale}')
    block = match.group(2)
    block = re.sub(r"^    title: .*,$", f"    title: {title!r},", block, count=1, flags=re.M)
    block = re.sub(r"^    subtitle: .*,$", f"    subtitle: {subtitle!r},", block, count=1, flags=re.M)
    block = re.sub(r"^    description: .*,$", f"    description: {description!r},", block, count=1, flags=re.M)
    return source[:match.start()] + match.group(1) + block + match.group(3) + source[match.end():]

text = patch_locale(text, 'zh', 'quziang', '中国科学院大学 · 硕士研究生', 'quziang — 个人博客')
text = patch_locale(text, 'en', 'quziang', "University of Chinese Academy of Sciences · Master's Student", 'quziang — personal blog')
ui.write_text(text, encoding='utf-8')
PY

rm -rf site/src/content/posts/* site/src/content/about/*
touch site/src/content/posts/.gitkeep

cat > site/src/content/about/about-zh.md <<'EOF'
---
lang: zh
---

## 教育经历

<div style="display:flex;align-items:center;gap:1rem;margin:1.5rem 0 2rem;">
  <img src="/assets/ucas-emblem.svg" alt="中国科学院大学校徽" width="54" height="54" style="width:54px;height:54px;margin:0;object-fit:contain;" />
  <div><strong>中国科学院大学</strong><br />硕士研究生 · 2024—2027</div>
</div>

<div style="display:flex;align-items:center;gap:1rem;margin:0 0 2rem;">
  <img src="/assets/nefu-emblem.svg" alt="东北林业大学校徽" width="54" height="54" style="width:54px;height:54px;margin:0;object-fit:contain;" />
  <div><strong>东北林业大学</strong><br />本科 · 2020—2024</div>
</div>
EOF

cat > site/src/content/about/about-en.md <<'EOF'
---
lang: en
---

## Education

<div style="display:flex;align-items:center;gap:1rem;margin:1.5rem 0 2rem;">
  <img src="/assets/ucas-emblem.svg" alt="University of Chinese Academy of Sciences emblem" width="54" height="54" style="width:54px;height:54px;margin:0;object-fit:contain;" />
  <div><strong>University of Chinese Academy of Sciences</strong><br />Master's Student · 2024—2027</div>
</div>

<div style="display:flex;align-items:center;gap:1rem;margin:0 0 2rem;">
  <img src="/assets/nefu-emblem.svg" alt="Northeast Forestry University emblem" width="54" height="54" style="width:54px;height:54px;margin:0;object-fit:contain;" />
  <div><strong>Northeast Forestry University</strong><br />Bachelor's Degree · 2020—2024</div>
</div>
EOF

cd site
pnpm install --frozen-lockfile
pnpm build
cd ..

rsync -a --delete \
  --exclude '.git/' \
  --exclude '.github/' \
  --exclude 'site/' \
  --exclude 'CNAME' \
  site/dist/ ./
touch .nojekyll

git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
git add -A
git commit -m 'feat: use upstream Retypeset template'
git push origin main
