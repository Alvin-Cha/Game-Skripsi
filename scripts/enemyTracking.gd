extends CharacterBody3D

var speed: float = 2.0
var hp: int = 1
const BULLET_SCENE = preload("res://scenes/enemy/bulletEnemy.tscn")
var shoot_timer: float = 0.0
var shoot_interval: float = 2.0
@export var player: Node3D

func _ready() -> void:
	var type = randi() % 3
	if type == 0:
		speed = 1.0
		hp = 4
	elif type == 1:
		speed = 2.0
		hp = 2
	else:
		speed = 4.0
		hp = 1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player:
		var direction = position.direction_to(player.position)
		direction.y = 0
		direction = direction.normalized()

		if position.distance_squared_to(player.position) > 0.1:
			var look_target = Vector3(player.position.x, position.y, player.position.z)
			look_at(look_target, Vector3.UP)

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		shoot_timer -= delta
		if shoot_timer <= 0.0:
			shoot_timer = shoot_interval
			shoot()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if (collider == player or "Player" in collider.name) and collider.has_method("take_damage"):
			collider.take_damage(1)

func shoot() -> void:
	if not player:
		return
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	bullet.position = global_position + Vector3(0, 1.0, 0)
	var aim_target = player.global_position + Vector3(0, 1.0, 0)
	bullet.direction = bullet.position.direction_to(aim_target).normalized()

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	queue_free()
