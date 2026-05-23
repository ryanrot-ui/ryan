extends Node

# ─── Audio Manager v2 ─────────────────────────────────────────────────────────
# All paths are @placeholders — drop real OGG/WAV files at these paths.
# See audio/README.md for free asset sources.

const SFX_PATHS = {
	"footstep_wet_1":    "res://audio/sfx/footstep_wet_1.ogg",
	"footstep_wet_2":    "res://audio/sfx/footstep_wet_2.ogg",
	"footstep_wet_3":    "res://audio/sfx/footstep_wet_3.ogg",
	"note_pickup":       "res://audio/sfx/note_pickup.ogg",
	"shrine_charge":     "res://audio/sfx/shrine_charge.ogg",
	"flashlight_on":     "res://audio/sfx/flashlight_click.ogg",
	"flashlight_off":    "res://audio/sfx/flashlight_off.ogg",
	"battery_low":       "res://audio/sfx/battery_low_beep.ogg",
	"jumpscare_sting":   "res://audio/sfx/jumpscare_sting.ogg",
	"breath_fast":       "res://audio/sfx/breath_fast.ogg",
}

const AMBIENT_PATHS = {
	"forest_night":    "res://audio/ambient/forest_night.ogg",
	"deep_forest":     "res://audio/ambient/deep_forest_drip.ogg",
	"cave_wind":       "res://audio/ambient/cave_wind.ogg",
	"rain_light":      "res://audio/ambient/rain_light.ogg",
}

const GHOST_PATHS = {
	# Whispers / crying — louder & clearer at each tier
	"whisper_jp_1":    "res://audio/ghost/whisper_jp_1.ogg",     # barely audible distant cry
	"whisper_jp_2":    "res://audio/ghost/whisper_jp_2.ogg",     # closer, name audible
	"whisper_jp_3":    "res://audio/ghost/whisper_jp_3.ogg",     # clear, "助けて" distinct
	"hair_drag":       "res://audio/ghost/hair_dragging.ogg",    # floor drag cue (behind-player scare)
	"yurei_shriek":    "res://audio/ghost/yurei_shriek.ogg",     # kill / reveal sting
	"onryo_growl":     "res://audio/ghost/onryo_growl.ogg",      # low guttural
	"koto_sting":      "res://audio/ghost/koto_horror_sting.ogg",# flashlight reveal music hit
	# Crying tiers (same keys used by SanitySystem)
	"cry_distant":     "res://audio/ghost/cry_distant.ogg",      # tier 0: far female sob
	"cry_closer":      "res://audio/ghost/cry_closer.ogg",       # tier 1: closing in
	"cry_clear":       "res://audio/ghost/cry_clear.ogg",        # tier 2: name whispered
	"cry_intense":     "res://audio/ghost/cry_intense.ogg",      # tier 3: overlapping voices
}

var _sfx_pool:    Array[AudioStreamPlayer] = []
var _ambient_bus: AudioStreamPlayer
var _ghost_bus:   AudioStreamPlayer
var _cry_bus:     AudioStreamPlayer
var _foot_idx:    int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_players()

func _setup_players() -> void:
	for i in 8:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)

	_ambient_bus = _make_player("Ambient", -6.0)
	_ghost_bus   = _make_player("Ghost",   -3.0)
	_cry_bus     = _make_player("Ghost",   -80.0)  # starts inaudible, fades in

func _make_player(bus: String, vol: float) -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	p.bus = bus
	p.volume_db = vol
	add_child(p)
	return p

# ─── SFX ──────────────────────────────────────────────────────────────────────

func play_sfx(key: String, vol_db: float = 0.0) -> void:
	if not SFX_PATHS.has(key):
		return
	var path = SFX_PATHS[key]
	if not ResourceLoader.exists(path):
		return
	var p = _free_sfx()
	if p:
		p.stream    = load(path)
		p.volume_db = vol_db
		p.play()

func play_footstep() -> void:
	var keys = ["footstep_wet_1", "footstep_wet_2", "footstep_wet_3"]
	_foot_idx = (_foot_idx + 1) % keys.size()
	play_sfx(keys[_foot_idx], randf_range(-2.5, 0.5))

func play_jumpscare_sting() -> void:
	play_sfx("jumpscare_sting", 2.5)

# ─── Ghost / Whispers ─────────────────────────────────────────────────────────

func play_ghost_sound(key: String) -> void:
	if not GHOST_PATHS.has(key):
		return
	var path = GHOST_PATHS[key]
	if not ResourceLoader.exists(path):
		return
	_ghost_bus.stream = load(path)
	_ghost_bus.play()

func play_whisper() -> void:
	var keys = ["whisper_jp_1", "whisper_jp_2", "whisper_jp_3"]
	play_ghost_sound(keys[randi() % keys.size()])

# Called by SanitySystem for the graduated crying system
func set_cry_stream(key: String, target_vol_db: float, fade_time: float = 1.8) -> void:
	if not GHOST_PATHS.has(key):
		return
	var path = GHOST_PATHS[key]
	if not ResourceLoader.exists(path):
		_cry_bus.volume_db = -80.0
		return
	# Only change stream if different to avoid restarting same clip
	var stream = load(path)
	if _cry_bus.stream != stream:
		_cry_bus.stream = stream
		_cry_bus.volume_db = -80.0
		_cry_bus.play()
	var tween = create_tween()
	tween.tween_property(_cry_bus, "volume_db", target_vol_db, fade_time)

func stop_crying(fade_time: float = 2.0) -> void:
	var tween = create_tween()
	tween.tween_property(_cry_bus, "volume_db", -80.0, fade_time)
	await tween.finished
	_cry_bus.stop()

# ─── Ambient ──────────────────────────────────────────────────────────────────

func play_ambient(key: String, fade: float = 2.0) -> void:
	if not AMBIENT_PATHS.has(key):
		return
	var path = AMBIENT_PATHS[key]
	if not ResourceLoader.exists(path):
		return
	var tween = create_tween()
	tween.tween_property(_ambient_bus, "volume_db", -80.0, fade * 0.4)
	await tween.finished
	_ambient_bus.stream = load(path)
	_ambient_bus.play()
	tween = create_tween()
	tween.tween_property(_ambient_bus, "volume_db", -6.0, fade * 0.6)

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _free_sfx() -> AudioStreamPlayer:
	for p in _sfx_pool:
		if not p.playing:
			return p
	return _sfx_pool[0]
