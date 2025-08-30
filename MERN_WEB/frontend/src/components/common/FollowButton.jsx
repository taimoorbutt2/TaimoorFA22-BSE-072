import React, { useState, useEffect } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import toast from 'react-hot-toast';

const FollowButton = ({ vendorId, initialFollowersCount = 0, className = '' }) => {
  const { user } = useAuth();
  const [isFollowing, setIsFollowing] = useState(false);
  const [followersCount, setFollowersCount] = useState(initialFollowersCount);
  const [isLoading, setIsLoading] = useState(false);

  // Check if user is already following this vendor
  useEffect(() => {
    if (user && vendorId) {
      checkFollowStatus();
    }
  }, [user, vendorId]);

  const checkFollowStatus = async () => {
    try {
      const response = await fetch(`/api/follows/is-following/${vendorId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        setIsFollowing(data.data.isFollowing);
      }
    } catch (error) {
      console.error('Error checking follow status:', error);
    }
  };

  const handleFollow = async () => {
    if (!user) {
      toast.error('Please login to follow vendors');
      return;
    }

    if (user.role === 'vendor') {
      toast.error('Vendors cannot follow other vendors');
      return;
    }

    setIsLoading(true);
    
    try {
      if (isFollowing) {
        // Unfollow
        const response = await fetch('/api/follows/unfollow', {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          },
          body: JSON.stringify({ vendorId })
        });

        if (response.ok) {
          setIsFollowing(false);
          setFollowersCount(prev => Math.max(0, prev - 1));
          toast.success('Unfollowed vendor');
        } else {
          const data = await response.json();
          toast.error(data.message || 'Failed to unfollow');
        }
      } else {
        // Follow
        const response = await fetch('/api/follows/follow', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          },
          body: JSON.stringify({ vendorId })
        });

        if (response.ok) {
          setIsFollowing(true);
          setFollowersCount(prev => prev + 1);
          toast.success('Followed vendor');
        } else {
          const data = await response.json();
          toast.error(data.message || 'Failed to follow');
        }
      }
    } catch (error) {
      console.error('Error following/unfollowing:', error);
      toast.error('Something went wrong');
    } finally {
      setIsLoading(false);
    }
  };

  // Don't show follow button for vendors or if not logged in
  if (!user || user.role === 'vendor') {
    return null;
  }

  return (
    <button
      onClick={handleFollow}
      disabled={isLoading}
      className={`px-6 py-2 rounded-lg font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed ${
        isFollowing
          ? 'bg-gray-200 text-gray-700 hover:bg-gray-300 border border-gray-300'
          : 'bg-gradient-to-r from-blue-500 to-purple-600 text-white hover:from-blue-600 hover:to-purple-700 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5'
      } ${className}`}
    >
      {isLoading ? (
        <div className="flex items-center space-x-2">
          <div className="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin"></div>
          <span>{isFollowing ? 'Unfollowing...' : 'Following...'}</span>
        </div>
      ) : (
        <span>{isFollowing ? 'Following' : 'Follow'}</span>
      )}
    </button>
  );
};

export default FollowButton;
