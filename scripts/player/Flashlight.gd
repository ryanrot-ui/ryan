extends SpotLight3D

# ─── Flashlight v2 — The Core Experience Tool ────────────────────────────────
# Battery drains faster in open clearings.
# Flicker intensity scales with sanity loss.
# Exposes beam-intersection check for ghost AI.

signal battery_changed(pct: float)
signal battery_empty
signal battery_restored
signal flashlight_toggled(on: bool)

const MAX_BATTERY         = 100.0
const DRAIN_BASE          = 2.2
const DRAIN_OPEN_BONUS    = 1.6
const SANITY_FLICKER_MULT = 2.8
const FORCED_DARK_DUR     = 0.35

var battery: float       = MAX_BATTERY
var is_on: bool          = true
var is_in_clearing: bool = false
var _dead: bool          = false
var _base_energy: float  = 2.5
var _flicker_t: float    = 0.0
var _flicker_interval: float  = 0.0
var _forced_flicker_active: bool = false
var _was_in_beam: Dictionary = {}

func _ready() -> void:
	light_energy = _base_energy
	visible      = is_on
	_new_flicker_interval()

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	if is_on and not _dead:
		_drain(delta)
		_tick_flicker(delta)

# ─── Battery ──────────────────────────────────────────────────────────────────

func _drain(delta: float) -> void:
	var rate = DRAIN_BASE
	if is_in_clearing:
		rate += DRAIN_OPEN_BONUS
	battery -= rate * delta
	battery  = max(0.0, battery)
	battery_changed.emit(battery / MAX_BATTERY)
	if battery <= 0.0:
		_die()

func toggle() -> void:
	if _dead:
		return
	is_on   = !is_on
	visible = is_on
	flashlight_toggled.emit(is_on)
	if is_on:
		AudioManager.play_sfx("flashlight_on")
		light_energy = _base_energy
	else:
		AudioManager.play_sfx("flashlight_off")

func recharge(amount: float = MAX_BATTERY) -> void:
	battery = min(MAX_BATTERY, battery + amount)
	_dead   = false
	is_on   = true
	visible = true
	_forced_flicker_active = false
	light_energy = _base_energy
	battery_changed.emit(battery / MAX_BATTERY)
	battery_restored.emit()
	AudioManager.play_sfx("shrine_charge")

func _die() -> void:
	_dead   = true
	is_on   = false
	visible = false
	battery_empty.emit()
	AudioManager.play_sfx("battery_low")

# ─── Flicker System ───────────────────────────────────────────────────────────

func _tick_flicker(delta: float) -> void:
	_flicker_t += delta
	if _flicker_t < _flicker_interval:
		return
	_flicker_t = 0.0
	_new_flicker_interval()

	var bat_factor    = 1.0 - clamp(battery / MAX_BATTERY, 0.0, 1.0)
	var sanity_factor = 0.0
	if GameManager.sanity_ref:
		sanity_factor = 1.0 - clamp(GameManager.sanity_ref.sanity / 100.0, 0.0, 1.0)

	var flicker_chance = bat_factor * 0.55 + sanity_factor * 0.45 * SANITY_FLICKER_MULT
	flicker_chance = clamp(flicker_chance, 0.0, 0.9)

	if randf() < flicker_chance:
		_do_flicker()

func _new_flicker_interval() -> void:
	var bat_factor = 1.0 - clamp(battery / MAX_BATTERY, 0.0, 1.0)
	var sanity_factor = 0.0
	if GameManager.sanity_ref:
		sanity_factor = 1.0 - clamp(GameManager.sanity_ref.sanity / 100.0, 0.0, 1.0)
	var combined = maxf(bat_factor, sanity_factor)
	_flicker_interval = lerpf(1.8, 0.08, combined)

func _do_flicker() -> void:
	var dark_dur = randf_range(0.04, 0.18)
	var prev_vis = visible
	visible      = false
	light_energy = 0.0
	await get_tree().create_timer(dark_dur).timeout
	if not is_instance_valid(self):
		return
	if is_on and not _dead and not _forced_flicker_active:
		visible      = prev_vis
		light_energy = _base_energy * lerpf(0.5, 1.0, battery / MAX_BATTERY)

func force_flicker_event(dark_duration: float = FORCED_DARK_DUR) -> void:
	if _dead:
		return
	_forced_flicker_active = true
	for i in 3:
		visible = false
		await get_tree().create_timer(0.04).timeout
		if not is_instance_valid(self):
			return
		visible = true
		await get_tree().create_timer(0.06).timeout
		if not is_instance_valid(self):
			return
	visible = false
	await get_tree().create_timer(dark_duration).timeout
	if not is_instance_valid(self):
		return
	_forced_flicker_active = false
	if is_on and not _dead:
		visible      = true
		light_energy = _base_energy * lerpf(0.5, 1.0, battery / MAX_BATTERY)

# ─── Ghost Beam Detection ─────────────────────────────────────────────────────

func is_ghost_in_beam(ghost_global_pos: Vector3) -> bool:
	if not is_on or _dead:
		return false
	var to_ghost = ghost_global_pos - global_position
	var dist     = to_ghost.length()
	if dist > spot_range:
		return false
	var dir = -global_transform.basis.z
	var dot = dir.dot(to_ghost.normalized())
	return dot > cos(deg_to_rad(spot_angle))

func check_beam_entry(gid: int, ghost_global_pos: Vector3) -> bool:
	var in_beam = is_ghost_in_beam(ghost_global_pos)
	var was_in  = _was_in_beam.get(gid, false)
	_was_in_beam[gid] = in_beam
	return in_beam and not was_in

# ─── Area Multiplier ──────────────────────────────────────────────────────────

func set_clearing(in_clearing: bool) -> void:
	is_in_clearing = in_clearing
