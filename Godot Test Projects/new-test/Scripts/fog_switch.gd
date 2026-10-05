extends StaticBody3D

@onready var lightswitch: AnimationPlayer = $"../Lightswitch_animation"

@onready var fog: AnimationPlayer = $"../../../Wall5/FogVolume/FogAnimation"


var playing := false

func kicked (_direction, _intensity): 
	if lightswitch.is_playing() or fog.is_playing():
		return 
	playing = !playing 
	if playing: 
		lightswitch.play("Lights_on")
		fog.play_backwards("fog_in")
		
		
	else: 
		lightswitch.play_backwards("Lights_on")
		fog.play("fog_in")
