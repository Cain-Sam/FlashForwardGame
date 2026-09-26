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
@onready var kick_cast: RayCast3D = $"../../../../KickCast"
@onready var altFire: MeshInstance3D = $fps_rig/shotgun/Shotgun_Model/AltFire
@onready var rat_shot: AudioStreamPlayer3D = $rat_shot
@onready var scan: AudioStreamPlayer = $scan
@onready var bullet_preview: MeshInstance3D = $fps_rig/shotgun/BulletPreview
@onready var shotgun_model: Node3D = $fps_rig/shotgun/Shotgun_Model
@onready var fail: AudioStreamPlayer = $IlluFail
@onready var suck_cast: RayCast3D = $"../../../../SuckCast"


#Bullets
@onready var barrel_raycast: RayCast3D = $barrel_raycast

var bullet = load("res://Scenes/bullet.tscn")
var drawMaterial = load("res://Scenes/drawmaterial.tscn")
var bullet_instance
var scanSelected: bool = false
var infinite_ammo: bool = false
var colorStore
var scanCollisionMesh
var bulletmesh = null

#Gun
var shotgun_in_use = true;
var alt_fire = false;
var lightMode = false;
var lightBulb
var playerLight
var lightAmmo: int = 0
var hold_time = 0

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
	bullet_preview.rotate(Vector3.UP, 0.01)
	if lightMode && is_instance_valid(lightBulb):
		playerHoldingBulb()
	if Input.is_action_just_released("shoot"):
		hold_time = 0
	if Input.is_action_pressed("shoot"):
		if alt_fire && suck_cast.is_colliding():
			if is_instance_valid(suck_cast.get_collider()) && suck_cast.get_collider().is_in_group("light"):
				hold_time += delta
				if hold_time > 1:
					hold_time = 0
					var lightSuck: bool = suck_cast.get_collider().suckLight()
					if lightSuck:
						increaseAmmo()
					
	if Input.is_action_pressed("paint"):
		if !animation_player.is_playing():
			fireDraw()
		
	if vision.is_colliding() || scanSelected:
		if !scanSelected: 
			if vision.get_collider() != null:
				if vision.get_collider().is_in_group("scannable"):
					scanCollisionMesh = vision.get_collider().get_parent().get_child(0)
					var unique_material = scanCollisionMesh.material_override.duplicate()
					colorStore = unique_material.albedo_color
					scanCollisionMesh.material_override = unique_material
					scanCollisionMesh.material_override.albedo_color = Color(1,0,0)
					scanSelected = true
		elif !vision.is_colliding():
			scanCollisionMesh.material_override.albedo_color = colorStore
			scanSelected = false
			
func sway(sway_amount):
	fps_rig.position.x -= sway_amount.x*sway_x_multiplyer
	fps_rig.position.y += sway_amount.y*sway_y_multiplyer

func _input(event):
	
	if(event.is_action_pressed("interact")): 
		if lightMode && vision.is_colliding():
			placeLight()
		if scanSelected:
			bulletmesh = scanCollisionMesh
			bullet_preview.mesh = scanCollisionMesh.mesh
			scan.play()
	
	if(event.is_action_pressed("shoot")):
		if alt_fire:
			return
		elif lightAmmo < 1 && !infinite_ammo:
			fail.play()
		elif !animation_player.is_playing() && !alt_fire:
			animateShoot()
			fireGun()
			if lightAmmo > 0:
				lightAmmo -= 1
			
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
		if kick_cast.is_colliding():
			checkKickCollision()
			
	if(event.is_action_pressed("light")):
		if lightMode:
			putLightAway()
		else:
			equipLight()
		
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
	
	if(event.is_action_pressed("darknessdown")):
		if ColorList.darkenindex == 0:
			ColorList.darkenindex = ColorList.darken_list.size() - 1
		else:
			ColorList.darkenindex -= 1
			
	if(event.is_action_pressed("darknessup")):
		if ColorList.darkenindex == ColorList.darken_list.size() - 1:
			ColorList.darkenindex = 0
		else:
			ColorList.darkenindex += 1
	
	if(event.is_action_pressed("swap_mode")):
		if alt_fire:
			alt_fire = false
			altFire.visible = false
		else:
			alt_fire = true
			altFire.visible = true	
		
	if(event.is_action_pressed("infiniteAmmo")):
		if infinite_ammo:
			infinite_ammo = false;
		else:
			infinite_ammo = true;
			
	if(event.is_action_pressed("Hotkey1")):
		ColorList.colorindex = 0
			
	if(event.is_action_pressed("Hotkey2")):
		ColorList.colorindex = 4
		
	if(event.is_action_pressed("Hotkey3")):
		ColorList.colorindex = 8
		
	if(event.is_action_pressed("Hotkey4")):
		ColorList.colorindex = 16
		
	if(event.is_action_pressed("Hotkey5")):
		ColorList.colorindex = 32
		
	if(event.is_action_pressed("Hotkey6")):
		ColorList.colorindex = 36
			
