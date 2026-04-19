extends CharacterBody3D

const SPEED = 2.0
const BULLET_SCENE = preload("res://scenes/enemy/bulletEnemy.tscn")
var shoot_timer: float = 0.0
var shoot_interval: float = 2.0

# In the Inspector, you must assign the Player node to this slot!
@export var player: Node3D

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
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# Shooting logic
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			shoot_timer = shoot_interval
			shoot()
	else:
		# Stop moving if no player is found
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Execute the movement
	move_and_slide()
	
	# Check for collisions with the player to deal damage
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider == player and collider.has_method("take_damage"):
			collider.take_damage(1)

func shoot() -> void:
	if not player:
		return
		
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	
	# Start bullet slightly elevated
	bullet.position = global_position + Vector3(0, 1.0, 0)
	
	# Aim at player
	var aim_target = player.global_position + Vector3(0, 1.0, 0) # Aim at center of player
	bullet.direction = bullet.position.direction_to(aim_target).normalized()

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

