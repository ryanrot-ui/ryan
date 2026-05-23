extends Node

# ─── Audio Manager ────────────────────────────────────────────────────────────
# All audio paths are @placeholders — drop real OGG/WAV files at these paths.
# Free sources listed in SETUP.md.

const SFX_PATHS = {
	"footstep_wet_1": "res://audio/sfx/footstep_wet_1.ogg",
	"footstep_wet_2": "res://audio/sfx/footstep_wet_2.ogg",
	"footstep_wet_3": "res://audio/sfx/footstep_wet_3.ogg",
	"note_pickup":    "res://audio/sfx/note_pickup.ogg",
	"shrine_charge":  "res://audio/sfx/shrine_charge.ogg",
	"flashlight_on":  "res://audio/sfx/flashlight_click.ogg",
	"flashlight_off": "res://audio/sfx/flashlight_off.ogg",
	"battery_low":    "res://audio/sfx/battery_low_beep.ogg",
	"jumpscare_sting":"res://audio/sfx/jumpscare_sting.ogg",
	"breath_fast":    "res://audio/sfx/breath_fast.ogg",
	"door_creak":     "res://audio/sfx/door_creak.ogg",
}

const AMBIENT_PATHS = {
	"forest_night":   "res://audio/ambient/forest_night.ogg",
	"deep_forest":    "res://audio/ambient/deep_forest_drip.ogg",
	"cave_wind":      "res://audio/ambient/cave_wind.ogg",
	"rain_light":     "res://audio/ambient/rain_light.ogg",
}

const GHOST_PATHS = {
	"whisper_jp_1":   "res://audio/ghost/whisper_jp_1.ogg",
	"whisper_jp_2":   "res://audio/ghost/whisper_jp_2.ogg",
	"whisper_jp_3":   "res://audio/ghost/whisper_jp_3.ogg",
	"hair_drag":      "res://audio/ghost/hair_dragging.ogg",
	"yurei_shriek":   "res://audio/ghost/yurei_shriek.ogg",
	"onryo_growl":    "res://audio/ghost/onryo_growl.ogg",
	"koto_sting":     "res://audio/ghost/koto_horror_sting.ogg",
}

var _sfx_pool: Array[AudioStreamPlayer] = []
var _ambient_player: AudioStreamPlayer
var _ghost_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _footstep_index: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_players()

func _setup_players() -> void:
	# Pool of 8 SFX players for overlapping sounds
	for i in 8:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)

	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Ambient"
	_ambient_player.volume_db = -6.0
	add_child(_ambient_player)

	_ghost_player = AudioStreamPlayer.new()
	_ghost_player.bus = "Ghost"
	_ghost_player.volume_db = -3.0
	add_child(_ghost_player)

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.volume_db = -12.0
	add_child(_music_player)

func play_sfx(key: String, volume_db: float = 0.0) -> void:
	if not SFX_PATHS.has(key):
		return
	var path = SFX_PATHS[key]
	if not ResourceLoader.exists(path):
		return
	var player = _get_free_sfx_player()
	if player:
		player.stream = load(path)
		player.volume_db = volume_db
		player.play()

func play_footstep() -> void:
	var keys = ["footstep_wet_1", "footstep_wet_2", "footstep_wet_3"]
	_footstep_index = (_footstep_index + 1) % keys.size()
	play_sfx(keys[_footstep_index], randf_range(-3.0, 0.0))

func play_ghost_sound(key: String) -> void:
	if not GHOST_PATHS.has(key):
		return
	var path = GHOST_PATHS[key]
	if not ResourceLoader.exists(path):
		return
	_ghost_player.stream = load(path)
	_ghost_player.play()

func play_whisper() -> void:
	var keys = ["whisper_jp_1", "whisper_jp_2", "whisper_jp_3"]
	play_ghost_sound(keys[randi() % keys.size()])

func play_ambient(key: String, fade_time: float = 2.0) -> void:
	if not AMBIENT_PATHS.has(key):
		return
	var path = AMBIENT_PATHS[key]
	if not ResourceLoader.exists(path):
		return
	var tween = create_tween()
	tween.tween_property(_ambient_player, "volume_db", -80.0, fade_time * 0.4)
	await tween.finished
	_ambient_player.stream = load(path)
	_ambient_player.play()
	tween = create_tween()
	tween.tween_property(_ambient_player, "volume_db", -6.0, fade_time * 0.6)

func stop_ambient(fade_time: float = 1.5) -> void:
	var tween = create_tween()
	tween.tween_property(_ambient_player, "volume_db", -80.0, fade_time)
	await tween.finished
	_ambient_player.stop()

func play_jumpscare_sting() -> void:
	play_sfx("jumpscare_sting", 3.0)

func _get_free_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_pool:
		if not p.playing:
			return p
	return _sfx_pool[0]
