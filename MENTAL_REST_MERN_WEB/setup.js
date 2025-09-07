#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 MindSpace Setup Script');
console.log('========================\n');

// Check if Node.js version is compatible
function checkNodeVersion() {
  const nodeVersion = process.version;
  const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
  
  if (majorVersion < 18) {
    console.error('❌ Node.js version 18 or higher is required');
    console.error(`   Current version: ${nodeVersion}`);
    process.exit(1);
  }
  
  console.log(`✅ Node.js version: ${nodeVersion}`);
}

// Check if required directories exist
function checkDirectories() {
  const requiredDirs = ['backend', 'frontend'];
  const missingDirs = requiredDirs.filter(dir => !fs.existsSync(dir));
  
  if (missingDirs.length > 0) {
    console.error('❌ Missing required directories:', missingDirs.join(', '));
    process.exit(1);
  }
  
  console.log('✅ Project structure is correct');
}

// Install dependencies
function installDependencies() {
  console.log('\n📦 Installing dependencies...');
  
  try {
    console.log('   Installing backend dependencies...');
    execSync('npm install', { cwd: path.join(__dirname, 'backend'), stdio: 'inherit' });
    
    console.log('   Installing frontend dependencies...');
    execSync('npm install', { cwd: path.join(__dirname, 'frontend'), stdio: 'inherit' });
    
    console.log('✅ All dependencies installed successfully');
  } catch (error) {
    console.error('❌ Failed to install dependencies:', error.message);
    process.exit(1);
  }
}

// Check environment file
function checkEnvironmentFile() {
  const envPath = path.join(__dirname, 'backend', '.env');
  const envExamplePath = path.join(__dirname, 'backend', 'env.example');
  
  if (!fs.existsSync(envPath)) {
    if (fs.existsSync(envExamplePath)) {
      console.log('\n📝 Creating .env file from template...');
      fs.copyFileSync(envExamplePath, envPath);
      console.log('✅ .env file created');
      console.log('⚠️  Please edit backend/.env with your configuration');
    } else {
      console.log('⚠️  No .env file found. Please create one in the backend directory');
    }
  } else {
    console.log('✅ .env file exists');
  }
}

// Check Ollama installation
function checkOllama() {
  try {
    execSync('ollama --version', { stdio: 'pipe' });
    console.log('✅ Ollama is installed');
    
    // Check if gemma:2b model is available
    try {
      execSync('ollama list | grep gemma:2b', { stdio: 'pipe' });
      console.log('✅ gemma:2b model is available');
    } catch {
      console.log('⚠️  gemma:2b model not found. Run: ollama pull gemma:2b');
    }
  } catch {
    console.log('⚠️  Ollama not found. Please install Ollama for AI features');
    console.log('   Download from: https://ollama.com');
  }
}

// Main setup function
function main() {
  try {
    checkNodeVersion();
    checkDirectories();
    installDependencies();
    checkEnvironmentFile();
    checkOllama();
    
    console.log('\n🎉 Setup completed successfully!');
    console.log('\n📋 Next steps:');
    console.log('1. Edit backend/.env with your MongoDB connection string');
    console.log('2. Install Ollama and pull gemma:2b model (optional)');
    console.log('3. Run: npm run seed (to populate database)');
    console.log('4. Run: npm run dev (to start development servers)');
    console.log('\n📚 For more information, see README.md');
    
  } catch (error) {
    console.error('\n❌ Setup failed:', error.message);
    process.exit(1);
  }
}

// Run setup
main();
