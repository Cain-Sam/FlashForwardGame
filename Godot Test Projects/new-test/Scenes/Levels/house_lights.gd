extends StaticBody3D

@onready var lightswitch: AnimationPlayer = $"../Lightswitch_animation"
@onready var house_lights: Node3D = $"../../../../Lights/HouseLights"
@onready var work_lights: Node3D = $"../../../../Lights/WorkLights"
@onready var lobby_lights: Node3D = $"../../../../Lights/LobbyLights"


var on = false

func kicked (_direction, _intensity): 
	if lightswitch.is_playing():
		return 
	on = !on 
	if on:
		lightswitch.play_backwards("Lights_on") 
		for light in house_lights.get_children():
			if light.ON:
				light.ON = false
		for light in work_lights.get_children():
			if light.ON:
				light.ON = false
		for light in lobby_lights.get_children():
			if light.ON:
				light.ON = false
	else:
		lightswitch.play("Lights_on") 
		for light in house_lights.get_children():
			if !light.ON:
				light.ON = true
		for light in work_lights.get_children():
			if !light.ON:
				light.ON = true
		for light in lobby_lights.get_children():
			if !light.ON:
				light.ON = true
