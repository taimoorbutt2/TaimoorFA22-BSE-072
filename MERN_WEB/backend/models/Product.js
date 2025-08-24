const mongoose = require('mongoose')

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Product name is required'],
    trim: true,
    maxlength: [100, 'Product name cannot exceed 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Product description is required'],
    maxlength: [2000, 'Description cannot exceed 2000 characters']
  },
  price: {
    type: Number,
    required: [true, 'Price is required'],
    min: [0, 'Price cannot be negative']
  },
  comparePrice: {
    type: Number,
    min: [0, 'Compare price cannot be negative']
  },
  images: [{
    type: String,
    required: [true, 'At least one image is required']
  }],
  category: {
    type: String,
    required: [true, 'Category is required'],
    enum: ['Jewelry', 'Home Decor', 'Art & Prints', 'Clothing', 'Pottery', 'Textiles', 'Other']
  },
  subcategory: {
    type: String,
    trim: true
  },
  tags: [{
    type: String,
    trim: true
  }],
  vendorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vendor',
    required: [true, 'Vendor ID is required']
  },
  vendorName: {
    type: String,
    required: [true, 'Vendor name is required']
  },
  stock: {
    type: Number,
    required: [true, 'Stock quantity is required'],
    min: [0, 'Stock cannot be negative'],
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  dimensions: {
    length: Number,
    width: Number,
    height: Number,
    weight: Number,
    unit: {
      type: String,
      enum: ['cm', 'inch', 'mm', 'kg', 'lb', 'g', 'oz'],
      default: 'cm'
    }
  },
  materials: [{
    type: String,
    trim: true
  }],
  colors: [{
    type: String,
    trim: true
  }],
  sizes: [{
    type: String,
    trim: true
  }],
  customOptions: [{
    name: String,
    options: [String],
    required: Boolean,
    additionalCost: Number
  }],
  shipping: {
    weight: Number,
    dimensions: {
      length: Number,
      width: Number,
      height: Number
    },
    freeShipping: {
      type: Boolean,
      default: false
    },
    shippingCost: {
      type: Number,
      default: 0
    }
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
  soldCount: {
    type: Number,
    default: 0
  },
  viewCount: {
    type: Number,
    default: 0
  },
  isHandmade: {
    type: Boolean,
    default: true
  },
  productionTime: {
    type: Number, // in days
    default: 0
  },
  returnPolicy: {
    type: String,
    maxlength: [500, 'Return policy cannot exceed 500 characters']
  }
}, {
  timestamps: true
})

// Virtual for average rating
productSchema.virtual('averageRating').get(function() {
  return this.rating || 0
})

// Virtual for discount percentage
productSchema.virtual('discountPercentage').get(function() {
  if (this.comparePrice && this.comparePrice > this.price) {
    return Math.round(((this.comparePrice - this.price) / this.comparePrice) * 100)
  }
  return 0
})

// Index for search functionality
productSchema.index({ 
  name: 'text', 
  description: 'text', 
  category: 'text',
  tags: 'text',
  materials: 'text'
})

// Index for filtering and sorting
productSchema.index({ category: 1, price: 1, rating: -1, createdAt: -1 })
productSchema.index({ vendorId: 1, isActive: 1 })
productSchema.index({ isFeatured: 1, rating: -1 })

// Ensure virtuals are serialized
productSchema.set('toJSON', { virtuals: true })
productSchema.set('toObject', { virtuals: true })

module.exports = mongoose.model('Product', productSchema)
