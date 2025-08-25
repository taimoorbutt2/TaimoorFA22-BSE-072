import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

console.log('🚀 React app starting...')

const root = ReactDOM.createRoot(document.getElementById('root'))
console.log('📱 Root element found:', root)

root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)

console.log('✅ React app rendered')
