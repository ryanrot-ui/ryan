extends CanvasLayer

# ─── HUD / UI Manager ─────────────────────────────────────────────────────────

@onready var sanity_bar:     ProgressBar  = $HUD/SanityBar
@onready var battery_bar:    ProgressBar  = $HUD/BatteryBar
@onready var note_counter:   Label        = $HUD/NoteCounter
@onready var crosshair:      TextureRect  = $HUD/Crosshair
@onready var interact_hint:  Label        = $HUD/InteractHint
@onready var note_notif:     PanelContainer = $HUD/NoteNotification
@onready var note_notif_lbl: Label        = $HUD/NoteNotification/Label
@onready var note_reader:    PanelContainer = $HUD/NoteReader
@onready var note_reader_txt: RichTextLabel = $HUD/NoteReader/RichTextLabel
@onready var pause_menu:     Control      = $PauseMenu
@onready var sanity_overlay: ColorRect    = $SanityOverlay
@onready var vignette:       ColorRect    = $Vignette
@onready var flash_overlay:  ColorRect    = $FlashOverlay

const NOTE_NAMES = {
	0: "山田花子の手紙",
	1: "壊れた小物",
	2: "錆びた鍵",
	3: "最後の写真",
}

func _ready() -> void:
	GameManager.ui_ref = self
	add_to_group("hud")
	pause_menu.visible = false
	note_notif.visible = false
	note_reader.visible = false
	flash_overlay.visible = false

	# Wire up sanity shader to sanity system
	if vignette and vignette.material is ShaderMaterial:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var sanity = player.get_node_or_null("SanitySystem")
			if sanity:
				sanity.vignette_mat = vignette.material as ShaderMaterial
				sanity.overlay_node = sanity_overlay

	# Connect signals
	GameManager.note_collected.connect(_on_note_collected)
	_update_note_counter()

func _process(_delta: float) -> void:
	if GameManager.sanity_ref:
		sanity_bar.value = GameManager.sanity_ref.sanity
	var flashlight = _get_flashlight()
	if flashlight:
		battery_bar.value = flashlight.battery

func _get_flashlight() -> Node:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return player.get_node_or_null("Camera3D/Flashlight")
	return null

func show_pause_menu() -> void:
	pause_menu.visible = true

func hide_pause_menu() -> void:
	pause_menu.visible = false

func show_note_notification(note_id: int) -> void:
	var name_jp = NOTE_NAMES.get(note_id, "形見")
	note_notif_lbl.text = "拾得: " + name_jp
	note_notif.visible = true
	_update_note_counter()
	await get_tree().create_timer(3.5).timeout
	note_notif.visible = false

func show_note(data: Dictionary) -> void:
	var lang_key = "jp"
	note_reader_txt.bbcode_text = "[b]%s[/b]\n\n%s" % [
		data.get("title_" + lang_key, ""),
		data.get("text_" + lang_key, "")
	]
	note_reader.visible = true
	GameManager.state = GameManager.GameState.CINEMATIC
	await get_tree().create_timer(6.0).timeout
	note_reader.visible = false
	GameManager.state = GameManager.GameState.PLAYING

func do_jumpscare_flash() -> void:
	flash_overlay.modulate = Color(1.0, 1.0, 1.0, 0.9)
	flash_overlay.visible = true
	var tween = create_tween()
	tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.4)
	await tween.finished
	flash_overlay.visible = false

func _update_note_counter() -> void:
	var count = GameManager.collected_notes.size()
	note_counter.text = "形見: %d / %d" % [count, GameManager.notes_total]

func _on_note_collected(_id: int) -> void:
	_update_note_counter()
