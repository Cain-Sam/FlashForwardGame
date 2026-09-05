extends Camera3D

@onready var fps_rig: Node3D = $fps_rig
@onready var animation_player: AnimationPlayer = $fps_rig/shotgun/AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $fps_rig/leg/left_leg/AnimationPlayer2
@onready var door: CSGBox3D = $"../../../../../../stage/Door"
@onready var vision: RayCast3D = $"../../../../Vision"


var shotgun_in_use = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_rig.position.x = lerp(fps_rig.position.x,0.0,delta*5)
	fps_rig.position.y = lerp(fps_rig.position.y,0.0,delta*5)
	
func sway(sway_amount):
	fps_rig.position.x -= sway_amount.x*0.00004
	fps_rig.position.y += sway_amount.y*0.00004

func _input(event):
	if(event.is_action_pressed("shoot")):
		animation_player.play("fire")
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
			if collider.is_in_group("door"):
				collider.queue_free()
