extends CharacterBody3D

# ─── Player Controller ────────────────────────────────────────────────────────

const WALK_SPEED    = 3.8
const SPRINT_SPEED  = 6.2
const MOUSE_SENS    = 0.0025
const BOB_FREQ      = 1.9
const BOB_AMP       = 0.045
const FOOTSTEP_WALK = 0.52
const FOOTSTEP_SPRINT = 0.33
const INTERACT_DIST = 2.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var cam_pitch: float = 0.0
var bob_timer: float = 0.0
var footstep_timer: float = 0.0
var is_sprinting: bool = false
var is_dead: bool = false
var look_direction: Vector3 = Vector3.FORWARD

@onready var camera:       Camera3D         = $Camera3D
@onready var flashlight:   Node             = $Camera3D/Flashlight
@onready var sanity:       Node             = $SanitySystem
@onready var interact_ray: RayCast3D        = $Camera3D/InteractRay
@onready var step_sound:   AudioStreamPlayer3D = $FootstepAudio

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.player_ref = self
	GameManager.sanity_ref = sanity

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

	is_sprinting = Input.is_action_pressed("sprint") and sanity.sanity > 15.0
	var speed = SPRINT_SPEED if is_sprinting else WALK_SPEED

	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()

	if dir.length() > 0.01:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		_tick_footstep(delta)
		_tick_bob(delta, speed)
		if is_sprinting:
			sanity.drain(0.8 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)
		bob_timer = lerpf(bob_timer, 0.0, delta * 5.0)

	move_and_slide()

	# Update look direction for ghost AI
	look_direction = -camera.global_transform.basis.z

	_apply_sanity_tilt(delta)

func _tick_footstep(delta: float) -> void:
	footstep_timer += delta
	var interval = FOOTSTEP_SPRINT if is_sprinting else FOOTSTEP_WALK
	if footstep_timer >= interval:
		footstep_timer = 0.0
		AudioManager.play_footstep()

func _tick_bob(delta: float, speed: float) -> void:
	bob_timer += delta * BOB_FREQ * (speed / WALK_SPEED)
	var bob_y = sin(bob_timer) * BOB_AMP
	var bob_x = cos(bob_timer * 0.5) * BOB_AMP * 0.4
	camera.position.y = lerpf(camera.position.y, bob_y, delta * 12.0)
	camera.position.x = lerpf(camera.position.x, bob_x, delta * 8.0)

func _apply_sanity_tilt(delta: float) -> void:
	var s = sanity.sanity
	var tilt = 0.0
	if s < 40.0:
		# Oscillating tilt increases as sanity drops
		var intensity = (40.0 - s) / 40.0
		tilt = sin(Time.get_ticks_msec() * 0.0007) * 0.06 * intensity
	camera.rotation.z = lerpf(camera.rotation.z, tilt, delta * 2.5)

func _try_interact() -> void:
	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		if target and target.has_method("interact"):
			target.interact(self)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	AudioManager.play_ghost_sound("yurei_shriek")
	GameManager.trigger_game_over()

func get_look_direction() -> Vector3:
	return look_direction
