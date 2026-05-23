extends Node3D

# ─── Hanging Spirit v2 ────────────────────────────────────────────────────────
# Suspended from a tree. Snaps to face player (wrong orientation — head down).
# Normal descent: slow, creepy, building dread.
# force_fast_drop(): used by GhostSpawnDirector for Scare 4 — drops FAST.

enum State { HIDDEN, TRIGGERED, DESCENDING, GRABBING }

const DESCEND_SPEED_NORMAL = 0.28
const DESCEND_SPEED_FAST   = 2.8   # Scare 4: drops like a stone
const TRIGGER_DIST         = 10.0
const GRAB_DIST            = 1.3
const LINGER_TIME          = 3.5

@export var hang_height: float = 4.5

var state: State    = State.HIDDEN
var _ground_y: float = 0.0
var _linger_t: float = 0.0
var _descent_speed: float = DESCEND_SPEED_NORMAL
var _triggered: bool = false
var _player: CharacterBody3D = null

@onready var mesh:  MeshInstance3D      = $MeshInstance3D
@onready var anim:  AnimationPlayer     = $AnimationPlayer
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	_ground_y = global_position.y
	global_position.y += hang_height
	visible = false

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	_player = GameManager.player_ref
	if not _player:
		return

	match state:
		State.HIDDEN:     _check_trigger()
		State.TRIGGERED:  _tick_triggered(delta)
		State.DESCENDING: _tick_descend(delta)

func _check_trigger() -> void:
	if _triggered:
		return
	if global_position.distance_to(_player.global_position) <= TRIGGER_DIST:
		_trigger_normal()

func _trigger_normal() -> void:
	_triggered = true
	state   = State.TRIGGERED
	visible = true
	_play_anim("hang_idle")
	AudioManager.play_ghost_sound("whisper_jp_1")
	JumpscareSystem.trigger(JumpscareSystem.Intensity.MEDIUM)
	if GameManager.sanity_ref:
		GameManager.sanity_ref.drain(12.0)

# Called by GhostSpawnDirector for Scare 4 — immediate fast drop
func force_fast_drop() -> void:
	_triggered = true
	state   = State.DESCENDING
	visible = true
	_descent_speed = DESCEND_SPEED_FAST
	_play_anim("descend")
	AudioManager.play_ghost_sound("hair_drag")

func _tick_triggered(delta: float) -> void:
	# Face player (upside-down — head toward floor)
	var look_pos = Vector3(_player.global_position.x, global_position.y, _player.global_position.z)
	look_at(look_pos, Vector3.DOWN)

	var dist = global_position.distance_to(_player.global_position)
	if dist <= TRIGGER_DIST * 1.3:
		_linger_t += delta
		if _linger_t >= LINGER_TIME:
			state = State.DESCENDING
			_play_anim("descend")
	else:
		_linger_t = max(0.0, _linger_t - delta * 2.0)

func _tick_descend(delta: float) -> void:
	global_position.y -= _descent_speed * delta

	var dist = global_position.distance_to(_player.global_position)
	if dist <= GRAB_DIST or global_position.y <= _ground_y + 0.1:
		_grab()

func _grab() -> void:
	if state == State.GRABBING:
		return
	state = State.GRABBING
	JumpscareSystem.trigger(JumpscareSystem.Intensity.MAX)
	AudioManager.play_ghost_sound("yurei_shriek")
	if _descent_speed >= DESCEND_SPEED_FAST:
		# High-speed drop is always a scare, not always a kill
		if global_position.distance_to(_player.global_position) <= GRAB_DIST:
			if _player.has_method("die"):
				_player.die()
	else:
		if _player.has_method("die"):
			_player.die()

func _play_anim(anim_name: String) -> void:
	if anim.has_animation(anim_name):
		anim.play(anim_name)
