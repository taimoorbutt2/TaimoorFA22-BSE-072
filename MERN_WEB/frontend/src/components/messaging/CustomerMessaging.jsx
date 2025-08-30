import React, { useState, useEffect, useRef } from 'react';
import { FiSend, FiMessageCircle, FiArrowLeft, FiCheck, FiCheckSquare, FiX } from 'react-icons/fi';
import { useAuth } from '../../contexts/AuthContext';
import toast from 'react-hot-toast';

const CustomerMessaging = ({ vendor, onClose }) => {
  const { user } = useAuth();
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const messagesEndRef = useRef(null);

  // Generate conversation ID using the correct user ID field
  const conversationId = [user?._id, vendor.id].sort().join('_');

  // Debug logging
  console.log('CustomerMessaging Debug:', {
    user: user,
    user_id: user?._id,
    vendor: vendor,
    vendor_id: vendor.id,
    conversationId: conversationId
  });

  // Additional detailed logging
  console.log('User object:', JSON.stringify(user, null, 2));
  console.log('Vendor object:', JSON.stringify(vendor, null, 2));
  console.log('Conversation ID:', conversationId);

  // Fetch messages for this conversation
  const fetchMessages = async () => {
    try {
      setLoading(true);
      const response = await fetch(`/api/chat/messages/${conversationId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        setMessages(data.messages);
        scrollToBottom();
      } else if (response.status === 404) {
        // No conversation yet, start fresh
        setMessages([]);
      } else {
        console.error('Failed to fetch messages:', response.status, response.statusText);
        setMessages([]);
      }
    } catch (error) {
      console.error('Error fetching messages:', error);
      // Start with empty messages for new conversations
      setMessages([]);
    } finally {
      setLoading(false);
    }
  };

  // Send message
  const sendMessage = async () => {
    if (!newMessage.trim()) return;

    try {
      setSending(true);
      const response = await fetch('/api/chat/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({
          recipientId: vendor.id,
          message: newMessage.trim()
        })
      });

      if (response.ok) {
        const data = await response.json();
        setMessages(prev => [...prev, data.data]);
        setNewMessage('');
        scrollToBottom();
        toast.success('Message sent successfully!');
      } else {
        const errorData = await response.json();
        toast.error(errorData.message || 'Failed to send message');
      }
    } catch (error) {
      console.error('Error sending message:', error);
      toast.error('Failed to send message');
    } finally {
      setSending(false);
    }
  };

  // Scroll to bottom of messages
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  // Format timestamp
  const formatTime = (timestamp) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diffInHours = (now - date) / (1000 * 60 * 60);

    if (diffInHours < 24) {
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    } else if (diffInHours < 48) {
      return 'Yesterday';
    } else {
      return date.toLocaleDateString();
    }
  };

  useEffect(() => {
    if (user?._id && vendor.id) {
      fetchMessages();
    }
  }, [conversationId, user?._id, vendor.id]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // Don't render if user or vendor is not available
  if (!user?._id || !vendor.id) {
    return null;
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl h-[600px] flex flex-col">
        {/* Header */}
        <div className="p-4 border-b border-gray-200 bg-gray-50 flex items-center justify-between rounded-t-2xl">
          <div className="flex items-center space-x-3">
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-200 rounded-lg transition-colors duration-200"
            >
              <FiArrowLeft className="w-5 h-5 text-gray-600" />
            </button>
            
            <div className="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-semibold text-sm">
              {vendor.name?.charAt(0)?.toUpperCase() || 'A'}
            </div>
            
            <div>
              <h4 className="font-semibold text-gray-900">{vendor.name || 'Unknown'}</h4>
              <p className="text-sm text-gray-500">{vendor.shopName || 'Unnamed Shop'}</p>
            </div>
          </div>
          
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-200 rounded-lg transition-colors duration-200"
          >
            <FiX className="w-5 h-5 text-gray-600" />
          </button>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {loading ? (
            <div className="flex items-center justify-center h-32">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>
          ) : messages.length === 0 ? (
            <div className="text-center text-gray-500 py-8">
              <FiMessageCircle className="w-12 h-12 mx-auto mb-2 text-gray-300" />
              <p>Start a conversation with {vendor.name || 'this vendor'}</p>
              <p className="text-sm">Send your first message below</p>
            </div>
          ) : (
            messages.map((message) => (
              <div
                key={message._id}
                className={`flex ${message.sender._id === user._id ? 'justify-end' : 'justify-start'}`}
              >
                <div
                  className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                    message.sender._id === user._id
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-100 text-gray-900'
                  }`}
                >
                  <p className="text-sm">{message.message}</p>
                  <div className={`flex items-center justify-between mt-1 text-xs ${
                    message.sender._id === user._id ? 'text-blue-100' : 'text-gray-500'
                  }`}>
                    <span>{formatTime(message.createdAt)}</span>
                    {message.sender._id === user._id && (
                      <span>
                        {message.isRead ? (
                          <FiCheckSquare className="w-3 h-3" />
                        ) : (
                          <FiCheck className="w-3 h-3" />
                        )}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            ))
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Message Input */}
        <div className="p-4 border-t border-gray-200 rounded-b-2xl">
          <div className="flex space-x-2">
            <input
              type="text"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
              placeholder={`Message ${vendor.name || 'vendor'}...`}
              className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              disabled={sending}
            />
            <button
              onClick={sendMessage}
              disabled={!newMessage.trim() || sending}
              className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200 flex items-center space-x-2"
            >
              <FiSend className="w-4 h-4" />
              <span>Send</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CustomerMessaging;
