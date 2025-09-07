import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  BookOpenIcon, 
  ChartBarIcon, 
  FireIcon, 
  HeartIcon,
  PlusIcon,
  TrendingUpIcon,
  CalendarIcon
} from '@heroicons/react/24/outline';
import { useAuth } from '../contexts/AuthContext';
import { journalService } from '../services/journalService';
import { insightService } from '../services/insightService';
import Card from '../components/common/Card';
import Button from '../components/common/Button';
import LoadingSpinner from '../components/common/LoadingSpinner';

const Dashboard: React.FC = () => {
  const { user } = useAuth();
  const [stats, setStats] = useState<any>(null);
  const [insights, setInsights] = useState<any>(null);
  const [recentEntries, setRecentEntries] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        const [statsData, insightsData, entriesData] = await Promise.all([
          journalService.getStats('7'),
          insightService.getDashboard('7'),
          journalService.getEntries({ limit: 3 })
        ]);

        setStats(statsData);
        setInsights(insightsData);
        setRecentEntries(entriesData.data);
      } catch (error) {
        console.error('Failed to fetch dashboard data:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  const getMoodEmoji = (mood: string) => {
    const moodEmojis: Record<string, string> = {
      'very-happy': '😄',
      'happy': '😊',
      'neutral': '😐',
      'sad': '😢',
      'very-sad': '😭',
      'anxious': '😰',
      'stressed': '😓',
      'calm': '😌',
      'excited': '🤩',
      'grateful': '🙏',
      'frustrated': '😤',
      'peaceful': '☮️'
    };
    return moodEmojis[mood] || '😐';
  };

  const getMoodColor = (mood: string) => {
    const moodColors: Record<string, string> = {
      'very-happy': 'text-yellow-500',
      'happy': 'text-green-500',
      'neutral': 'text-gray-500',
      'sad': 'text-blue-500',
      'very-sad': 'text-indigo-500',
      'anxious': 'text-orange-500',
      'stressed': 'text-red-500',
      'calm': 'text-teal-500',
      'excited': 'text-purple-500',
      'grateful': 'text-pink-500',
      'frustrated': 'text-red-600',
      'peaceful': 'text-cyan-500'
    };
    return moodColors[mood] || 'text-gray-500';
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="bg-gradient-to-r from-blue-600 to-green-600 rounded-xl p-6 text-white">
        <h1 className="text-2xl font-bold mb-2">
          Welcome back, {user?.name?.split(' ')[0]}! 👋
        </h1>
        <p className="text-blue-100">
          Ready to continue your wellness journey? Let's check in on how you're feeling today.
        </p>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Link to="/app/journal">
          <Card hover className="text-center">
            <PlusIcon className="h-8 w-8 text-blue-600 mx-auto mb-2" />
            <h3 className="font-semibold text-gray-900">New Entry</h3>
            <p className="text-sm text-gray-600">Start journaling</p>
          </Card>
        </Link>

        <Link to="/app/insights">
          <Card hover className="text-center">
            <ChartBarIcon className="h-8 w-8 text-green-600 mx-auto mb-2" />
            <h3 className="font-semibold text-gray-900">View Insights</h3>
            <p className="text-sm text-gray-600">See your progress</p>
          </Card>
        </Link>

        <Link to="/app/resources">
          <Card hover className="text-center">
            <BookOpenIcon className="h-8 w-8 text-purple-600 mx-auto mb-2" />
            <h3 className="font-semibold text-gray-900">Resources</h3>
            <p className="text-sm text-gray-600">Wellness tools</p>
          </Card>
        </Link>

        <Link to="/app/profile">
          <Card hover className="text-center">
            <HeartIcon className="h-8 w-8 text-pink-600 mx-auto mb-2" />
            <h3 className="font-semibold text-gray-900">Profile</h3>
            <p className="text-sm text-gray-600">Manage settings</p>
          </Card>
        </Link>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <div className="flex items-center">
            <div className="p-2 bg-blue-100 rounded-lg">
              <BookOpenIcon className="h-6 w-6 text-blue-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Entries</p>
              <p className="text-2xl font-bold text-gray-900">{stats?.totalEntries || 0}</p>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center">
            <div className="p-2 bg-green-100 rounded-lg">
              <FireIcon className="h-6 w-6 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Current Streak</p>
              <p className="text-2xl font-bold text-gray-900">{user?.streak?.current || 0} days</p>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center">
            <div className="p-2 bg-purple-100 rounded-lg">
              <TrendingUpIcon className="h-6 w-6 text-purple-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Longest Streak</p>
              <p className="text-2xl font-bold text-gray-900">{user?.streak?.longest || 0} days</p>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center">
            <div className="p-2 bg-yellow-100 rounded-lg">
              <HeartIcon className="h-6 w-6 text-yellow-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Favorites</p>
              <p className="text-2xl font-bold text-gray-900">{stats?.favoriteCount || 0}</p>
            </div>
          </div>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Entries */}
        <Card>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Recent Entries</h2>
            <Link to="/app/journal">
              <Button variant="ghost" size="sm">View All</Button>
            </Link>
          </div>
          
          {recentEntries.length > 0 ? (
            <div className="space-y-3">
              {recentEntries.map((entry) => (
                <div key={entry._id} className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
                  <span className={`text-2xl ${getMoodColor(entry.mood)}`}>
                    {getMoodEmoji(entry.mood)}
                  </span>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 truncate">
                      {entry.title || 'Untitled Entry'}
                    </p>
                    <p className="text-xs text-gray-500">
                      {new Date(entry.createdAt).toLocaleDateString()}
                    </p>
                  </div>
                  <Link to={`/app/journal/${entry._id}`}>
                    <Button variant="ghost" size="sm">View</Button>
                  </Link>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8">
              <BookOpenIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500 mb-4">No entries yet</p>
              <Link to="/app/journal">
                <Button>Start Journaling</Button>
              </Link>
            </div>
          )}
        </Card>

        {/* Recent Insights */}
        <Card>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Recent Insights</h2>
            <Link to="/app/insights">
              <Button variant="ghost" size="sm">View All</Button>
            </Link>
          </div>
          
          {insights?.recentInsights?.length > 0 ? (
            <div className="space-y-3">
              {insights.recentInsights.slice(0, 3).map((insight: any) => (
                <div key={insight._id} className="p-3 bg-gray-50 rounded-lg">
                  <h3 className="text-sm font-medium text-gray-900 mb-1">
                    {insight.title}
                  </h3>
                  <p className="text-xs text-gray-600 line-clamp-2">
                    {insight.description}
                  </p>
                  <div className="flex items-center mt-2">
                    <CalendarIcon className="h-3 w-3 text-gray-400 mr-1" />
                    <span className="text-xs text-gray-500">
                      {new Date(insight.createdAt).toLocaleDateString()}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8">
              <ChartBarIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500 mb-4">No insights yet</p>
              <p className="text-sm text-gray-400">
                Keep journaling to generate personalized insights
              </p>
            </div>
          )}
        </Card>
      </div>

      {/* Mood Overview */}
      {stats?.moodStats?.length > 0 && (
        <Card>
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Mood Overview (Last 7 Days)</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
            {stats.moodStats.map((moodStat: any) => (
              <div key={moodStat._id} className="text-center">
                <div className={`text-3xl mb-2 ${getMoodColor(moodStat._id)}`}>
                  {getMoodEmoji(moodStat._id)}
                </div>
                <p className="text-sm font-medium text-gray-900">{moodStat.count}</p>
                <p className="text-xs text-gray-500 capitalize">
                  {moodStat._id.replace('-', ' ')}
                </p>
              </div>
            ))}
          </div>
        </Card>
      )}
    </div>
  );
};

export default Dashboard;
