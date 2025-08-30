const mongoose = require('mongoose');

const chatMessageSchema = new mongoose.Schema({
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  recipient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  message: {
    type: String,
    required: true,
    trim: true
  },
  isRead: {
    type: Boolean,
    default: false
  },
  conversationId: {
    type: String,
    required: true,
    index: true
  },
  messageType: {
    type: String,
    enum: ['text', 'image', 'file'],
    default: 'text'
  },
  attachments: [{
    type: String, // Base64 or file URL
    description: String
  }]
}, {
  timestamps: true
});

// Create a compound index for efficient querying
chatMessageSchema.index({ conversationId: 1, createdAt: -1 });

// Create a compound index for unread messages
chatMessageSchema.index({ recipient: 1, isRead: 1 });

module.exports = mongoose.model('ChatMessage', chatMessageSchema);
