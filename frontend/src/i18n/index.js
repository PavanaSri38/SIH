import en from '../locales/en.json'
import hi from '../locales/hi.json'
import te from '../locales/te.json'

const translations = { en, hi, te }

let currentLang = localStorage.getItem('lang') || 'en'

export function setLanguage(lang) {
  currentLang = lang
  localStorage.setItem('lang', lang)
}

export function t(key) {
  return translations[currentLang]?.[key] || translations['en']?.[key] || key
}
