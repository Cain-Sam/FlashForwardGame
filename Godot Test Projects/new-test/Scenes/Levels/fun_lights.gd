extends StaticBody3D

@onready var lightswitch: AnimationPlayer = $"../Lightswitch_animation"
@onready var back_lights_top: Node3D = $"../../../../Lights/StageLights/BackLightsTop"
@onready var back_lights_bottom: Node3D = $"../../../../Lights/StageLights/BackLightsBottom"

var on = true

func kicked (_direction, _intensity): 
	if lightswitch.is_playing():
		return 
	on = !on 
	if on:
		lightswitch.play_backwards("Lights_on") 
		for light in back_lights_bottom.get_children():
			if light.ON:
				light.ON = false
		for light in back_lights_top.get_children():
			if light.ON:
				light.ON = false
	else:
		lightswitch.play("Lights_on") 
		for light in back_lights_bottom.get_children():
			if !light.ON:
				light.ON = true
		for light in back_lights_top.get_children():
			if !light.ON:
				light.ON = true
