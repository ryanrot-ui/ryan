# Jukai No Yami — Setup Guide (macOS Intel)

## 1. Prerequisites

| Tool | Where |
|------|-------|
| Godot 4.3 (Standard, not .NET) | https://godotengine.org/download |
| macOS 12+ (Intel or Rosetta) | — |
| ~500 MB disk space | — |

Download the macOS Universal build — it runs natively on Intel i3 Macs.

---

## 2. Open the project

1. Launch Godot 4.3
2. Click **Import** → navigate to this folder → select `project.godot` → **Import & Edit**
3. The editor opens. Ignore import errors about missing audio/mesh assets — those are placeholders.

---

## 3. Configure Audio Buses

In the **Audio** panel (bottom of editor):

1. Keep the default **Master** bus
2. Add bus: **Music** — set to -12 dB
3. Add bus: **Ambient** — set to -6 dB
4. Add bus: **SFX** — set to 0 dB
5. Add bus: **Ghost** — set to -3 dB
6. On the **Ghost** bus, click **Add Effect** → **Reverb** → Room: Large Hall

---

## 4. Create Ghost Materials

For each ghost entity (Yurei, Onryo, HangingSpirit):

1. Open the entity scene (e.g. `scenes/entities/YureiEntity.tscn`)
2. Select the `MeshInstance3D` node
3. In the Inspector, assign a mesh (Capsule or import a model)
4. Create a new **ShaderMaterial** → paste `shaders/ghost_material.gdshader`
5. Tweak `ghost_color` for each type:
   - Yurei: `rgba(0.75, 0.85, 1.0, 0.5)` — cold blue-white
   - Onryo: `rgba(0.9, 0.7, 0.7, 0.6)` — faint red tinge
   - Hanging: `rgba(0.8, 0.82, 0.95, 0.45)` — near-transparent

---

## 5. Set up the Sanity Vignette

1. Open `scenes/ui/HUD.tscn`
2. Select the **Vignette** (ColorRect at canvas root)
3. In the Inspector → Material → New ShaderMaterial
4. Shader → Load → `shaders/sanity_vignette.gdshader`
5. The shader parameters are driven by `SanitySystem.gd` at runtime

---

## 6. Set up the Rain Overlay

1. In `scenes/ui/HUD.tscn`, select the **RainOverlay** ColorRect
2. Material → New ShaderMaterial → `shaders/rain_overlay.gdshader`
3. Set `rain_intensity` to `0.35` for subtle effect

---

## 7. Build simple placeholder meshes

Until you source real assets, build simple geometry in Godot:

### Yurei (ghost figure)
- Add a **CapsuleShape3D** (0.3 radius, 1.5 height) as MeshInstance3D mesh
- Add a thin Cylinder on top (0.05 radius, 0.8 height) for a hair strand
- Apply ghost_material shader

### Trees
- The **TreeSpawner** auto-generates crossed-plane trees if no mesh is assigned
- For better trees: Kenney's Low Poly Nature pack → import .glb into `assets/models/`

### Lava rocks
- Use **BoxMesh** or **SphereMesh** → scale non-uniformly → dark gray material
- Position near paths for navigation variety

### Shrine
- Combine a **BoxMesh** (base) + **CylinderMesh** (pillar) + **PrismMesh** (roof)
- Dark wood material + gold emission on lantern child mesh

---

## 8. Performance Settings (Intel i3)

These are already configured in `project.godot`, but verify:

1. **Project → Project Settings → Rendering**:
   - MSAA 3D: **Disabled**
   - Directional Shadow Size: **1024**
   - Shadow Filter Quality: **Disabled**
   - Occlusion Culling: **Enabled**
2. In-game: press **Escape → Settings → Enable Performance Mode**
   - Disables volumetric fog
   - Reduces fog density
3. Target: 30–60 FPS. The MultiMesh tree system means all trees = 1 draw call.

---

## 9. Test the game

1. Press **F5** (or the Play button) — starts from MainMenu
2. Press **F6** to run the current open scene directly
3. For a quick level test: open `scenes/levels/ForestEntrance.tscn` → F6

### Debug controls
| Key | Action |
|-----|--------|
| WASD | Move |
| Mouse | Look |
| Shift | Sprint |
| F | Toggle flashlight |
| E | Interact |
| Esc | Pause |

---

## 10. macOS Export (for Steam / distribution)

1. **Editor → Export → Add → macOS**
2. Set App Name: `Jukai No Yami`
3. Set Bundle ID: `com.yourname.jukai`
4. Architecture: **x86_64 + arm64** (Universal)
5. Click **Export Project** → `.dmg` or `.app`

For Steam: wrap the `.app` in a Steamworks `.sh` launcher.
No code signing needed for personal use; for App Store: requires Apple Developer account.

---

## 11. Recommended free models

| Asset | Source | Use |
|-------|--------|-----|
| Low Poly Nature Pack | kenney.nl/assets/nature-kit | Trees, rocks |
| Low Poly Characters | quaternius.com | Yurei/Onryo base |
| Horror Ambience Pack | freesound.org | Ambient loops |
| GDC Audio 2023 | sonniss.com/gameaudiogdc | SFX everything |
| Koto Horror Music | dova-s.jp | J-horror BGM |

---

## Project structure reference

```
jukai_no_yami/
├── project.godot
├── SETUP.md
├── scenes/
│   ├── main/
│   │   ├── MainMenu.tscn
│   │   └── EndingScreen.tscn
│   ├── levels/
│   │   ├── ForestEntrance.tscn    ← Area 1: shrine, first Yurei, Note 0
│   │   ├── DenseTreeSea.tscn      ← Area 2: Onryo spawns, Stalker, Notes 1+2
│   │   └── RibbonPathCave.tscn    ← Area 3: final Note 3, cave exit, endings
│   ├── entities/
│   │   ├── Player.tscn
│   │   ├── YureiEntity.tscn
│   │   ├── OnryoEntity.tscn
│   │   └── HangingSpirit.tscn
│   ├── interactables/
│   │   ├── CollectibleNote.tscn
│   │   └── Shrine.tscn
│   └── ui/
│       └── HUD.tscn
├── scripts/
│   ├── autoload/
│   │   ├── GameManager.gd
│   │   └── AudioManager.gd
│   ├── player/
│   │   ├── Player.gd
│   │   ├── SanitySystem.gd
│   │   └── Flashlight.gd
│   ├── entities/
│   │   ├── YureiEntity.gd
│   │   ├── OnryoEntity.gd
│   │   ├── HangingSpirit.gd
│   │   └── StalkerAI.gd
│   ├── interactables/
│   │   ├── CollectibleNote.gd
│   │   └── ShrineInteraction.gd
│   ├── ui/
│   │   ├── UIManager.gd
│   │   ├── MainMenu.gd
│   │   ├── PauseMenu.gd
│   │   └── EndingScreen.gd
│   └── world/
│       ├── LevelManager.gd
│       ├── TreeSpawner.gd
│       ├── RibbonSpawner.gd
│       └── (add FogController.gd if volumetric needed)
├── shaders/
│   ├── sanity_vignette.gdshader
│   ├── ghost_material.gdshader
│   └── rain_overlay.gdshader
└── audio/
    ├── README.md
    ├── sfx/      ← drop .ogg files here
    ├── ambient/
    └── ghost/
```
