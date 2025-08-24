import React, { createContext, useContext, useReducer, useEffect } from 'react'
import { useAuth } from './AuthContext'

const CartContext = createContext()

const initialState = {
  items: [],
  total: 0,
  itemCount: 0
}

const cartReducer = (state, action) => {
  switch (action.type) {
    case 'ADD_ITEM':
      const existingItem = state.items.find(
        item => item._id === action.payload._id && item.vendorId === action.payload.vendorId
      )
      
      if (existingItem) {
        const updatedItems = state.items.map(item =>
          item._id === action.payload._id && item.vendorId === action.payload.vendorId
            ? { ...item, quantity: item.quantity + action.payload.quantity }
            : item
        )
        return calculateTotals(updatedItems)
      } else {
        const newItems = [...state.items, action.payload]
        return calculateTotals(newItems)
      }

    case 'REMOVE_ITEM':
      const filteredItems = state.items.filter(
        item => !(item._id === action.payload._id && item.vendorId === action.payload.vendorId)
      )
      return calculateTotals(filteredItems)

    case 'UPDATE_QUANTITY':
      const updatedItems = state.items.map(item =>
        item._id === action.payload._id && item.vendorId === action.payload.vendorId
          ? { ...item, quantity: action.payload.quantity }
          : item
      )
      return calculateTotals(updatedItems)

    case 'CLEAR_CART':
      return initialState

    case 'LOAD_CART':
      return calculateTotals(action.payload)

    default:
      return state
  }
}

const calculateTotals = (items) => {
  const total = items.reduce((sum, item) => sum + (item.price * item.quantity), 0)
  const itemCount = items.reduce((sum, item) => sum + item.quantity, 0)
  return { items, total, itemCount }
}

export const CartProvider = ({ children }) => {
  const [state, dispatch] = useReducer(cartReducer, initialState)
  const { isAuthenticated, user } = useAuth()

  // Load cart from localStorage on mount
  useEffect(() => {
    const savedCart = localStorage.getItem('cart')
    if (savedCart) {
      try {
        const parsedCart = JSON.parse(savedCart)
        dispatch({ type: 'LOAD_CART', payload: parsedCart })
      } catch (error) {
        console.error('Error loading cart from localStorage:', error)
      }
    }
  }, [])

  // Save cart to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('cart', JSON.stringify(state.items))
  }, [state.items])

  const addToCart = (product, quantity = 1) => {
    const cartItem = {
      _id: product._id,
      name: product.name,
      price: product.price,
      image: product.images?.[0] || product.image,
      vendorId: product.vendorId,
      vendorName: product.vendorName,
      quantity,
      maxQuantity: product.stock || 999
    }
    
    dispatch({ type: 'ADD_ITEM', payload: cartItem })
  }

  const removeFromCart = (productId, vendorId) => {
    dispatch({ type: 'REMOVE_ITEM', payload: { _id: productId, vendorId } })
  }

  const updateQuantity = (productId, vendorId, quantity) => {
    if (quantity <= 0) {
      removeFromCart(productId, vendorId)
    } else {
      dispatch({ type: 'UPDATE_QUANTITY', payload: { _id: productId, vendorId, quantity } })
    }
  }

  const clearCart = () => {
    dispatch({ type: 'CLEAR_CART' })
  }

  const getVendorSubtotals = () => {
    const vendorGroups = {}
    state.items.forEach(item => {
      if (!vendorGroups[item.vendorId]) {
        vendorGroups[item.vendorId] = {
          vendorId: item.vendorId,
          vendorName: item.vendorName,
          items: [],
          subtotal: 0
        }
      }
      vendorGroups[item.vendorId].items.push(item)
      vendorGroups[item.vendorId].subtotal += item.price * item.quantity
    })
    return Object.values(vendorGroups)
  }

  const value = {
    ...state,
    addToCart,
    removeFromCart,
    updateQuantity,
    clearCart,
    getVendorSubtotals
  }

  return (
    <CartContext.Provider value={value}>
      {children}
    </CartContext.Provider>
  )
}

export const useCart = () => {
  const context = useContext(CartContext)
  if (!context) {
    throw new Error('useCart must be used within a CartProvider')
  }
  return context
}
