extends Camera3D
#region Initial Variables
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
@onready var barrel_raycast: RayCast3D = $barrel_raycast

var bullet = load("res://Scenes/bullet.tscn")
var bullet_instance

#Gun
var shotgun_in_use = true;
var lightMode = false;
var lightBulb
var playerLight

#endregion

#region Fun Variables for Fucking With
var held_bulb_light_multiplyer = 0.1
var placed_bulb_light_multiplyer = 7
var placed_light_energy = 4.5
var non_placable_lightbulb_transparency = 0.1
var placable_lightbulb_transparency = 0
var bullet_light_multiplyer = 7
var bullet_light_energy = 4.5
var sway_x_multiplyer = 0.00004
var sway_y_multiplyer = 0.00004
var INTENSITY = 8.0
#endregion

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_rig.position.x = lerp(fps_rig.position.x,0.0,delta*5)
	fps_rig.position.y = lerp(fps_rig.position.y,0.0,delta*5)
	if lightMode && is_instance_valid(lightBulb):
		playerHoldingBulb()
	
func sway(sway_amount):
	fps_rig.position.x -= sway_amount.x*sway_x_multiplyer
	fps_rig.position.y += sway_amount.y*sway_y_multiplyer

func _input(event):
	
	if(event.is_action_pressed("shoot")):
		if !animation_player.is_playing():
			fireGun()
			
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
			checkKickCollision()
			
	if(event.is_action_pressed("light")):
		if lightMode:
			putLightAway()
		else:
			equipLight()
			
	if(event.is_action_pressed("interact")) && lightMode && vision.is_colliding():
		placeLight()
		
	if(event.is_action_pressed("scrollup")):
		if ColorList.colorindex == ColorList.color_list.size() - 1:
			ColorList.colorindex = 0
		else:
			ColorList.colorindex += 1
			
	if(event.is_action_pressed("scrolldown")):
		if ColorList.colorindex == 0:
			ColorList.colorindex = ColorList.color_list.size() - 1
		else:
			ColorList.colorindex -= 1
			
func playerHoldingBulb():
	
	#Bulb can not be placed
	if !vision.is_colliding():
		playerLight.global_position = vision.to_global(vision.target_position)
		lightBulb.transparency = non_placable_lightbulb_transparency
		lightBulb.material.albedo_color = ColorList.color_list[ColorList.colorindex]
		lightBulb.material.emission = ColorList.color_list[ColorList.colorindex]
		
	#Bulb CAN be placed
	else:
		playerLight.global_position = vision.get_collision_point()
		lightBulb.transparency = placable_lightbulb_transparency
		lightBulb.material.albedo_color = ColorList.color_list[ColorList.colorindex]
		lightBulb.material.emission = ColorList.color_list[ColorList.colorindex]
		
func fireGun():
	animation_player.play("fire")
	shootsound.play()
	
	#Create Bullet
	bullet_instance = bullet.instantiate()
	var bullet_light = bullet_instance.get_child(0)
	var bullet_mesh = bullet_instance.get_child(1)
	
	#Bullet Possition
	bullet_instance.position = barrel_raycast.global_position
	bullet_instance.transform.basis = barrel_raycast.global_transform.basis
	
	#Bullet Light
	bullet_light.light_energy = bullet_light_energy
	bullet_light.light_color = ColorList.color_list[ColorList.colorindex]
	
	#Make Bullet Mesh Seperate From Other Bullet Meshes
	if bullet_mesh.material:
		bullet_mesh.material = bullet_mesh.material.duplicate()
	
	#Set Bullet Color Equal To Chosen Color
	bullet_mesh.material.albedo_color = ColorList.color_list[ColorList.colorindex]
	bullet_mesh.material.emission = ColorList.color_list[ColorList.colorindex]
	bullet_mesh.material.emission_energy_multiplier = bullet_light_multiplyer
	
	#Fire
	get_parent().add_child(bullet_instance)
	
	#Clean Up
	bullet_mesh = null
	bullet_light = null
	
func checkKickCollision():
	var collider = vision.get_collider()
	if collider.is_in_group("kickable"):
		kickKickable(collider)
	if collider.is_in_group("myhead"):
		kickMyHead()

func kickKickable(collider):
	var direction = -global_transform.basis.z
	var intensity = INTENSITY
	if collider.has_method("kicked"):
		collider.kicked(direction, intensity)
	
	
func kickMyHead():
	get_tree().call_group("global_kick_events", "trigger_kick_effect")
	
func putLightAway():
	lightMode = false
	playerLight.queue_free()
	playerLight = null 
	lightBulb = null
	
func equipLight():
	#Set Lightmode
	lightMode = true
	
	#Create Instance of Light
	playerLight = player_light.duplicate()
	get_tree().current_scene.add_child(playerLight)
	playerLight.visible = true
	
	#Create Variable for Light and Mesh
	var light = playerLight.get_child(0)
	lightBulb = playerLight.get_child(1)
	
	#Set Mesh and Light Settings for Unplaced Light
	if lightBulb.material:
		lightBulb.material = lightBulb.material.duplicate()
	light.light_energy = held_bulb_light_multiplyer
	
func placeLight():
	#Set Lightmode
	lightMode = false
	
	#Create Variable for Light and Mesh
	var light = playerLight.get_child(0)
	lightBulb = playerLight.get_child(1)
	
	#Set Position to Object We are Looking At
	playerLight.global_position = vision.get_collision_point()
	
	#Set Light Settings for Placed Light
	light.light_energy = placed_light_energy
	light.light_color = ColorList.color_list[ColorList.colorindex]
	
	#Set Mesh Settings for Placed Light
	lightBulb.material.albedo_color = ColorList.color_list[ColorList.colorindex]
	lightBulb.material.emission = ColorList.color_list[ColorList.colorindex]
	lightBulb.material.emission_energy_multiplier = placed_bulb_light_multiplyer
	
	#Clear Variables
	playerLight = null 
	lightBulb = null
