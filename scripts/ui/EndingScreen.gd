extends Control

# ─── Ending Screen ─────────────────────────────────────────────────────────────

const ENDINGS = {
	"bad": {
		"title":    "悪い結末",
		"subtitle": "Bad Ending",
		"body":     "あなたは形見を集めることができなかった。\n怨霊たちはこの森に安らぎを見つけられなかった。\nあなたの記憶もまた、この樹海に飲み込まれていく。\n\nYou could not collect the keepsakes.\nThe vengeful spirits found no peace.\nYour memory too is swallowed by the Sea of Trees.",
		"color":    Color(0.5, 0.1, 0.1),
	},
	"good": {
		"title":    "良い結末",
		"subtitle": "Good Ending",
		"body":     "あなたはいくつかの形見を持って森を出た。\n一部の霊魂は解放されたが、まだ残りがいる。\n完全な真実を知るためには、すべての形見が必要だ。\n\nYou escaped with some keepsakes.\nSome spirits found release — others remain.\nThe full truth requires all four belongings.",
		"color":    Color(0.2, 0.35, 0.5),
	},
	"true": {
		"title":    "真の結末",
		"subtitle": "True Ending — 解放",
		"body":     "すべての形見が集められた。\nあなたの正気が保たれたまま、霊魂たちに声を届けた。\n花子、そして他の霊魂たちは、ついに安らぎを得た。\n樹海の闇は晴れ、朝の光が差し込んでくる。\n\nAll belongings collected. Your mind held fast.\nYou gave voice to those forgotten.\nHanako and the others — at last, at peace.\nThe darkness lifts. Dawn reaches the Sea of Trees.",
		"color":    Color(0.4, 0.6, 0.3),
	},
}

@onready var title_lbl:    Label = $VBox/TitleLabel
@onready var subtitle_lbl: Label = $VBox/SubtitleLabel
@onready var body_lbl:     RichTextLabel = $VBox/BodyText
@onready var stats_lbl:    Label = $VBox/StatsLabel
@onready var retry_btn:    Button = $VBox/RetryButton
@onready var menu_btn:     Button = $VBox/MenuButton
@onready var bg:           ColorRect = $Background

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	modulate.a = 0.0
	var ending_key = _get_ending_from_signal()
	_display_ending(ending_key)
	retry_btn.pressed.connect(_on_retry)
	menu_btn.pressed.connect(_on_menu)
	# Fade in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.0)

func _get_ending_from_signal() -> String:
	# GameManager stores the ending result
	return GameManager.determine_ending()

func _display_ending(key: String) -> void:
	var data = ENDINGS.get(key, ENDINGS["bad"])
	title_lbl.text = data["title"]
	subtitle_lbl.text = data["subtitle"]
	body_lbl.bbcode_text = data["body"]
	bg.color = data["color"]

	var notes = GameManager.collected_notes.size()
	var sanity = GameManager.player_final_sanity
	stats_lbl.text = "形見: %d/4  |  精神力: %.0f%%  |  結末: %s" % [
		notes, sanity, data["subtitle"]
	]

func _on_retry() -> void:
	GameManager.start_game()

func _on_menu() -> void:
	GameManager.state = GameManager.GameState.MENU
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
