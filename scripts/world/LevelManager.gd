extends Node

# ─── Level Manager ────────────────────────────────────────────────────────────
# Attached to each level scene root. Handles level-specific setup,
# area transitions, ambient audio, and ghost trigger zones.

@export var level_ambient_key: String = "forest_night"
@export var next_level_path: String = ""
@export var is_final_level: bool = false

@onready var spawn_point: Node3D = $SpawnPoint
@onready var fog: WorldEnvironment = $WorldEnvironment

func _ready() -> void:
	_setup_player()
	_setup_ui()
	_start_ambient()
	_apply_performance_mode()
	AudioManager.play_ambient(level_ambient_key)

func _setup_player() -> void:
	# Find player and place at spawn
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player and spawn_point:
		player.global_position = spawn_point.global_position
	if player:
		GameManager.player_ref = player
		GameManager.sanity_ref = player.get_node_or_null("SanitySystem")
	GameManager.state = GameManager.GameState.PLAYING

func _setup_ui() -> void:
	var ui = get_tree().get_first_node_in_group("hud")
	if ui:
		GameManager.ui_ref = ui

func _start_ambient() -> void:
	AudioManager.play_ambient(level_ambient_key)

func _apply_performance_mode() -> void:
	if not fog:
		return
	var env = fog.environment
	if not env:
		return
	if GameManager.performance_mode:
		env.fog_density = 0.04
		env.volumetric_fog_enabled = false
	else:
		env.fog_density = 0.02
		env.volumetric_fog_enabled = true
		env.volumetric_fog_density = 0.01

func transition_to_next() -> void:
	if is_final_level:
		GameManager.reach_exit()
		return
	if not next_level_path.is_empty():
		GameManager.load_level(next_level_path)

# Called by trigger area nodes placed at level exits
func _on_exit_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		transition_to_next()
