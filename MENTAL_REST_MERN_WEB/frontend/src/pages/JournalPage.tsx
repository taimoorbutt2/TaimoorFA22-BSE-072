import React, { useState, useEffect } from 'react';

const JournalPage = () => {
  const [user, setUser] = useState<any>(null);
  const [entries, setEntries] = useState<any[]>([]);
  const [currentEntry, setCurrentEntry] = useState({
    id: null,
    content: '',
    mood: '',
    tags: '',
    date: new Date().toISOString().split('T')[0]
  });
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState<{type: 'success' | 'error', text: string} | null>(null);

  const guidedPrompts = [
    "What are three things you're grateful for today?",
    "Describe a moment that made you smile today.",
    "What challenge did you overcome recently?",
    "How are you feeling right now, and why?",
    "What would you like to let go of today?",
    "What's one thing you learned about yourself this week?",
    "Describe your ideal day in detail.",
    "What's something you're looking forward to?",
    "How did you take care of yourself today?",
    "What's a small win you had today?"
  ];

  const moodOptions = [
    { value: 'happy', emoji: '😊', label: 'Happy' },
    { value: 'sad', emoji: '😢', label: 'Sad' },
    { value: 'angry', emoji: '😠', label: 'Angry' },
    { value: 'anxious', emoji: '😰', label: 'Anxious' },
    { value: 'calm', emoji: '😌', label: 'Calm' },
    { value: 'excited', emoji: '🤩', label: 'Excited' },
    { value: 'grateful', emoji: '🙏', label: 'Grateful' },
    { value: 'stressed', emoji: '😓', label: 'Stressed' },
    { value: 'peaceful', emoji: '🧘', label: 'Peaceful' },
    { value: 'motivated', emoji: '💪', label: 'Motivated' },
    { value: 'confused', emoji: '😕', label: 'Confused' },
    { value: 'hopeful', emoji: '🌟', label: 'Hopeful' }
  ];

  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }
    
    // Load existing entries from localStorage
    const storedEntries = localStorage.getItem('journalEntries');
    if (storedEntries) {
      setEntries(JSON.parse(storedEntries));
    }
  }, []);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setCurrentEntry(prev => ({
      ...prev,
      [name]: value
    }));
    setMessage(null);
  };

  const handlePromptClick = (prompt: string) => {
    setCurrentEntry(prev => ({
      ...prev,
      content: prev.content + (prev.content ? '\n\n' : '') + prompt + '\n'
    }));
  };

  const handleSave = async () => {
    if (!currentEntry.content.trim()) {
      setMessage({ type: 'error', text: 'Please write something before saving.' });
      return;
    }

    setIsSaving(true);
    
    try {
      const newEntry = {
        id: currentEntry.id || Date.now(),
        content: currentEntry.content,
        mood: currentEntry.mood,
        tags: currentEntry.tags.split(',').map(tag => tag.trim()).filter(tag => tag),
        date: currentEntry.date,
        createdAt: new Date().toISOString()
      };

      let updatedEntries;
      if (isEditing) {
        updatedEntries = entries.map(entry => 
          entry.id === currentEntry.id ? newEntry : entry
        );
      } else {
        updatedEntries = [newEntry, ...entries];
      }

      setEntries(updatedEntries);
      localStorage.setItem('journalEntries', JSON.stringify(updatedEntries));
      
      setCurrentEntry({
        id: null,
        content: '',
        mood: '',
        tags: '',
        date: new Date().toISOString().split('T')[0]
      });
      setIsEditing(false);
      setMessage({ type: 'success', text: 'Entry saved successfully!' });
    } catch (error) {
      setMessage({ type: 'error', text: 'Failed to save entry. Please try again.' });
    } finally {
      setIsSaving(false);
    }
  };

  const handleEdit = (entry: any) => {
    setCurrentEntry({
      id: entry.id,
      content: entry.content,
      mood: entry.mood,
      tags: entry.tags.join(', '),
      date: entry.date
    });
    setIsEditing(true);
    setMessage(null);
  };

  const handleDelete = (entryId: number) => {
    if (window.confirm('Are you sure you want to delete this entry?')) {
      const updatedEntries = entries.filter(entry => entry.id !== entryId);
      setEntries(updatedEntries);
      localStorage.setItem('journalEntries', JSON.stringify(updatedEntries));
      setMessage({ type: 'success', text: 'Entry deleted successfully!' });
    }
  };

  const handleNewEntry = () => {
    setCurrentEntry({
      id: null,
      content: '',
      mood: '',
      tags: '',
      date: new Date().toISOString().split('T')[0]
    });
    setIsEditing(false);
    setMessage(null);
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
              <a href="/journal" className="text-blue-600 font-medium">Journal</a>
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
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Journal Editor */}
          <div className="lg:col-span-2 space-y-6">
            {/* Journal Editor */}
            <div className="bg-white rounded-3xl p-8 shadow-lg hover:shadow-xl transition-all duration-300">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-gray-800">
                  {isEditing ? 'Edit Entry' : 'New Journal Entry'}
                </h2>
                <button
                  onClick={handleNewEntry}
                  className="px-4 py-2 text-blue-600 hover:text-blue-800 font-medium transition-colors"
                >
                  New Entry
                </button>
              </div>

              {/* Date and Mood Selector */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Date
                  </label>
                  <input
                    type="date"
                    name="date"
                    value={currentEntry.date}
                    onChange={handleInputChange}
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    How are you feeling?
                  </label>
                  <select
                    name="mood"
                    value={currentEntry.mood}
                    onChange={handleInputChange}
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300"
                  >
                    <option value="">Select your mood</option>
                    {moodOptions.map((mood) => (
                      <option key={mood.value} value={mood.value}>
                        {mood.emoji} {mood.label}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Text Editor */}
              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  What's on your mind?
                </label>
                <textarea
                  name="content"
                  value={currentEntry.content}
                  onChange={handleInputChange}
                  rows={12}
                  placeholder="Start writing about your day, thoughts, feelings, or anything that's on your mind..."
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300 resize-none"
                />
                <div className="text-sm text-gray-500 mt-2">
                  {currentEntry.content.length} characters
                </div>
              </div>

              {/* Tags */}
              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tags (comma-separated)
                </label>
                <input
                  type="text"
                  name="tags"
                  value={currentEntry.tags}
                  onChange={handleInputChange}
                  placeholder="work, family, gratitude, stress..."
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300"
                />
              </div>

              {/* Save Button */}
              <div className="flex items-center justify-between">
                <button
                  onClick={handleSave}
                  disabled={isSaving}
                  className="px-8 py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-xl shadow-lg hover:shadow-xl transform hover:-translate-y-1 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
                >
                  {isSaving ? (
                    <div className="flex items-center">
                      <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                      Saving...
                    </div>
                  ) : (
                    isEditing ? 'Update Entry' : 'Save Entry'
                  )}
                </button>
                
                {isEditing && (
                  <button
                    onClick={handleNewEntry}
                    className="px-6 py-3 text-gray-600 hover:text-gray-800 font-medium transition-colors"
                  >
                    Cancel
                  </button>
                )}
              </div>

              {/* Message */}
              {message && (
                <div className={`mt-4 p-4 rounded-xl ${
                  message.type === 'success' 
                    ? 'bg-green-100 border border-green-400 text-green-700' 
                    : 'bg-red-100 border border-red-400 text-red-700'
                }`}>
                  <div className="flex items-center">
                    <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      {message.type === 'success' ? (
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      ) : (
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      )}
                    </svg>
                    {message.text}
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Right Column - Guided Prompts & Recent Entries */}
          <div className="space-y-6">
            {/* Guided Prompts */}
            <div className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-xl font-bold text-gray-800 mb-4">Guided Prompts</h3>
              <p className="text-gray-600 text-sm mb-4">Click on a prompt to add it to your entry:</p>
              <div className="space-y-3">
                {guidedPrompts.map((prompt, index) => (
                  <button
                    key={index}
                    onClick={() => handlePromptClick(prompt)}
                    className="w-full text-left p-3 bg-gradient-to-r from-blue-50 to-purple-50 rounded-xl hover:from-blue-100 hover:to-purple-100 transition-all duration-300 border border-blue-200 hover:border-blue-300"
                  >
                    <span className="text-sm text-gray-700">{prompt}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Recent Entries */}
            <div className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-xl transition-all duration-300">
              <h3 className="text-xl font-bold text-gray-800 mb-4">Recent Entries</h3>
              {entries.length === 0 ? (
                <p className="text-gray-500 text-center py-8">No entries yet. Start writing your first journal entry!</p>
              ) : (
                <div className="space-y-4">
                  {entries.slice(0, 5).map((entry) => {
                    const moodOption = moodOptions.find(m => m.value === entry.mood);
                    return (
                      <div key={entry.id} className="border border-gray-200 rounded-xl p-4 hover:shadow-md transition-all duration-300">
                        <div className="flex items-center justify-between mb-2">
                          <div className="flex items-center space-x-2">
                            {moodOption && (
                              <>
                                <span className="text-lg">{moodOption.emoji}</span>
                                <span className="text-sm font-medium text-gray-700">{moodOption.label}</span>
                              </>
                            )}
                          </div>
                          <span className="text-xs text-gray-500">{entry.date}</span>
                        </div>
                        <p className="text-gray-600 text-sm mb-3 line-clamp-3">
                          {entry.content.substring(0, 100)}...
                        </p>
                        {entry.tags.length > 0 && (
                          <div className="flex flex-wrap gap-1 mb-3">
                            {entry.tags.map((tag: string, index: number) => (
                              <span key={index} className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">
                                #{tag}
                              </span>
                            ))}
                          </div>
                        )}
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handleEdit(entry)}
                            className="text-blue-600 hover:text-blue-800 text-sm font-medium transition-colors"
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => handleDelete(entry.id)}
                            className="text-red-600 hover:text-red-800 text-sm font-medium transition-colors"
                          >
                            Delete
                          </button>
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

export default JournalPage;
