const mongoose = require('mongoose')

const reviewSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  customerName: {
    type: String,
    required: true
  },
  customerAvatar: String,
  rating: {
    type: Number,
    required: [true, 'Rating is required'],
    min: [1, 'Rating must be at least 1'],
    max: [5, 'Rating cannot exceed 5']
  },
  title: {
    type: String,
    trim: true,
    maxlength: [100, 'Review title cannot exceed 100 characters']
  },
  comment: {
    type: String,
    required: [true, 'Review comment is required'],
    trim: true,
    maxlength: [1000, 'Review comment cannot exceed 1000 characters']
  },
  images: [{
    type: String
  }],
  isVerified: {
    type: Boolean,
    default: false
  },
  isHelpful: {
    type: Number,
    default: 0
  },
  helpfulVotes: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    isHelpful: Boolean,
    votedAt: {
      type: Date,
      default: Date.now
    }
  }],
  vendorResponse: {
    comment: String,
    respondedAt: Date
  },
  isEdited: {
    type: Boolean,
    default: false
  },
  editHistory: [{
    comment: String,
    editedAt: Date
  }],
  isReported: {
    type: Boolean,
    default: false
  },
  reportReason: String,
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
})

// Ensure one review per customer per product
reviewSchema.index({ productId: 1, customerId: 1 }, { unique: true })

// Index for efficient queries
reviewSchema.index({ productId: 1, rating: -1, createdAt: -1 })
reviewSchema.index({ customerId: 1, createdAt: -1 })
reviewSchema.index({ isVerified: 1, rating: -1 })
reviewSchema.index({ isActive: 1, createdAt: -1 })

// Update product rating when review is saved/updated
reviewSchema.post('save', async function() {
  await this.constructor.updateProductRating(this.productId)
})

reviewSchema.post('findOneAndUpdate', async function() {
  if (this.productId) {
    await this.constructor.updateProductRating(this.productId)
  }
})

reviewSchema.post('findOneAndDelete', async function() {
  if (this.productId) {
    await this.constructor.updateProductRating(this.productId)
  }
})

// Static method to update product rating
reviewSchema.statics.updateProductRating = async function(productId) {
  const stats = await this.aggregate([
    {
      $match: { 
        productId: mongoose.Types.ObjectId(productId),
        isActive: true 
      }
    },
    {
      $group: {
        _id: '$productId',
        avgRating: { $avg: '$rating' },
        numReviews: { $sum: 1 }
      }
    }
  ])

  if (stats.length > 0) {
    const Product = mongoose.model('Product')
    await Product.findByIdAndUpdate(productId, {
      rating: Math.round(stats[0].avgRating * 10) / 10,
      reviewCount: stats[0].numReviews
    })
  }
}

// Method to mark review as helpful
reviewSchema.methods.markHelpful = async function(userId, isHelpful) {
  const existingVote = this.helpfulVotes.find(vote => vote.userId.equals(userId))
  
  if (existingVote) {
    // Update existing vote
    if (existingVote.isHelpful !== isHelpful) {
      existingVote.isHelpful = isHelpful
      existingVote.votedAt = new Date()
      this.isHelpful += isHelpful ? 2 : -2 // +1 for new vote, -1 for old vote
    }
  } else {
    // Add new vote
    this.helpfulVotes.push({ userId, isHelpful, votedAt: new Date() })
    this.isHelpful += isHelpful ? 1 : -1
  }
  
  return this.save()
}

// Method to add vendor response
reviewSchema.methods.addVendorResponse = function(comment) {
  this.vendorResponse = {
    comment,
    respondedAt: new Date()
  }
  return this.save()
}

// Method to edit review
reviewSchema.methods.editReview = function(newComment) {
  // Store edit history
  this.editHistory.push({
    comment: this.comment,
    editedAt: new Date()
  })
  
  this.comment = newComment
  this.isEdited = true
  return this.save()
}

module.exports = mongoose.model('Review', reviewSchema)
