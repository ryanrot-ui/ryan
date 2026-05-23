extends StaticBody3D

# ─── Collectible Note / Belonging ─────────────────────────────────────────────

const NOTE_DATA = {
	0: {
		"title_jp": "山田花子の手紙",
		"title_en": "Hanako Yamada's Letter",
		"text_jp":  "「もう帰れない。あなたに会いたい。この森が私を呼んでいる。」\n— 花子",
		"text_en":  "'I cannot return. I want to see you. This forest calls to me.'\n— Hanako",
		"yurei":    "Yurei_1",
	},
	1: {
		"title_jp": "壊れた小物",
		"title_en": "A Broken Keepsake",
		"text_jp":  "ガラスの破片。裏に書かれた文字: 「待っていて」",
		"text_en":  "Shards of glass. Scratched on the back: 'Wait for me'",
		"yurei":    "Yurei_2",
	},
	2: {
		"title_jp": "錆びた鍵",
		"title_en": "A Rusted Key",
		"text_jp":  "鍵は何も開かない。ただ、誰かの形見として、ここに残っている。",
		"text_en":  "The key opens nothing. It remains here as a memorial to someone.",
		"yurei":    "HangingSpirit_1",
	},
	3: {
		"title_jp": "最後の写真",
		"title_en": "The Final Photograph",
		"text_jp":  "家族の写真。顔に×印がついている。怨霊の仕業か。",
		"text_en":  "A family photo. Each face crossed out. The work of an Onryo.",
		"yurei":    "Onryo_1",
	},
}

@export var note_id: int = 0
@export var trigger_ghost_on_pickup: bool = true

@onready var mesh:   MeshInstance3D  = $MeshInstance3D
@onready var prompt: Label3D         = $Prompt
@onready var light:  OmniLight3D     = $OmniLight3D
@onready var anim:   AnimationPlayer = $AnimationPlayer
@onready var area:   Area3D          = $Area3D

var _collected: bool = false

func _ready() -> void:
	if is_instance_valid(prompt):
		prompt.visible = false
	if note_id in GameManager.collected_notes:
		_collected = true
		visible    = false
	if is_instance_valid(area):
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	if is_instance_valid(prompt):
		prompt.visible = true
		var data = NOTE_DATA.get(note_id, {})
		prompt.text = "[E] %s" % data.get("title_jp", "拾う")

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and is_instance_valid(prompt):
		prompt.visible = false

func interact(_player: CharacterBody3D) -> void:
	if _collected:
		return
	_collected = true
	GameManager.collect_note(note_id)
	if is_instance_valid(prompt):
		prompt.visible = false

	var data = NOTE_DATA.get(note_id, {})
	if GameManager.ui_ref and GameManager.ui_ref.has_method("show_note"):
		GameManager.ui_ref.show_note(data)

	if trigger_ghost_on_pickup:
		_spawn_linked_ghost()

	if is_instance_valid(anim) and anim.has_animation("pickup"):
		anim.play("pickup")
	await get_tree().create_timer(0.8).timeout
	if not is_instance_valid(self):
		return
	visible = false

func _spawn_linked_ghost() -> void:
	var data       = NOTE_DATA.get(note_id, {})
	var ghost_name = data.get("yurei", "")
	if ghost_name.is_empty():
		return
	var ghost = get_tree().get_root().find_child(ghost_name, true, false)
	if ghost and ghost.has_method("activate"):
		ghost.activate()
