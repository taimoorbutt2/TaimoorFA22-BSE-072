const mongoose = require('mongoose')

const vendorSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  shopName: {
    type: String,
    required: [true, 'Shop name is required'],
    trim: true,
    maxlength: [100, 'Shop name cannot exceed 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Shop description is required'],
    maxlength: [1000, 'Description cannot exceed 1000 characters']
  },
  logo: {
    type: String,
    default: ''
  },
  banner: {
    type: String,
    default: ''
  },
  category: {
    type: String,
    required: [true, 'Category is required'],
    enum: ['Jewelry', 'Home Decor', 'Art & Prints', 'Clothing', 'Pottery', 'Textiles', 'Other']
  },
  tags: [{
    type: String,
    trim: true
  }],
  location: {
    city: String,
    state: String,
    country: String
  },
  contactInfo: {
    phone: String,
    website: String,
    socialMedia: {
      instagram: String,
      facebook: String,
      twitter: String
    }
  },
  businessHours: {
    monday: { open: String, close: String, closed: { type: Boolean, default: false } },
    tuesday: { open: String, close: String, closed: { type: Boolean, default: false } },
    wednesday: { open: String, close: String, closed: { type: Boolean, default: false } },
    thursday: { open: String, close: String, closed: { type: Boolean, default: false } },
    friday: { open: String, close: String, closed: { type: Boolean, default: false } },
    saturday: { open: String, close: String, closed: { type: Boolean, default: false } },
    sunday: { open: String, close: String, closed: { type: Boolean, default: false } }
  },
  policies: {
    shipping: String,
    returns: String,
    customOrders: String
  },
  isApproved: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  reviewCount: {
    type: Number,
    default: 0
  },
  totalSales: {
    type: Number,
    default: 0
  },
  commissionRate: {
    type: Number,
    default: 0.10, // 10% default commission
    min: 0,
    max: 1
  },
  stripeAccountId: String,
  payoutSchedule: {
    type: String,
    enum: ['weekly', 'monthly'],
    default: 'monthly'
  }
}, {
  timestamps: true
})

// Virtual for average rating
vendorSchema.virtual('averageRating').get(function() {
  return this.rating || 0
})

// Index for search functionality
vendorSchema.index({ 
  shopName: 'text', 
  description: 'text', 
  category: 'text',
  tags: 'text'
})

// Ensure virtuals are serialized
vendorSchema.set('toJSON', { virtuals: true })
vendorSchema.set('toObject', { virtuals: true })

module.exports = mongoose.model('Vendor', vendorSchema)
