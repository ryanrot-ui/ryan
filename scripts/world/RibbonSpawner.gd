extends Node3D

# ─── Hanging Ribbon / Tape Spawner ────────────────────────────────────────────
# Places white ribbon strips (warning tape / prayer ribbons) around trees.
# Uses a single MultiMesh for performance.

@export var ribbon_count: int = 40
@export var area_size: Vector2 = Vector2(60.0, 60.0)
@export var ribbon_height_min: float = 1.2
@export var ribbon_height_max: float = 2.8
@export var sway_speed: float = 0.4

@onready var multi_mesh_inst: MultiMeshInstance3D = $MultiMeshInstance3D

var _time: float = 0.0

func _ready() -> void:
	_build_ribbons()

func _build_ribbons() -> void:
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = ribbon_count
	mm.mesh = _make_ribbon_mesh()

	var rng = RandomNumberGenerator.new()
	rng.seed = 1337

	for i in ribbon_count:
		var x = rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var z = rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5)
		var y = rng.randf_range(ribbon_height_min, ribbon_height_max)
		var rot = rng.randf_range(0.0, TAU)
		var t = Transform3D()
		t = t.rotated(Vector3.UP, rot)
		t.origin = Vector3(x, y, z)
		mm.set_instance_transform(i, t)

	multi_mesh_inst.multimesh = mm

func _make_ribbon_mesh() -> Mesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Ribbon: thin quad, 0.05 wide × 0.8 tall, ghostly white
	var c = Color(0.92, 0.90, 0.88, 0.75)
	st.set_color(c)
	st.add_vertex(Vector3(-0.025, 0.0, 0.0))
	st.add_vertex(Vector3(0.025, 0.0, 0.0))
	st.add_vertex(Vector3(0.025, 0.8, 0.0))
	st.add_vertex(Vector3(-0.025, 0.0, 0.0))
	st.add_vertex(Vector3(0.025, 0.8, 0.0))
	st.add_vertex(Vector3(-0.025, 0.8, 0.0))
	return st.commit()

func _process(delta: float) -> void:
	# Gentle swaying via shader time — no per-instance transform updates needed
	_time += delta
