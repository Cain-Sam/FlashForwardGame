extends StaticBody3D

@onready var lightswitch: AnimationPlayer = $"../Lightswitch_animation"
@onready var above_stage: Node3D = $"../../../../Lights/StageLights/AboveStage"
@onready var first_row: Node3D = $"../../../../Lights/StageLights/FirstRow"
@onready var back_row: Node3D = $"../../../../Lights/StageLights/BackRow"
@onready var on_stage: Node3D = $"../../../../Lights/StageLights/OnStage"

var on = true

func _ready() -> void:
	flipSwitch()

func kicked (_direction, _intensity):
	flipSwitch()

func flipSwitch():
	if lightswitch.is_playing():
		return 
	on = !on 
	if on:
		lightswitch.play("Lights_on")
		for light in above_stage.get_children():
			if !light.ON:
				light.ON = true
		for light in first_row.get_children():
			if !light.ON:
				light.ON = true
		for light in back_row.get_children():
			if !light.ON:
				light.ON = true
		for light in on_stage.get_children():
			if !light.ON:
				light.ON = true
				
	else:
		lightswitch.play_backwards("Lights_on")
		for light in above_stage.get_children():
			if light.ON:
				light.ON = false
		for light in first_row.get_children():
			if light.ON:
				light.ON = false
		for light in back_row.get_children():
			if light.ON:
				light.ON = false
		for light in on_stage.get_children():
			if light.ON:
				light.ON = false
