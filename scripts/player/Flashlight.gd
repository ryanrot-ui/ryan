extends SpotLight3D

# ─── Flashlight with Battery ──────────────────────────────────────────────────

signal battery_changed(pct: float)
signal battery_empty
signal battery_restored

const MAX_BATTERY     = 100.0
const DRAIN_RATE      = 2.8    # per second while on
const FLICKER_THRESHOLD = 25.0

var battery: float = MAX_BATTERY
var is_on: bool = true
var _flicker_timer: float = 0.0
var _flicker_active: bool = false
var _base_energy: float = 2.2
var _dead: bool = false

func _ready() -> void:
	light_energy = _base_energy
	visible = is_on

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return

	if is_on and not _dead:
		battery -= DRAIN_RATE * delta
		battery = max(0.0, battery)
		battery_changed.emit(battery / MAX_BATTERY)

		if battery <= 0.0:
			_battery_dead()
		elif battery <= FLICKER_THRESHOLD:
			_tick_flicker(delta)

func toggle() -> void:
	if _dead:
		return
	is_on = !is_on
	visible = is_on
	if is_on:
		AudioManager.play_sfx("flashlight_on")
		light_energy = _base_energy
	else:
		AudioManager.play_sfx("flashlight_off")

func recharge(amount: float = MAX_BATTERY) -> void:
	battery = min(MAX_BATTERY, battery + amount)
	_dead = false
	is_on = true
	visible = true
	_flicker_active = false
	light_energy = _base_energy
	battery_changed.emit(battery / MAX_BATTERY)
	battery_restored.emit()
	AudioManager.play_sfx("shrine_charge")

func _battery_dead() -> void:
	_dead = true
	is_on = false
	visible = false
	battery_empty.emit()
	AudioManager.play_sfx("battery_low")

func _tick_flicker(delta: float) -> void:
	_flicker_timer += delta
	# Flicker speed increases as battery dies
	var speed = lerpf(0.05, 0.015, battery / FLICKER_THRESHOLD)
	if _flicker_timer >= speed:
		_flicker_timer = 0.0
		if randf() < 0.3:
			visible = false
			await get_tree().create_timer(randf_range(0.03, 0.12)).timeout
			visible = is_on and not _dead
		# Dim the light proportional to remaining battery
		light_energy = _base_energy * lerpf(0.4, 1.0, battery / FLICKER_THRESHOLD)
