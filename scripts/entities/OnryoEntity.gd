extends CharacterBody3D

# ─── Onryo Entity v2 ──────────────────────────────────────────────────────────
# Vengeful spirit in tattered kimono. Does NOT flee from gaze.
# FREEZES when in flashlight beam + looked at ("don't move when watched").
# Teleports close during GhostSpawnDirector's forced flicker event (scare 3).

enum State { DORMANT, STALKING, CLOSE_STALK, CHARGING, REPELLED }

const STALK_SPEED    = 1.85
const CHARGE_SPEED   = 7.0
const CHARGE_DIST    = 2.5
const CLOSE_DIST     = 5.0
const LOOK_THRESHOLD = 0.86
const SANITY_SPAWN   = 35.0

@export var ghost_id: int         = 10
@export var spawn_on_sanity: bool = true

var state: State    = State.DORMANT
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _repel_t: float = 0.0
var _charge_dir: Vector3
var _player: CharacterBody3D = null
var _spawned: bool  = false
var _revealed: bool = false
var _sanity_connected: bool = false

@onready var anim:  AnimationPlayer     = $AnimationPlayer
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	visible = false
	set_physics_process(false)

func _process(_delta: float) -> void:
	# Defer sanity signal connection until sanity_ref is available
	if not _sanity_connected and spawn_on_sanity:
		if GameManager.sanity_ref:
			GameManager.sanity_ref.sanity_critical.connect(_on_sanity_critical)
			_sanity_connected = true
			set_process(false)

func _on_sanity_critical() -> void:
	if not _spawned:
		_spawned = true
		spawn_behind_player()

# ─── Spawn API ────────────────────────────────────────────────────────────────

func spawn_behind_player() -> void:
	_player = GameManager.player_ref
	if not _player:
		return
	var behind = _player.global_position - _player.get_look_direction() * 9.0
	behind.y   = _player.global_position.y
	global_position = behind
	_activate()

func teleport_close_silent() -> void:
	_player = GameManager.player_ref
	if not _player:
		return
	var angle  = _player.rotation.y + PI + randf_range(-0.4, 0.4)
	var offset = Vector3(sin(angle) * 3.8, 0.0, cos(angle) * 3.8)
	global_position   = _player.global_position + offset
	global_position.y = _player.global_position.y
	visible = true
	state   = State.CLOSE_STALK
	set_physics_process(true)

func _activate() -> void:
	state   = State.STALKING
	visible = true
	set_physics_process(true)
	AudioManager.play_ghost_sound("onryo_growl")
	if GameManager.sanity_ref:
		GameManager.sanity_ref.drain(14.0)
	_play_anim("walk")

# ─── Physics Loop ─────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	_player = GameManager.player_ref
	if not _player:
		return
	if not is_on_floor():
		velocity.y -= _gravity * delta

	match state:
		State.STALKING:    _handle_stalk(delta)
		State.CLOSE_STALK: _handle_close_stalk(delta)
		State.CHARGING:    _handle_charge(delta)
		State.REPELLED:    _handle_repelled(delta)

func _handle_stalk(_delta: float) -> void:
	var flashlight = _player.get_node_or_null("Camera3D/Flashlight")
	if flashlight and flashlight.check_beam_entry(ghost_id, global_position):
		_on_beam_reveal()

	if _is_in_beam_and_looked_at():
		velocity = Vector3.ZERO
		if GameManager.sanity_ref:
			GameManager.sanity_ref.set_ghost_visible(true)
		move_and_slide()
		return

	if GameManager.sanity_ref:
		GameManager.sanity_ref.set_ghost_visible(false)

	var dist = global_position.distance_to(_player.global_position)
	if dist <= CLOSE_DIST:
		state = State.CLOSE_STALK
		return

	var dir = (_player.global_position - global_position)
	dir.y = 0.0
	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity.x = dir.x * STALK_SPEED
		velocity.z = dir.z * STALK_SPEED
		look_at(Vector3(_player.global_position.x, global_position.y, _player.global_position.z), Vector3.UP)
	move_and_slide()

func _handle_close_stalk(delta: float) -> void:
	var flashlight = _player.get_node_or_null("Camera3D/Flashlight")
	if flashlight and flashlight.check_beam_entry(ghost_id, global_position):
		_on_beam_reveal()

	if _is_in_beam_and_looked_at():
		velocity = Vector3.ZERO
		if GameManager.sanity_ref:
			GameManager.sanity_ref.set_ghost_visible(true)
			GameManager.sanity_ref.drain(4.0 * delta)
		move_and_slide()
		return

	if GameManager.sanity_ref:
		GameManager.sanity_ref.set_ghost_visible(false)

	var dist = global_position.distance_to(_player.global_position)
	if dist <= CHARGE_DIST:
		_begin_charge()
		return
	elif dist > CLOSE_DIST * 2.5:
		state = State.STALKING

	var dir = (_player.global_position - global_position)
	dir.y = 0.0
	if dir.length() > 0.1:
		velocity.x = dir.normalized().x * STALK_SPEED * 0.6
		velocity.z = dir.normalized().z * STALK_SPEED * 0.6
	move_and_slide()

func _handle_charge(_delta: float) -> void:
	velocity.x = _charge_dir.x * CHARGE_SPEED
	velocity.z = _charge_dir.z * CHARGE_SPEED
	move_and_slide()
	var dist = global_position.distance_to(_player.global_position)
	if dist <= 0.85:
		if _player.has_method("die"):
			_player.die()
	elif dist > 15.0:
		state = State.STALKING

func _handle_repelled(delta: float) -> void:
	_repel_t += delta
	velocity = velocity.move_toward(Vector3.ZERO, delta * 4.0)
	move_and_slide()
	if _repel_t >= 10.0:
		state = State.STALKING

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _on_beam_reveal() -> void:
	if not _revealed:
		_revealed = true
		JumpscareSystem.trigger_flashlight_reveal("onryo", JumpscareSystem.Intensity.MAX)
		AudioManager.play_ghost_sound("onryo_growl")
		if GameManager.sanity_ref:
			GameManager.sanity_ref.drain(20.0)

func _is_in_beam_and_looked_at() -> bool:
	if not _player:
		return false
	var in_beam = _player.is_ghost_in_flashlight(global_position)
	var looked  = _player.get_look_direction().dot((global_position - _player.global_position).normalized()) > LOOK_THRESHOLD
	return in_beam and looked

func _begin_charge() -> void:
	state       = State.CHARGING
	_charge_dir = (_player.global_position - global_position).normalized()
	_play_anim("charge")
	JumpscareSystem.trigger(JumpscareSystem.Intensity.HARD)
	AudioManager.play_ghost_sound("onryo_growl")

func repel() -> void:
	state    = State.REPELLED
	_repel_t = 0.0
	var away = (global_position - _player.global_position).normalized()
	velocity = away * 6.0
	AudioManager.play_ghost_sound("onryo_growl")

func _play_anim(anim_name: String) -> void:
	if is_instance_valid(anim) and anim.has_animation(anim_name):
		anim.play(anim_name)
