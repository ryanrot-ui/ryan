# Audio Assets — Jukai No Yami

All audio slots are placeholders. Drop OGG or WAV files into the correct folders.
Godot imports OGG natively; WAV works too but OGG is smaller.

## Required folder structure

```
audio/
├── sfx/
│   ├── footstep_wet_1.ogg
│   ├── footstep_wet_2.ogg
│   ├── footstep_wet_3.ogg
│   ├── note_pickup.ogg
│   ├── shrine_charge.ogg
│   ├── flashlight_click.ogg
│   ├── flashlight_off.ogg
│   ├── battery_low_beep.ogg
│   ├── jumpscare_sting.ogg
│   ├── breath_fast.ogg
│   └── door_creak.ogg
├── ambient/
│   ├── forest_night.ogg        ← looping night forest ambience
│   ├── deep_forest_drip.ogg    ← denser, drips, low wind
│   ├── cave_wind.ogg           ← cave/tunnel air movement
│   └── rain_light.ogg          ← soft rainfall loop
└── ghost/
    ├── whisper_jp_1.ogg        ← Japanese whisper ("助けて" / tasukete)
    ├── whisper_jp_2.ogg        ← Japanese whisper ("なぜ来たの")
    ├── whisper_jp_3.ogg        ← Japanese whisper ("帰れ")
    ├── hair_dragging.ogg       ← hair dragging on floor
    ├── yurei_shriek.ogg        ← classic J-horror shriek
    ├── onryo_growl.ogg         ← low, guttural growl
    └── koto_horror_sting.ogg   ← koto / traditional horror sting
```

## Free sources

### SFX + Ambient
- **freesound.org** — search: "wet footstep", "forest night ambience", "cave wind"
  - Filter: CC0 license for commercial use
- **pixabay.com/sound-effects** — "horror sting", "flashlight click"
- **zapsplat.com** (free account) — excellent horror SFX library
- **sonniss.com/gameaudiogdc** — annual free GDC audio pack, huge selection

### Japanese whispers
- Record yourself whispering Japanese phrases, pitch-shift down 20%
- Or: Eleven Labs / TTSMaker TTS → Japanese female voice → whisper effect in Audacity
- Suggested phrases: 助けて (tasukete), なぜ来たの (naze kita no), 帰れ (kaere), 一緒に (issho ni)

### Music / Koto sting
- **Kevin MacLeod** (incompetech.com) — "Lightless Dawn", "Ossuary" — CC BY
- **Epidemic Sound** (paid) — excellent J-horror koto tracks
- **DOVA-SYNDROME** (dova-s.jp) — Japanese free music library, excellent for atmosphere

### Ghost models (for MeshInstance3D)
- **Kenney.nl** — low-poly character packs (base for Yurei/Onryo)
- **Quaternius.com** — free low-poly character assets
- **sketchfab.com** — search "low poly ghost" (check license)
- Hand-craft in Godot: elongated capsule + thin cylinder hair strands

## Audio Bus setup (create in Godot's Audio panel)

```
Master
├── Music   (volume: -12 dB)
├── Ambient (volume: -6 dB)
├── SFX     (volume: 0 dB)
└── Ghost   (volume: -3 dB, Reverb effect: Large Hall)
```

Add a **Reverb** effect to the Ghost bus — makes ghosts sound distant and eerie.
Add a **LowPassFilter** to Ambient for when inside cave (cutoff ~800 Hz).
