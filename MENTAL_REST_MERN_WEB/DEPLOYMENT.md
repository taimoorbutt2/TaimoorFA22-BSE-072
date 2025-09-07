# MindSpace Deployment Guide

This guide covers deploying MindSpace to various platforms.

## 🚀 Vercel Deployment (Recommended)

### Backend Deployment

1. **Prepare Backend**
   ```bash
   cd backend
   npm run build  # If you have a build script
   ```

2. **Deploy to Vercel**
   ```bash
   # Install Vercel CLI
   npm i -g vercel
   
   # Deploy backend
   cd backend
   vercel
   ```

3. **Environment Variables**
   Set these in Vercel dashboard:
   - `MONGODB_URI`
   - `JWT_SECRET`
   - `GOOGLE_CLIENT_ID`
   - `GOOGLE_CLIENT_SECRET`
   - `OLLAMA_BASE_URL` (if using external Ollama)
   - `CLIENT_URL` (your frontend URL)

### Frontend Deployment

1. **Build Frontend**
   ```bash
   cd frontend
   npm run build
   ```

2. **Deploy to Vercel**
   ```bash
   cd frontend
   vercel
   ```

3. **Environment Variables**
   Set these in Vercel dashboard:
   - `REACT_APP_API_URL` (your backend URL)

## 🐳 Docker Deployment

### Backend Dockerfile
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 5000

CMD ["npm", "start"]
```

### Frontend Dockerfile
```dockerfile
FROM node:18-alpine as build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose
```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "5000:5000"
    environment:
      - MONGODB_URI=${MONGODB_URI}
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - mongodb

  frontend:
    build: ./frontend
    ports:
      - "3000:80"
    environment:
      - REACT_APP_API_URL=http://localhost:5000

  mongodb:
    image: mongo:latest
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db

volumes:
  mongodb_data:
```

## ☁️ Cloud Deployment Options

### Heroku
1. **Backend**
   ```bash
   cd backend
   heroku create mindspace-backend
   heroku config:set MONGODB_URI=your_mongodb_uri
   heroku config:set JWT_SECRET=your_jwt_secret
   git push heroku main
   ```

2. **Frontend**
   ```bash
   cd frontend
   heroku create mindspace-frontend
   heroku config:set REACT_APP_API_URL=your_backend_url
   git push heroku main
   ```

### Netlify
1. **Frontend**
   - Connect GitHub repository
   - Set build command: `npm run build`
   - Set publish directory: `build`
   - Add environment variables

### Railway
1. **Backend**
   - Connect GitHub repository
   - Set root directory: `backend`
   - Add environment variables

2. **Frontend**
   - Connect GitHub repository
   - Set root directory: `frontend`
   - Add environment variables

## 🔧 Environment Configuration

### Production Environment Variables

#### Backend
```env
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/mindspace
JWT_SECRET=your_super_secure_jwt_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
CLIENT_URL=https://your-frontend-domain.com
OLLAMA_BASE_URL=https://your-ollama-server.com
```

#### Frontend
```env
REACT_APP_API_URL=https://your-backend-domain.com
REACT_APP_GOOGLE_CLIENT_ID=your_google_client_id
```

## 🗄️ Database Setup

### MongoDB Atlas
1. Create a MongoDB Atlas account
2. Create a new cluster
3. Get connection string
4. Set up database user
5. Configure network access
6. Update `MONGODB_URI` in environment variables

### Local MongoDB
```bash
# Install MongoDB
brew install mongodb/brew/mongodb-community  # macOS
# or
sudo apt-get install mongodb  # Ubuntu

# Start MongoDB
mongod
```

## 🤖 AI Service Setup

### Ollama Cloud Deployment
1. **Railway/Render**
   ```bash
   # Deploy Ollama server
   git clone https://github.com/ollama/ollama
   # Deploy to cloud platform
   ```

2. **Docker**
   ```bash
   docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
   docker exec -it ollama ollama pull gemma:2b
   ```

### Alternative AI Services
- **OpenAI API**: Replace Ollama with OpenAI GPT models
- **Hugging Face**: Use Hugging Face inference API
- **Google AI**: Use Google's Gemini models

## 🔒 Security Considerations

### Production Security
1. **HTTPS**: Always use HTTPS in production
2. **CORS**: Configure CORS for production domains
3. **Rate Limiting**: Implement rate limiting
4. **Input Validation**: Validate all inputs
5. **Error Handling**: Don't expose sensitive information

### Environment Security
1. **Secrets**: Use environment variables for secrets
2. **Database**: Use strong passwords and network restrictions
3. **JWT**: Use strong JWT secrets
4. **OAuth**: Configure OAuth redirect URIs correctly

## 📊 Monitoring & Analytics

### Application Monitoring
- **Vercel Analytics**: Built-in analytics for Vercel deployments
- **Sentry**: Error tracking and performance monitoring
- **LogRocket**: Session replay and error tracking

### Database Monitoring
- **MongoDB Atlas**: Built-in monitoring and alerts
- **MongoDB Compass**: Database management and monitoring

## 🚨 Troubleshooting

### Common Issues

1. **CORS Errors**
   - Check `CLIENT_URL` environment variable
   - Verify CORS configuration in backend

2. **Database Connection**
   - Verify MongoDB connection string
   - Check network access settings

3. **AI Service Issues**
   - Verify Ollama server is running
   - Check model availability
   - Verify API endpoints

4. **Build Failures**
   - Check Node.js version compatibility
   - Verify all dependencies are installed
   - Check for TypeScript errors

### Debug Commands
```bash
# Check backend logs
vercel logs

# Check frontend build
npm run build

# Test database connection
npm run seed

# Check AI service
curl http://localhost:11434/api/tags
```

## 📈 Performance Optimization

### Backend Optimization
- Enable gzip compression
- Implement caching
- Optimize database queries
- Use connection pooling

### Frontend Optimization
- Enable code splitting
- Optimize images
- Use CDN for static assets
- Implement lazy loading

## 🔄 CI/CD Pipeline

### GitHub Actions
```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          working-directory: ./backend
```

---

For more detailed information, refer to the main README.md file.
