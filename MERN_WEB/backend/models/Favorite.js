const mongoose = require('mongoose');

const favoriteSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: [true, 'Product ID is required']
  },
  addedAt: {
    type: Date,
    default: Date.now
  }
});

// Ensure a user can only favorite a product once
favoriteSchema.index({ user: 1, product: 1 }, { unique: true });

// Create indexes for better query performance
favoriteSchema.index({ user: 1, addedAt: -1 });
favoriteSchema.index({ product: 1 });

module.exports = mongoose.model('Favorite', favoriteSchema);
