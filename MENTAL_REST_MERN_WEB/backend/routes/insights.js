const express = require('express');
const Journal = require('../models/Journal');
const Insight = require('../models/Insight');
const User = require('../models/User');
const aiService = require('../services/aiService');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/insights
// @desc    Get user insights
// @access  Private
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { 
      type, 
      category, 
      isRead, 
      page = 1, 
      limit = 10,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    const query = { user: req.user._id };

    // Apply filters
    if (type) query.type = type;
    if (category) query.category = category;
    if (isRead !== undefined) query.isRead = isRead === 'true';

    // Sort options
    const sortOptions = {};
    sortOptions[sortBy] = sortOrder === 'desc' ? -1 : 1;

    const insights = await Insight.find(query)
      .sort(sortOptions)
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Insight.countDocuments(query);

    res.json({
      insights,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalInsights: total,
        hasNext: page * limit < total,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error('Get insights error:', error);
    res.status(500).json({
      message: 'Failed to fetch insights',
      code: 'FETCH_INSIGHTS_ERROR'
    });
  }
});

// @route   GET /api/insights/dashboard
// @desc    Get insights dashboard data
// @access  Private
router.get('/dashboard', authenticateToken, async (req, res) => {
  try {
    const { period = '30' } = req.query;
    const days = parseInt(period);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // Get mood trends
    const moodStats = await Journal.getMoodStats(req.user._id, startDate, new Date());

    // Get recent insights
    const recentInsights = await Insight.find({
      user: req.user._id,
      createdAt: { $gte: startDate }
    })
    .sort({ createdAt: -1 })
    .limit(5);

    // Get unread insights count
    const unreadCount = await Insight.countDocuments({
      user: req.user._id,
      isRead: false
    });

    // Get high priority insights
    const highPriorityInsights = await Insight.find({
      user: req.user._id,
      priority: 'high',
      isRead: false
    }).limit(3);

    // Calculate mood trend
    const totalEntries = moodStats.reduce((sum, stat) => sum + stat.count, 0);
    const avgMood = totalEntries > 0 ? moodStats.reduce((sum, stat) => {
      const moodValues = {
        'very-sad': 1, 'sad': 2, 'neutral': 3, 'happy': 4, 'very-happy': 5,
        'anxious': 2, 'stressed': 2, 'calm': 4, 'excited': 4, 'grateful': 5,
        'frustrated': 2, 'peaceful': 4
      };
      return sum + (moodValues[stat._id] * stat.count);
    }, 0) / totalEntries : 3;

    res.json({
      period: `${days} days`,
      moodTrend: {
        average: avgMood,
        stats: moodStats,
        totalEntries
      },
      recentInsights,
      unreadCount,
      highPriorityInsights,
      summary: {
        moodStatus: avgMood >= 4 ? 'positive' : avgMood >= 3 ? 'stable' : 'needs-attention',
        insightsGenerated: recentInsights.length,
        hasHighPriority: highPriorityInsights.length > 0
      }
    });
  } catch (error) {
    console.error('Get insights dashboard error:', error);
    res.status(500).json({
      message: 'Failed to fetch insights dashboard',
      code: 'FETCH_DASHBOARD_ERROR'
    });
  }
});

// @route   POST /api/insights/generate
// @desc    Generate new insights
// @access  Private
router.post('/generate', authenticateToken, async (req, res) => {
  try {
    const { type = 'mood-trend', period = 'weekly' } = req.body;
    let insight = null;

    switch (type) {
      case 'mood-trend':
        insight = await Insight.generateMoodTrendInsight(req.user._id, period);
        break;
      case 'writing-pattern':
        insight = await Insight.generateWritingPatternInsight(req.user._id);
        break;
      case 'ai-sentiment':
        insight = await generateAISentimentInsight(req.user._id, period);
        break;
      default:
        return res.status(400).json({
          message: 'Invalid insight type',
          code: 'INVALID_INSIGHT_TYPE'
        });
    }

    if (!insight) {
      return res.status(404).json({
        message: 'No data available to generate insights',
        code: 'NO_DATA_AVAILABLE'
      });
    }

    await insight.save();

    res.status(201).json({
      message: 'Insight generated successfully',
      insight
    });
  } catch (error) {
    console.error('Generate insight error:', error);
    res.status(500).json({
      message: 'Failed to generate insight',
      code: 'GENERATE_INSIGHT_ERROR'
    });
  }
});

// @route   PUT /api/insights/:id/read
// @desc    Mark insight as read
// @access  Private
router.put('/:id/read', authenticateToken, async (req, res) => {
  try {
    const insight = await Insight.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      { isRead: true },
      { new: true }
    );

    if (!insight) {
      return res.status(404).json({
        message: 'Insight not found',
        code: 'INSIGHT_NOT_FOUND'
      });
    }

    res.json({
      message: 'Insight marked as read',
      insight
    });
  } catch (error) {
    console.error('Mark insight as read error:', error);
    res.status(500).json({
      message: 'Failed to update insight',
      code: 'UPDATE_INSIGHT_ERROR'
    });
  }
});

// @route   POST /api/insights/:id/favorite
// @desc    Toggle favorite status of insight
// @access  Private
router.post('/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const insight = await Insight.findOne({
      _id: req.params.id,
      user: req.user._id
    });

    if (!insight) {
      return res.status(404).json({
        message: 'Insight not found',
        code: 'INSIGHT_NOT_FOUND'
      });
    }

    insight.isFavorite = !insight.isFavorite;
    await insight.save();

    res.json({
      message: `Insight ${insight.isFavorite ? 'added to' : 'removed from'} favorites`,
      isFavorite: insight.isFavorite
    });
  } catch (error) {
    console.error('Toggle insight favorite error:', error);
    res.status(500).json({
      message: 'Failed to update favorite status',
      code: 'FAVORITE_ERROR'
    });
  }
});

