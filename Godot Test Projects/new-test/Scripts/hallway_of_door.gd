extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().has_group("bullet"):
		for bullet in get_tree().get_nodes_in_group("bullet"):
			if bullet is not StaticBody3D && !bullet.is_in_group("paint") && bullet.get_child(0).light_negative == false:
				bullet.get_child(0).light_negative = true
				bullet.get_child(0).layers = 1
