extends CharacterBody3D

# ─── Peripheral Stalker ───────────────────────────────────────────────────────
# Only moves when the player is NOT looking at it.
# Appears at edges of vision, teleports closer each time player looks away.
# Purely psychological — never directly kills unless very close for long.

enum State { INACTIVE, PERIPHERAL, TELEPORTING, CLOSE, GONE }

const PERIPHERAL_LOOK = 0.65   # dot threshold for "peripheral" vision
const DIRECT_LOOK     = 0.88   # dot threshold for direct gaze
const MAX_TELEPORTS   = 5
const CLOSE_KILL_TIME = 6.0    # seconds at close range before kill
const MOVE_SPEED      = 2.2

@export var activation_sanity: float = 50.0  # appears when sanity below this

var state: State = State.INACTIVE
var _teleport_count: int = 0
var _close_timer: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _player: CharacterBody3D = null
var _waypoints: Array[Vector3] = []

@onready var mesh:  MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	visible = false
	set_physics_process(false)
	# Build teleport waypoints around spawn position
	for i in 6:
		var angle = (TAU / 6.0) * i
		_waypoints.append(global_position + Vector3(cos(angle) * 12.0, 0.0, sin(angle) * 12.0))

func activate() -> void:
	if state != State.INACTIVE:
		return
	state = State.PERIPHERAL
	visible = true
	set_physics_process(true)
	_teleport_to_peripheral()

func _physics_process(delta: float) -> void:
	_player = GameManager.player_ref
	if not _player:
		return

	if not is_on_floor():
		velocity.y -= _gravity * delta

	# Check sanity threshold
	if GameManager.sanity_ref and GameManager.sanity_ref.sanity > activation_sanity:
		if state != State.INACTIVE:
			_disappear()
		return

	match state:
		State.PERIPHERAL:
			_handle_peripheral(delta)
		State.TELEPORTING:
			_handle_teleport(delta)
		State.CLOSE:
			_handle_close(delta)

func _handle_peripheral(delta: float) -> void:
	var looking = _check_direct_look()
	if looking:
		# Player looked — freeze, become more opaque
		velocity = Vector3.ZERO
	else:
		# Creep closer when not watched
		var dir = (_player.global_position - global_position).normalized()
		dir.y = 0.0
		velocity.x = dir.x * MOVE_SPEED
		velocity.z = dir.z * MOVE_SPEED
		move_and_slide()

	var dist = global_position.distance_to(_player.global_position)
	if dist < 5.0:
		state = State.CLOSE
	elif looking and _teleport_count < MAX_TELEPORTS:
		# Teleport behind player's back when looked at
		_teleport_behind_player()

func _handle_teleport(_delta: float) -> void:
	state = State.PERIPHERAL

func _handle_close(delta: float) -> void:
	_close_timer += delta
	var looking = _check_direct_look()
	GameManager.sanity_ref.set_ghost_visible(looking)
	GameManager.sanity_ref.drain(3.0 * delta)

	if looking:
		velocity = Vector3.ZERO
	else:
		var dir = (_player.global_position - global_position).normalized()
		dir.y = 0.0
		velocity.x = dir.x * MOVE_SPEED * 0.5
		velocity.z = dir.z * MOVE_SPEED * 0.5
		move_and_slide()

	if _close_timer >= CLOSE_KILL_TIME:
		if _player.has_method("die"):
			_player.die()

func _teleport_to_peripheral() -> void:
	if not _player:
		return
	# Place just outside player's direct view
	var angle = _player.rotation.y + PI + randf_range(-0.8, 0.8)
	var dist = randf_range(10.0, 18.0)
	global_position = _player.global_position + Vector3(sin(angle) * dist, 0.0, cos(angle) * dist)

func _teleport_behind_player() -> void:
	_teleport_count += 1
	state = State.TELEPORTING
	var behind = _player.global_position - _player.get_look_direction() * randf_range(6.0, 12.0)
	behind.y = _player.global_position.y
	global_position = behind
	AudioManager.play_ghost_sound("whisper_jp_2")

func _check_direct_look() -> bool:
	if not _player:
		return false
	var to_self = (global_position - _player.global_position).normalized()
	return _player.get_look_direction().dot(to_self) > DIRECT_LOOK

func _disappear() -> void:
	state = State.GONE
	visible = false
	set_physics_process(false)
