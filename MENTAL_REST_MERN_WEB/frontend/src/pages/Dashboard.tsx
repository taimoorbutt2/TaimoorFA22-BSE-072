import React, { useState, useEffect } from 'react';

const Dashboard = () => {
  const [user, setUser] = useState<any>(null);
  const [moodData, setMoodData] = useState({
    today: 'happy',
    streak: 5,
    totalEntries: 12,
    favorites: 8,
    bestStreak: 15
  });
  const [recentEntries, setRecentEntries] = useState([
    {
      id: 1,
      date: '2024-01-15',
      mood: 'happy',
      preview: 'Had a great day at work today. Feeling motivated and productive...',
      tags: ['work', 'productivity']
    },
    {
      id: 2,
      date: '2024-01-14',
      mood: 'calm',
      preview: 'Spent the evening reading and reflecting. Found peace in solitude...',
      tags: ['reading', 'reflection']
    },
    {
      id: 3,
      date: '2024-01-13',
      mood: 'grateful',
      preview: 'Grateful for the support of friends and family. Life is beautiful...',
      tags: ['gratitude', 'family']
    }
  ]);
  const [aiInsight, setAiInsight] = useState('You\'ve been feeling calmer this week. Your journal entries show improved positivity and mindfulness practices.');

  useEffect(() => {
    // Get user data from localStorage or API
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }
  }, []);

  const moodEmojis = {
    happy: '😊',
    sad: '😢',
    angry: '😠',
    anxious: '😰',
    calm: '😌',
    excited: '🤩',
    grateful: '🙏',
    stressed: '😓',
    peaceful: '🧘',
    motivated: '💪'
  };

  const moodColors = {
    happy: 'from-yellow-400 to-orange-400',
    sad: 'from-blue-400 to-indigo-400',
    angry: 'from-red-400 to-pink-400',
    anxious: 'from-purple-400 to-indigo-400',
    calm: 'from-green-400 to-teal-400',
    excited: 'from-pink-400 to-purple-400',
    grateful: 'from-orange-400 to-yellow-400',
    stressed: 'from-gray-400 to-slate-400',
    peaceful: 'from-emerald-400 to-green-400',
    motivated: 'from-blue-500 to-purple-500'
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-4">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center">
                <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                </svg>
              </div>
              <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                MindSpace
              </h1>
            </div>
            <nav className="hidden md:flex space-x-8">
              <a href="/dashboard" className="text-blue-600 font-medium">Dashboard</a>
              <a href="/journal" className="text-gray-600 hover:text-blue-600 transition-colors">Journal</a>
              <a href="/insights" className="text-gray-600 hover:text-blue-600 transition-colors">Insights</a>
              <a href="/resources" className="text-gray-600 hover:text-blue-600 transition-colors">Resources</a>
              <a href="/profile" className="text-gray-600 hover:text-blue-600 transition-colors">Profile</a>
            </nav>
            <div className="flex items-center space-x-4">
              <span className="text-gray-700">Welcome, {user?.name || 'User'}!</span>
              <button 
                onClick={() => {
                  localStorage.removeItem('token');
                  localStorage.removeItem('user');
                  window.location.href = '/';
                }}
                className="px-4 py-2 text-gray-600 hover:text-red-600 transition-colors"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Welcome Section */}
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-800 mb-2">
            Welcome back, {user?.name || 'User'}! 👋
          </h2>
          <p className="text-gray-600">
            How are you feeling today? Let's continue your mental wellness journey.
          </p>
        </div>

        {/* Dashboard Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Mood Ring & Quick Actions */}
          <div className="lg:col-span-1 space-y-6">
            {/* Mood Ring */}
            <div className="bg-white rounded-3xl p-8 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-xl font-bold text-gray-800 mb-6 text-center">Today's Mood</h3>
              <div className="flex flex-col items-center">
                <div className={`w-32 h-32 rounded-full bg-gradient-to-br ${moodColors[moodData.today as keyof typeof moodColors]} flex items-center justify-center mb-4 shadow-lg`}>
                  <span className="text-6xl">{moodEmojis[moodData.today as keyof typeof moodEmojis]}</span>
                </div>
                <p className="text-lg font-semibold text-gray-700 capitalize mb-2">{moodData.today}</p>
                <p className="text-sm text-gray-500 text-center">
                  You're doing great! Keep up the positive energy.
                </p>
              </div>
            </div>

            {/* Quick Actions */}
            <div className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-xl font-bold text-gray-800 mb-6">Quick Actions</h3>
              <div className="space-y-4">
                <a 
                  href="/journal"
                  className="w-full flex items-center justify-center px-6 py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-xl hover:shadow-lg transform hover:-translate-y-1 transition-all duration-300"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                  </svg>
                  Write Journal
                </a>
                <a 
                  href="/insights"
                  className="w-full flex items-center justify-center px-6 py-3 bg-gradient-to-r from-green-500 to-teal-600 text-white font-semibold rounded-xl hover:shadow-lg transform hover:-translate-y-1 transition-all duration-300"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                  Track Mood
                </a>
                <a 
                  href="/resources"
                  className="w-full flex items-center justify-center px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-600 text-white font-semibold rounded-xl hover:shadow-lg transform hover:-translate-y-1 transition-all duration-300"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                  </svg>
                  Explore Resources
                </a>
              </div>
            </div>
          </div>

          {/* Right Column - Recent Entries & Stats */}
          <div className="lg:col-span-2 space-y-6">
            {/* Stats Overview */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="bg-white rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
                <div className="text-3xl font-bold text-blue-600 mb-2">{moodData.totalEntries}</div>
                <div className="text-blue-800 font-medium">Total Entries</div>
              </div>
              <div className="bg-white rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
                <div className="text-3xl font-bold text-green-600 mb-2">{moodData.streak}</div>
                <div className="text-green-800 font-medium">Day Streak</div>
              </div>
              <div className="bg-white rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
                <div className="text-3xl font-bold text-purple-600 mb-2">{moodData.favorites}</div>
                <div className="text-purple-800 font-medium">Favorites</div>
              </div>
              <div className="bg-white rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
                <div className="text-3xl font-bold text-orange-600 mb-2">{moodData.bestStreak}</div>
                <div className="text-orange-800 font-medium">Best Streak</div>
              </div>
            </div>

            {/* Recent Entries */}
            <div className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-gray-800">Recent Entries</h3>
                <a 
                  href="/journal"
                  className="text-blue-600 hover:text-blue-800 font-medium transition-colors"
                >
                  View All
                </a>
              </div>
              <div className="space-y-4">
                {recentEntries.map((entry) => (
                  <div key={entry.id} className="border border-gray-200 rounded-xl p-4 hover:shadow-md transition-all duration-300">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center space-x-3">
                        <span className="text-2xl">{moodEmojis[entry.mood as keyof typeof moodEmojis]}</span>
                        <span className="font-semibold text-gray-800 capitalize">{entry.mood}</span>
                      </div>
                      <span className="text-sm text-gray-500">{entry.date}</span>
                    </div>
                    <p className="text-gray-600 mb-3">{entry.preview}</p>
                    <div className="flex flex-wrap gap-2">
                      {entry.tags.map((tag, index) => (
                        <span key={index} className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">
                          #{tag}
                        </span>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* AI Insights */}
            <div className="bg-gradient-to-br from-indigo-50 to-purple-50 rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 border border-indigo-200">
              <div className="flex items-center mb-4">
                <div className="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl flex items-center justify-center mr-3">
                  <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                  </svg>
                </div>
                <h3 className="text-xl font-bold text-gray-800">AI Insights</h3>
              </div>
              <p className="text-gray-700 leading-relaxed mb-4">{aiInsight}</p>
              <div className="flex items-center text-sm text-indigo-600">
                <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Powered by AI • Updated 2 hours ago
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;