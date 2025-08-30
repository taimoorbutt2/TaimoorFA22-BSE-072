import React, { createContext, useContext, useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { useAuth } from './AuthContext';

const FavoritesContext = createContext();

export const useFavorites = () => {
  const context = useContext(FavoritesContext);
  if (!context) {
    throw new Error('useFavorites must be used within a FavoritesProvider');
  }
  return context;
};

export const FavoritesProvider = ({ children }) => {
  const { user, isAuthenticated } = useAuth();
  const [favorites, setFavorites] = useState([]);
  const [loading, setLoading] = useState(false);
  const [favoritesCount, setFavoritesCount] = useState(0);

  // Check if user is authenticated (local check)
  const isTokenValid = () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) return false;
      
      // Basic token validation
      const payload = JSON.parse(atob(token.split('.')[1]));
      const currentTime = Date.now() / 1000;
      
      return payload.exp > currentTime;
    } catch (error) {
      return false;
    }
  };

  // Get user's favorites from API
  const fetchFavorites = async () => {
    if (!isAuthenticated || !user) {
      console.log('FavoritesContext: Cannot fetch favorites - not authenticated or no user');
      setFavorites([]);
      setFavoritesCount(0);
      return;
    }

    try {
      console.log('FavoritesContext: Fetching favorites for user:', user._id);
      setLoading(true);
      const response = await fetch('/api/favorites/my-favorites', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });

      if (response.ok) {
        const data = await response.json();
        console.log('FavoritesContext: Fetched favorites:', data.favorites?.length || 0, 'items');
        setFavorites(data.favorites);
        setFavoritesCount(data.pagination.totalFavorites);
      } else {
        console.error('Failed to fetch favorites');
        setFavorites([]);
        setFavoritesCount(0);
      }
    } catch (error) {
      console.error('Error fetching favorites:', error);
      setFavorites([]);
      setFavoritesCount(0);
    } finally {
      setLoading(false);
    }
  };

  // Check if a product is favorited
  const checkFavoriteStatus = async (productId) => {
    if (!isAuthenticated || !user) return false;

    try {
      const response = await fetch(`/api/favorites/check/${productId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });

      if (response.ok) {
        const data = await response.json();
        return data.isFavorited;
      }
      return false;
    } catch (error) {
      console.error('Error checking favorite status:', error);
      return false;
    }
  };

  // Add product to favorites
  const addToFavorites = async (productId) => {
    if (!isAuthenticated || !user) {
      toast.error('Please login to add products to favorites');
      return false;
    }

    try {
      const response = await fetch('/api/favorites/add', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({ productId })
      });

      if (response.ok) {
        const data = await response.json();
        toast.success('Added to favorites! ❤️');
        
        // Refresh favorites list
        await fetchFavorites();
        return true;
      } else {
        const errorData = await response.json();
        toast.error(errorData.message || 'Failed to add to favorites');
        return false;
      }
    } catch (error) {
      console.error('Error adding to favorites:', error);
      toast.error('Failed to add to favorites');
      return false;
    }
  };

  // Remove product from favorites
  const removeFromFavorites = async (productId) => {
    if (!isAuthenticated || !user) return false;

    try {
      const response = await fetch(`/api/favorites/remove/${productId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });

      if (response.ok) {
        toast.success('Removed from favorites 💔');
        
        // Refresh favorites list
        await fetchFavorites();
        return true;
      } else {
        const errorData = await response.json();
        toast.error(errorData.message || 'Failed to remove from favorites');
        return false;
      }
    } catch (error) {
      console.error('Error removing from favorites:', error);
      toast.error('Failed to remove from favorites');
      return false;
    }
  };

  // Toggle favorite status
  const toggleFavorite = async (productId) => {
    const isFavorited = favorites.some(fav => fav.product._id === productId);
    
    if (isFavorited) {
      return await removeFromFavorites(productId);
    } else {
      return await addToFavorites(productId);
    }
  };

  // Check if a product is in favorites (synchronous check)
  const isInFavorites = (productId) => {
    return favorites.some(fav => fav.product._id === productId);
  };

  // Clear favorites (on logout or user change)
  const clearFavorites = () => {
    setFavorites([]);
    setFavoritesCount(0);
  };

  // Clear favorites when user changes (called automatically by useEffect)
  const handleUserChange = () => {
    if (!isAuthenticated || !user) {
      clearFavorites();
    }
  };

  // Initialize favorites when component mounts or user changes
  useEffect(() => {
    console.log('FavoritesContext: User changed', { 
      isAuthenticated, 
      userId: user?._id, 
      userEmail: user?.email 
    });
    
    // Only fetch if user is authenticated
    if (isAuthenticated && user) {
      console.log('FavoritesContext: Fetching favorites for user:', user._id);
      fetchFavorites();
    } else {
      // Clear favorites if not authenticated
      console.log('FavoritesContext: Clearing favorites - user not authenticated');
      setFavorites([]);
      setFavoritesCount(0);
    }
  }, [isAuthenticated, user]);

  const value = {
    favorites,
    loading,
    favoritesCount,
    addToFavorites,
    removeFromFavorites,
    toggleFavorite,
    isInFavorites,
    checkFavoriteStatus,
    fetchFavorites,
    clearFavorites,
    currentUserId: user?._id || null
  };

  return (
    <FavoritesContext.Provider value={value}>
      {children}
    </FavoritesContext.Provider>
  );
};
