extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if(event.is_action_pressed("lightcheat")):
		var lights_node = get_node("Lights")
		var stage_lights_node = lights_node.get_node("StageLights")
		for node in stage_lights_node.get_children():
			for childnode in node.get_children():
				childnode.ON = true
				childnode.currentPower = childnode.maxPower
