extends StaticBody3D

@onready var lightswitch: AnimationPlayer = $"../Lightswitch_animation"
@onready var spot_light: Node3D = $"../../../../Lights/StageLights/SpotLight"

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
		for light in spot_light.get_children():
			if !light.ON:
				light.ON = true
	else:
		lightswitch.play_backwards("Lights_on")
		for light in spot_light.get_children():
			if light.ON:
				light.ON = false
