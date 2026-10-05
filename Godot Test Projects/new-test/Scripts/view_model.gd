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
@onready var player: CharacterBody3D = $"../../../../.."

#Bullets
@onready var barrel_raycast: RayCast3D = $barrel_raycast

var bullet = load("res://Scenes/Bullets/bullet.tscn")
var drawMaterial = load("res://Scenes/Bullets/drawmaterial.tscn")
var bullet_instance
var scanSelected: bool = false
var colorStore
var scanCollisionMesh
var bulletmesh = null

#Gun
var shotgun_in_use = true;
var alt_fire = false;
var lightMode = false;
var lightBulb
var lightSource
var playerLight
var hold_time = 0

#endregion

#region Fun Variables for Fucking With
var held_bulb_light_multiplyer = 0.3
var non_placable_lightbulb_transparency = 0
var bullet_light_multiplyer = 7
var paint_light_multiplyer = 0.02
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
	if is_instance_valid(playerLight):
		playerLight.rotate(Vector3.UP, 0.01)
	
	# This is the feature where a player can place a light that we don't use
	if lightMode && is_instance_valid(lightBulb):
		playerHoldingBulb()
	
	# Sucking Functionality
	if Input.is_action_just_released("shoot"):
		hold_time = 0
	if Input.is_action_pressed("shoot"):
		# If we are in suck mode and pointed at a light
		if alt_fire && suck_cast.is_colliding():
			if is_instance_valid(suck_cast.get_collider()):
				hold_time += delta
				for child in suck_cast.get_collider().get_children():
					if child.is_in_group("bullet") && !child.is_in_group("paint"):
						suckBullet(child)

			# This is formatted weird to make sure we check if we are still colliding each frame. It stops crashes.
			if is_instance_valid(suck_cast.get_collider()) && suck_cast.get_collider().is_in_group("light"):
				hold_time += delta
				suckLight()
					
	if Input.is_action_pressed("paint"):
		if !animation_player.is_playing():
			fireDraw()
		
	if vision.is_colliding() || scanSelected:
		if !scanSelected: 
			if vision.get_collider() != null:
				if vision.get_collider().is_in_group("scannable") && !lightMode:
					showScannableObjectIsSelectable()
		
		# Change scannable object color back when not looking at it
		elif !vision.is_colliding():
			if colorStore == null:
				scanCollisionMesh.material_override = null
			else:	
				scanCollisionMesh.material_override.albedo_color = colorStore
			scanSelected = false
			
func sway(sway_amount):
	fps_rig.position.x -= sway_amount.x*sway_x_multiplyer
	fps_rig.position.y += sway_amount.y*sway_y_multiplyer

func _input(event):
	
	if(event.is_action_pressed("interact")): 
		if scanSelected:
			bulletmesh = scanCollisionMesh
			bullet_preview.mesh = scanCollisionMesh.mesh
			scan.play()
	
	if(event.is_action_pressed("shoot")):
		if alt_fire:
			return
		elif GlobalVariables.lightAmmo < 1 && !GlobalVariables.infinite_ammo:
			fail.play()
		elif !animation_player.is_playing() && !alt_fire:
			animateShoot()
			fireGun()
			if GlobalVariables.lightAmmo > 0:
				GlobalVariables.lightAmmo -= 1
			
	if(event.is_action_pressed("reload")):
		animation_player.play("reload")
		
	if(event.is_action_pressed("use")):
		if shotgun_in_use:
			shotgun_in_use = !shotgun_in_use
			animation_player.play("put_away")
		elif !shotgun_in_use && !lightMode:
			shotgun_in_use = !shotgun_in_use
			animation_player.play("pull_up")
			
	if(event.is_action_pressed("kick")):
		animation_player_2.play("kick")
		if kick_cast.is_colliding():
			checkKickCollision()
			
	if(event.is_action_pressed("light")):
		if lightMode:
			putLightAway()
			if !shotgun_in_use:
				shotgun_in_use = true
				animation_player.play("pull_up")
		else:
			if shotgun_in_use:
				shotgun_in_use = false
				animation_player.play("put_away")
				await animation_player.animation_finished
			equipLight()
		
	if(event.is_action_pressed("scrollup")):
		GlobalVariables.white = false
		if GlobalVariables.colorindex == GlobalVariables.color_list.size() - 1:
			GlobalVariables.colorindex = 0
		else:
			GlobalVariables.colorindex += 1
			
	if(event.is_action_pressed("scrolldown")):
		GlobalVariables.white = false
		if GlobalVariables.colorindex == 0:
			GlobalVariables.colorindex = GlobalVariables.color_list.size() - 1
		else:
			GlobalVariables.colorindex -= 1
	
	if(event.is_action_pressed("darknessdown")):
		if GlobalVariables.darkenindex == 0:
			GlobalVariables.darkenindex = GlobalVariables.darken_list.size() - 1
		else:
			GlobalVariables.darkenindex -= 1
			
	if(event.is_action_pressed("darknessup")):
		if GlobalVariables.darkenindex == GlobalVariables.darken_list.size() - 1:
			GlobalVariables.darkenindex = 0
		else:
			GlobalVariables.darkenindex += 1
	
	if(event.is_action_pressed("swap_mode")):
		if alt_fire:
			alt_fire = false
			altFire.visible = false
		else:
			alt_fire = true
			altFire.visible = true	
		
	if(event.is_action_pressed("infiniteAmmo")):
		if GlobalVariables.infinite_ammo:
			GlobalVariables.infinite_ammo = false;
		else:
			GlobalVariables.infinite_ammo = true;
			
	if(event.is_action_pressed("Hotkey1")):
		GlobalVariables.white = true
			
	if(event.is_action_pressed("Hotkey2")):
		GlobalVariables.white = false
		GlobalVariables.colorindex = 0
		
	if(event.is_action_pressed("Hotkey3")):
		GlobalVariables.white = false
		GlobalVariables.colorindex = 8
		
	if(event.is_action_pressed("Hotkey4")):
		GlobalVariables.white = false
		GlobalVariables.colorindex = 16
		
	if(event.is_action_pressed("Hotkey5")):
		GlobalVariables.white = false
		GlobalVariables.colorindex = 24
		
	if(event.is_action_pressed("Hotkey6")):
		GlobalVariables.white = false
		GlobalVariables.colorindex = 32
			
