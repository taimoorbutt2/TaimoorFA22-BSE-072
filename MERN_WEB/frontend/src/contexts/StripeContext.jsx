import React, { createContext, useContext, useState } from 'react'
import { loadStripe } from '@stripe/stripe-js'

const StripeContext = createContext()

export const StripeProvider = ({ children }) => {
  const [stripe, setStripe] = useState(null)
  const [loading, setLoading] = useState(true)

  React.useEffect(() => {
    const initStripe = async () => {
      try {
        const stripeInstance = await loadStripe(import.meta.env.VITE_STRIPE_PUBLISHABLE_KEY)
        setStripe(stripeInstance)
      } catch (error) {
        console.error('Failed to load Stripe:', error)
      } finally {
        setLoading(false)
      }
    }
    initStripe()
  }, [])

  const value = { stripe, loading }
  return <StripeContext.Provider value={value}>{children}</StripeContext.Provider>
}

export const useStripe = () => {
  const context = useContext(StripeContext)
  if (!context) throw new Error('useStripe must be used within StripeProvider')
  return context
}
