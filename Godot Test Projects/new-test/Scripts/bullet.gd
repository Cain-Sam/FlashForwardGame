extends Node3D


const SPEED = 30

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var bullet_raycast: RayCast3D = $bullet_raycast
@onready var omni_light: OmniLight3D = $OmniLight
@onready var timer: Timer = $Timer
var mesh

var stuck = false

func _ready() -> void:
	mesh = mesh_instance_3d;
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stuck:
		return
	omni_light.light_color = GlobalVariables.get_color()
	for child in self.get_children():
		if child is MeshInstance3D:
			mesh = child
	mesh.material_override.albedo_color = GlobalVariables.get_color()
	mesh.material_override.emission = GlobalVariables.get_color()
		
	if bullet_raycast.is_colliding():
		stick()
		
	else:
		position += transform.basis * Vector3(0, 0, -SPEED) * delta
		if timer.time_left <= 0:
			bulletTimeout(self)

func stick() -> void:
	stuck = true
	var collision = bullet_raycast.get_collision_point()
	var coll_normal = bullet_raycast.get_collision_normal()
	var hit_object = bullet_raycast.get_collider()
	global_position = collision
	bulletFaceUp(collision, coll_normal)
	checkForObjectReaction(hit_object)
	#removeCollision()
	mergeWithObject(hit_object)
		
func bulletTimeout(body):
	GlobalVariables.lightAmmo += 1
	body.queue_free()
	
func paintLieFlat(coll_normal):
	var up_dir = Vector3.UP if abs(coll_normal.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	look_at(global_position + coll_normal, up_dir)

func checkForObjectReaction(hit_object):
	var collider = bullet_raycast.get_collider()
	bullet_raycast.queue_free()
	if collider.has_method("bulletHit"):
		hit_object.bulletHit(self)

func removeCollision():
	for child in get_children():
		if child is CollisionShape3D or child is CollisionObject3D:
			child.queue_free()
			
func mergeWithObject(hit_object):
	if hit_object and hit_object is Node:
		reparent(hit_object, true)

func bulletFaceUp(collision, coll_normal):
	if coll_normal.abs() != Vector3.UP:
			look_at(collision + coll_normal, Vector3.UP)