func playerHoldingBulb():
	playerLight.global_position = vision.to_global(vision.target_position)
	lightBulb.transparency = non_placable_lightbulb_transparency
	lightBulb.material_override.albedo_color = GlobalVariables.get_color()
	lightBulb.material_override.emission = GlobalVariables.get_color()
	lightSource.light_color = GlobalVariables.get_color()
	
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
	var bullet_body = bullet_instance.find_child("StaticBody3D", true, false)
	bullet_body.add_collision_exception_with(player)
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
	bullet_light.light_color = GlobalVariables.get_color()
	
	#Make Bullet Mesh Seperate From Other Bullet Meshes
	if bullet_mesh.material_override:
		bullet_mesh.material_override = bullet_mesh.material_override.duplicate()
		
	#Set Bullet Color Equal To Chosen Color
	bullet_mesh.material_override.albedo_color = GlobalVariables.color_list[GlobalVariables.colorindex]
	bullet_mesh.material_override.emission = GlobalVariables.color_list[GlobalVariables.colorindex]
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
	lightSource = playerLight.get_child(0)
	lightBulb = playerLight.get_child(1)
	
	#Set Mesh and Light Settings for Unplaced Light
	lightSource.light_energy = held_bulb_light_multiplyer
	lightSource.light_color = GlobalVariables.get_color()
	if is_instance_valid(scanCollisionMesh):
		if bulletmesh != null:
			var bulletmeshCopy = bulletmesh.duplicate()
			var meshOverrideCopy = lightBulb.material_override.duplicate()
			bulletmeshCopy.material_override = meshOverrideCopy
			playerLight.get_child(1).queue_free()
			playerLight.add_child(bulletmeshCopy)
			lightBulb = bulletmeshCopy
	
func fireDraw():
	#Create Bullet
	bullet_instance = drawMaterial.instantiate()
	var bullet_body = bullet_instance.find_child("StaticBody3D", true, false)
	var bullet_mesh = bullet_instance.get_child(0)
	bullet_body.add_collision_exception_with(player)
	
	#Bullet Possition
	bullet_instance.position = barrel_raycast.global_position
	bullet_instance.transform.basis = barrel_raycast.global_transform.basis
	
	#Make Bullet Mesh Seperate From Other Bullet Meshes
	if bullet_mesh.material_override:
		bullet_mesh.material_override = bullet_mesh.material_override.duplicate()
	
	#Set Bullet Color Equal To Chosen Color
	bullet_mesh.material_override.albedo_color = GlobalVariables.get_color()
	bullet_mesh.material_override.emission = GlobalVariables.get_color()
	bullet_mesh.material_override.emission_energy_multiplier = paint_light_multiplyer
	
	#Fire
	get_parent().add_child(bullet_instance)
	
	#Clean Up
	bullet_mesh = null

func increaseAmmo():
	GlobalVariables.lightAmmo += 1

func suckBullet(child):
	var bullet_node = child
	if hold_time > 1:
		hold_time = 0
		bullet_node.queue_free()
		increaseAmmo()
		
func suckLight():
	if hold_time > 1:
		hold_time = 0
		var lightSuck: bool = suck_cast.get_collider().suckLight()
		if lightSuck:
			increaseAmmo()
			
func showScannableObjectIsSelectable():
	scanCollisionMesh = vision.get_collider().get_parent().get_child(0)
	if is_instance_valid(scanCollisionMesh.material_override):
		var unique_material = scanCollisionMesh.material_override.duplicate()
		colorStore = unique_material.albedo_color
		scanCollisionMesh.material_override = unique_material
	else:
		colorStore = null
	scanCollisionMesh.material_override = StandardMaterial3D.new()
	scanCollisionMesh.material_override.albedo_color = Color(1,0,0)
	scanSelected = true
