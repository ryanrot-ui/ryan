extends StaticBody3D

# ─── Shinto Shrine ────────────────────────────────────────────────────────────
# Recharges flashlight battery and restores sanity.
# Only activates once per level visit. Repels nearby Onryo entities.

const SHRINE_RADIUS   = 5.0
const BATTERY_RESTORE = 80.0
const SANITY_RESTORE  = 25.0
const PROMPT_DIST     = 3.0

@export var shrine_id:    int  = 0
@export var already_used: bool = false

@onready var light:  OmniLight3D     = $OmniLight3D
@onready var prompt: Label3D         = $Prompt
@onready var anim:   AnimationPlayer = $AnimationPlayer
@onready var area:   Area3D          = $Area3D

var _player_in_range: bool = false

func _ready() -> void:
	if is_instance_valid(prompt):
		prompt.visible = false
	_update_light_state()
	if is_instance_valid(area):
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _update_light_state() -> void:
	if not is_instance_valid(light):
		return
	if already_used:
		light.light_energy = 0.3
		light.light_color  = Color(0.4, 0.4, 0.5)
	else:
		light.light_energy = 1.4
		light.light_color  = Color(0.9, 0.85, 0.6)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	if not already_used and is_instance_valid(prompt):
		prompt.visible = true
		prompt.text    = "[E] 祈る — Pray"
	_repel_nearby_onryo()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if is_instance_valid(prompt):
			prompt.visible = false

func interact(_player: CharacterBody3D) -> void:
	if already_used:
		if is_instance_valid(prompt):
			prompt.text = "この祠はすでに使われました"
		await get_tree().create_timer(2.0).timeout
		if not is_instance_valid(self):
			return
		if is_instance_valid(prompt):
			prompt.visible = false
		return

	already_used = true
	if is_instance_valid(prompt):
		prompt.visible = false
	_perform_charge()

func _perform_charge() -> void:
	if is_instance_valid(anim) and anim.has_animation("activate"):
		anim.play("activate")

	if GameManager.player_ref:
		var flashlight = GameManager.player_ref.get_node_or_null("Camera3D/Flashlight")
		if flashlight and flashlight.has_method("recharge"):
			flashlight.recharge(BATTERY_RESTORE)

	if GameManager.sanity_ref:
		GameManager.sanity_ref.restore(SANITY_RESTORE)
		GameManager.sanity_ref.is_near_shrine = false

	_update_light_state()
	AudioManager.play_sfx("shrine_charge")
	_repel_nearby_onryo()

func _repel_nearby_onryo() -> void:
	var onryos = get_tree().get_nodes_in_group("onryo")
	for o in onryos:
		if o.global_position.distance_to(global_position) < SHRINE_RADIUS * 2.0:
			if o.has_method("repel"):
				o.repel()

func _process(_delta: float) -> void:
	if not _player_in_range or already_used:
		return
	if GameManager.sanity_ref:
		GameManager.sanity_ref.is_near_shrine = true
