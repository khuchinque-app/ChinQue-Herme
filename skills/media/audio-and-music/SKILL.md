---
name: audio-and-music
description: "Audio generation, music generation, songwriting, and audio visualization — AudioCraft, HeartMuLa, Suno, songcraft, and SongSee spectrograms."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [audio, music, generation, songwriting, visualization, audiocraft, heartmula, suno, spectrogram]
    related_skills: [youtube-content, gif-search, humanizer]
---

# Audio & Music Production

Class-level skill covering four distinct but related audio domains. Use the section that matches the user's request.

## Section 1: AudioCraft — Text-to-Music & Sound

Meta's AudioCraft for text-to-music (MusicGen) and text-to-sound (AudioGen) generation.

### Installation

```bash
pip install audiocraft
# Or from GitHub
pip install git+https://github.com/facebookresearch/audiocraft.git
# Or via HuggingFace Transformers
pip install transformers torch torchaudio
```

### MusicGen — Text-to-Music

```python
from audiocraft.models import MusicGen
import torchaudio

model = MusicGen.get_pretrained('facebook/musicgen-medium')
model.set_generation_params(duration=8, top_k=250, temperature=1.0)
wav = model.generate(["happy upbeat electronic dance music with synths"])
torchaudio.save("output.wav", wav[0].cpu(), sample_rate=32000)
```

### HuggingFace Transformers

```python
from transformers import AutoProcessor, MusicgenForConditionalGeneration
import scipy

processor = AutoProcessor.from_pretrained("facebook/musicgen-small")
model = MusicgenForConditionalGeneration.from_pretrained("facebook/musicgen-small")
inputs = processor(text=["80s pop track with bassy drums and synth"], padding=True, return_tensors="pt")
audio_values = model.generate(**inputs, do_sample=True, guidance_scale=3, max_new_tokens=256)
scipy.io.wavfile.write("output.wav", rate=model.config.audio_encoder.sampling_rate, data=audio_values[0, 0].cpu().numpy())
```

### AudioGen — Text-to-Sound

```python
from audiocraft.models import AudioGen
model = AudioGen.get_pretrained('facebook/audiogen-medium')
model.set_generation_params(duration=5)
wav = model.generate(["dog barking in a park with birds chirping"])
torchaudio.save("sound.wav", wav[0].cpu(), sample_rate=16000)
```

### Model Variants

| Model | Size | Use Case |
|-------|------|----------|
| `musicgen-small` | 300M | Quick generation |
| `musicgen-medium` | 1.5B | Balanced |
| `musicgen-large` | 3.3B | Best quality |
| `musicgen-melody` | 1.5B | Melody conditioning |
| `musicgen-stereo-*` | Varies | Stereo output |
| `musicgen-style` | 1.5B | Style transfer |
| `audiogen-medium` | 1.5B | Sound effects |

### Key Parameters

`duration` (1-120s), `top_k` (sampling diversity), `temperature` (creativity), `cfg_coef` (text adherence, 1.0-10.0).

### EnCodec Audio Compression

```python
from audiocraft.models import CompressionModel
model = CompressionModel.get_pretrained('facebook/encodec_32khz')
# encode/decode audio tokens for compression
```

### Performance Notes

- GPU memory: small ~4GB FP32, medium ~8GB, large ~16GB
- Use half precision (`model = model.half()`) for lower VRAM
- Batch generation is more efficient than single-prompt loops

## Section 2: HeartMuLa — Open-Source Song Generation

HeartMuLa generates full songs from lyrics + tags. Apache-2.0, comparable to Suno.

### Installation

```bash
cd ~/
git clone https://github.com/HeartMuLa/heartlib.git
cd heartlib
uv venv --python 3.10 .venv
source .venv/bin/activate
uv pip install -e .
uv pip install --upgrade datasets transformers
```

**Requires Python 3.10.** Also apply source patches for transformers 5.x (see `heartmula` skill in archive for details).

### Download Checkpoints

```bash
cd heartlib
hf download --local-dir './ckpt' 'HeartMuLa/HeartMuLaGen'
hf download --local-dir './ckpt/HeartMuLa-oss-3B' 'HeartMuLa/HeartMuLa-oss-3B-happy-new-year'
hf download --local-dir './ckpt/HeartCodec-oss' 'HeartMuLa/HeartCodec-oss-20260123'
```

### Basic Generation

