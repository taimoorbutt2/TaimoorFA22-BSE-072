import React, { createContext, useContext, useState, useEffect } from 'react'
import { loadStripe } from '@stripe/stripe-js'
import axios from 'axios'

const StripeContext = createContext()

export const StripeProvider = ({ children }) => {
  const [stripe, setStripe] = useState(null)
  const [loading, setLoading] = useState(false)
  const [clientSecret, setClientSecret] = useState(null)
  const [paymentMethods, setPaymentMethods] = useState([])

  // Initialize Stripe
  useEffect(() => {
    const initStripe = async () => {
      try {
        const stripeInstance = await loadStripe(import.meta.env.VITE_STRIPE_PUBLISHABLE_KEY || 'pk_test_your_stripe_publishable_key_here')
        setStripe(stripeInstance)
      } catch (error) {
        console.error('Error loading Stripe:', error)
      }
    }
    initStripe()
  }, [])

  // Create payment intent
  const createPaymentIntent = async (amount, currency = 'usd', metadata = {}) => {
    try {
      setLoading(true)
      const response = await axios.post('/api/stripe/create-payment-intent', {
        amount,
        currency,
        metadata
      })
      
      setClientSecret(response.data.clientSecret)
      return response.data
    } catch (error) {
      console.error('Error creating payment intent:', error)
      throw error
    } finally {
      setLoading(false)
    }
  }

  // Get payment methods
  const fetchPaymentMethods = async () => {
    try {
      const response = await axios.get('/api/stripe/payment-methods')
      setPaymentMethods(response.data.paymentMethods)
      return response.data
    } catch (error) {
      console.error('Error fetching payment methods:', error)
      throw error
    }
  }

  // Create order
  const createOrder = async (orderData) => {
    try {
      setLoading(true)
      const response = await axios.post('/api/stripe/create-order', orderData)
      return response.data
    } catch (error) {
      console.error('Error creating order:', error)
      throw error
    } finally {
      setLoading(false)
    }
  }

  const value = {
    stripe,
    setStripe,
    loading,
    setLoading,
    clientSecret,
    setClientSecret,
    paymentMethods,
    createPaymentIntent,
    fetchPaymentMethods,
    createOrder
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
