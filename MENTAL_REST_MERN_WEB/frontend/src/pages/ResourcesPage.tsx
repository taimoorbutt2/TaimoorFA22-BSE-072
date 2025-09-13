import React, { useState, useEffect } from 'react';

const ResourcesPage = () => {
  const [user, setUser] = useState<any>(null);
  const [goals, setGoals] = useState<any[]>([]);
  const [newGoal, setNewGoal] = useState({
    title: '',
    description: '',
    targetDate: '',
    category: 'wellness'
  });
  const [isAddingGoal, setIsAddingGoal] = useState(false);

  const mindfulnessGuides = [
    {
      id: 1,
      title: "5-Minute Breathing Exercise",
      description: "A quick breathing technique to reduce stress and anxiety",
      duration: "5 minutes",
      category: "Breathing",
      steps: [
        "Find a comfortable seated position",
        "Close your eyes and relax your shoulders",
        "Inhale slowly through your nose for 4 counts",
        "Hold your breath for 4 counts",
        "Exhale slowly through your mouth for 6 counts",
        "Repeat for 5 minutes"
      ],
      benefits: ["Reduces stress", "Improves focus", "Calms the mind"]
    },
    {
      id: 2,
      title: "Body Scan Meditation",
      description: "A mindfulness practice to connect with your body",
      duration: "10 minutes",
      category: "Meditation",
      steps: [
        "Lie down comfortably on your back",
        "Close your eyes and take deep breaths",
        "Start by focusing on your toes",
        "Slowly move your attention up through your body",
        "Notice any tension and breathe into it",
        "End by focusing on your entire body"
      ],
      benefits: ["Reduces tension", "Improves sleep", "Increases body awareness"]
    },
    {
      id: 3,
      title: "Gratitude Journaling",
      description: "Write down things you're grateful for to boost positivity",
      duration: "10 minutes",
      category: "Journaling",
      steps: [
        "Set aside time each morning or evening",
        "Write down 3 things you're grateful for",
        "Be specific about why you're grateful",
        "Reflect on how these things make you feel",
        "Consider sharing your gratitude with others"
      ],
      benefits: ["Increases happiness", "Improves relationships", "Reduces depression"]
    },
    {
      id: 4,
      title: "Mindful Walking",
      description: "Practice mindfulness while walking in nature",
      duration: "15 minutes",
      category: "Movement",
      steps: [
        "Choose a quiet outdoor location",
        "Walk at a comfortable pace",
        "Focus on the sensation of your feet touching the ground",
        "Notice the sounds, smells, and sights around you",
        "If your mind wanders, gently return to the present moment"
      ],
      benefits: ["Reduces anxiety", "Improves mood", "Connects with nature"]
    }
  ];

  const communityTips = [
    {
      id: 1,
      tip: "Start your day with 3 deep breaths before getting out of bed",
      category: "Morning Routine",
      likes: 24
    },
    {
      id: 2,
      tip: "Keep a small notebook by your bed to write down thoughts before sleep",
      category: "Sleep Hygiene",
      likes: 18
    },
    {
      id: 3,
      tip: "Take a 2-minute break every hour to stretch and breathe",
      category: "Work Wellness",
      likes: 31
    },
    {
      id: 4,
      tip: "Practice the 5-4-3-2-1 grounding technique when feeling anxious",
      category: "Anxiety Relief",
      likes: 27
    },
    {
      id: 5,
      tip: "Set a daily intention each morning to guide your day",
      category: "Mindfulness",
      likes: 22
    }
  ];

  const goalCategories = [
    { value: 'wellness', label: 'Wellness', color: 'bg-green-100 text-green-800' },
    { value: 'mindfulness', label: 'Mindfulness', color: 'bg-blue-100 text-blue-800' },
    { value: 'productivity', label: 'Productivity', color: 'bg-purple-100 text-purple-800' },
    { value: 'relationships', label: 'Relationships', color: 'bg-pink-100 text-pink-800' },
    { value: 'learning', label: 'Learning', color: 'bg-yellow-100 text-yellow-800' }
  ];

  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }
    
    const storedGoals = localStorage.getItem('wellnessGoals');
    if (storedGoals) {
      setGoals(JSON.parse(storedGoals));
    }
  }, []);

  const handleAddGoal = () => {
    if (!newGoal.title.trim()) return;

    const goal = {
      id: Date.now(),
      ...newGoal,
      createdAt: new Date().toISOString(),
      completed: false,
      progress: 0
    };

    const updatedGoals = [...goals, goal];
    setGoals(updatedGoals);
    localStorage.setItem('wellnessGoals', JSON.stringify(updatedGoals));
    
    setNewGoal({ title: '', description: '', targetDate: '', category: 'wellness' });
    setIsAddingGoal(false);
  };

  const handleDeleteGoal = (goalId: number) => {
    if (window.confirm('Are you sure you want to delete this goal?')) {
      const updatedGoals = goals.filter(goal => goal.id !== goalId);
      setGoals(updatedGoals);
      localStorage.setItem('wellnessGoals', JSON.stringify(updatedGoals));
    }
  };

  const handleUpdateProgress = (goalId: number, progress: number) => {
    const updatedGoals = goals.map(goal => 
      goal.id === goalId ? { ...goal, progress: Math.min(100, Math.max(0, progress)) } : goal
    );
    setGoals(updatedGoals);
    localStorage.setItem('wellnessGoals', JSON.stringify(updatedGoals));
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
              <a href="/dashboard" className="text-gray-600 hover:text-blue-600 transition-colors">Dashboard</a>
              <a href="/journal" className="text-gray-600 hover:text-blue-600 transition-colors">Journal</a>
              <a href="/insights" className="text-gray-600 hover:text-blue-600 transition-colors">Insights</a>
              <a href="/resources" className="text-blue-600 font-medium">Resources</a>
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
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-800 mb-2">Wellness Resources</h2>
          <p className="text-gray-600">Explore mindfulness guides, set wellness goals, and discover community tips</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Mindfulness Guides */}
          <div className="lg:col-span-2 space-y-6">
            <div className="bg-white rounded-3xl p-8 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-2xl font-bold text-gray-800 mb-6">Mindfulness Guides</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {mindfulnessGuides.map((guide) => (
                  <div key={guide.id} className="border border-gray-200 rounded-2xl p-6 hover:shadow-md transition-all duration-300">
                    <div className="flex items-start justify-between mb-4">
                      <div>
                        <h4 className="text-lg font-semibold text-gray-800 mb-2">{guide.title}</h4>
                        <p className="text-gray-600 text-sm mb-3">{guide.description}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500">
                          <span className="flex items-center">
                            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            {guide.duration}
                          </span>
                          <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-xs">
                            {guide.category}
                          </span>
                        </div>
                      </div>
                    </div>
                    
                    <div className="mb-4">
                      <h5 className="font-medium text-gray-700 mb-2">Steps:</h5>
                      <ol className="text-sm text-gray-600 space-y-1">
                        {guide.steps.map((step, index) => (
                          <li key={index} className="flex items-start">
                            <span className="font-medium mr-2">{index + 1}.</span>
                            {step}
                          </li>
                        ))}
                      </ol>
                    </div>
                    
                    <div>
                      <h5 className="font-medium text-gray-700 mb-2">Benefits:</h5>
                      <div className="flex flex-wrap gap-2">
                        {guide.benefits.map((benefit, index) => (
                          <span key={index} className="px-2 py-1 bg-green-100 text-green-800 rounded-full text-xs">
                            {benefit}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Right Column - Goals & Community Tips */}
          <div className="space-y-6">
            {/* Goal Tracker */}
            <div className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-gray-800">Wellness Goals</h3>
                <button
                  onClick={() => setIsAddingGoal(!isAddingGoal)}
                  className="px-4 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-xl hover:shadow-lg transform hover:-translate-y-1 transition-all duration-300"
                >
                  Add Goal
                </button>
              </div>

              {/* Add Goal Form */}
              {isAddingGoal && (
                <div className="mb-6 p-4 bg-gray-50 rounded-xl">
                  <div className="space-y-4">
                    <input
                      type="text"
                      placeholder="Goal title"
                      value={newGoal.title}
                      onChange={(e) => setNewGoal({...newGoal, title: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                    <textarea
                      placeholder="Description (optional)"
                      value={newGoal.description}
                      onChange={(e) => setNewGoal({...newGoal, description: e.target.value})}
                      rows={2}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                    />
                    <div className="grid grid-cols-2 gap-3">
                      <select
                        value={newGoal.category}
                        onChange={(e) => setNewGoal({...newGoal, category: e.target.value})}
                        className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      >
                        {goalCategories.map((category) => (
                          <option key={category.value} value={category.value}>
                            {category.label}
                          </option>
                        ))}
                      </select>
                      <input
                        type="date"
                        value={newGoal.targetDate}
                        onChange={(e) => setNewGoal({...newGoal, targetDate: e.target.value})}
                        className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      />
                    </div>
                    <div className="flex space-x-2">
                      <button
                        onClick={handleAddGoal}
                        className="px-4 py-2 bg-green-500 text-white font-semibold rounded-lg hover:bg-green-600 transition-colors"
                      >
                        Save Goal
                      </button>
                      <button
                        onClick={() => setIsAddingGoal(false)}
                        className="px-4 py-2 bg-gray-500 text-white font-semibold rounded-lg hover:bg-gray-600 transition-colors"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {/* Goals List */}
              <div className="space-y-4">
                {goals.length === 0 ? (
                  <p className="text-gray-500 text-center py-4">No goals set yet. Add your first wellness goal!</p>
                ) : (
                  goals.map((goal) => {
                    const category = goalCategories.find(c => c.value === goal.category);
                    return (
                      <div key={goal.id} className="border border-gray-200 rounded-xl p-4">
                        <div className="flex items-start justify-between mb-3">
                          <div className="flex-1">
                            <h4 className="font-semibold text-gray-800 mb-1">{goal.title}</h4>
                            {goal.description && (
                              <p className="text-gray-600 text-sm mb-2">{goal.description}</p>
                            )}
                            <div className="flex items-center space-x-3">
                              <span className={`px-2 py-1 rounded-full text-xs ${category?.color}`}>
                                {category?.label}
                              </span>
                              {goal.targetDate && (
                                <span className="text-xs text-gray-500">
                                  Target: {new Date(goal.targetDate).toLocaleDateString()}
                                </span>
                              )}
                            </div>
                          </div>
                          <button
                            onClick={() => handleDeleteGoal(goal.id)}
                            className="text-red-500 hover:text-red-700 transition-colors"
                          >
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                            </svg>
                          </button>
                        </div>
                        <div className="flex items-center space-x-3">
                          <div className="flex-1 bg-gray-200 rounded-full h-2">
                            <div
                              className="bg-gradient-to-r from-blue-500 to-purple-600 h-2 rounded-full transition-all duration-300"
                              style={{ width: `${goal.progress}%` }}
                            />
                          </div>
                          <span className="text-sm font-medium text-gray-700 w-12 text-right">
                            {goal.progress}%
                          </span>
                        </div>
                        <div className="flex space-x-2 mt-3">
                          {[0, 25, 50, 75, 100].map((value) => (
                            <button
                              key={value}
                              onClick={() => handleUpdateProgress(goal.id, value)}
                              className={`px-2 py-1 text-xs rounded ${
                                goal.progress === value
                                  ? 'bg-blue-500 text-white'
                                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                              } transition-colors`}
                            >
                              {value}%
                            </button>
                          ))}
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            </div>

            {/* Community Tips */}
            <div className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-xl font-bold text-gray-800 mb-6">Community Tips</h3>
              <div className="space-y-4">
                {communityTips.map((tip) => (
                  <div key={tip.id} className="border border-gray-200 rounded-xl p-4 hover:shadow-md transition-all duration-300">
                    <p className="text-gray-700 text-sm mb-3">{tip.tip}</p>
                    <div className="flex items-center justify-between">
                      <span className="px-2 py-1 bg-purple-100 text-purple-800 rounded-full text-xs">
                        {tip.category}
                      </span>
                      <div className="flex items-center space-x-1 text-gray-500">
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                        </svg>
                        <span className="text-xs">{tip.likes}</span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default ResourcesPage;
