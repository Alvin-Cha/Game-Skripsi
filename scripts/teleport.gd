extends Area3D

@export var target_destination: Node3D

func _ready() -> void:
	# Connect the body_entered signal to our function
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Check if the body that entered the area is the Player
	if body.name == "Player":
		if target_destination:
			# Teleport the player to the target destination's global position
			body.global_position = target_destination.global_position
			print("Player teleported to ", target_destination.name)
		else:
			print("Teleport failed: No target destination set!")
