extends Node3D

# ─── Optimized Low-Poly Tree Spawner ─────────────────────────────────────────
# Places trees using a MultiMeshInstance3D for maximum draw-call efficiency.
# One draw call for ALL trees of each type — critical for Intel i3 performance.

@export var tree_mesh: Mesh = null
@export var count: int = 200
@export var area_size: Vector2 = Vector2(80.0, 80.0)
@export var min_scale: float = 0.7
@export var max_scale: float = 1.8
@export var avoid_center_radius: float = 6.0
@export var random_seed: int = 42

@onready var multi_mesh_instance: MultiMeshInstance3D = $MultiMeshInstance3D

func _ready() -> void:
	if not tree_mesh:
		_generate_placeholder_mesh()
	_spawn_trees()

func _spawn_trees() -> void:
	if not multi_mesh_instance:
		return

	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = count
	mm.mesh = tree_mesh

	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed
	var placed = 0

	for i in count * 3:
		if placed >= count:
			break
		var x = rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var z = rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5)
		if Vector2(x, z).length() < avoid_center_radius:
			continue

		var scale_v = rng.randf_range(min_scale, max_scale)
		var rot_y = rng.randf_range(0.0, TAU)
		var t = Transform3D()
		t = t.scaled(Vector3(scale_v, scale_v, scale_v))
		t = t.rotated(Vector3.UP, rot_y)
		t.origin = Vector3(x, 0.0, z)
		mm.set_instance_transform(placed, t)
		placed += 1

	# Fill unused slots
	for i in range(placed, count):
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO), Vector3.ZERO))

	multi_mesh_instance.multimesh = mm

func _generate_placeholder_mesh() -> void:
	# Simple crossed-planes tree (2 quads) as placeholder
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bark_color = Color(0.12, 0.09, 0.06)
	_add_plane(st, Vector3.ZERO, Vector3(0.3, 2.0, 0.0), bark_color)
	_add_plane(st, Vector3.ZERO, Vector3(0.0, 2.0, 0.3), bark_color)
	tree_mesh = st.commit()

func _add_plane(st: SurfaceTool, origin: Vector3, size: Vector3, color: Color) -> void:
	st.set_color(color)
	var hw = size.x * 0.5 if size.x > 0 else size.z * 0.5
	var h = size.y
	if size.x > 0:
		st.add_vertex(origin + Vector3(-hw, 0, 0))
		st.add_vertex(origin + Vector3(hw, 0, 0))
		st.add_vertex(origin + Vector3(hw, h, 0))
		st.add_vertex(origin + Vector3(-hw, 0, 0))
		st.add_vertex(origin + Vector3(hw, h, 0))
		st.add_vertex(origin + Vector3(-hw, h, 0))
	else:
		st.add_vertex(origin + Vector3(0, 0, -hw))
		st.add_vertex(origin + Vector3(0, 0, hw))
		st.add_vertex(origin + Vector3(0, h, hw))
		st.add_vertex(origin + Vector3(0, 0, -hw))
		st.add_vertex(origin + Vector3(0, h, hw))
		st.add_vertex(origin + Vector3(0, h, -hw))
