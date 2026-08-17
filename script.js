const year = document.getElementById('year');
if (year) year.textContent = new Date().getFullYear();

const toggle = document.getElementById('langToggle');
let lang = localStorage.getItem('siteLang') || 'zh';

function applyLanguage(nextLang) {
  lang = nextLang;
  document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';
  document.querySelectorAll('[data-zh][data-en]').forEach((el) => {
    el.textContent = el.dataset[lang];
  });
  if (toggle) toggle.textContent = lang === 'zh' ? 'EN' : '中';
  localStorage.setItem('siteLang', lang);
}

if (toggle) {
  toggle.addEventListener('click', () => applyLanguage(lang === 'zh' ? 'en' : 'zh'));
}

applyLanguage(lang);
