extends CharacterBody3D

# ─── Player Controller v2 ─────────────────────────────────────────────────────

const WALK_SPEED    = 3.8
const SPRINT_SPEED  = 6.0
const MOUSE_SENS    = 0.0025
const BOB_FREQ      = 1.9
const BOB_AMP       = 0.045
const STEP_WALK     = 0.52
const STEP_SPRINT   = 0.33
const INTERACT_DIST = 2.5

var gravity: float  = ProjectSettings.get_setting("physics/3d/default_gravity")
var cam_pitch: float = 0.0
var bob_t: float     = 0.0
var step_t: float    = 0.0
var is_sprinting: bool = false
var is_dead: bool      = false

@onready var camera:    Camera3D         = $Camera3D
@onready var flashlight: Node            = $Camera3D/Flashlight
@onready var sanity:    Node             = $SanitySystem
@onready var ray:       RayCast3D        = $Camera3D/InteractRay

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.player_ref = self
	GameManager.sanity_ref = sanity
	add_to_group("player")

func _input(event: InputEvent) -> void:
	if is_dead:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		cam_pitch -= event.relative.y * MOUSE_SENS
		cam_pitch = clamp(cam_pitch, -1.4, 1.4)
		camera.rotation.x = cam_pitch
	if event.is_action_pressed("interact"):
		_try_interact()
	if event.is_action_pressed("flashlight_toggle"):
		flashlight.toggle()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta

	is_sprinting = Input.is_action_pressed("sprint") and sanity.sanity > 12.0
	var speed = SPRINT_SPEED if is_sprinting else WALK_SPEED
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir   = (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()

	if dir.length() > 0.01:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		_tick_footstep(delta, speed)
		_tick_bob(delta, speed)
		if is_sprinting:
			sanity.drain(0.7 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)
		bob_t = lerpf(bob_t, 0.0, delta * 6.0)

	move_and_slide()
	_apply_sanity_tilt(delta)

func _tick_footstep(delta: float, speed: float) -> void:
	step_t += delta
	var interval = STEP_SPRINT if is_sprinting else STEP_WALK
	if step_t >= interval:
		step_t = 0.0
		AudioManager.play_footstep()

func _tick_bob(delta: float, speed: float) -> void:
	bob_t += delta * BOB_FREQ * (speed / WALK_SPEED)
	camera.position.y = lerpf(camera.position.y, sin(bob_t) * BOB_AMP, delta * 12.0)
	camera.position.x = lerpf(camera.position.x, cos(bob_t * 0.5) * BOB_AMP * 0.4, delta * 8.0)

func _apply_sanity_tilt(delta: float) -> void:
	var s = sanity.sanity
	if s < 40.0:
		var intensity = (40.0 - s) / 40.0
		var tilt = sin(Time.get_ticks_msec() * 0.0007) * 0.06 * intensity
		camera.rotation.z = lerpf(camera.rotation.z, tilt, delta * 2.5)
	else:
		camera.rotation.z = lerpf(camera.rotation.z, 0.0, delta * 3.0)

func _try_interact() -> void:
	if ray.is_colliding():
		var target = ray.get_collider()
		if target and target.has_method("interact"):
			target.interact(self)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	JumpscareSystem.trigger(JumpscareSystem.Intensity.MAX)
	await get_tree().create_timer(2.0).timeout
	GameManager.trigger_game_over()

# ─── Helpers for Ghost AI ─────────────────────────────────────────────────────

func get_look_direction() -> Vector3:
	return -camera.global_transform.basis.z

func get_flashlight() -> Node:
	return flashlight

func is_ghost_in_flashlight(ghost_pos: Vector3) -> bool:
	if not flashlight.is_on or flashlight._dead:
		return false
	return flashlight.is_ghost_in_beam(ghost_pos)
