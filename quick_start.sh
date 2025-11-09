#!/bin/bash
# Quick start script for EmpathLens

echo "🚀 EmpathLens Quick Start"
echo "=========================="
echo ""

# Step 1: Check Ollama
echo "📋 Step 1: Checking Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama not found. Please install:"
    echo "   curl -fsSL https://ollama.com/install.sh | sh"
    exit 1
fi
echo "✅ Ollama is installed"

# Step 2: Check if Ollama is running
echo ""
echo "📋 Step 2: Checking if Ollama is running..."
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "⚠️  Ollama is not running!"
    echo ""
    echo "Please start Ollama in another terminal:"
    echo "   ollama serve"
    echo ""
    echo "Then run this script again."
    exit 1
fi
echo "✅ Ollama is running"

# Step 3: Check for llama3 model
echo ""
echo "📋 Step 3: Checking for llama3 model..."
if ! ollama list | grep -q "llama3"; then
    echo "⚠️  llama3 model not found. Pulling now (this may take a few minutes)..."
    ollama pull llama3
    if [ $? -ne 0 ]; then
        echo "❌ Failed to pull model"
        exit 1
    fi
fi
echo "✅ llama3 model is ready"

# Step 4: Set up Python environment
echo ""
echo "📋 Step 4: Setting up Python environment..."
cd "$(dirname "$0")"

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate
pip install -q -r requirements.txt
echo "✅ Python dependencies installed"

# Step 5: Create .env if needed
echo ""
echo "📋 Step 5: Checking configuration..."
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
OLLAMA_URL=http://localhost:11434
OLLAMA_MODEL=llama3
TEXT_WEIGHT=0.6
AUDIO_WEIGHT=0.4
ENABLE_AUDIO=false
HOST=0.0.0.0
PORT=8000
EOF
    echo "✅ Created .env file"
else
    echo "✅ .env file exists"
fi

echo ""
echo "=========================="
echo "✅ Setup complete!"
echo "=========================="
echo ""
echo "To start the service:"
echo "  source venv/bin/activate"
echo "  python main.py"
echo ""
echo "To test it:"
echo "  python test_service.py"
echo ""

