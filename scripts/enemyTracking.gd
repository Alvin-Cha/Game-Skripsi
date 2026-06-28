extends CharacterBody3D

var speed: float = 2.0
var hp: int = 1
const BULLET_SCENE = preload("res://scenes/enemy/bulletEnemy.tscn")
var shoot_timer: float = 0.0
var shoot_interval: float = 2.0

var enemy_type: int = 0

# In the Inspector, you must assign the Player node to this slot!
@export var player: Node3D

func _ready() -> void:
	enemy_type = randi() % 3
	if enemy_type == 0:
		speed = 1.0
		hp = 4
		apply_visual_tint(Color(0.2, 0.8, 0.4)) # Green/Teal for slow tanky enemy
	elif enemy_type == 1:
		speed = 2.0
		hp = 2
		apply_visual_tint(Color(0.2, 0.6, 1.0)) # Cyan/Blue for normal enemy
	else:
		speed = 4.0
		hp = 1
		apply_visual_tint(Color(1.0, 0.3, 0.3)) # Red/Orange for fast enemy

func apply_visual_tint(color: Color) -> void:
	if has_node("CharacterModel"):
		_apply_color_to_meshes($CharacterModel, color)

func _apply_color_to_meshes(node: Node, color: Color) -> void:
	if node is MeshInstance3D:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		node.material_override = mat
	for child in node.get_children():
		_apply_color_to_meshes(child, color)

func _physics_process(delta: float) -> void:
	# Add the gravity so the enemy falls to the floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Check if we have assigned a player
	if player:
		# Get the direction moving towards the player
		var direction = position.direction_to(player.position)
		
		# We only want to move horizontally across the floor, ignoring Y (up/down)
		direction.y = 0
		direction = direction.normalized()
		
		# Make the enemy look at the player
		if position.distance_squared_to(player.position) > 0.1:
			var look_target = Vector3(player.position.x, position.y, player.position.z)
			look_at(look_target, Vector3.UP)
		
		# Apply movement speed
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# Shooting logic
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			shoot_timer = shoot_interval
			shoot()
	else:
		# Stop moving if no player is found
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Execute the movement
	move_and_slide()
	
	# Check for collisions with the player to deal damage
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if (collider == player or "Player" in collider.name) and collider.has_method("take_damage"):
			collider.take_damage(1)

func shoot() -> void:
	if not player:
		return
		
	var aim_target = player.global_position + Vector3(0, 1.0, 0) # Aim at center of player
	var spawn_pos = global_position + Vector3(0, 1.0, 0) # Start bullet slightly elevated
	
	if enemy_type == 2:
		# Fast enemy: 3 bullet cluster at 45 degree spread
		var angles = [-30.0, 0.0, 30.0]
		for angle in angles:
			var bullet = BULLET_SCENE.instantiate()
			get_parent().add_child(bullet)
			bullet.position = spawn_pos
			
			var base_dir = spawn_pos.direction_to(aim_target).normalized()
			bullet.direction = base_dir.rotated(Vector3.UP, deg_to_rad(angle)).normalized()
	elif enemy_type == 0:
		# Slow enemy: shoot slow bullet but bigger
		var bullet = BULLET_SCENE.instantiate()
		get_parent().add_child(bullet)
		bullet.position = spawn_pos
		bullet.direction = spawn_pos.direction_to(aim_target).normalized()
		bullet.speed = 4.0 # Slower speed (default is 10.0)
		bullet.scale = Vector3(2.5, 2.5, 2.5) # Bigger bullet
	else:
		# Medium enemy: shoot standard single bullet
		var bullet = BULLET_SCENE.instantiate()
		get_parent().add_child(bullet)
		bullet.position = spawn_pos
		bullet.direction = spawn_pos.direction_to(aim_target).normalized()

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	var new_enemy = load("res://scenes/enemy/enemy.tscn").instantiate()
	
	var angle = randf() * PI * 2.0
	var radius = 8.0
	var random_pos = Vector3(cos(angle) * radius, position.y, sin(angle) * radius)
	var center = Vector3(0, 0, 0) 
	
	new_enemy.position = center + random_pos
	new_enemy.player = player
	
	get_parent().call_deferred("add_child", new_enemy)
	queue_free()
