const mongoose = require('mongoose');

const vendorProfileSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    unique: true
  },
  shopName: {
    type: String,
    required: [true, 'Shop name is required'],
    trim: true,
    maxlength: [100, 'Shop name cannot exceed 100 characters']
  },
  bio: {
    type: String,
    required: [true, 'Vendor bio is required'],
    trim: true,
    maxlength: [1000, 'Bio cannot exceed 1000 characters']
  },
  tagline: {
    type: String,
    trim: true,
    maxlength: [200, 'Tagline cannot exceed 200 characters']
  },
  specialties: [{
    type: String,
    trim: true
  }],
  profileImage: {
    type: String,
    required: [true, 'Profile image is required']
  },
  bannerImage: {
    type: String
  },
  gallery: [{
    type: String,
    description: String
  }],
  location: {
    address: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  experience: {
    years: {
      type: Number,
      min: [0, 'Experience years cannot be negative']
    },
    description: String
  },
  education: {
    degree: String,
    institution: String,
    year: Number
  },
  certifications: [{
    name: String,
    issuer: String,
    year: Number,
    description: String
  }],
  socialLinks: {
    website: String,
    instagram: String,
    facebook: String,
    twitter: String,
    pinterest: String,
    etsy: String
  },
  contactInfo: {
    email: String,
    phone: String,
    address: String
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
    returnPolicy: String,
    shippingPolicy: String,
    customOrderPolicy: String
  },
  stats: {
    totalProducts: { type: Number, default: 0 },
    totalSales: { type: Number, default: 0 },
    totalOrders: { type: Number, default: 0 },
    averageRating: { type: Number, default: 0 },
    reviewCount: { type: Number, default: 0 },
    followerCount: { type: Number, default: 0 }
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  status: {
    type: String,
    enum: ['active', 'inactive', 'suspended', 'pending'],
    default: 'pending'
  },
  featuredUntil: Date,
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update the updatedAt field on save
vendorProfileSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Create indexes for better query performance
vendorProfileSchema.index({ userId: 1 });
vendorProfileSchema.index({ shopName: 'text', bio: 'text', specialties: 'text' });
vendorProfileSchema.index({ isVerified: 1, isFeatured: 1 });
vendorProfileSchema.index({ status: 1 });
vendorProfileSchema.index({ 'stats.averageRating': -1 });
vendorProfileSchema.index({ createdAt: -1 });

// Virtual for full address
vendorProfileSchema.virtual('fullAddress').get(function() {
  if (this.location.city && this.location.state && this.location.country) {
    return `${this.location.city}, ${this.location.state}, ${this.location.country}`;
  }
  return this.location.city || this.location.state || this.location.country || 'Location not specified';
});

// Virtual for experience display
vendorProfileSchema.virtual('experienceDisplay').get(function() {
  if (this.experience.years) {
    return `${this.experience.years} year${this.experience.years !== 1 ? 's' : ''} of experience`;
  }
  return this.experience.description || 'Experience information not available';
});

// Ensure virtual fields are serialized
vendorProfileSchema.set('toJSON', { virtuals: true });
vendorProfileSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('VendorProfile', vendorProfileSchema);
