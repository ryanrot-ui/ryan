extends Node

# ─── Ghost Spawn Director ─────────────────────────────────────────────────────
# Manages the 5 scripted jump scares across all three levels.

signal all_scares_complete

@export_group("Level Scare Config")
@export var scare_1_ghost_path: NodePath
@export var scare_1_delay:      float = 90.0
@export var scare_2_ghost_path: NodePath
@export var scare_2_note_id:    int   = -1
@export var scare_2_delay:      float = 150.0
@export var scare_3_onryo_path: NodePath
@export var scare_3_delay:      float = 60.0
@export var scare_4_hang_path:  NodePath
@export var scare_4_note_id:    int   = -1
@export var scare_5_yurei_path: NodePath
@export var scare_5_note_id:    int   = -1

var _triggered: Array[bool] = [false, false, false, false, false]
var _timer: float = 0.0
var _player: CharacterBody3D = null

func _ready() -> void:
	await get_tree().process_frame
	if not is_instance_valid(self):
		return
	_player = GameManager.player_ref
	GameManager.note_collected.connect(_on_note_collected)

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	_timer  += delta
	_player  = GameManager.player_ref

	if not _triggered[0] and scare_1_ghost_path != NodePath("") and _timer >= scare_1_delay:
		_trigger_scare_1()
	if not _triggered[1] and scare_2_ghost_path != NodePath("") and scare_2_note_id < 0 and _timer >= scare_2_delay:
		_trigger_scare_2()
	if not _triggered[2] and scare_3_onryo_path != NodePath("") and _timer >= scare_3_delay:
		_trigger_scare_3()

# ─── Scare 1 ──────────────────────────────────────────────────────────────────

func _trigger_scare_1() -> void:
	_triggered[0] = true
	var ghost = _get_node(scare_1_ghost_path)
	if not ghost or not ghost.has_method("activate"):
		return
	_place_at_beam_edge(ghost, 14.0, 18.0)
	ghost.activate()

func _place_at_beam_edge(ghost: Node3D, dist_min: float, dist_max: float) -> void:
	if not _player:
		return
	var look_angle    = _player.rotation.y
	var offset_angle  = look_angle + deg_to_rad(randf_range(16.0, 22.0) * (1.0 if randf() > 0.5 else -1.0))
	var dist          = randf_range(dist_min, dist_max)
	ghost.global_position = _player.global_position + Vector3(sin(offset_angle) * dist, 0.0, cos(offset_angle) * dist)

# ─── Scare 2 ──────────────────────────────────────────────────────────────────

func _trigger_scare_2() -> void:
	_triggered[1] = true
	var ghost = _get_node(scare_2_ghost_path)
	if not ghost or not ghost.has_method("spawn_behind_player"):
		return
	ghost.spawn_behind_player()

# ─── Scare 3 ──────────────────────────────────────────────────────────────────

func _trigger_scare_3() -> void:
	_triggered[2] = true
	var onryo = _get_node(scare_3_onryo_path)
	if not onryo:
		return
	_do_scare_3_sequence(onryo)

func _do_scare_3_sequence(onryo: Node) -> void:
	var flashlight = _get_flashlight()
	if flashlight and flashlight.has_method("force_flicker_event"):
		flashlight.force_flicker_event(0.4)

	await get_tree().create_timer(0.25).timeout
	if not is_instance_valid(self):
		return

	if is_instance_valid(onryo) and onryo.has_method("teleport_close_silent"):
		onryo.teleport_close_silent()

# ─── Scare 4 ──────────────────────────────────────────────────────────────────

func _trigger_scare_4() -> void:
	_triggered[3] = true
	var spirit = _get_node(scare_4_hang_path)
	if not spirit:
		return
	if "hang_height" in spirit:
		spirit.hang_height = 5.5
	if spirit.has_method("force_fast_drop"):
		spirit.force_fast_drop()
	elif spirit.has_method("activate"):
		spirit.activate()
	JumpscareSystem.trigger(JumpscareSystem.Intensity.HARD)
	AudioManager.play_ghost_sound("yurei_shriek")

# ─── Scare 5 ──────────────────────────────────────────────────────────────────

func _trigger_scare_5() -> void:
	_triggered[4] = true
	var ghost = _get_node(scare_5_yurei_path)
	if not ghost:
		return
	_do_scare_5_sequence(ghost)

func _do_scare_5_sequence(ghost: Node) -> void:
	var flashlight = _get_flashlight()
	if flashlight:
		flashlight.visible = false

	await get_tree().create_timer(0.55).timeout
	if not is_instance_valid(self):
		return

	if is_instance_valid(ghost) and ghost.has_method("force_reveal_close"):
		ghost.force_reveal_close()

	await get_tree().create_timer(0.08).timeout
	if not is_instance_valid(self):
		return

	if flashlight and is_instance_valid(flashlight) and flashlight.is_on and not flashlight._dead:
		flashlight.visible = true

# ─── Note Triggers ────────────────────────────────────────────────────────────

func _on_note_collected(note_id: int) -> void:
	if note_id == scare_2_note_id and not _triggered[1]:
		_trigger_scare_2()
	if note_id == scare_4_note_id and not _triggered[3]:
		_trigger_scare_4()
	if note_id == scare_5_note_id and not _triggered[4]:
		_trigger_scare_5()

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _get_node(path: NodePath) -> Node:
	if path == NodePath(""):
		return null
	return get_node_or_null(path)

func _get_flashlight() -> Node:
	if not _player:
		return null
	return _player.get_node_or_null("Camera3D/Flashlight")
