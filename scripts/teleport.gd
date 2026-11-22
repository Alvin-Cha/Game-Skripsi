extends Area3D

@export var target_destination: Node3D
@export var next_scene: PackedScene

var is_changing_scene: bool = false

func _ready() -> void:
	# Connect the body_entered signal to our function
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Check if the body that entered the area is the Player
	if body.name != "Player":
		return

	# Change to the next scene (e.g. Level 1 -> Level 2)
	if next_scene:
		if is_changing_scene:
			return
		is_changing_scene = true
		# Deferred so it is safe to call during a physics callback
		get_tree().call_deferred("change_scene_to_packed", next_scene)
		print("Changing scene to: ", next_scene.resource_path)
		return

	# Fallback: teleport the player to a target inside the current scene
	if target_destination:
		body.global_position = target_destination.global_position
		print("Player teleported to ", target_destination.name)
	else:
		print("Teleport failed: No next_scene or target_destination set!")
