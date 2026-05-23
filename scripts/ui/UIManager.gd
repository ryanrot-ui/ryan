extends CanvasLayer

# ─── HUD / UI Manager v2 ──────────────────────────────────────────────────────

@onready var sanity_bar:     ProgressBar    = $HUD/BarsContainer/SanityRow/SanityBar
@onready var battery_bar:    ProgressBar    = $HUD/BarsContainer/BatteryRow/BatteryBar
@onready var battery_icon:   Label          = $HUD/BarsContainer/BatteryRow/BatteryIcon
@onready var note_counter:   Label          = $HUD/NoteCounter
@onready var note_notif:     PanelContainer = $HUD/NoteNotification
@onready var note_notif_lbl: Label          = $HUD/NoteNotification/VBox/NoteName
@onready var note_reader:    PanelContainer = $HUD/NoteReader
@onready var note_title_lbl: Label          = $HUD/NoteReader/VBox/TitleLabel
@onready var note_body_lbl:  RichTextLabel  = $HUD/NoteReader/VBox/BodyText
@onready var close_hint:     Label          = $HUD/NoteReader/VBox/CloseHint
@onready var pause_menu:     Control        = $PauseMenu
@onready var vignette:       ColorRect      = $Vignette
@onready var flash_overlay:  ColorRect      = $FlashOverlay
@onready var static_overlay: ColorRect      = $StaticOverlay
@onready var halluc_overlay: ColorRect      = $HallucinationOverlay

const NOTE_JP = {
	0: "山田花子の手紙",
	1: "壊れた小物",
	2: "錆びた鍵",
	3: "最後の写真",
}

func _ready() -> void:
	GameManager.ui_ref = self
	add_to_group("hud")
	pause_menu.visible      = false
	note_notif.visible      = false
	note_reader.visible     = false
	flash_overlay.visible   = false
	static_overlay.visible  = false
	halluc_overlay.visible  = false

	_setup_overlay_materials()
	_connect_vignette()

	JumpscareSystem.jumpscare_fired.connect(_on_jumpscare_fired)
	GameManager.note_collected.connect(_on_note_collected)
	_refresh_note_counter()

func _process(_delta: float) -> void:
	if GameManager.sanity_ref:
		sanity_bar.value = GameManager.sanity_ref.sanity

	var flashlight = _get_flashlight()
	if flashlight:
		battery_bar.value = flashlight.battery
		if flashlight.battery < 25.0:
			var pulse = abs(sin(Time.get_ticks_msec() * 0.004))
			battery_icon.modulate = Color(1.0, lerpf(0.2, 0.9, pulse), lerpf(0.1, 0.2, pulse))
		else:
			battery_icon.modulate = Color(0.75, 0.72, 0.5)

# ─── Shader Material Setup ────────────────────────────────────────────────────

func _setup_overlay_materials() -> void:
	_try_assign_shader(vignette,        "res://shaders/sanity_vignette.gdshader")
	_try_assign_shader(static_overlay,  "res://shaders/static_overlay.gdshader")
	var rain := get_node_or_null("RainOverlay") as ColorRect
	if rain:
		_try_assign_shader(rain, "res://shaders/rain_overlay.gdshader")

func _try_assign_shader(node: ColorRect, shader_path: String) -> void:
	if node == null:
		return
	if node.material is ShaderMaterial:
		return
	if not ResourceLoader.exists(shader_path):
		return
	var mat := ShaderMaterial.new()
	mat.shader = load(shader_path)
	node.material = mat

func _connect_vignette() -> void:
	await get_tree().process_frame
	if not is_instance_valid(self):
		return
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var sanity = player.get_node_or_null("SanitySystem")
		if sanity:
			if vignette and vignette.material is ShaderMaterial:
				sanity.vignette_mat = vignette.material as ShaderMaterial
			sanity.overlay_node = halluc_overlay

# ─── Note Counter ─────────────────────────────────────────────────────────────

func _refresh_note_counter() -> void:
	var n = GameManager.collected_notes.size()
	note_counter.text = "形見  %d / %d" % [n, GameManager.notes_total]
	var t = float(n) / float(GameManager.notes_total)
	note_counter.add_theme_color_override("font_color",
		Color(lerpf(0.52, 0.78, t), lerpf(0.46, 0.58, t), lerpf(0.38, 0.25, t)))

func _on_note_collected(_id: int) -> void:
	_refresh_note_counter()

# ─── Note Notification ────────────────────────────────────────────────────────

func show_note_notification(note_id: int) -> void:
	note_notif_lbl.text = NOTE_JP.get(note_id, "形見")
	note_notif.visible = true
	var tween = create_tween()
	tween.tween_property(note_notif, "modulate:a", 1.0, 0.3)
	await get_tree().create_timer(3.0).timeout
	if not is_instance_valid(self):
		return
	tween = create_tween()
	tween.tween_property(note_notif, "modulate:a", 0.0, 0.5)
	await tween.finished
	if not is_instance_valid(self):
		return
	note_notif.visible = false
	note_notif.modulate.a = 1.0

# ─── Note Reader ──────────────────────────────────────────────────────────────

func show_note(data: Dictionary) -> void:
	note_title_lbl.text       = data.get("title_jp", "")
	note_body_lbl.bbcode_text = "[i]%s[/i]" % data.get("text_jp", "")
	note_reader.visible       = true
	close_hint.text           = "[E] 閉じる — Close"
	GameManager.state         = GameManager.GameState.CINEMATIC

	var t = 0.0
	while t < 7.0:
		t += get_process_delta_time()
		if Input.is_action_just_pressed("interact"):
			break
		await get_tree().process_frame
		if not is_instance_valid(self):
			return

	note_reader.visible = false
	GameManager.state   = GameManager.GameState.PLAYING

# ─── Jumpscare Effects ────────────────────────────────────────────────────────

func _on_jumpscare_fired(intensity: int) -> void:
	_do_flash(intensity)
	_do_static(intensity)

func _do_flash(intensity: int) -> void:
	const FLASH_ALPHAS = [0.35, 0.60, 0.82, 0.96]
	const FLASH_COLORS = [
		Color(1.0, 1.0,  1.0),
		Color(1.0, 0.95, 0.88),
		Color(1.0, 0.90, 0.82),
		Color(1.0, 0.88, 0.80),
	]
	const FLASH_DUR = [0.18, 0.30, 0.48, 0.65]

	flash_overlay.color      = FLASH_COLORS[intensity]
	flash_overlay.modulate.a = FLASH_ALPHAS[intensity]
	flash_overlay.visible    = true
	var tween = create_tween()
	tween.tween_property(flash_overlay, "modulate:a", 0.0, FLASH_DUR[intensity])
	await tween.finished
	if not is_instance_valid(self):
		return
	flash_overlay.visible    = false
	flash_overlay.modulate.a = 1.0

func _do_static(intensity: int) -> void:
	if intensity < 1:
		return
	const STATIC_DURS = [0.0, 0.05, 0.10, 0.18]
	static_overlay.visible = true
	await get_tree().create_timer(STATIC_DURS[intensity]).timeout
	if not is_instance_valid(self):
		return
	static_overlay.visible = false

# ─── Pause Menu ───────────────────────────────────────────────────────────────

func show_pause_menu() -> void:
	pause_menu.visible = true

func hide_pause_menu() -> void:
	pause_menu.visible = false

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _get_flashlight() -> Node:
	var player = get_tree().get_first_node_in_group("player")
	return player.get_node_or_null("Camera3D/Flashlight") if player else null
