const mongoose = require('mongoose');

const followSchema = new mongoose.Schema({
  follower: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  following: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  followedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Create compound index to prevent duplicate follows
followSchema.index({ follower: 1, following: 1 }, { unique: true });

// Create index for efficient queries
followSchema.index({ follower: 1, followedAt: -1 });
followSchema.index({ following: 1, followedAt: -1 });

module.exports = mongoose.model('Follow', followSchema);
