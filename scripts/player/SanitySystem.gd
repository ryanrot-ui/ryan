extends Node

# ─── Sanity System ────────────────────────────────────────────────────────────

signal sanity_updated(value: float)
signal sanity_critical

const MAX_SANITY       = 100.0
const PASSIVE_DRAIN    = 0.4    # per second baseline
const DARKNESS_DRAIN   = 1.2    # extra per second when flashlight is off + dark
const GHOST_SIGHT_DRAIN = 8.0   # per second when looking directly at a ghost
const REGEN_RATE       = 6.0    # per second at a shrine

var sanity: float = MAX_SANITY
var is_near_shrine: bool = false
var is_seeing_ghost: bool = false
var _whisper_timer: float = 0.0
var _hallucination_timer: float = 0.0
var _critical_emitted: bool = false

# HUD references (set by UIManager)
var vignette_mat: ShaderMaterial = null
var overlay_node: ColorRect = null

func _ready() -> void:
	GameManager.sanity_ref = self

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return

	_drain_sanity(delta)
	_update_visual_effects()
	_tick_whispers(delta)
	_tick_hallucinations(delta)

func _drain_sanity(delta: float) -> void:
	var drain = PASSIVE_DRAIN

	# Extra drain in darkness
	var flashlight_node = GameManager.player_ref.get_node_or_null("Camera3D/Flashlight")
	if flashlight_node and not flashlight_node.is_on:
		drain += DARKNESS_DRAIN

	# Ghost stare drain
	if is_seeing_ghost:
		drain += GHOST_SIGHT_DRAIN

	# Shrine regen
	if is_near_shrine:
		drain -= REGEN_RATE

	sanity = clamp(sanity - drain * delta, 0.0, MAX_SANITY)
	sanity_updated.emit(sanity)

	if sanity <= 0.0 and GameManager.player_ref:
		GameManager.player_ref.die()
	elif sanity <= 20.0 and not _critical_emitted:
		_critical_emitted = true
		sanity_critical.emit()

func drain(amount: float) -> void:
	sanity = max(0.0, sanity - amount)
	sanity_updated.emit(sanity)

func restore(amount: float) -> void:
	sanity = min(MAX_SANITY, sanity + amount)
	_critical_emitted = false
	sanity_updated.emit(sanity)

func set_ghost_visible(visible: bool) -> void:
	is_seeing_ghost = visible

func _update_visual_effects() -> void:
	if vignette_mat == null:
		return
	var t = 1.0 - (sanity / MAX_SANITY)
	# Vignette intensity
	vignette_mat.set_shader_parameter("vignette_strength", lerpf(0.0, 1.2, t))
	# Desaturation
	vignette_mat.set_shader_parameter("desaturate", lerpf(0.0, 0.85, t))
	# Chromatic aberration
	vignette_mat.set_shader_parameter("aberration", lerpf(0.0, 0.012, t))
	# Screen noise grain
	vignette_mat.set_shader_parameter("noise_strength", lerpf(0.0, 0.06, t))

func _tick_whispers(delta: float) -> void:
	if sanity > 60.0:
		return
	_whisper_timer += delta
	# Whispers become more frequent as sanity drops
	var interval = lerpf(25.0, 5.0, 1.0 - (sanity / 60.0))
	if _whisper_timer >= interval:
		_whisper_timer = 0.0
		AudioManager.play_whisper()

func _tick_hallucinations(delta: float) -> void:
	if sanity > 35.0:
		return
	_hallucination_timer += delta
	var interval = lerpf(20.0, 6.0, 1.0 - (sanity / 35.0))
	if _hallucination_timer >= interval:
		_hallucination_timer = 0.0
		_trigger_hallucination()

func _trigger_hallucination() -> void:
	# Flash a ghost silhouette briefly using a screen overlay
	if overlay_node == null:
		return
	overlay_node.visible = true
	await get_tree().create_timer(0.08).timeout
	overlay_node.visible = false
