extends Node3D


const SPEED = 10

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var bullet_raycast: RayCast3D = $bullet_raycast

var stuck = false
var physics_groups = ["kickable", "collidable"]

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stuck:
		return
	
	if bullet_raycast.is_colliding():
		if !bullet_raycast.get_collider().is_in_group("player") && !bullet_raycast.get_collider().is_in_group("bullet"):
			mesh_instance_3d.scale.x = 0.4
			mesh_instance_3d.scale.y = 0.4
			mesh_instance_3d.scale.z = 0.05
			_stick()
	else:
		position += transform.basis * Vector3(0, 0, -SPEED) * delta
		
func _stick() -> void:
	stuck = true
	var collision = bullet_raycast.get_collision_point()
	var coll_normal = bullet_raycast.get_collision_normal()
	var hit_object = bullet_raycast.get_collider()
	global_position = collision
	var collider = bullet_raycast.get_collider()
	var up_dir = Vector3.UP if abs(coll_normal.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	look_at(global_position + coll_normal, up_dir)
	for i in physics_groups:
		if collider.is_in_group(i) or collider.get_parent().is_in_group(i):
			merge_bullet(hit_object)

func merge_bullet(hit_object):
	bullet_raycast.queue_free()
	 
	if hit_object.has_method("_manual_on_body_entered"):
		hit_object._manual_on_body_entered(self)

	if hit_object and hit_object is Node:
		reparent(hit_object, true)