func playerHoldingBulb():
	
	#Bulb can not be placed
	if !vision.is_colliding():
		playerLight.global_position = vision.to_global(vision.target_position)
		lightBulb.transparency = non_placable_lightbulb_transparency
		lightBulb.material.albedo_color = ColorList.get_color()
		lightBulb.material.emission = ColorList.get_color()
		
	#Bulb CAN be placed
	else:
		playerLight.global_position = vision.get_collision_point()
		lightBulb.transparency = placable_lightbulb_transparency
		lightBulb.material.albedo_color = ColorList.get_color()
		lightBulb.material.emission = ColorList.get_color()
		
func animateShoot():
	animation_player.play("fire")
	if bulletmesh != null:
		if bulletmesh.name == "Rat":
			rat_shot.play()
		else:
			shootsound.play()
	else:
		shootsound.play()
func fireGun():
	#Create Bullet
	bullet_instance = bullet.instantiate()
	var bullet_light = bullet_instance.find_child("OmniLight", true, false)
	var bullet_mesh = bullet_instance.find_child("MeshInstance3D", true, false)
	if bulletmesh != null:
		var bulletmeshCopy = bulletmesh.duplicate()
		var meshOverrideCopy = bullet_mesh.material_override.duplicate()
		bulletmeshCopy.material_override = meshOverrideCopy
		bullet_instance.get_child(1).queue_free()
		bullet_instance.add_child(bulletmeshCopy)
		
	
	#Bullet Possition
	bullet_instance.position = barrel_raycast.global_position
	bullet_instance.transform.basis = barrel_raycast.global_transform.basis
	
	#Bullet Light
	bullet_light.light_energy = bullet_light_energy
	bullet_light.light_color = ColorList.get_color()
	
	#Make Bullet Mesh Seperate From Other Bullet Meshes
	if bullet_mesh.material_override:
		bullet_mesh.material_override = bullet_mesh.material_override.duplicate()
		
	#Set Bullet Color Equal To Chosen Color
	bullet_mesh.material_override.albedo_color = ColorList.color_list[ColorList.colorindex]
	bullet_mesh.material_override.emission = ColorList.color_list[ColorList.colorindex]
	bullet_mesh.material_override.emission_energy_multiplier = bullet_light_multiplyer
	
	#Fire
	get_parent().add_child(bullet_instance)
	
	#Clean Up
	bullet_mesh = null
	bullet_light = null
	
func checkKickCollision():
	var collider = kick_cast.get_collider()
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
	light.light_color = ColorList.get_color()
	
	#Set Mesh Settings for Placed Light
	lightBulb.material.albedo_color = ColorList.get_color()
	lightBulb.material.emission = ColorList.get_color()
	lightBulb.material.emission_energy_multiplier = placed_bulb_light_multiplyer
	
	#Clear Variables
	playerLight = null 
	lightBulb = null
	
func fireDraw():
	#Create Bullet
	bullet_instance = drawMaterial.instantiate()
	var bullet_mesh = bullet_instance.get_child(0)
	
	#Bullet Possition
	bullet_instance.position = barrel_raycast.global_position
	bullet_instance.transform.basis = barrel_raycast.global_transform.basis
	
	#Make Bullet Mesh Seperate From Other Bullet Meshes
	if bullet_mesh.material_override:
		bullet_mesh.material_override = bullet_mesh.material_override.duplicate()
	
	#Set Bullet Color Equal To Chosen Color
	bullet_mesh.material_override.albedo_color = ColorList.get_color()
	bullet_mesh.material_override.emission = ColorList.get_color()
	bullet_mesh.material_override.emission_energy_multiplier = bullet_light_multiplyer
	
	#Fire
	get_parent().add_child(bullet_instance)
	
	#Clean Up
	bullet_mesh = null

func increaseAmmo():
	lightAmmo += 1
