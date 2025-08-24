const mongoose = require('mongoose')

const orderItemSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  name: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    min: 1
  },
  image: String,
  vendorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vendor',
    required: true
  },
  vendorName: {
    type: String,
    required: true
  }
})

const orderSchema = new mongoose.Schema({
  orderNumber: {
    type: String,
    unique: true,
    required: true
  },
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  items: [orderItemSchema],
  subtotal: {
    type: Number,
    required: true,
    min: 0
  },
  shippingCost: {
    type: Number,
    default: 0,
    min: 0
  },
  tax: {
    type: Number,
    default: 0,
    min: 0
  },
  total: {
    type: Number,
    required: true,
    min: 0
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'],
    default: 'pending'
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'paid', 'failed', 'refunded'],
    default: 'pending'
  },
  paymentMethod: {
    type: String,
    required: true
  },
  paymentIntentId: String,
  shippingAddress: {
    firstName: String,
    lastName: String,
    address: String,
    city: String,
    state: String,
    zipCode: String,
    country: String,
    phone: String
  },
  billingAddress: {
    firstName: String,
    lastName: String,
    address: String,
    city: String,
    state: String,
    zipCode: String,
    country: String
  },
  shippingMethod: {
    type: String,
    default: 'standard'
  },
  trackingNumber: String,
  estimatedDelivery: Date,
  notes: String,
  vendorOrders: [{
    vendorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Vendor'
    },
    vendorName: String,
    items: [orderItemSchema],
    subtotal: Number,
    commission: Number,
    vendorAmount: Number,
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'],
      default: 'pending'
    },
    trackingNumber: String,
    shippedAt: Date,
    deliveredAt: Date
  }],
  refunds: [{
    amount: Number,
    reason: String,
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected'],
      default: 'pending'
    },
    processedAt: Date,
    notes: String
  }],
  isGift: {
    type: Boolean,
    default: false
  },
  giftMessage: String,
  emailSent: {
    confirmation: { type: Boolean, default: false },
    shipping: { type: Boolean, default: false },
    delivery: { type: Boolean, default: false }
  }
}, {
  timestamps: true
})

// Generate order number before saving
orderSchema.pre('save', async function(next) {
  if (this.isNew) {
    const date = new Date()
    const year = date.getFullYear().toString().slice(-2)
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    
    // Get count of orders for today
    const todayStart = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    const todayEnd = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1)
    
    const orderCount = await this.constructor.countDocuments({
      createdAt: { $gte: todayStart, $lt: todayEnd }
    })
    
    const sequence = (orderCount + 1).toString().padStart(4, '0')
    this.orderNumber = `AM${year}${month}${day}${sequence}`
  }
  next()
})

// Calculate totals
orderSchema.methods.calculateTotals = function() {
  this.subtotal = this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0)
  this.total = this.subtotal + this.shippingCost + this.tax
  return this
}

// Get order status timeline
orderSchema.methods.getStatusTimeline = function() {
  const timeline = []
  
  if (this.createdAt) {
    timeline.push({
      status: 'Order Placed',
      date: this.createdAt,
      description: 'Order has been placed successfully'
    })
  }
  
  if (this.status === 'confirmed' || this.status === 'processing' || this.status === 'shipped' || this.status === 'delivered') {
    timeline.push({
      status: 'Order Confirmed',
      date: this.updatedAt,
      description: 'Order has been confirmed by vendor'
    })
  }
  
  if (this.status === 'shipped' || this.status === 'delivered') {
    timeline.push({
      status: 'Order Shipped',
      date: this.vendorOrders.find(v => v.status === 'shipped')?.shippedAt || this.updatedAt,
      description: 'Order has been shipped'
    })
  }
  
  if (this.status === 'delivered') {
    timeline.push({
      status: 'Order Delivered',
      date: this.vendorOrders.find(v => v.status === 'delivered')?.deliveredAt || this.updatedAt,
      description: 'Order has been delivered successfully'
    })
  }
  
  return timeline
}

// Index for efficient queries
orderSchema.index({ customerId: 1, createdAt: -1 })
orderSchema.index({ orderNumber: 1 })
orderSchema.index({ status: 1, createdAt: -1 })
orderSchema.index({ paymentStatus: 1, createdAt: -1 })
orderSchema.index({ 'vendorOrders.vendorId': 1, 'vendorOrders.status': 1 })

module.exports = mongoose.model('Order', orderSchema)
