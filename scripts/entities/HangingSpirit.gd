extends Node3D

# ─── Hanging Spirit ───────────────────────────────────────────────────────────
# Appears suspended from tree branch. Snaps to face player when triggered.
# Slowly descends and grabs if player lingers.

enum State { HIDDEN, VISIBLE, DESCENDING, GRABBING }

const DESCEND_SPEED = 0.3
const TRIGGER_DIST  = 10.0
const GRAB_DIST     = 1.5
const LINGER_TIME   = 4.0    # seconds player can stay nearby before grab

@export var hang_height: float = 4.5   # distance above ground to spawn

var state: State = State.HIDDEN
var _ground_y: float = 0.0
var _linger_timer: float = 0.0
var _triggered: bool = false
var _player: CharacterBody3D = null

@onready var mesh:  MeshInstance3D      = $MeshInstance3D
@onready var anim:  AnimationPlayer     = $AnimationPlayer
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	_ground_y = global_position.y - hang_height
	global_position.y += hang_height
	visible = false

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return

	_player = GameManager.player_ref
	if not _player:
		return

	match state:
		State.HIDDEN:
			_check_trigger()
		State.VISIBLE:
			_face_player_tick(delta)
		State.DESCENDING:
			_descend_tick(delta)
		State.GRABBING:
			pass

func _check_trigger() -> void:
	if _triggered:
		return
	var dist = global_position.distance_to(_player.global_position)
	if dist <= TRIGGER_DIST:
		_trigger()

func _trigger() -> void:
	_triggered = true
	state = State.VISIBLE
	visible = true
	if anim.has_animation("hang_idle"):
		anim.play("hang_idle")
	AudioManager.play_jumpscare_sting()
	AudioManager.play_ghost_sound("whisper_jp_1")
	if GameManager.sanity_ref:
		GameManager.sanity_ref.drain(15.0)

func _face_player_tick(delta: float) -> void:
	# Snap to face player (no smooth lerp — unsettling)
	var look_target = Vector3(_player.global_position.x, global_position.y, _player.global_position.z)
	look_at(look_target, Vector3.DOWN)  # Upside-down look

	var dist = global_position.distance_to(_player.global_position)
	if dist <= TRIGGER_DIST * 1.2:
		_linger_timer += get_process_delta_time()
		if _linger_timer >= LINGER_TIME:
			state = State.DESCENDING
			if anim.has_animation("descend"):
				anim.play("descend")
	else:
		_linger_timer = max(0.0, _linger_timer - get_process_delta_time() * 2.0)

func _descend_tick(delta: float) -> void:
	global_position.y -= DESCEND_SPEED * delta

	var dist = global_position.distance_to(_player.global_position)
	if dist <= GRAB_DIST:
		_grab_player()
	elif global_position.y <= _ground_y:
		# Reached ground — charge at player
		var dir = (_player.global_position - global_position).normalized()
		global_position += dir * 8.0 * delta
		if dist <= GRAB_DIST:
			_grab_player()

func _grab_player() -> void:
	state = State.GRABBING
	AudioManager.play_ghost_sound("yurei_shriek")
	AudioManager.play_jumpscare_sting()
	if _player.has_method("die"):
		_player.die()
