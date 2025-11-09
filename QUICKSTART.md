# EmpathLens Quick Start

Get up and running in 5 minutes.

## Prerequisites

- Python 3.9+
- Meta Glasses (or Messenger app for testing)

## Installation

### 1. Install Ollama
```bash
# macOS/Linux
curl -fsSL https://ollama.com/install.sh | sh

# Windows: Download from ollama.com
```

### 2. Start Ollama and Pull Model
```bash
ollama serve &
ollama pull llama3
```

### 3. Set Up EmpathLens
```bash
cd /path/to/MakeUC2025

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create config file
cat > .env << EOF
OLLAMA_URL=http://localhost:11434
OLLAMA_MODEL=llama3
ELEVEN_API_KEY=
TEXT_WEIGHT=0.6
AUDIO_WEIGHT=0.4
ENABLE_AUDIO=false
HOST=0.0.0.0
PORT=8000
EOF
```

### 4. (Optional) Add ElevenLabs API Key

Get key from [elevenlabs.io](https://elevenlabs.io), then:
```bash
# Edit .env and add:
ELEVEN_API_KEY=your_key_here
```

### 5. Start the Service
```bash
./start.sh
# Or manually: python main.py
```

## Test It

### Terminal Test
```bash
# In a new terminal
python test_service.py
```

### Manual API Test
```bash
curl -X POST http://localhost:8000/distress/infer \
  -H "Content-Type: application/json" \
  -d '{
    "message": "I'\''m having a panic attack",
    "chat_id": "test_123"
  }'
```

## Connect Meta Glasses Extension

1. Install [Meta Glasses API extension](https://github.com/dcrebbin/meta-glasses-api)
2. In extension settings, add custom provider:
   - Name: EmpathLens
   - Infer URL: `http://localhost:8000/distress/infer`
   - Check-in URL: `http://localhost:8000/distress/checkin`
3. Create Messenger group chat, monitor it
4. Start talking!

## Quick Commands

### Test panic detection:
Say: "I'm having a panic attack"

### Test grounding:
Say: "I feel overwhelmed and shut down"

### Test crisis handling:
Say: "I don't want to live anymore"

### Stop intervention:
Say: "stop"

## Troubleshooting

**Service won't start:**
- Check Ollama is running: `curl http://localhost:11434/api/tags`
- Check port 8000 is free: `lsof -i :8000`

**No voice output:**
- ElevenLabs API key not set (service works without it)
- Check `.env` file has correct key

**Glasses not responding:**
- Verify extension is monitoring correct chat
- Check provider URL is `http://localhost:8000/distress/infer`
- Test API directly with curl first

## Next Steps

- Read full [README.md](README.md) for details
- Review [DEMO_SCRIPT.md](DEMO_SCRIPT.md) for demo prep
- Check [CONTRIBUTING.md](CONTRIBUTING.md) to help improve EmpathLens

## Support

- 🇺🇸 Crisis: 988 Suicide & Crisis Lifeline
- 🇺🇸 Text: HOME to 741741
- 🌍 International: [findahelpline.com](https://findahelpline.com)

---

**Ready in 5 minutes. Privacy-first. Runs locally.**

