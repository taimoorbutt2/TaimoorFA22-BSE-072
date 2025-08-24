import React, { createContext, useContext, useReducer, useEffect } from 'react'
import { jwtDecode } from 'jwt-decode'
import api from '../utils/api'

const AuthContext = createContext()

const initialState = {
  user: null,
  token: localStorage.getItem('token'),
  isAuthenticated: false,
  loading: true,
  error: null
}

const authReducer = (state, action) => {
  switch (action.type) {
    case 'AUTH_START':
      return { ...state, loading: true, error: null }
    case 'AUTH_SUCCESS':
      return {
        ...state,
        user: action.payload.user,
        token: action.payload.token,
        isAuthenticated: true,
        loading: false,
        error: null
      }
    case 'AUTH_FAILURE':
      return {
        ...state,
        user: null,
        token: null,
        isAuthenticated: false,
        loading: false,
        error: action.payload
      }
    case 'LOGOUT':
      return {
        ...state,
        user: null,
        token: null,
        isAuthenticated: false,
        loading: false,
        error: null
      }
    case 'UPDATE_USER':
      return { ...state, user: action.payload }
    default:
      return state
  }
}

export const AuthProvider = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState)

  // Check if token is valid on app load
  useEffect(() => {
    const checkAuth = async () => {
      const token = localStorage.getItem('token')
      if (token) {
        try {
          const decoded = jwtDecode(token)
          const currentTime = Date.now() / 1000
          
          if (decoded.exp < currentTime) {
            // Token expired
            localStorage.removeItem('token')
            dispatch({ type: 'AUTH_FAILURE', payload: 'Token expired' })
            return
          }

          // Token is valid, fetch user data
          const response = await api.get('/auth/me')
          dispatch({
            type: 'AUTH_SUCCESS',
            payload: { user: response.data.user, token }
          })
        } catch (error) {
          localStorage.removeItem('token')
          dispatch({ type: 'AUTH_FAILURE', payload: 'Authentication failed' })
        }
      } else {
        dispatch({ type: 'AUTH_FAILURE', payload: null })
      }
    }

    checkAuth()
  }, [])

  const login = async (email, password) => {
    dispatch({ type: 'AUTH_START' })
    try {
      const response = await api.post('/auth/login', { email, password })
      const { token, user } = response.data
      
      localStorage.setItem('token', token)
      dispatch({
        type: 'AUTH_SUCCESS',
        payload: { user, token }
      })
      return { success: true }
    } catch (error) {
      const message = error.response?.data?.message || 'Login failed'
      dispatch({ type: 'AUTH_FAILURE', payload: message })
      return { success: false, error: message }
    }
  }

  const register = async (userData) => {
    dispatch({ type: 'AUTH_START' })
    try {
      const response = await api.post('/auth/register', userData)
      const { token, user } = response.data
      
      localStorage.setItem('token', token)
      dispatch({
        type: 'AUTH_SUCCESS',
        payload: { user, token }
      })
      return { success: true }
    } catch (error) {
      const message = error.response?.data?.message || 'Registration failed'
      dispatch({ type: 'AUTH_FAILURE', payload: message })
      return { success: false, error: message }
    }
  }

  const logout = () => {
    localStorage.removeItem('token')
    dispatch({ type: 'LOGOUT' })
  }

  const updateUser = (userData) => {
    dispatch({ type: 'UPDATE_USER', payload: userData })
  }

  const hasRole = (requiredRole) => {
    if (!state.user) return false
    return state.user.role === requiredRole || state.user.role === 'admin'
  }

  const value = {
    ...state,
    login,
    register,
    logout,
    updateUser,
    hasRole
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
