extends Node3D
@onready var label_3d: Label3D = $player/Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/shotgun/Shotgun_Model/Body_lowpoly/Label3D
@onready var body_lowpoly: MeshInstance3D = $player/Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/fps_rig/shotgun/Shotgun_Model/Body_lowpoly



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3d.set_script(null)
	label_3d.text = "KICK"
	label_3d.modulate = Color(75,0,0)
	ColorList.infinite_ammo = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().has_group("bullet"):
		for bullet in get_tree().get_nodes_in_group("bullet"):
			if bullet is not StaticBody3D && !bullet.is_in_group("paint") && bullet.get_child(0).light_negative == false:
				bullet.get_child(0).light_negative = true
				bullet.get_child(0).layers = 1
