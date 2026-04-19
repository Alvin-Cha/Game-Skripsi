extends Area3D

var speed: float = 10.0
var direction: Vector3 = Vector3.ZERO
var lifetime: float = 5.0
var is_player_bullet: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if not is_player_bullet and "Player" in body.name and body.has_method("take_damage"):
		body.take_damage(1)
		queue_free()
	elif is_player_bullet and body.has_method("die") and not "Player" in body.name:
		body.die()
		queue_free()
