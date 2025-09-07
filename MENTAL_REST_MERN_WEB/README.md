# MindSpace - Mental Wellness Journal

A comprehensive MERN stack application designed to promote mental wellness through journaling, mood tracking, and AI-powered insights.

## 🌟 Features

### Core Functionality
- **Personal Journaling**: Create, edit, and manage daily journal entries
- **Mood Tracking**: Log moods with intensity levels and visual trends
- **AI-Powered Insights**: Sentiment analysis using Ollama's gemma:2b model
- **Guided Prompts**: Pre-built and AI-generated journal prompts
- **Wellness Goals**: Set and track personal wellness objectives
- **Community Features**: Anonymous sharing and leaderboards
- **Admin Dashboard**: Content moderation and analytics

### Technical Features
- **Secure Authentication**: JWT-based auth with Google OAuth support
- **Responsive Design**: Mobile-first UI with Tailwind CSS
- **Real-time Analytics**: Interactive charts and mood trends
- **Privacy-Focused**: User data protection and anonymization
- **AI Integration**: Local Ollama server for sentiment analysis

## 🏗️ Project Structure

```
mindspace/
├── backend/                 # Node.js/Express backend
│   ├── models/             # MongoDB schemas
│   ├── routes/             # API routes
│   ├── middleware/         # Authentication & validation
│   ├── services/           # AI service integration
│   ├── config/             # Passport configuration
│   ├── scripts/            # Database seeding
│   ├── server.js           # Main server file
│   └── package.json        # Backend dependencies
├── frontend/               # React TypeScript frontend
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── contexts/       # React contexts
│   │   ├── hooks/          # Custom hooks
│   │   ├── services/       # API services
│   │   ├── types/          # TypeScript types
│   │   └── utils/          # Utility functions
│   ├── public/             # Static assets
│   └── package.json        # Frontend dependencies
└── package.json            # Root package.json for scripts
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18.x or higher
- MongoDB Atlas account (or local MongoDB)
- Python 3.11+ (for Ollama integration)
- Ollama server (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mindspace
   ```

2. **Install dependencies**
   ```bash
   npm run install:all
   ```

3. **Set up environment variables**
   ```bash
   # Backend environment
   cd backend
   cp env.example .env
   # Edit .env with your MongoDB connection string and other variables
   ```

4. **Set up Ollama (for AI features)**
   ```bash
   # Install Ollama (Windows)
   curl -L https://ollama.com/download/OllamaSetup.exe -o OllamaSetup.exe
   OllamaSetup.exe
   
   # Start Ollama server
   ollama serve
   
   # Pull the gemma:2b model
   ollama pull gemma:2b
   ```

5. **Seed the database**
   ```bash
   npm run seed
   ```

6. **Start the development servers**
   ```bash
   npm run dev
   ```

This will start:
- Backend server on `http://localhost:5000`
- Frontend development server on `http://localhost:3000`

## 🔧 Environment Variables

### Backend (.env)
```env
# MongoDB Connection
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/mindspace

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key_here

# Google OAuth (optional)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Server Configuration
PORT=5000
NODE_ENV=development

# Ollama Configuration
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=gemma:2b

# Frontend URL
CLIENT_URL=http://localhost:3000
```

## 📱 Usage

### For Users
1. **Register/Login**: Create an account or use Google OAuth
2. **Start Journaling**: Write daily entries with mood tracking
3. **View Insights**: Get AI-powered sentiment analysis and trends
4. **Set Goals**: Create and track wellness objectives
5. **Explore Community**: View anonymized shared content

### For Admins
1. **Access Dashboard**: Use admin credentials to access moderation tools
2. **Monitor Analytics**: View user engagement and content statistics
3. **Moderate Content**: Review and manage shared community content
4. **Export Data**: Generate reports for analysis

## 🛠️ Development

### Backend Development
```bash
cd backend
npm run dev          # Start with nodemon
npm run seed         # Seed database with sample data
npm test            # Run backend tests
```

### Frontend Development
```bash
cd frontend
npm start           # Start development server
npm run build       # Build for production
npm test           # Run frontend tests
```

### Available Scripts
- `npm run dev` - Start both frontend and backend in development mode
- `npm run build` - Build both frontend and backend for production
- `npm run seed` - Seed the database with sample data
- `npm run install:all` - Install dependencies for both frontend and backend

## 🧠 AI Integration

The application uses Ollama with the gemma:2b model for:
- **Sentiment Analysis**: Analyze journal entries for emotional tone
- **Wellness Tips**: Generate personalized recommendations
- **Prompt Generation**: Create contextual journal prompts

### Ollama Setup
1. Install Ollama from [ollama.com](https://ollama.com)
2. Start the server: `ollama serve`
3. Pull the model: `ollama pull gemma:2b`
4. Ensure the server is running on `http://localhost:11434`

## 🎨 UI/UX Design

### Design Philosophy
- **Calming Aesthetics**: Soft blues and greens for mental wellness
- **Accessibility**: High contrast, keyboard navigation, screen reader support
- **Responsive**: Mobile-first design with seamless desktop experience
- **Intuitive**: Clean, minimal interface focused on user well-being

### Color Palette
- Primary: Soft blues (#E6F0FA, #0069CD)
- Secondary: Calming greens (#D4F1F4, #218B9D)
- Wellness: Mood-specific colors for emotional states

## 🔒 Security & Privacy

- **Data Encryption**: Passwords hashed with bcrypt
- **JWT Authentication**: Secure token-based authentication
- **Privacy Controls**: User-controlled data sharing settings
- **Anonymization**: Community features use anonymized data
- **Rate Limiting**: API protection against abuse

## 📊 Database Schema

### Collections
- **Users**: User profiles, preferences, and wellness goals
- **Journals**: Journal entries with mood data and AI analysis
- **Prompts**: Guided journal prompts and templates
- **Insights**: AI-generated insights and recommendations

## 🚀 Deployment

### Vercel Deployment
1. **Backend**: Deploy to Vercel with environment variables
2. **Frontend**: Build and deploy React app
3. **Database**: Use MongoDB Atlas (free tier)
4. **AI**: Ollama server (local or cloud instance)

### Environment Setup
- Set production environment variables
- Configure CORS for production domains
- Set up MongoDB Atlas connection
- Configure Ollama server URL

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the troubleshooting guide

## 🔮 Future Enhancements

- Mobile app (React Native/Flutter)
- Advanced AI features
- Wearable device integration
- Group therapy features
- Professional therapist dashboard
- Multi-language support

---

**Built with ❤️ for mental wellness and self-care**
