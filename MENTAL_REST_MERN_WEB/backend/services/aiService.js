const axios = require('axios');

class AIService {
  constructor() {
    this.baseURL = process.env.OLLAMA_BASE_URL || 'http://localhost:11434';
    this.model = process.env.OLLAMA_MODEL || 'gemma:2b';
    this.timeout = 30000; // 30 seconds timeout
  }

  // Check if Ollama server is running
  async checkServerHealth() {
    try {
      const response = await axios.get(`${this.baseURL}/api/tags`, {
        timeout: 5000
      });
      return {
        isRunning: true,
        models: response.data.models || []
      };
    } catch (error) {
      console.error('Ollama server health check failed:', error.message);
      return {
        isRunning: false,
        error: error.message
      };
    }
  }

  // Analyze sentiment of journal entry
  async analyzeSentiment(text) {
    try {
      const prompt = `Analyze the emotional sentiment of the following journal entry. Respond with a JSON object containing:
      - sentiment: "positive", "negative", or "neutral"
      - confidence: a number between 0 and 1
      - keywords: an array of 3-5 key emotional words
      - summary: a brief 1-2 sentence summary
      - suggestions: an array of 2-3 helpful suggestions for mental wellness

      Journal entry: "${text}"

      Respond only with valid JSON:`;

      const response = await this.generateResponse(prompt);
      
      // Try to parse JSON response
      try {
        const analysis = JSON.parse(response);
        return {
          sentiment: analysis.sentiment || 'neutral',
          confidence: Math.min(Math.max(analysis.confidence || 0.5, 0), 1),
          keywords: analysis.keywords || [],
          summary: analysis.summary || 'No summary available',
          suggestions: analysis.suggestions || []
        };
      } catch (parseError) {
        // Fallback if JSON parsing fails
        return this.parseFallbackSentiment(response);
      }
    } catch (error) {
      console.error('Sentiment analysis error:', error.message);
      return {
        sentiment: 'neutral',
        confidence: 0.5,
        keywords: [],
        summary: 'Unable to analyze sentiment at this time',
        suggestions: ['Consider taking a moment to reflect on your feelings', 'Try some deep breathing exercises']
      };
    }
  }

  // Generate wellness tips based on mood patterns
  async generateWellnessTips(moodData, userPreferences = {}) {
    try {
      const prompt = `Based on the following mood data, generate personalized wellness tips. Respond with a JSON object containing:
      - tips: an array of 3-5 specific, actionable wellness tips
      - focus: the main area to focus on (e.g., "stress management", "positive thinking", "self-care")
      - encouragement: a motivational message

      Mood data: ${JSON.stringify(moodData)}
      User preferences: ${JSON.stringify(userPreferences)}

      Respond only with valid JSON:`;

      const response = await this.generateResponse(prompt);
      
      try {
        const tips = JSON.parse(response);
        return {
          tips: tips.tips || ['Take a 5-minute break', 'Practice gratitude', 'Get some fresh air'],
          focus: tips.focus || 'general wellness',
          encouragement: tips.encouragement || 'You\'re doing great! Keep taking care of yourself.'
        };
      } catch (parseError) {
        return this.parseFallbackTips(response);
      }
    } catch (error) {
      console.error('Wellness tips generation error:', error.message);
      return {
        tips: [
          'Take a 5-minute break to breathe deeply',
          'Write down three things you\'re grateful for',
          'Go for a short walk outside',
          'Listen to calming music',
          'Practice mindfulness meditation'
        ],
        focus: 'general wellness',
        encouragement: 'Remember to be kind to yourself. Small steps lead to big changes.'
      };
    }
  }

