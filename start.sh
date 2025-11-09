#!/bin/bash

# EmpathLens Quick Start Script
# This script checks dependencies and starts the service

set -e

echo "================================================"
echo "EmpathLens - Distress Helper"
echo "Quick Start Script"
echo "================================================"
echo ""

# Check if Ollama is running
echo "[1/5] Checking Ollama..."
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "✅ Ollama is running"
else
    echo "❌ Ollama is not running!"
    echo "   Start it with: ollama serve"
    echo "   Or install it: curl -fsSL https://ollama.com/install.sh | sh"
    exit 1
fi

# Check if model is available
echo "[2/5] Checking Ollama model..."
if ollama list | grep -q "llama3"; then
    echo "✅ llama3 model is available"
else
    echo "⚠️  llama3 model not found. Pulling now..."
    ollama pull llama3
fi

# Check Python virtual environment
echo "[3/5] Checking Python environment..."
if [ ! -d "venv" ]; then
    echo "⚠️  Virtual environment not found. Creating..."
    python3 -m venv venv
fi

source venv/bin/activate
echo "✅ Virtual environment activated"

# Install dependencies
echo "[4/5] Installing dependencies..."
pip install -q -r requirements.txt
echo "✅ Dependencies installed"

# Check .env file
echo "[5/5] Checking configuration..."
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from template..."
    cp .env.example .env
    echo "   Please edit .env with your settings (especially ELEVEN_API_KEY)"
fi
echo "✅ Configuration ready"

echo ""
echo "================================================"
echo "Starting EmpathLens Provider..."
echo "================================================"
echo ""
echo "Service will be available at: http://localhost:8000"
echo "Press Ctrl+C to stop"
echo ""

# Start the service
python main.py