```bash
cd heartlib && source .venv/bin/activate
python ./examples/run_music_generation.py \
  --model_path=./ckpt --version="3B" \
  --lyrics="./assets/lyrics.txt" --tags="./assets/tags.txt" \
  --save_path="./assets/output.mp3" --lazy_load true
```

### Input Format

**Tags** (comma-separated): `piano,happy,wedding,synthesizer,romantic`
**Lyrics** (bracketed structural tags): `[Intro]`, `[Verse]`, `[Chorus]`, `[Bridge]`, `[Outro]`

### Key Parameters

`--max_audio_length_ms` (240000 = 4 min), `--topk` (50), `--temperature` (1.0), `--cfg_scale` (1.5), `--lazy_load` (saves VRAM).

### Hardware

- Minimum: 8GB VRAM with `--lazy_load true`
- Recommended: 16GB+ VRAM
- CPU mode possible but extremely slow (30-60 min per song)

### Pitfalls

- Do NOT use bf16 for HeartCodec (degrades quality)
- Tags may be ignored — lyrics dominate
- Linux/CUDA only for GPU acceleration

## Section 3: Songwriting & Suno AI Music

Songwriting craft and Suno AI prompting. Guidelines, not rules — art breaks rules on purpose.

### Song Structure Options

- **ABABCB** — Verse/Chorus/Verse/Chorus/Bridge/Chorus (pop/rock)
- **AABA** — Verse/Verse/Bridge/Verse (ballads, jazz)
- **ABAB** — Verse/Chorus alternating (simple, direct)
- **AAA** — Strophic (folk, storytelling)

Building blocks: Intro, Verse, Pre-Chorus, Chorus, Bridge, Outro.

### Lyric Craft

- **Show, don't tell:** "Your hoodie's still on the hook by the door" > "I was sad"
- **Rhyme types (mix them):** perfect (lean/mean), family (crate/braid), assonance (had/glass), near/slant
- **Meter:** stressed syllables matter more than total count. Say it out loud.
- **Energy mapping:** Intro 2-3 → Verse 5-6 → Chorus 8-9 → Bridge varies → Final Chorus 9-10
- **Contrast is the most powerful dynamic tool:** whisper before a scream hits harder

### Suno Prompt Engineering

**Style field formula:** Genre + Mood + Era + Instruments + Vocal Style + Production + Dynamics
```
BAD: "sad rock song"
GOOD: "Cinematic orchestral spy thriller, 1960s Cold War era, smoky sultry female vocalist,
       big band jazz, brass section with trumpets and french horns, sweeping strings, minor key"
```

**Describe the journey:** "Begins as haunting whisper over sparse piano. Gradually layers in muted brass..."

**Metatags** (place in [brackets]): `[Verse]`, `[Chorus]`, `[Whispered]`, `[Belted]`, `[High Energy]`, `[Female Vocals]`, `[Vinyl Crackle]`

**Phonetic tricks:** Spell words as they sound ("through" → "thru"), ALL CAPS = louder, hyphens for sustained notes ("lo-o-o-ove").

### Parody Adaptation

1. Map original's syllable count, rhyme scheme, stressed beats
2. Match stressed syllables to original's beats
3. On held notes, match the VOWEL SOUND of the original
4. Keep some original lines for recognizability

## Section 4: SongSee — Audio Visualization (Spectrograms)

Generate spectrograms and multi-panel audio feature visualizations from audio files.

### Installation

```bash
go install github.com/steipete/songsee/cmd/songsee@latest
```

### Basic Usage

```bash
songsee track.mp3                              # basic spectrogram
songsee track.mp3 -o spectrogram.png            # save to file
songsee track.mp3 --viz spectrogram,mel,chroma  # multi-panel grid
songsee track.mp3 --start 12.5 --duration 8     # time slice
```

### Visualization Types

| Type | Description |
|------|-------------|
| `spectrogram` | Standard frequency spectrogram |
| `mel` | Mel-scaled spectrogram |
| `chroma` | Pitch class distribution |
| `hpss` | Harmonic/percussive separation |
| `selfsim` | Self-similarity matrix |
| `loudness` | Loudness over time |
| `tempogram` | Tempo estimation |
| `mfcc` | Mel-frequency cepstral coefficients |
| `flux` | Spectral flux (onset detection) |

### Key Flags

`--style` (classic/magma/inferno/viridis/gray), `--width`/`--height`, `--window`/`--hop`, `--min-freq`/`--max-freq`, `--format` (jpg/png).

### Notes

- WAV/MP3 decoded natively; other formats need ffmpeg
- Output images can be analyzed with `vision_analyze`
