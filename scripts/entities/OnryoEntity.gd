extends CharacterBody3D

# ─── Onryo Entity ─────────────────────────────────────────────────────────────
# Vengeful spirit — spawns only when sanity drops below 35%.
# Does NOT flee when looked at. Blocks paths and charges when player is close.
# Can only be repelled by shrine light briefly.

enum State { DORMANT, STALKING, BLOCKING, CHARGING, REPELLED }

const STALK_SPEED   = 2.0
const CHARGE_SPEED  = 6.5
const BLOCK_DIST    = 4.5
const CHARGE_DIST   = 2.8
const SANITY_SPAWN  = 35.0
const REPEL_TIME    = 8.0

@export var spawn_on_sanity_drop: bool = true

var state: State = State.DORMANT
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _repel_timer: float = 0.0
var _charge_dir: Vector3 = Vector3.ZERO
var _player: CharacterBody3D = null
var _spawned: bool = false

@onready var anim:  AnimationPlayer     = $AnimationPlayer
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	visible = false
	set_physics_process(false)
	if spawn_on_sanity_drop and GameManager.sanity_ref:
		GameManager.sanity_ref.sanity_critical.connect(_on_sanity_critical)

func _on_sanity_critical() -> void:
	if not _spawned:
		_spawned = true
		_spawn_behind_player()

func _spawn_behind_player() -> void:
	_player = GameManager.player_ref
	if not _player:
		return
	var behind = _player.global_position - _player.get_look_direction() * 8.0
	behind.y = _player.global_position.y
	global_position = behind
	state = State.STALKING
	visible = true
	set_physics_process(true)
	AudioManager.play_ghost_sound("onryo_growl")
	AudioManager.play_jumpscare_sting()
	if GameManager.sanity_ref:
		GameManager.sanity_ref.drain(18.0)

func _physics_process(delta: float) -> void:
	_player = GameManager.player_ref
	if not _player:
		return

	if not is_on_floor():
		velocity.y -= _gravity * delta

	match state:
		State.STALKING:
			_handle_stalk(delta)
		State.BLOCKING:
			_handle_block(delta)
		State.CHARGING:
			_handle_charge(delta)
		State.REPELLED:
			_handle_repelled(delta)

func _handle_stalk(delta: float) -> void:
	# "Only moves when not looked at" mechanic
	var looking = _is_player_looking_at_me()
	GameManager.sanity_ref.set_ghost_visible(looking)

	if looking:
		# Freeze — classic horror mechanic
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var dist = global_position.distance_to(_player.global_position)
	if dist <= BLOCK_DIST:
		state = State.BLOCKING
		return

	# Move toward player slowly
	var dir = (_player.global_position - global_position).normalized()
	dir.y = 0.0
	velocity.x = dir.x * STALK_SPEED
	velocity.z = dir.z * STALK_SPEED
	look_at(Vector3(_player.global_position.x, global_position.y, _player.global_position.z), Vector3.UP)
	move_and_slide()

func _handle_block(delta: float) -> void:
	var dist = global_position.distance_to(_player.global_position)
	# Drift to stay in front of player's path
	var target_pos = _player.global_position + _player.get_look_direction() * 3.5
	target_pos.y = global_position.y
	var dir = (target_pos - global_position).normalized()
	velocity.x = lerpf(velocity.x, dir.x * STALK_SPEED, delta * 4.0)
	velocity.z = lerpf(velocity.z, dir.z * STALK_SPEED, delta * 4.0)
	move_and_slide()

	if dist <= CHARGE_DIST:
		_begin_charge()
	elif dist > BLOCK_DIST * 2.0:
		state = State.STALKING

func _begin_charge() -> void:
	state = State.CHARGING
	_charge_dir = (_player.global_position - global_position).normalized()
	AudioManager.play_ghost_sound("onryo_growl")
	if GameManager.sanity_ref:
		GameManager.sanity_ref.drain(25.0)

func _handle_charge(delta: float) -> void:
	velocity.x = _charge_dir.x * CHARGE_SPEED
	velocity.z = _charge_dir.z * CHARGE_SPEED
	move_and_slide()

	var dist = global_position.distance_to(_player.global_position)
	if dist <= 0.9:
		if _player.has_method("die"):
			_player.die()
	elif dist > 12.0:
		state = State.STALKING

func repel() -> void:
	# Called by shrine proximity
	state = State.REPELLED
	_repel_timer = 0.0
	var away = (global_position - _player.global_position).normalized()
	velocity = away * 5.0
	AudioManager.play_ghost_sound("onryo_growl")

func _handle_repelled(delta: float) -> void:
	_repel_timer += delta
	velocity = velocity.move_toward(Vector3.ZERO, delta * 3.0)
	move_and_slide()
	if _repel_timer >= REPEL_TIME:
		state = State.STALKING

func _is_player_looking_at_me() -> bool:
	if not _player:
		return false
	var to_ghost = (global_position - _player.global_position).normalized()
	var dot = _player.get_look_direction().dot(to_ghost)
	return dot > 0.88
