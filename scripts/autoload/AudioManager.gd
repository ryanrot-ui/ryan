extends Node

# ─── Audio Manager ────────────────────────────────────────────────────────────
# Auto-creates required audio buses on first run so the game works even
# before the editor Audio panel is configured.

const SFX_PATHS = {
	"footstep_wet_1":  "res://audio/sfx/footstep_wet_1.ogg",
	"footstep_wet_2":  "res://audio/sfx/footstep_wet_2.ogg",
	"footstep_wet_3":  "res://audio/sfx/footstep_wet_3.ogg",
	"note_pickup":     "res://audio/sfx/note_pickup.ogg",
	"shrine_charge":   "res://audio/sfx/shrine_charge.ogg",
	"flashlight_on":   "res://audio/sfx/flashlight_click.ogg",
	"flashlight_off":  "res://audio/sfx/flashlight_off.ogg",
	"battery_low":     "res://audio/sfx/battery_low_beep.ogg",
	"jumpscare_sting": "res://audio/sfx/jumpscare_sting.ogg",
	"breath_fast":     "res://audio/sfx/breath_fast.ogg",
}
const AMBIENT_PATHS = {
	"forest_night": "res://audio/ambient/forest_night.ogg",
	"deep_forest":  "res://audio/ambient/deep_forest_drip.ogg",
	"cave_wind":    "res://audio/ambient/cave_wind.ogg",
	"rain_light":   "res://audio/ambient/rain_light.ogg",
}
const GHOST_PATHS = {
	"whisper_jp_1": "res://audio/ghost/whisper_jp_1.ogg",
	"whisper_jp_2": "res://audio/ghost/whisper_jp_2.ogg",
	"whisper_jp_3": "res://audio/ghost/whisper_jp_3.ogg",
	"hair_drag":    "res://audio/ghost/hair_dragging.ogg",
	"yurei_shriek": "res://audio/ghost/yurei_shriek.ogg",
	"onryo_growl":  "res://audio/ghost/onryo_growl.ogg",
	"koto_sting":   "res://audio/ghost/koto_horror_sting.ogg",
	"cry_distant":  "res://audio/ghost/cry_distant.ogg",
	"cry_closer":   "res://audio/ghost/cry_closer.ogg",
	"cry_clear":    "res://audio/ghost/cry_clear.ogg",
	"cry_intense":  "res://audio/ghost/cry_intense.ogg",
}

var _sfx_pool:   Array[AudioStreamPlayer] = []
var _ambient:    AudioStreamPlayer
var _ghost:      AudioStreamPlayer
var _cry:        AudioStreamPlayer
var _foot_idx:   int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_buses()
	_build_players()

# ─── Bus auto-creation ────────────────────────────────────────────────────────

func _ensure_buses() -> void:
	var needed = {"Music": -12.0, "Ambient": -6.0, "SFX": 0.0, "Ghost": -3.0}
	for bus_name in needed.keys():
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			var i = AudioServer.get_bus_count() - 1
			AudioServer.set_bus_name(i, bus_name)
			AudioServer.set_bus_volume_db(i, needed[bus_name])

func _build_players() -> void:
	for _i in 8:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)
	_ambient = _make_player("Ambient", -6.0)
	_ghost   = _make_player("Ghost",   -3.0)
	_cry     = _make_player("Ghost",   -80.0)

func _make_player(bus: String, vol: float) -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	p.bus = bus
	p.volume_db = vol
	add_child(p)
	return p

# ─── SFX ──────────────────────────────────────────────────────────────────────

func play_sfx(key: String, vol_db: float = 0.0) -> void:
	var path = SFX_PATHS.get(key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var p = _free_sfx()
	if not p:
		return
	p.stream    = load(path)
	p.volume_db = vol_db
	p.play()

func play_footstep() -> void:
	var keys = ["footstep_wet_1", "footstep_wet_2", "footstep_wet_3"]
	_foot_idx = (_foot_idx + 1) % keys.size()
	play_sfx(keys[_foot_idx], randf_range(-2.5, 0.5))

func play_jumpscare_sting() -> void:
	play_sfx("jumpscare_sting", 2.5)

# ─── Ghost ────────────────────────────────────────────────────────────────────

func play_ghost_sound(key: String) -> void:
	var path = GHOST_PATHS.get(key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	if not is_instance_valid(_ghost):
		return
	_ghost.stream = load(path)
	_ghost.play()

func play_whisper() -> void:
	var keys = ["whisper_jp_1", "whisper_jp_2", "whisper_jp_3"]
	play_ghost_sound(keys[randi() % keys.size()])

func set_cry_stream(key: String, target_vol: float, fade: float = 1.8) -> void:
	if not is_instance_valid(_cry):
		return
	var path = GHOST_PATHS.get(key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var stream = load(path)
	if _cry.stream != stream:
		_cry.stream = stream
		_cry.volume_db = -80.0
		_cry.play()
	var tween = create_tween()
	tween.tween_property(_cry, "volume_db", target_vol, fade)

func stop_crying(fade: float = 2.0) -> void:
	if not is_instance_valid(_cry):
		return
	var tween = create_tween()
	tween.tween_property(_cry, "volume_db", -80.0, fade)
	await tween.finished
	if is_instance_valid(_cry):
		_cry.stop()

# ─── Ambient ──────────────────────────────────────────────────────────────────

func play_ambient(key: String, fade: float = 2.0) -> void:
	var path = AMBIENT_PATHS.get(key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	if not is_instance_valid(_ambient):
		return
	var tween = create_tween()
	tween.tween_property(_ambient, "volume_db", -80.0, fade * 0.4)
	await tween.finished
	if not is_instance_valid(_ambient):
		return
	_ambient.stream = load(path)
	_ambient.play()
	tween = create_tween()
	tween.tween_property(_ambient, "volume_db", -6.0, fade * 0.6)

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _free_sfx() -> AudioStreamPlayer:
	for p in _sfx_pool:
		if is_instance_valid(p) and not p.playing:
			return p
	return _sfx_pool[0] if not _sfx_pool.is_empty() else null
