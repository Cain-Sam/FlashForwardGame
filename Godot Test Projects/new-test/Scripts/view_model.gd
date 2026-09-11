extends Camera3D

@onready var fps_rig: Node3D = $fps_rig
@onready var animation_player: AnimationPlayer = $fps_rig/shotgun/AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $fps_rig/leg/left_leg/AnimationPlayer2
@onready var vision: RayCast3D = $"../../../../Vision"
@export var myhead: MeshInstance3D
@export var gpu_particles_3d: GPUParticles3D
@export var spot_light_3d: SpotLight3D
@export var lostcause: AudioStreamPlayer3D 
@onready var player_light: Node3D = $"../../../../../PlayerLight"
@onready var shootsound: AudioStreamPlayer3D = $shootsound

#Bullets
@onready var colorchange = $"res://Scripts/color_list.gd"
@onready var barrel_raycast: RayCast3D = $barrel_raycast

var bullet = load("res://Scenes/bullet.tscn")
var bullet_instance

#Gun
var shotgun_in_use = true;
var lightMode = false;
var lightBulb
var playerLight
var colorindex = 0;



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_rig.position.x = lerp(fps_rig.position.x,0.0,delta*5)
	fps_rig.position.y = lerp(fps_rig.position.y,0.0,delta*5)
	if lightMode && is_instance_valid(lightBulb):
		playerLight.look_at(global_position, Vector3.UP)
		if !vision.is_colliding():
			playerLight.global_position = vision.to_global(vision.target_position)
			lightBulb.transparency =  0.1
			lightBulb.material.albedo_color = ColorList.color_list[colorindex]
			lightBulb.material.emission = ColorList.color_list[colorindex]
		else:
			playerLight.global_position = vision.get_collision_point()
			lightBulb.transparency = 0
			lightBulb.material.albedo_color = ColorList.color_list[colorindex]
			lightBulb.material.emission = ColorList.color_list[colorindex]
	
func sway(sway_amount):
	fps_rig.position.x -= sway_amount.x*0.00004
	fps_rig.position.y += sway_amount.y*0.00004

func _input(event):
	if(event.is_action_pressed("shoot")):
		if !animation_player.is_playing():
			animation_player.play("fire")
			shootsound.play()
			bullet_instance = bullet.instantiate()
			bullet_instance.position = barrel_raycast.global_position
			bullet_instance.transform.basis = barrel_raycast.global_transform.basis
			get_parent().add_child(bullet_instance)
			
	if(event.is_action_pressed("reload")):
		animation_player.play("reload")
	if(event.is_action_pressed("use")):
		shotgun_in_use = !shotgun_in_use
		if(shotgun_in_use):
			animation_player.play("put_away")
		else:
			animation_player.play("pull_up")
	if(event.is_action_pressed("kick")):
		animation_player_2.play("kick")
		if vision.is_colliding():
			var collider = vision.get_collider()
			if collider.is_in_group("kickable"):
				collider.queue_free()
			if collider.is_in_group("myhead"):
				get_tree().call_group("global_kick_events", "trigger_kick_effect")
	if(event.is_action_pressed("light")):
		if lightMode:
			lightMode = false
			playerLight.queue_free()
			playerLight = null 
			lightBulb = null
		else:
			lightMode = true
			playerLight = player_light.duplicate()
			get_tree().current_scene.add_child(playerLight)
			playerLight.visible = true
			lightBulb = playerLight.get_child(1)
			if lightBulb.material:
				lightBulb.material = lightBulb.material.duplicate()
			playerLight.get_child(0).light_energy = 0.1
	if(event.is_action_pressed("interact")) && lightMode && vision.is_colliding():
		lightMode = false
		playerLight.global_position = vision.get_collision_point()
		playerLight.get_child(0).light_energy = 4.5
		playerLight.get_child(0).light_color = ColorList.color_list[colorindex]
		lightBulb.material.albedo_color = ColorList.color_list[colorindex]
		lightBulb.material.emission = ColorList.color_list[colorindex]
		lightBulb.material.emission_energy_multiplier = 7
		playerLight = null 
		lightBulb = null
	if(event.is_action_pressed("scrollup")) && lightMode:
		if colorindex == ColorList.color_list.size() - 1:
			colorindex = 0
		else:
			colorindex += 1
	if(event.is_action_pressed("scrolldown")) && lightMode:
		if colorindex == 0:
			colorindex = ColorList.color_list.size() - 1
		else:
			colorindex -= 1
