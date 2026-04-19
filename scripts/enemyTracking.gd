extends CharacterBody3D

const SPEED = 2.0

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