// @route   GET /api/insights/wellness-tips
// @desc    Get AI-generated wellness tips
// @access  Private
router.get('/wellness-tips', authenticateToken, async (req, res) => {
  try {
    const { period = '7' } = req.query;
    const days = parseInt(period);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // Get recent mood data
    const moodStats = await Journal.getMoodStats(req.user._id, startDate, new Date());
    
    // Get user preferences
    const user = await User.findById(req.user._id).select('preferences');
    
    // Generate wellness tips using AI
    const tips = await aiService.generateWellnessTips(moodStats, user.preferences);

    res.json({
      tips,
      basedOn: {
        period: `${days} days`,
        moodData: moodStats
      },
      generatedAt: new Date()
    });
  } catch (error) {
    console.error('Get wellness tips error:', error);
    res.status(500).json({
      message: 'Failed to generate wellness tips',
      code: 'WELLNESS_TIPS_ERROR'
    });
  }
});

// @route   POST /api/insights/analyze-entry
// @desc    Analyze a specific journal entry with AI
// @access  Private
router.post('/analyze-entry', authenticateToken, async (req, res) => {
  try {
    const { entryId } = req.body;

    if (!entryId) {
      return res.status(400).json({
        message: 'Entry ID is required',
        code: 'ENTRY_ID_REQUIRED'
      });
    }

    // Get the journal entry
    const entry = await Journal.findOne({
      _id: entryId,
      user: req.user._id
    });

    if (!entry) {
      return res.status(404).json({
        message: 'Journal entry not found',
        code: 'ENTRY_NOT_FOUND'
      });
    }

    // Analyze with AI
    const analysis = await aiService.analyzeSentiment(entry.content);

    // Update the entry with AI analysis
    entry.aiAnalysis = {
      ...analysis,
      analyzedAt: new Date()
    };
    await entry.save();

    res.json({
      message: 'Entry analyzed successfully',
      analysis,
      entry: {
        id: entry._id,
        content: entry.content,
        mood: entry.mood,
        createdAt: entry.createdAt
      }
    });
  } catch (error) {
    console.error('Analyze entry error:', error);
    res.status(500).json({
      message: 'Failed to analyze entry',
      code: 'ANALYZE_ENTRY_ERROR'
    });
  }
});

// @route   GET /api/insights/ai-health
// @desc    Check AI service health
// @access  Private
router.get('/ai-health', authenticateToken, async (req, res) => {
  try {
    const health = await aiService.checkServerHealth();
    
    res.json({
      aiService: health,
      timestamp: new Date()
    });
  } catch (error) {
    console.error('AI health check error:', error);
    res.status(500).json({
      message: 'Failed to check AI service health',
      code: 'AI_HEALTH_ERROR'
    });
  }
});

// Helper function to generate AI sentiment insight
async function generateAISentimentInsight(userId, period) {
  try {
    const endDate = new Date();
    const startDate = new Date();
    
    switch (period) {
      case 'daily':
        startDate.setDate(endDate.getDate() - 1);
        break;
      case 'weekly':
        startDate.setDate(endDate.getDate() - 7);
        break;
      case 'monthly':
        startDate.setMonth(endDate.getMonth() - 1);
        break;
    }

    const entries = await Journal.find({
      user: userId,
      createdAt: { $gte: startDate, $lte: endDate },
      content: { $exists: true, $ne: '' }
    }).sort({ createdAt: -1 }).limit(10);

    if (entries.length === 0) {
      return null;
    }

    // Analyze entries with AI
    const analyses = await aiService.batchAnalyzeSentiment(entries);
    
    // Calculate overall sentiment
    const sentiments = analyses.map(a => a.analysis.sentiment);
    const positiveCount = sentiments.filter(s => s === 'positive').length;
    const negativeCount = sentiments.filter(s => s === 'negative').length;
    const neutralCount = sentiments.filter(s => s === 'neutral').length;
    
    const total = sentiments.length;
    const overallSentiment = positiveCount > negativeCount ? 'positive' : 
                           negativeCount > positiveCount ? 'negative' : 'neutral';
    
    const confidence = Math.max(positiveCount, negativeCount, neutralCount) / total;

    let title, description, category;
    
    if (overallSentiment === 'positive') {
      title = 'Positive Sentiment Trend';
      description = `Your recent entries show a positive emotional pattern. You've been expressing positive sentiments in ${Math.round((positiveCount/total)*100)}% of your recent entries.`;
      category = 'positive';
    } else if (overallSentiment === 'negative') {
      title = 'Supportive Sentiment Analysis';
      description = `Your recent entries show some challenging emotions. Consider reaching out for support or trying some wellness activities.`;
      category = 'concern';
    } else {
      title = 'Balanced Emotional State';
      description = `Your recent entries show a balanced emotional state with mixed sentiments. This is normal and healthy.`;
      category = 'neutral';
    }

    return new Insight({
      user: userId,
      type: 'sentiment-analysis',
      title,
      description,
      data: {
        overallSentiment,
        confidence,
        breakdown: {
          positive: positiveCount,
          negative: negativeCount,
          neutral: neutralCount,
          total
        },
        analyses: analyses.map(a => ({
          entryId: a.entryId,
          sentiment: a.analysis.sentiment,
          confidence: a.analysis.confidence
        }))
      },
      period: {
        startDate,
        endDate,
        type: period
      },
      category,
      generatedBy: 'ai'
    });
  } catch (error) {
    console.error('Generate AI sentiment insight error:', error);
    return null;
  }
}

module.exports = router;
