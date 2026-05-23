extends CharacterBody3D

# ─── Yurei Entity v2 ──────────────────────────────────────────────────────────
# Pale woman in white kimono, long wet black hair, crawls forward.
# LOOK-TO-BANISH: stare for LOOK_BANISH_TIME seconds to send away.

enum State { DORMANT, IDLE_DISTANT, REVEALED, CRAWLING, BANISHED, GONE }

const CRAWL_SPEED      = 1.5
const DETECT_RANGE     = 24.0
const KILL_RANGE       = 1.1
const LOOK_BANISH_TIME = 0.6
const LOOK_THRESHOLD   = 0.91
const REAPPEAR_DELAY   = 20.0

@export var ghost_id: int = 0

var state: State = State.DORMANT
var _look_t:    float = 0.0
var _gone_t:    float = 0.0
var _gravity:   float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _origin:    Vector3
var _player:    CharacterBody3D = null
var _revealed_once: bool = false

@onready var anim:  AnimationPlayer     = $AnimationPlayer
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	_origin = global_position
	visible = false
	set_physics_process(false)

# ─── Activation API ───────────────────────────────────────────────────────────

func activate() -> void:
	if state != State.DORMANT:
		return
	state   = State.IDLE_DISTANT
	visible = true
	set_physics_process(true)
	_play_anim("idle")
	AudioManager.play_ghost_sound("hair_drag")

func spawn_behind_player() -> void:
	if not GameManager.player_ref:
		return
	var p = GameManager.player_ref
	var behind = p.global_position - p.get_look_direction() * randf_range(0.8, 1.5)
	behind.y = p.global_position.y
	global_position = behind
	state   = State.IDLE_DISTANT
	visible = true
	set_physics_process(true)
	_play_anim("idle")
	AudioManager.play_ghost_sound("hair_drag")
	if GameManager.sanity_ref:
		GameManager.sanity_ref.drain(8.0)

func force_reveal_close() -> void:
	if not GameManager.player_ref:
		return
	var p    = GameManager.player_ref
	var close = p.global_position + p.get_look_direction() * 1.2
	close.y  = p.global_position.y
	global_position = close
	state   = State.REVEALED
	visible = true
	set_physics_process(true)
	_do_jumpscare(JumpscareSystem.Intensity.MAX)

# ─── Physics Loop ─────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	_player = GameManager.player_ref
	if not _player:
		return
	if not is_on_floor():
		velocity.y -= _gravity * delta

	match state:
		State.IDLE_DISTANT: _handle_idle(delta)
		State.REVEALED:     _handle_revealed(delta)
		State.CRAWLING:     _handle_crawl(delta)
		State.BANISHED:     _handle_banished(delta)
		State.GONE:         _handle_gone(delta)

func _handle_idle(_delta: float) -> void:
	var dist = global_position.distance_to(_player.global_position)
	if dist > DETECT_RANGE:
		_vanish()
		return

	var flashlight = _player.get_node_or_null("Camera3D/Flashlight")
	if flashlight and flashlight.check_beam_entry(ghost_id, global_position):
		_on_beam_reveal()
		return

	if dist < 6.0:
		state = State.CRAWLING
		_play_anim("crawl")

func _on_beam_reveal() -> void:
	state = State.REVEALED
	if not _revealed_once:
		_revealed_once = true
		_do_jumpscare(JumpscareSystem.Intensity.HARD)
	else:
		_do_jumpscare(JumpscareSystem.Intensity.MEDIUM)

func _handle_revealed(delta: float) -> void:
	var in_beam = _is_in_flashlight_beam()
	var looking = _is_looked_at()

	if looking:
		_look_t += delta
		if GameManager.sanity_ref:
			GameManager.sanity_ref.set_ghost_visible(true)
		if _look_t >= LOOK_BANISH_TIME:
			_banish()
			return
	else:
		_look_t = max(0.0, _look_t - delta * 2.0)
		if GameManager.sanity_ref:
			GameManager.sanity_ref.set_ghost_visible(false)

	if not in_beam:
		state = State.CRAWLING
		_play_anim("crawl")

	_check_kill()

func _handle_crawl(delta: float) -> void:
	var flashlight = _player.get_node_or_null("Camera3D/Flashlight")
	if flashlight and flashlight.check_beam_entry(ghost_id, global_position):
		_on_beam_reveal()
		return

	if _is_looked_at():
		_look_t += delta
		if GameManager.sanity_ref:
			GameManager.sanity_ref.set_ghost_visible(true)
		if _look_t >= LOOK_BANISH_TIME:
			_banish()
			return
	else:
		_look_t = max(0.0, _look_t - delta * 1.5)
		if GameManager.sanity_ref:
			GameManager.sanity_ref.set_ghost_visible(false)

	var dir = (_player.global_position - global_position)
	dir.y = 0.0
	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity.x = dir.x * CRAWL_SPEED
		velocity.z = dir.z * CRAWL_SPEED
		look_at(Vector3(_player.global_position.x, global_position.y, _player.global_position.z), Vector3.UP)
	move_and_slide()
	_check_kill()

func _handle_banished(delta: float) -> void:
	var away = (global_position - _player.global_position).normalized()
	velocity = velocity.move_toward(away * 3.0, delta * 5.0)
	move_and_slide()
	_look_t += delta
	if _look_t >= 1.5:
		_vanish()

func _handle_gone(delta: float) -> void:
	_gone_t += delta
	if _gone_t >= REAPPEAR_DELAY:
		_reset()

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _is_looked_at() -> bool:
	if not _player:
		return false
	return _player.get_look_direction().dot((global_position - _player.global_position).normalized()) > LOOK_THRESHOLD

func _is_in_flashlight_beam() -> bool:
	if not _player:
		return false
	return _player.is_ghost_in_flashlight(global_position)

func _check_kill() -> void:
	if global_position.distance_to(_player.global_position) <= KILL_RANGE:
		_kill()

func _do_jumpscare(intensity: int) -> void:
	JumpscareSystem.trigger_flashlight_reveal("yurei", intensity)
	AudioManager.play_ghost_sound("yurei_shriek")

func _banish() -> void:
	state   = State.BANISHED
	_look_t = 0.0
	if GameManager.sanity_ref:
		GameManager.sanity_ref.set_ghost_visible(false)
	_play_anim("flee")

func _vanish() -> void:
	state   = State.GONE
	visible = false
	_gone_t = 0.0
	set_physics_process(false)
	if GameManager.sanity_ref:
		GameManager.sanity_ref.set_ghost_visible(false)

func _reset() -> void:
	global_position = _origin
	state   = State.DORMANT
	visible = false
	_look_t = 0.0

func _kill() -> void:
	_do_jumpscare(JumpscareSystem.Intensity.MAX)
	AudioManager.play_ghost_sound("yurei_shriek")
	if _player and _player.has_method("die"):
		_player.die()

func _play_anim(anim_name: String) -> void:
	if is_instance_valid(anim) and anim.has_animation(anim_name):
		anim.play(anim_name)
