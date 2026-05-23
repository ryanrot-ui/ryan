extends CharacterBody3D

# ─── Yurei Entity ─────────────────────────────────────────────────────────────
# Classic J-horror ghost: appears suddenly, crawls toward player,
# vanishes when player looks directly at it for 0.5+ seconds.

enum State { DORMANT, APPROACHING, CRAWLING, FLEEING, VANISHED }

const CRAWL_SPEED   = 1.6
const DETECT_RANGE  = 22.0
const KILL_RANGE    = 1.2
const LOOK_THRESHOLD = 0.92   # dot product — how "directly" player must look
const LOOK_KILL_TIME = 0.55   # seconds player must look to banish
const REAPPEAR_TIME  = 18.0

@export var spawn_trigger_radius: float = 16.0
@export var note_id: int = -1

var state: State = State.DORMANT
var _look_timer: float = 0.0
var _reappear_timer: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _original_position: Vector3
var _player: CharacterBody3D = null

@onready var anim:    AnimationPlayer = $AnimationPlayer
@onready var mesh:    MeshInstance3D  = $MeshInstance3D
@onready var audio:   AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	_original_position = global_position
	visible = false
	set_physics_process(false)

func activate() -> void:
	if state != State.DORMANT:
		return
	state = State.APPROACHING
	visible = true
	set_physics_process(true)
	AudioManager.play_ghost_sound("hair_drag")
	AudioManager.play_jumpscare_sting()
	if anim.has_animation("crawl"):
		anim.play("crawl")
	# Sanity hit on spawn
	if GameManager.sanity_ref:
		GameManager.sanity_ref.drain(12.0)

func _physics_process(delta: float) -> void:
	_player = GameManager.player_ref
	if not _player:
		return

	match state:
		State.APPROACHING:
			_handle_approaching(delta)
		State.CRAWLING:
			_handle_crawling(delta)
		State.FLEEING:
			_handle_flee(delta)
		State.VANISHED:
			_handle_reappear(delta)

func _handle_approaching(delta: float) -> void:
	var dist = global_position.distance_to(_player.global_position)
	if dist > DETECT_RANGE:
		_vanish()
		return

	if _is_player_looking_at_me():
		_look_timer += delta
		if _look_timer >= LOOK_KILL_TIME:
			_banish()
			return
	else:
		_look_timer = max(0.0, _look_timer - delta * 2.0)

	state = State.CRAWLING
	_handle_crawling(delta)

func _handle_crawling(delta: float) -> void:
	var dist = global_position.distance_to(_player.global_position)

	if dist <= KILL_RANGE:
		_kill_player()
		return

	if _is_player_looking_at_me():
		_look_timer += delta
		GameManager.sanity_ref.set_ghost_visible(true)
		if _look_timer >= LOOK_KILL_TIME:
			_banish()
			return
	else:
		_look_timer = max(0.0, _look_timer - delta * 1.5)
		GameManager.sanity_ref.set_ghost_visible(false)

	# Crawl toward player
	var dir = (_player.global_position - global_position).normalized()
	dir.y = 0.0
	velocity.x = dir.x * CRAWL_SPEED
	velocity.z = dir.z * CRAWL_SPEED
	velocity.y -= _gravity * delta

	look_at(_player.global_position, Vector3.UP)
	move_and_slide()

func _handle_flee(delta: float) -> void:
	# Ghost fled from player's gaze — drift away then vanish
	velocity = velocity.move_toward(Vector3.ZERO, delta * 3.0)
	move_and_slide()
	_look_timer += delta
	if _look_timer >= 1.5:
		_vanish()

func _handle_reappear(delta: float) -> void:
	_reappear_timer += delta
	if _reappear_timer >= REAPPEAR_TIME:
		_reset()

func _is_player_looking_at_me() -> bool:
	if not _player:
		return false
	var to_ghost = (global_position - _player.global_position).normalized()
	var player_look = _player.get_look_direction()
	return player_look.dot(to_ghost) > LOOK_THRESHOLD

func _banish() -> void:
	state = State.FLEEING
	_look_timer = 0.0
	GameManager.sanity_ref.set_ghost_visible(false)
	if anim.has_animation("flee"):
		anim.play("flee")

func _vanish() -> void:
	state = State.VANISHED
	visible = false
	_reappear_timer = 0.0
	set_physics_process(false)
	GameManager.sanity_ref.set_ghost_visible(false)

func _reset() -> void:
	global_position = _original_position
	state = State.DORMANT
	visible = false

func _kill_player() -> void:
	AudioManager.play_ghost_sound("yurei_shriek")
	AudioManager.play_jumpscare_sting()
	if _player.has_method("die"):
		_player.die()
