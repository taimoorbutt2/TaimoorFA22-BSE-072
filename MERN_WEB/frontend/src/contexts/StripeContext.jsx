import React, { createContext, useContext, useState } from 'react'

const StripeContext = createContext()

export const StripeProvider = ({ children }) => {
  const [stripe, setStripe] = useState(null)
  const [loading, setLoading] = useState(false)

  const value = {
    stripe,
    setStripe,
    loading,
    setLoading
  }

  return (
    <StripeContext.Provider value={value}>
      {children}
    </StripeContext.Provider>
  )
}

export const useStripe = () => {
  const context = useContext(StripeContext)
  if (!context) {
    throw new Error('useStripe must be used within a StripeProvider')
  }
  return context
}
