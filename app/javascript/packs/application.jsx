import React from 'react'
import { createRoot } from 'react-dom/client'
import App from '../finac/App'

document.addEventListener('DOMContentLoaded', () => {
  const rootElement = document.getElementById('root')
  if (!rootElement) return

  createRoot(rootElement).render(<App />)
})
