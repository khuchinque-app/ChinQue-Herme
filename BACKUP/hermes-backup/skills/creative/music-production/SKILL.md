---
name: music-production
description: "Music and audio production umbrella: AI music generation (AudioCraft/HeartMuLa), songwriting craft and Suno prompts, and audio spectrogram visualization. Use when generating music, writing songs, or analyzing audio."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [music, audio, production, songwriting, suno, generation, spectrogram]
    related_skills: [ascii-video, humanizer]
---

# Music Production

Umbrella skill for music and audio creation. Three subsystems, each with its own trigger.

## Section 1: AI Music Generation (AudioCraft / HeartMuLa)

Use when the user asks to generate music from text descriptions, create sound effects, or use Meta's AudioCraft (MusicGen, AudioGen, EnCodec).

### Quick start (AudioCraft)

```bash
pip install audiocraft
```

```python
from audiocraft.models import MusicGen
import torchaudio

model = MusicGen.get_pretrained('facebook/musicgen-medium')
model.set_generation_params(duration=8, top_k=250, temperature=1.0)

wav = model.generate(["happy upbeat electronic dance music with synths"])
torchaudio.save("output.wav", wav[0].cpu(), sample_rate=32000)
```

**Model variants:** `musicgen-small` (300M), `musicgen-medium` (1.5B), `musicgen-large` (3.3B), `musicgen-melody` (text+melody), `musicgen-stereo-*`.

**Parameters:** `duration` (1-120s), `top_k` (250), `top_p` (0=disabled), `temperature` (1.0), `cfg_coef` (3.0).

### AudioGen (sound effects)

```python
from audiocraft.models import AudioGen
model = AudioGen.get_pretrained('facebook/audiogen-medium')
model.set_generation_params(duration=5)
wav = model.generate(["dog barking in a park with birds chirping"])
torchaudio.save("sound.wav", wav[0].cpu(), sample_rate=16000)
```

### HeartMuLa — Open-Source Song Generation from Lyrics + Tags

For lyrics+tags-to-music (comparable to Suno). See `references/heartmula.md` for full setup including dependency patches, model downloads, and generation parameters. Requires Python 3.10 and CUDA GPU.

**Key difference from AudioCraft:** HeartMuLa takes structured lyrics with bracketed structural tags and genre/mood tags as input — not free-form text descriptions.

### Advanced AudioCraft

See `references/audiocraft-advanced.md` for: training, fine-tuning, deployment, batch processing, Gradio demos.
See `references/audiocraft-troubleshooting.md` for: CUDA OOM, poor quality, artifacts.

---

## Section 2: Songwriting & Suno AI Prompts

Use when the user asks to write song lyrics, craft Suno prompts, create a parody song, or adapt existing lyrics.

### Song Structure Building Blocks

```
ABABCB  Verse/Chorus/Verse/Chorus/Bridge/Chorus   (pop/rock)
AABA    Verse/Verse/Bridge/Verse                   (jazz/ballads)
AAA     Verse/Verse/Verse (strophic)               (folk/storytelling)
```

Building blocks: Intro, Verse, Pre-Chorus, Chorus, Bridge, Outro.

### Suno Style Prompt Formula

```
Genre + Mood + Era + Instruments + Vocal Style + Production + Dynamics
```

**Bad:** "sad rock song"
**Good:** "Cinematic orchestral spy thriller, 1960s Cold War era, smoky sultry female vocalist..."

Describe the dynamic arc: "Begins as a haunting whisper over sparse piano. Gradually layers in muted brass. Builds through the chorus..."

### Suno Metatags

Place `[bracketed]` tags inside lyrics field:
- **Structure:** `[Intro]`, `[Verse]`, `[Chorus]`, `[Bridge]`, `[Outro]`
- **Vocal:** `[Whispered]`, `[Belted]`, `[Falsetto]`, `[Breathy]`
- **Dynamics:** `[High Energy]`, `[Building Energy]`, `[Explosive]`
- **Atmosphere:** `[Melancholic]`, `[Euphoric]`, `[Nostalgic]`

### Phonetic Tricks for AI Singers

- Spell words as they SOUND: "through" → "thru", "Nous" → "Noose"
- ALL CAPS = louder; vowel extension "lo-o-o-ove" = sustained
- Spell out numbers: "24/7" → "twenty four seven"
- Space acronyms: "AI" → "A I" or "A-I"

---

## Section 3: Audio Spectrogram Visualization

Use when the user asks to generate spectrograms, visualize audio features, or analyze audio files.

### songsee CLI

Requires Go: `go install github.com/steipete/songsee/cmd/songsee@latest`

```bash
songsee track.mp3 -o spectrogram.png
songsee track.mp3 --viz spectrogram,mel,chroma,hpss,selfsim,loudness,tempogram,mfcc,flux
songsee track.mp3 --start 12.5 --duration 8 -o slice.jpg
```

**Visualization types:** `spectrogram`, `mel`, `chroma`, `hpss`, `selfsim`, `loudness`, `tempogram`, `mfcc`, `flux`

**Flags:** `--style` (classic/magma/inferno/viridis/gray), `--width`/`--height`, `--window`/`--hop`, `--min-freq`/`--max-freq`, `--format` (jpg/png).

### Decision Flow

| Task | Use |
|------|-----|
| Generate music from text | AudioCraft MusicGen |
| Generate sound effects | AudioCraft AudioGen |
| Generate song from lyrics+tags | HeartMuLa |
| Write lyrics / craft Suno prompts | Songwriting section |
| Create spectrogram / audio viz | songsee |

---

## References

| File | Contents |
|------|----------|
| `references/heartmula.md` | Full HeartMuLa setup with dependency patches, model downloads, generation parameters, and troubleshooting |
| `references/audiocraft-advanced.md` | AudioCraft training, fine-tuning, batch processing, Gradio demos, GPU optimization |
| `references/audiocraft-troubleshooting.md` | AudioCraft common issues: CUDA OOM, poor quality, artifacts, model loading failures |

## Pitfalls

- **HeartMuLa requires Python 3.10** — do not attempt with 3.11+; dependency pins will fail
- **Do NOT use bf16 for HeartCodec** — degrades audio quality. Use fp32.
- **Tags may be ignored by HeartMuLa** — known issue; lyrics tend to dominate
- **AudioCraft model variants matter** — stereo generation requires `musicgen-stereo-*` models
- **MusicGen vs AudioGen sample rates differ** — MusicGen uses 32kHz, AudioGen uses 16kHz
- **Suno style field:** 1,000 char limit in V4.5+, no artist names/trademarks
- **songsee requires Go** — install via `go install`, not apt