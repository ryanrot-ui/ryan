extends Node

# ─── Global Game State ───────────────────────────────────────────────────────

signal note_collected(note_id: int)
signal sanity_changed(value: float)
signal flashlight_battery_changed(value: float)
signal game_over(ending_type: String)
signal level_transition_requested(level_path: String)

enum GameState { MENU, PLAYING, PAUSED, CINEMATIC, GAME_OVER }
enum Ending { NONE, BAD, GOOD, TRUE }

var state: GameState = GameState.MENU
var collected_notes: Array[int] = []
var notes_total: int = 4
var current_level: String = ""
var player_final_sanity: float = 100.0
var performance_mode: bool = false

# References updated each level load
var player_ref: CharacterBody3D = null
var sanity_ref: Node = null
var ui_ref: CanvasLayer = null

# ─── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_performance_settings()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and state == GameState.PLAYING:
		toggle_pause()

# ─── State Management ─────────────────────────────────────────────────────────

func start_game() -> void:
	collected_notes.clear()
	player_final_sanity = 100.0
	state = GameState.PLAYING
	load_level("res://scenes/levels/ForestEntrance.tscn")

func toggle_pause() -> void:
	if state == GameState.PLAYING:
		state = GameState.PAUSED
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if ui_ref:
			ui_ref.show_pause_menu()
	elif state == GameState.PAUSED:
		resume_game()

func resume_game() -> void:
	state = GameState.PLAYING
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if ui_ref:
		ui_ref.hide_pause_menu()

func load_level(path: String) -> void:
	current_level = path
	get_tree().paused = false
	get_tree().change_scene_to_file(path)

func collect_note(id: int) -> void:
	if id not in collected_notes:
		collected_notes.append(id)
		note_collected.emit(id)
		AudioManager.play_sfx("note_pickup")
		if ui_ref:
			ui_ref.show_note_notification(id)

func trigger_game_over() -> void:
	state = GameState.GAME_OVER
	if sanity_ref:
		player_final_sanity = sanity_ref.sanity
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var ending = determine_ending()
	game_over.emit(ending)
	await get_tree().create_timer(1.5).timeout
	load_level("res://scenes/main/EndingScreen.tscn")

func determine_ending() -> String:
	var note_count = collected_notes.size()
	if note_count == 4 and player_final_sanity > 50.0:
		return "true"
	elif note_count >= 2 and player_final_sanity > 20.0:
		return "good"
	else:
		return "bad"

func reach_exit() -> void:
	player_final_sanity = sanity_ref.sanity if sanity_ref else 50.0
	state = GameState.GAME_OVER
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var ending = determine_ending()
	game_over.emit(ending)
	load_level("res://scenes/main/EndingScreen.tscn")

# ─── Performance ─────────────────────────────────────────────────────────────

func set_performance_mode(enabled: bool) -> void:
	performance_mode = enabled
	_apply_performance_settings()

func _apply_performance_settings() -> void:
	if performance_mode:
		RenderingServer.global_shader_parameter_set("performance_mode", 1.0)
		ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", 0)
	else:
		RenderingServer.global_shader_parameter_set("performance_mode", 0.0)
