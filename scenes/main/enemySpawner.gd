extends Area3D

@export var enemy_scene: PackedScene
@export var max_spawns: int = 3
@export var spawn_zone: MeshInstance3D

var has_triggered := false

func _ready():
	collision_layer = 2
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if not body.is_in_group("player"):
		return
	if has_triggered:
		return
	has_triggered = true
	_spawn_enemies(body)

func _spawn_enemies(player: Node3D):
	if enemy_scene == null:
		push_warning("SpawnTrigger: no enemy_scene assigned!")
		return
	if spawn_zone == null:
		push_warning("SpawnTrigger: no spawn_zone assigned!")
		return

	# Read the AABB which accounts for position, scale and mesh size correctly
	var aabb = spawn_zone.get_aabb()
	var world_aabb = spawn_zone.global_transform * aabb

	var min_x = world_aabb.position.x
	var max_x = world_aabb.position.x + world_aabb.size.x
	var min_z = world_aabb.position.z
	var max_z = world_aabb.position.z + world_aabb.size.z
	var center_y = spawn_zone.global_position.y

	for i in range(max_spawns):
		var enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child(enemy)
		enemy.player = player
		enemy.global_position = Vector3(
			randf_range(min_x, max_x),
			center_y + 1.0,
			randf_range(min_z, max_z)
		)
