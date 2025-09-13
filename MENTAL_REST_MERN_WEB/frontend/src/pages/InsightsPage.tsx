import React, { useState, useEffect } from 'react';

const InsightsPage = () => {
  const [user, setUser] = useState<any>(null);
  const [entries, setEntries] = useState<any[]>([]);
  const [selectedPeriod, setSelectedPeriod] = useState('week');
  const [isExporting, setIsExporting] = useState(false);

  const moodOptions = [
    { value: 'happy', emoji: '😊', label: 'Happy', color: '#FCD34D' },
    { value: 'sad', emoji: '😢', label: 'Sad', color: '#60A5FA' },
    { value: 'angry', emoji: '😠', label: 'Angry', color: '#F87171' },
    { value: 'anxious', emoji: '😰', label: 'Anxious', color: '#A78BFA' },
    { value: 'calm', emoji: '😌', label: 'Calm', color: '#34D399' },
    { value: 'excited', emoji: '🤩', label: 'Excited', color: '#F472B6' },
    { value: 'grateful', emoji: '🙏', label: 'Grateful', color: '#FB923C' },
    { value: 'stressed', emoji: '😓', label: 'Stressed', color: '#9CA3AF' },
    { value: 'peaceful', emoji: '🧘', label: 'Peaceful', color: '#10B981' },
    { value: 'motivated', emoji: '💪', label: 'Motivated', color: '#3B82F6' }
  ];

  const aiInsights = [
    {
      title: "Mood Trend Analysis",
      content: "Your mood has been generally positive this week, with 70% of entries showing happy or calm emotions. You've been particularly grateful and motivated on weekdays.",
      type: "positive"
    },
    {
      title: "Pattern Recognition",
      content: "You tend to feel more stressed on Mondays and more peaceful on weekends. Consider implementing relaxation techniques on Sunday evenings.",
      type: "insight"
    },
    {
      title: "Wellness Recommendations",
      content: "Based on your journal entries, you might benefit from more outdoor activities and social connections. Your entries about nature and friends show increased positivity.",
      type: "recommendation"
    }
  ];

  const wellnessTips = [
    {
      title: "Deep Breathing Exercise",
      description: "Try the 4-7-8 breathing technique: Inhale for 4 counts, hold for 7, exhale for 8.",
      category: "Stress Relief"
    },
    {
      title: "Gratitude Practice",
      description: "Write down three things you're grateful for each morning to start your day positively.",
      category: "Mindfulness"
    },
    {
      title: "Mindful Walking",
      description: "Take a 10-minute walk while focusing on your surroundings and breathing.",
      category: "Physical Wellness"
    },
    {
      title: "Digital Detox",
      description: "Take a 30-minute break from screens before bedtime to improve sleep quality.",
      category: "Sleep Hygiene"
    }
  ];

  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }
    
    const storedEntries = localStorage.getItem('journalEntries');
    if (storedEntries) {
      setEntries(JSON.parse(storedEntries));
    }
  }, []);

  const getMoodData = () => {
    const now = new Date();
    const periodDays = selectedPeriod === 'week' ? 7 : selectedPeriod === 'month' ? 30 : 90;
    const startDate = new Date(now.getTime() - (periodDays * 24 * 60 * 60 * 1000));
    
    const filteredEntries = entries.filter(entry => 
      new Date(entry.date) >= startDate
    );

    const moodCounts = moodOptions.reduce((acc, mood) => {
      acc[mood.value] = filteredEntries.filter(entry => entry.mood === mood.value).length;
      return acc;
    }, {} as Record<string, number>);

    return { filteredEntries, moodCounts };
  };

  const handleExport = async () => {
    setIsExporting(true);
    
    try {
      const { filteredEntries } = getMoodData();
      const exportData = {
        user: user?.name || 'User',
        period: selectedPeriod,
        exportDate: new Date().toISOString(),
        entries: filteredEntries,
        insights: aiInsights
      };

      const dataStr = JSON.stringify(exportData, null, 2);
      const dataBlob = new Blob([dataStr], { type: 'application/json' });
      const url = URL.createObjectURL(dataBlob);
      
      const link = document.createElement('a');
      link.href = url;
      link.download = `mindspace-insights-${selectedPeriod}-${new Date().toISOString().split('T')[0]}.json`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } catch (error) {
      console.error('Export failed:', error);
    } finally {
      setIsExporting(false);
    }
  };

  const { filteredEntries, moodCounts } = getMoodData();
  const totalEntries = filteredEntries.length;
  const mostCommonMood = Object.entries(moodCounts).reduce((a, b) => moodCounts[a[0]] > moodCounts[b[0]] ? a : b, ['happy', 0]);

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
              <a href="/dashboard" className="text-gray-600 hover:text-blue-600 transition-colors">Dashboard</a>
              <a href="/journal" className="text-gray-600 hover:text-blue-600 transition-colors">Journal</a>
              <a href="/insights" className="text-blue-600 font-medium">Insights</a>
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
        {/* Header Section */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-8">
          <div>
            <h2 className="text-3xl font-bold text-gray-800 mb-2">Your Wellness Insights</h2>
            <p className="text-gray-600">Discover patterns and get personalized recommendations</p>
          </div>
          <div className="flex items-center space-x-4 mt-4 md:mt-0">
            <select
              value={selectedPeriod}
              onChange={(e) => setSelectedPeriod(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300"
            >
              <option value="week">Last 7 days</option>
              <option value="month">Last 30 days</option>
              <option value="quarter">Last 90 days</option>
            </select>
            <button
              onClick={handleExport}
              disabled={isExporting}
              className="px-6 py-2 bg-gradient-to-r from-green-500 to-teal-600 text-white font-semibold rounded-xl shadow-lg hover:shadow-xl transform hover:-translate-y-1 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
            >
              {isExporting ? (
                <div className="flex items-center">
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                  Exporting...
                </div>
              ) : (
                'Export Data'
              )}
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Mood Charts & Stats */}
          <div className="lg:col-span-2 space-y-6">
            {/* Mood Distribution Chart */}
            <div className="bg-white rounded-3xl p-8 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-xl font-bold text-gray-800 mb-6">Mood Distribution</h3>
              {totalEntries === 0 ? (
                <div className="text-center py-12">
                  <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                    </svg>
                  </div>
                  <p className="text-gray-500">No entries found for the selected period</p>
                  <p className="text-gray-400 text-sm">Start journaling to see your mood insights</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {moodOptions.map((mood) => {
                    const count = moodCounts[mood.value] || 0;
                    const percentage = totalEntries > 0 ? (count / totalEntries) * 100 : 0;
                    return (
                      <div key={mood.value} className="flex items-center space-x-4">
                        <div className="flex items-center space-x-3 w-32">
                          <span className="text-2xl">{mood.emoji}</span>
                          <span className="text-sm font-medium text-gray-700">{mood.label}</span>
                        </div>
                        <div className="flex-1 bg-gray-200 rounded-full h-4">
                          <div
                            className="h-4 rounded-full transition-all duration-500"
                            style={{
                              width: `${percentage}%`,
                              backgroundColor: mood.color
                            }}
                          />
                        </div>
                        <div className="w-16 text-right">
                          <span className="text-sm font-semibold text-gray-700">{count}</span>
                          <span className="text-xs text-gray-500 ml-1">({percentage.toFixed(1)}%)</span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            {/* AI Insights */}
            <div className="bg-gradient-to-br from-indigo-50 to-purple-50 rounded-3xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 border border-indigo-200">
              <div className="flex items-center mb-6">
                <div className="w-12 h-12 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl flex items-center justify-center mr-4">
                  <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                  </svg>
                </div>
                <h3 className="text-xl font-bold text-gray-800">AI-Powered Insights</h3>
              </div>
              <div className="space-y-6">
                {aiInsights.map((insight, index) => (
                  <div key={index} className="bg-white rounded-2xl p-6 shadow-sm">
                    <div className="flex items-start space-x-3">
                      <div className={`w-3 h-3 rounded-full mt-2 ${
                        insight.type === 'positive' ? 'bg-green-400' :
                        insight.type === 'insight' ? 'bg-blue-400' : 'bg-purple-400'
                      }`} />
                      <div>
                        <h4 className="font-semibold text-gray-800 mb-2">{insight.title}</h4>
                        <p className="text-gray-600 leading-relaxed">{insight.content}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Right Column - Stats & Tips */}
          <div className="space-y-6">
            {/* Quick Stats */}
            <div className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-xl font-bold text-gray-800 mb-6">Quick Stats</h3>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-gray-600">Total Entries</span>
                  <span className="text-2xl font-bold text-blue-600">{totalEntries}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-gray-600">Most Common Mood</span>
                  <div className="flex items-center space-x-2">
                    <span className="text-xl">
                      {moodOptions.find(m => m.value === mostCommonMood[0])?.emoji}
                    </span>
                    <span className="font-semibold text-gray-700">
                      {moodOptions.find(m => m.value === mostCommonMood[0])?.label}
                    </span>
                  </div>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-gray-600">Average per Day</span>
                  <span className="text-2xl font-bold text-green-600">
                    {(totalEntries / (selectedPeriod === 'week' ? 7 : selectedPeriod === 'month' ? 30 : 90)).toFixed(1)}
                  </span>
                </div>
              </div>
            </div>

            {/* Wellness Tips */}
            <div className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-xl font-bold text-gray-800 mb-6">Wellness Tips</h3>
              <div className="space-y-4">
                {wellnessTips.map((tip, index) => (
                  <div key={index} className="border border-gray-200 rounded-xl p-4 hover:shadow-md transition-all duration-300">
                    <div className="flex items-start justify-between mb-2">
                      <h4 className="font-semibold text-gray-800 text-sm">{tip.title}</h4>
                      <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">
                        {tip.category}
                      </span>
                    </div>
                    <p className="text-gray-600 text-sm">{tip.description}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Recent Activity */}
            <div className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-xl font-bold text-gray-800 mb-6">Recent Activity</h3>
              {filteredEntries.length === 0 ? (
                <p className="text-gray-500 text-center py-4">No recent activity</p>
              ) : (
                <div className="space-y-3">
                  {filteredEntries.slice(0, 5).map((entry) => {
                    const moodOption = moodOptions.find(m => m.value === entry.mood);
                    return (
                      <div key={entry.id} className="flex items-center space-x-3">
                        <span className="text-lg">{moodOption?.emoji}</span>
                        <div className="flex-1">
                          <p className="text-sm text-gray-700 line-clamp-1">{entry.content}</p>
                          <p className="text-xs text-gray-500">{entry.date}</p>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default InsightsPage;
