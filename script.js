const year = document.getElementById('year');
if (year) year.textContent = new Date().getFullYear();

const langButtons = document.querySelectorAll('[data-lang]');
let lang = localStorage.getItem('siteLang') || 'zh';

function applyLanguage(nextLang) {
  lang = nextLang === 'en' ? 'en' : 'zh';
  document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';

  document.querySelectorAll('[data-zh][data-en]').forEach((el) => {
    el.textContent = el.dataset[lang];
  });

  langButtons.forEach((button) => {
    const active = button.dataset.lang === lang;
    button.classList.toggle('is-active', active);
    button.setAttribute('aria-pressed', active ? 'true' : 'false');
  });

  localStorage.setItem('siteLang', lang);
}

langButtons.forEach((button) => {
  button.addEventListener('click', () => applyLanguage(button.dataset.lang));
});

applyLanguage(lang);
