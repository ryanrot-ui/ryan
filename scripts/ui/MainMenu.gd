extends Control

# ─── Main Menu ────────────────────────────────────────────────────────────────

@onready var start_btn:       Button = $VBoxContainer/StartButton
@onready var settings_btn:    Button = $VBoxContainer/SettingsButton
@onready var quit_btn:        Button = $VBoxContainer/QuitButton
@onready var settings_panel:  Control = $SettingsPanel
@onready var perf_toggle:     CheckButton = $SettingsPanel/VBox/PerfToggle
@onready var master_slider:   HSlider = $SettingsPanel/VBox/MasterSlider
@onready var sfx_slider:      HSlider = $SettingsPanel/VBox/SFXSlider
@onready var title_label:     Label = $TitleLabel
@onready var subtitle_label:  Label = $SubtitleLabel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.state = GameManager.GameState.MENU

	settings_panel.visible = false
	title_label.text = "樹海の闇"
	subtitle_label.text = "Jukai No Yami — Sea of Trees Darkness"

	start_btn.pressed.connect(_on_start)
	settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(_on_quit)
	perf_toggle.toggled.connect(_on_perf_toggled)
	master_slider.value_changed.connect(_on_master_volume)
	sfx_slider.value_changed.connect(_on_sfx_volume)

	# Load saved settings
	perf_toggle.button_pressed = GameManager.performance_mode
	master_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) + 20.0

	_animate_title()

func _animate_title() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	var tween = create_tween().set_parallel()
	tween.tween_property(title_label, "modulate:a", 1.0, 2.5)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 3.5)

func _on_start() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	GameManager.start_game()

func _on_settings() -> void:
	settings_panel.visible = !settings_panel.visible

func _on_quit() -> void:
	get_tree().quit()

func _on_perf_toggled(enabled: bool) -> void:
	GameManager.set_performance_mode(enabled)

func _on_master_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value - 20.0)

func _on_sfx_volume(value: float) -> void:
	var idx = AudioServer.get_bus_index("SFX")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, value - 20.0)
