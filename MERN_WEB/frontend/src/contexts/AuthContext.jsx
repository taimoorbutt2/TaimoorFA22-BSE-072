import React, { createContext, useContext, useReducer, useEffect } from 'react'
import jwtDecode from 'jwt-decode'

const AuthContext = createContext()

const initialState = {
  user: null,
  token: localStorage.getItem('token'),
  isAuthenticated: false,
  loading: false,
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

          // Token is valid, but we need to fetch fresh user data
          // For now, use the decoded token data
          const userData = {
            _id: decoded.userId,
            name: decoded.name,
            email: decoded.email,
            role: decoded.role
          }
          dispatch({
            type: 'AUTH_SUCCESS',
            payload: { user: userData, token }
          })
        } catch (error) {
          localStorage.removeItem('token')
          dispatch({ type: 'AUTH_FAILURE', payload: 'Invalid token' })
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
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password }),
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.message || 'Login failed')
      }

      localStorage.setItem('token', data.token)
      dispatch({
        type: 'AUTH_SUCCESS',
        payload: { user: data.user, token: data.token }
      })
      
      return { success: true }
    } catch (error) {
      dispatch({ type: 'AUTH_FAILURE', payload: error.message })
      throw error
    }
  }

  const register = async (userData) => {
    dispatch({ type: 'AUTH_START' })
    try {
      console.log('Frontend sending registration data:', JSON.stringify(userData, null, 2))
      
      const response = await fetch('/api/auth/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(userData),
      })

      const data = await response.json()
      console.log('Backend response:', { status: response.status, data: JSON.stringify(data, null, 2) })

      if (!response.ok) {
        throw new Error(data.message || 'Registration failed')
      }

      localStorage.setItem('token', data.token)
      dispatch({
        type: 'AUTH_SUCCESS',
        payload: { user: data.user, token: data.token }
      })
      
      return { success: true }
    } catch (error) {
      dispatch({ type: 'AUTH_FAILURE', payload: error.message })
      throw error
    }
  }

  const logout = () => {
    localStorage.removeItem('token')
    dispatch({ type: 'LOGOUT' })
  }

  const updateProfile = (userData) => {
    dispatch({ type: 'UPDATE_USER', payload: { ...state.user, ...userData } })
  }

  const hasRole = (role) => {
    return state.user?.role === role
  }

  const value = {
    user: state.user,
    token: state.token,
    isAuthenticated: state.isAuthenticated,
    loading: state.loading,
    error: state.error,
    login,
    register,
    logout,
    updateProfile,
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