  // Generate guided journal prompts
  async generateJournalPrompts(category = 'general', userMood = 'neutral') {
    try {
      const prompt = `Generate 3 creative journal prompts for ${category} category, considering the user's current mood: ${userMood}. 
      Respond with a JSON object containing:
      - prompts: an array of 3 prompt objects, each with "title" and "content"
      - difficulty: "beginner", "intermediate", or "advanced"
      - estimatedTime: time in minutes

      Respond only with valid JSON:`;

      const response = await this.generateResponse(prompt);
      
      try {
        const prompts = JSON.parse(response);
        return {
          prompts: prompts.prompts || this.getDefaultPrompts(category),
          difficulty: prompts.difficulty || 'beginner',
          estimatedTime: prompts.estimatedTime || 5
        };
      } catch (parseError) {
        return {
          prompts: this.getDefaultPrompts(category),
          difficulty: 'beginner',
          estimatedTime: 5
        };
      }
    } catch (error) {
      console.error('Prompt generation error:', error.message);
      return {
        prompts: this.getDefaultPrompts(category),
        difficulty: 'beginner',
        estimatedTime: 5
      };
    }
  }

  // Core method to generate responses from Ollama
  async generateResponse(prompt) {
    try {
      const response = await axios.post(`${this.baseURL}/api/generate`, {
        model: this.model,
        prompt: prompt,
        stream: false,
        options: {
          temperature: 0.7,
          top_p: 0.9,
          max_tokens: 500
        }
      }, {
        timeout: this.timeout
      });

      return response.data.response || '';
    } catch (error) {
      if (error.code === 'ECONNREFUSED') {
        throw new Error('Ollama server is not running. Please start it with: ollama serve');
      }
      throw error;
    }
  }

  // Fallback sentiment parsing when JSON parsing fails
  parseFallbackSentiment(response) {
    const sentiment = response.toLowerCase().includes('positive') ? 'positive' :
                     response.toLowerCase().includes('negative') ? 'negative' : 'neutral';
    
    return {
      sentiment,
      confidence: 0.6,
      keywords: ['emotional', 'reflection'],
      summary: response.substring(0, 100) + '...',
      suggestions: ['Consider your emotional state', 'Take time for self-reflection']
    };
  }

  // Fallback tips parsing when JSON parsing fails
  parseFallbackTips(response) {
    return {
      tips: [
        'Take a 5-minute break to breathe deeply',
        'Write down three things you\'re grateful for',
        'Go for a short walk outside'
      ],
      focus: 'general wellness',
      encouragement: 'You\'re doing great! Keep taking care of yourself.'
    };
  }

  // Default prompts when AI generation fails
  getDefaultPrompts(category) {
    const defaultPrompts = {
      gratitude: [
        { title: 'Three Good Things', content: 'Write about three good things that happened today, no matter how small.' },
        { title: 'Grateful Person', content: 'Think of someone you\'re grateful for and write about why they mean so much to you.' },
        { title: 'Simple Pleasures', content: 'What simple pleasures brought you joy today?' }
      ],
      reflection: [
        { title: 'Today\'s Learning', content: 'What did you learn about yourself today?' },
        { title: 'Growth Moment', content: 'Describe a moment today when you felt you grew or improved.' },
        { title: 'Challenges Overcome', content: 'What challenge did you face today and how did you handle it?' }
      ],
      mindfulness: [
        { title: 'Present Moment', content: 'Describe what you\'re experiencing right now using all your senses.' },
        { title: 'Breath Awareness', content: 'Write about your breathing and how it feels in this moment.' },
        { title: 'Body Scan', content: 'Notice how your body feels right now and write about any sensations.' }
      ],
      general: [
        { title: 'Free Write', content: 'Write whatever comes to mind. Don\'t worry about structure or grammar.' },
        { title: 'Emotional Check-in', content: 'How are you feeling right now? What emotions are present?' },
        { title: 'Day Summary', content: 'Summarize your day in a few sentences. What stood out?' }
      ]
    };

    return defaultPrompts[category] || defaultPrompts.general;
  }

  // Batch analyze multiple entries
  async batchAnalyzeSentiment(entries) {
    try {
      const results = [];
      
      for (const entry of entries) {
        const analysis = await this.analyzeSentiment(entry.content);
        results.push({
          entryId: entry._id,
          analysis
        });
      }
      
      return results;
    } catch (error) {
      console.error('Batch sentiment analysis error:', error.message);
      return [];
    }
  }
}

module.exports = new AIService();
