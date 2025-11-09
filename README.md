# EmpathLens – Distress Helper

**A local provider service for Meta Glasses API that guides wearers through distress episodes using AI-powered micro-interventions.**

⚠️ **DISCLAIMER**: This is NOT a medical device. This tool provides brief distress management techniques and is not a substitute for professional mental health care, emergency services, or medical advice.

## Overview

EmpathLens integrates with the [Meta Glasses API (Messenger browser extension)](https://github.com/dcrebbin/meta-glasses-api) to provide real-time, voice-based support during anxiety, panic, or overwhelming moments. The system:

- **Detects distress** from text messages (primary signal) with optional audio prosody analysis
- **Generates empathetic coaching** using a local LLM (Ollama)
- **Delivers interventions** via voice (ElevenLabs TTS) and text
- **Adapts in real-time** based on user feedback (better/same/worse check-ins)
- **Prioritizes safety** with crisis keyword detection and immediate escalation offers
- **Runs locally** for maximum privacy (only TTS uses cloud API)

## Core Features

### State-Based Interventions

| State | Intervention | Duration | Example |
|-------|-------------|----------|---------|
| **RISING** | Paced breathing (4-4) | ~30s | "Breathe in for four, out for four." |
| **PANIC** | 4-7-8 breathing | ~60s | "In for four, hold seven, out for eight." |
| **OVERWHELMED** | 5-4-3-2-1 grounding | ~75s | "Name five things you can see." |
| **RECOVERY** | Reinforcement | — | "Your body is settling. Two slow breaths." |
| **CRISIS_RISK** | Escalation offer | — | "Can I contact your support person?" |

### Safety Guardrails

- ✅ Crisis keyword detection (self-harm, suicide ideation) triggers immediate escalation
- ✅ Post-LLM filtering: max 18 words, no medical claims, safe replacements
- ✅ "Stop" command immediately ends intervention
- ✅ Escalation after 2 minutes of persistent distress
- ✅ No raw audio/video storage

## Architecture

```
User (Meta Glasses) 
    ↓ (voice/text message)
Messenger Browser Extension
    ↓ (HTTP POST)
EmpathLens Provider (FastAPI) ←→ Ollama (local LLM)
    ↓                              ↓
ElevenLabs TTS ←→ Virtual Audio Device → Messenger Call
```

## Requirements

### Hardware
- Meta Ray-Ban Smart Glasses (or standalone Messenger app for testing)
- Computer running macOS/Linux/Windows

### Software
1. **Ollama** - Local LLM runtime
2. **Python 3.9+**
3. **Meta Glasses API** - Messenger browser extension
4. **ElevenLabs API key** (optional, for voice output)
5. **Virtual audio device** (optional, for routing TTS into calls)
   - macOS: [BlackHole](https://github.com/ExistentialAudio/BlackHole)
   - Windows: VB-Audio Cable
   - Linux: PulseAudio loopback

## Installation

### 1. Install Ollama

#### macOS/Linux:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

#### Windows:
Download from [ollama.com](https://ollama.com)

#### Pull the model:
```bash
ollama pull llama3
```

### 2. Set Up EmpathLens Provider

```bash
# Clone or navigate to project directory
cd /path/to/MakeUC2025

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
```

### 3. Configure Environment Variables

Edit `.env` with your settings:

```bash
# Ollama (required)
OLLAMA_URL=http://localhost:11434
OLLAMA_MODEL=llama3

# ElevenLabs (optional, for voice)
ELEVEN_API_KEY=your_api_key_here
ELEVEN_VOICE_ID=21m00Tcm4TlvDq8ikWAM

# Detection weights
TEXT_WEIGHT=0.6
AUDIO_WEIGHT=0.4

# Features
ENABLE_AUDIO=false  # Set to true for audio prosody analysis

# Server
HOST=0.0.0.0
PORT=8000
```

**Get ElevenLabs API Key:**
1. Sign up at [elevenlabs.io](https://elevenlabs.io)
2. Go to Profile → API Keys
3. Copy your API key

### 4. Set Up Meta Glasses API Extension

Follow the setup instructions at [github.com/dcrebbin/meta-glasses-api](https://github.com/dcrebbin/meta-glasses-api):

1. Install the browser extension
2. Create a Messenger group chat with your alt account
3. Configure the extension to use EmpathLens as a custom provider:
   - Provider URL: `http://localhost:8000/distress/infer`
   - Check-in URL: `http://localhost:8000/distress/checkin`

### 5. (Optional) Set Up Virtual Audio Routing

To route TTS audio into Messenger calls:

#### macOS with BlackHole:
```bash
# Install BlackHole
brew install blackhole-2ch

# Configure Multi-Output Device in Audio MIDI Setup
# 1. Open Audio MIDI Setup (/Applications/Utilities)
# 2. Click '+' → Create Multi-Output Device
# 3. Check: Built-in Output + BlackHole 2ch
# 4. Set as system output
# 5. In Messenger call settings, select BlackHole as microphone input
```

## Usage

### Starting the Service

```bash
# Activate virtual environment
source venv/bin/activate

# Start Ollama (in separate terminal)
ollama serve

# Start EmpathLens provider
python main.py
```

The service will start on `http://localhost:8000`.

### Testing the API

```bash
# Health check
curl http://localhost:8000/health

# Test distress detection
curl -X POST http://localhost:8000/distress/infer \
  -H "Content-Type: application/json" \
  -d '{
    "message": "I'\''m having a panic attack",
    "chat_id": "test_123"
  }'
```

### Using with Meta Glasses

1. **Join a Messenger call** with your alt account (or text the group chat)
2. **Say or type**: "I'm having a panic attack"
3. **Listen/read** the response (arrives in ~2 seconds)
4. **Follow the breathing cue** for ~45-60 seconds
5. **Respond** with "better", "same", or "worse" when prompted
6. **System adapts** based on your response

### Stop Command

Say or type **"stop"** at any time to end the intervention immediately.

## Demo Script (60-90 seconds)

### Scenario 1: Panic Attack
1. **User**: "I can't breathe, I'm losing control"
2. **System**: "In for four, hold seven, out for eight." *(spoken + text)*
3. *(Wait ~45 seconds)*
4. **System**: "How are you feeling now?" *(buttons: better/same/worse)*
5. **User**: Clicks "better"
6. **System**: "Your body is settling. Take two slow breaths."

### Scenario 2: Overwhelmed
1. **User**: "It's too much, I'm shutting down"
2. **System**: "Name five things you can see."
3. **User**: Lists items
4. **System**: "Name four things you can touch."
5. *(Continues grounding sequence)*
6. **System**: "You're here. You're present. Take a slow breath."

### Scenario 3: Crisis Keywords
1. **User**: "I don't want to live anymore"
2. **System**: "I hear you're struggling. Would you like me to contact your support person?" *(immediate, no coaching)*
3. *(Buttons: contact_support / continue_alone)*

## API Reference

### POST `/distress/infer`

Main endpoint for distress detection and intervention.

**Request:**
```json
{
  "message": "I'm having a panic attack",
  "chat_id": "unique_chat_id",
  "user_id": "optional_user_id",
  "timestamp": "2025-11-08T12:00:00Z",
  "frame_url": "optional_image_url"
}
```

**Response:**
```json
{
  "reply_text": "In for four, hold seven, out for eight.",
  "expect_followup": true,
  "followup_after_sec": 60,
  "buttons": ["better", "same", "worse"],
  "audio_url": "/tmp/empathlens_audio/response_123.mp3",
  "meta": {
    "state": "panic",
    "confidence": 0.85,
    "intervention_type": "four_seven_eight",
    "session_duration_seconds": 45
  }
}
```

### POST `/distress/checkin`

Handle follow-up check-ins.

**Request:**
```json
{
  "chat_id": "unique_chat_id",
  "response": "better",  // "better" | "same" | "worse"
  "timestamp": "2025-11-08T12:01:00Z"
}
```

**Response:** Same format as `/distress/infer`

### POST `/distress/stop`

Stop intervention for a conversation.

**Request:**
```bash
?chat_id=unique_chat_id
```

**Response:**
```json
{
  "status": "stopped",
  "chat_id": "unique_chat_id"
}
```

### GET `/health`

Service health check.

**Response:**
```json
{
  "status": "healthy",
  "components": {
    "detector": "operational",
    "state_machine": "operational",
    "ollama": "operational",
    "tts": "operational"
  },
  "active_sessions": 3
}
```

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_URL` | `http://localhost:11434` | Ollama API endpoint |
| `OLLAMA_MODEL` | `llama3` | Model to use (llama3, mistral, etc.) |
| `ELEVEN_API_KEY` | `None` | ElevenLabs API key (optional) |
| `ELEVEN_VOICE_ID` | `21m00Tcm4TlvDq8ikWAM` | Voice ID for TTS |
| `TEXT_WEIGHT` | `0.6` | Weight for text-based detection |
| `AUDIO_WEIGHT` | `0.4` | Weight for audio prosody (if enabled) |
| `ENABLE_AUDIO` | `false` | Enable audio prosody analysis |
| `HOST` | `0.0.0.0` | Server bind address |
| `PORT` | `8000` | Server port |

### Session Configuration

- **Session timeout**: 30 minutes of inactivity
- **Intervention cooldown**: 30 seconds between interventions
- **Escalation timeout**: 120 seconds of persistent distress
- **Max response words**: 18 words per LLM output

## Troubleshooting

### "Connection refused" when calling API
- Ensure Ollama is running: `ollama serve`
- Check Ollama URL: `curl http://localhost:11434/api/tags`

### No voice output
- Check ElevenLabs API key is set correctly
- Verify API key is valid: [elevenlabs.io/app](https://elevenlabs.io/app)
- Service falls back to text-only if TTS unavailable

### LLM responses are slow
- Use a smaller model: `ollama pull llama3:8b`
- Reduce `max_tokens` in `ollama_client.py`

### Glasses not responding
- Verify Messenger extension is monitoring the correct chat
- Check provider URL in extension settings
- Test API directly with curl first

### State machine too sensitive
- Increase `TEXT_WEIGHT` in `.env` (e.g., `0.8`)
- Adjust thresholds in `state_machine.py`

## Privacy & Security

### What's Stored
- ✅ Ephemeral session state (current distress level, intervention history)
- ✅ No raw audio or video
- ✅ No message history (processed then discarded)
- ✅ Temporary audio files (auto-cleaned after 1 hour)

### What's Shared
- ❌ Nothing leaves your machine except TTS API calls (optional)
- ❌ No analytics, telemetry, or third-party tracking
- ❌ No message content sent to ElevenLabs (only generated responses)

### Consent
- User must explicitly enable the extension and join monitored chats
- "Stop" command immediately ends all processing
- Sessions expire after 30 minutes of inactivity

## Development

### Project Structure

```
MakeUC2025/
├── main.py              # FastAPI server & endpoints
├── config.py            # Configuration management
├── models.py            # Pydantic data models
├── detector.py          # Text & audio distress detection
├── state_machine.py     # State transitions & logic
├── interventions.py     # Intervention mapping & sequences
├── ollama_client.py     # Ollama LLM integration
├── tts_client.py        # ElevenLabs TTS integration
├── session_manager.py   # Session state tracking
├── safety.py            # Post-LLM safety filters
├── requirements.txt     # Python dependencies
├── .env.example         # Environment template
└── README.md            # This file
```

### Running Tests

```bash
# Run with increased logging
LOG_LEVEL=DEBUG python main.py

# Test individual components
python -c "from detector import TextDistressDetector; d = TextDistressDetector(); print(d.detect('I am having a panic attack'))"
```

### Extending the System

#### Add a new intervention:
1. Update `models.py`: Add `InterventionType`
2. Update `interventions.py`: Map state → intervention
3. Update `ollama_client.py`: Add prompt guidance

#### Add new crisis keywords:
1. Edit `detector.py`: Add patterns to `CRISIS_KEYWORDS`

#### Change detection thresholds:
1. Edit `state_machine.py`: Adjust `THRESHOLDS` dict

## Limitations & Future Work

### Current Limitations
- Text-only detection by default (audio prosody is placeholder)
- English language only
- No persistent user profiles or learning
- Single-user sessions (no group support)

### Future Enhancements
- [ ] Audio prosody analysis (pitch, pace, tremor)
- [ ] Multi-language support
- [ ] Adaptive thresholds based on user baseline
- [ ] Integration with wearables (heart rate, HRV)
- [ ] Offline TTS option (e.g., Coqui TTS)
- [ ] Session summaries and progress tracking

## License

MIT License - See LICENSE file for details.

## Acknowledgments

- **Meta Glasses API** by [@dcrebbin](https://github.com/dcrebbin)
- **Ollama** - [ollama.com](https://ollama.com)
- **ElevenLabs** - [elevenlabs.io](https://elevenlabs.io)
- Therapeutic techniques inspired by CBT, DBT, and mindfulness practices

## Support & Contact

For issues, questions, or contributions:
- Open an issue on GitHub
- Built for MakeUC 2025 Hackathon

---

**Remember**: This tool supports but does not replace professional care. If you're in crisis:
- 🇺🇸 **988 Suicide & Crisis Lifeline**: Call/text 988
- 🇺🇸 **Crisis Text Line**: Text HOME to 741741
- 🌍 **International**: [findahelpline.com](https://findahelpline.com)

