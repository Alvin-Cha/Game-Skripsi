extends CharacterBody3D


const SPEED = 5.0
const DASH_VELOCITY = 5.0

var hp: int = 3
var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0


func _physics_process(delta: float) -> void:
	# Handle invulnerability timer
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if hp <= 0:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		return

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func take_damage(amount: int) -> void:
	if is_invulnerable or hp <= 0:
		return
		
	hp -= amount
	if hp < 0:
		hp = 0
		
	print("Player took damage! HP left: ", hp)
	
	if hp <= 0:
		print("Player died!")
		# Game over logic or scene reload can be added here
		
	is_invulnerable = true
	invulnerability_timer = 3.0
