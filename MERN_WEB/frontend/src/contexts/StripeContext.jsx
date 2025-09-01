import React, { createContext, useContext, useState, useEffect } from 'react';
import { loadStripe } from '@stripe/stripe-js';
import axios from 'axios';
import { useAuth } from './AuthContext';

const StripeContext = createContext();

const stripePromise = loadStripe('pk_test_51S2CYjBO7sFQMUIRtgGGTT3Bwx7qVCtUpOeYiPGDfJQvH7joHjXpDLNpgYKR8cdYCK47mT9PNkul42sMQeevg6MR00WzvMdqPk');

export const StripeProvider = ({ children }) => {
  const { user, isAuthenticated } = useAuth();
  const [stripe, setStripe] = useState(null);
  const [loading, setLoading] = useState(false);
  const [clientSecret, setClientSecret] = useState(null);
  const [paymentMethods, setPaymentMethods] = useState([]);

  useEffect(() => {
    const initializeStripe = async () => {
      try {
        setLoading(true);
        const stripeInstance = await stripePromise;
        setStripe(stripeInstance);
      } catch (error) {
        console.error('Error initializing Stripe:', error);
      } finally {
        setLoading(false);
      }
    };
    initializeStripe();
  }, []);

  const createPaymentIntent = async (amount, currency, metadata = {}) => {
    setLoading(true);
    try {
      console.log('StripeContext: createPaymentIntent called with:', { amount, currency, metadata });
      console.log('StripeContext: isAuthenticated:', isAuthenticated, 'user:', user);
      
      if (!isAuthenticated || !user) {
        throw new Error('User not authenticated');
      }
      
      const token = localStorage.getItem('token');
      console.log('StripeContext: token from localStorage:', token ? 'exists' : 'missing');
      
      if (!token) {
        throw new Error('No authentication token found');
      }
      
      const response = await axios.post('/api/stripe/create-payment-intent', {
        amount,
        currency,
        metadata
      }, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      console.log('StripeContext: payment intent created successfully:', response.data);
      setClientSecret(response.data.clientSecret);
      return response.data;
    } catch (error) {
      console.error('Error creating payment intent:', error);
      throw new Error('Failed to create payment intent');
    } finally {
      setLoading(false);
    }
  };

  const fetchPaymentMethods = async () => {
    setLoading(true);
    try {
      if (!isAuthenticated || !user) {
        throw new Error('User not authenticated');
      }
      
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No authentication token found');
      }
      
      const response = await axios.get('/api/stripe/payment-methods', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      setPaymentMethods(response.data.paymentMethods);
      return response.data.paymentMethods;
    } catch (error) {
      console.error('Error fetching payment methods:', error);
      throw new Error('Failed to fetch payment methods');
    } finally {
      setLoading(false);
    }
  };

  const createOrder = async (orderData) => {
    setLoading(true);
    try {
      if (!isAuthenticated || !user) {
        throw new Error('User not authenticated');
      }
      
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No authentication token found');
      }
      
      const response = await axios.post('/api/stripe/create-order', orderData, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      return response.data.order;
    } catch (error) {
      console.error('Error creating order:', error);
      throw new Error('Failed to create order');
    } finally {
      setLoading(false);
    }
  };

  const value = {
    stripe,
    loading,
    clientSecret,
    paymentMethods,
    createPaymentIntent,
    fetchPaymentMethods,
    createOrder,
  };

  return (
    <StripeContext.Provider value={value}>
      {children}
    </StripeContext.Provider>
  );
};

export const useStripe = () => {
  const context = useContext(StripeContext);
  if (!context) {
    throw new Error('useStripe must be used within a StripeProvider');
  }
  return context;
};
