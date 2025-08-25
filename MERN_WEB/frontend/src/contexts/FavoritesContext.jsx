import React, { createContext, useContext, useReducer, useEffect } from 'react'

const FavoritesContext = createContext()

const initialState = {
  favorites: [],
  loading: false,
  error: null
}

const favoritesReducer = (state, action) => {
  switch (action.type) {
    case 'ADD_TO_FAVORITES':
      const existingIndex = state.favorites.findIndex(item => item.id === action.payload.id)
      if (existingIndex >= 0) {
        return state // Already in favorites
      }
      return {
        ...state,
        favorites: [...state.favorites, action.payload]
      }
    
    case 'REMOVE_FROM_FAVORITES':
      return {
        ...state,
        favorites: state.favorites.filter(item => item.id !== action.payload)
      }
    
    case 'CLEAR_FAVORITES':
      return {
        ...state,
        favorites: []
      }
    
    case 'SET_FAVORITES':
      return {
        ...state,
        favorites: action.payload
      }
    
    case 'SET_LOADING':
      return {
        ...state,
        loading: action.payload
      }
    
    case 'SET_ERROR':
      return {
        ...state,
        error: action.payload
      }
    
    default:
      return state
  }
}

export const FavoritesProvider = ({ children }) => {
  const [state, dispatch] = useReducer(favoritesReducer, initialState)

  // Load favorites from localStorage on mount
  useEffect(() => {
    const savedFavorites = localStorage.getItem('artisanmart-favorites')
    if (savedFavorites) {
      try {
        const favorites = JSON.parse(savedFavorites)
        dispatch({ type: 'SET_FAVORITES', payload: favorites })
      } catch (error) {
        console.error('Error loading favorites from localStorage:', error)
      }
    }
  }, [])

  // Save favorites to localStorage whenever they change
  useEffect(() => {
    localStorage.setItem('artisanmart-favorites', JSON.stringify(state.favorites))
  }, [state.favorites])

  const addToFavorites = (product) => {
    const favoriteItem = {
      id: product._id || product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.category,
      image: product.image,
      vendorName: product.vendorName || 'Unknown Vendor',
      rating: product.rating || 0,
      reviews: product.reviewCount || 0,
      inStock: true,
      addedToFavorites: new Date().toISOString()
    }
    
    dispatch({ type: 'ADD_TO_FAVORITES', payload: favoriteItem })
  }

  const removeFromFavorites = (productId) => {
    dispatch({ type: 'REMOVE_FROM_FAVORITES', payload: productId })
  }

  const clearFavorites = () => {
    dispatch({ type: 'CLEAR_FAVORITES' })
  }

  const isInFavorites = (productId) => {
    return state.favorites.some(item => item.id === productId)
  }

  const getFavoritesCount = () => {
    return state.favorites.length
  }

  const value = {
    favorites: state.favorites,
    loading: state.loading,
    error: state.error,
    addToFavorites,
    removeFromFavorites,
    clearFavorites,
    isInFavorites,
    getFavoritesCount
  }

  return (
    <FavoritesContext.Provider value={value}>
      {children}
    </FavoritesContext.Provider>
  )
}

export const useFavorites = () => {
  const context = useContext(FavoritesContext)
  if (!context) {
    throw new Error('useFavorites must be used within a FavoritesProvider')
  }
  return context
}
