extends MultiMeshInstance3D

enum { WALK, CLIMB }

@export var rat_mesh: Mesh
@export var rat_scale := 3.0
@export var flip_facing := true
@export var count := 500
@export var spawn_radius := 4.0
@export var roam_min := Vector3(-30, 0, -30)
@export var roam_max := Vector3(30, 0, 30)
@export var reach_dist := 4.0
@export var edge_margin := 3.0          # redirect when this close to the roam bounds
@export var redirect_duration := 6.0    # seconds a redirected rat follows its own target

@export var walk_speed := 3.0
@export var climb_speed := 2.0
@export var gravity := 20.0
@export var rat_radius := 0.2
@export var wall_check_dist := 0.7
@export var max_climb_time := 6.0       # climbing longer than this counts as stuck
@export_flags_3d_physics var world_mask := 1

@export var w_seek := 1.0
@export var w_cohesion := 0.6
@export var w_align := 0.5
@export var w_separation := 1.2
@export var separation_radius := 0.8

@export var debug_print := false

# Per-rat data (array index = MultiMesh instance id)
var pos := PackedVector3Array()
var dir := PackedVector3Array()          # desired flat direction
var fwd := PackedVector3Array()          # smoothed facing
var up := PackedVector3Array()           # smoothed up (wall normal while climbing)
var normal := PackedVector3Array()       # wall normal while climbing
var own_target := PackedVector3Array()   # personal destination while redirected
var vel_y := PackedFloat32Array()
var timer := PackedFloat32Array()        # time spent climbing
var redirect_timer := PackedFloat32Array()
var state := PackedByteArray()

var spawn_origin := Vector3.ZERO
var roam_target := Vector3.ZERO
var query: PhysicsRayQueryParameters3D
var _cursor := 0
var _ok := false
const SLICES := 3   # each rat re-steers every 3rd physics frame

func _ready() -> void:
	_ok = false
	count = maxi(count, 1)

	if rat_mesh == null:
		push_warning("rat_horde: Rat Mesh is empty, using a placeholder box.")
		var box := BoxMesh.new()
		box.size = Vector3(0.15, 0.1, 0.3)
		rat_mesh = box

	spawn_origin = global_position   # rats spawn where you place this node
	top_level = true
	global_transform = Transform3D.IDENTITY

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D   # these two must be set
	mm.use_custom_data = true                      # BEFORE instance_count
	mm.mesh = rat_mesh
	mm.instance_count = count
	# Huge bounding box so the horde is never culled
	mm.custom_aabb = AABB(Vector3(-100000, -100000, -100000), Vector3(200000, 200000, 200000))
	multimesh = mm

	pos.resize(count)
	dir.resize(count)
	fwd.resize(count)
	up.resize(count)
	normal.resize(count)
	own_target.resize(count)
	vel_y.resize(count)
	timer.resize(count)
	redirect_timer.resize(count)
	state.resize(count)

	for i in count:
		pos[i] = spawn_origin + Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)) * spawn_radius
		dir[i] = Vector3.ZERO
		fwd[i] = Vector3.FORWARD
		up[i] = Vector3.UP
		normal[i] = Vector3.UP
		own_target[i] = spawn_origin
		vel_y[i] = 0.0
		timer[i] = 0.0
		redirect_timer[i] = 0.0
		state[i] = WALK
		mm.set_instance_custom_data(i, Color(randf(), 0.0, 0.0, 0.0))  # random anim phase
		mm.set_instance_transform(i, Transform3D(Basis(Vector3.RIGHT * rat_scale, Vector3.UP * rat_scale, Vector3.BACK * rat_scale), pos[i]))

	query = PhysicsRayQueryParameters3D.new()
	query.collision_mask = world_mask
	_pick_target()

	_ok = true
	if debug_print:
		print("rat_horde ready | count=", count, " | spawn=", spawn_origin, " | rat0 pos=", pos[0])

func _physics_process(delta: float) -> void:
	if not _ok:
		return

	var space := get_world_3d().direct_space_state

	# Horde-wide values (cheap)
	var centroid := Vector3.ZERO
	var heading := Vector3.ZERO
	for i in count:
		centroid += pos[i]
		heading += dir[i]
	centroid /= float(count)
	heading = heading.normalized()

	# New horde target when we arrive, or when the horde reaches the roam edge
	if _flat(centroid - roam_target).length() < reach_dist or _outside_margin(centroid):
		_pick_target()

	# Staggered steering
	var n := ceili(count / float(SLICES))
	for _k in n:
		dir[_cursor] = _steer(_cursor, centroid, heading)
		_cursor = (_cursor + 1) % count

	# Per-rat movement, then write the transform
	for i in count:
		if redirect_timer[i] > 0.0:
			redirect_timer[i] -= delta
		if state[i] == WALK:
			_walk(i, delta, space)
		else:
			_climb(i, delta, space)
		_write(i, delta)

	if debug_print and Engine.get_physics_frames() % 60 == 0:
		print("rat0 pos=", pos[0], " state=", state[0], " redirect=", redirect_timer[0])

func _walk(i: int, delta: float, space: PhysicsDirectSpaceState3D) -> void:
	var d: Vector3 = dir[i]
	var p: Vector3 = pos[i]

	# Steep surface directly ahead -> start climbing
	if d.length_squared() > 0.01:
		var o := p + Vector3.UP * 0.1
		var w := _ray(space, o, o + d.normalized() * wall_check_dist)
		if not w.is_empty():
			var wn: Vector3 = w.normal
			if absf(wn.y) < 0.5:
				state[i] = CLIMB
				normal[i] = wn
				timer[i] = 0.0
				return

	p += d * walk_speed * delta

	# Ground snap, or fall if there's no ground below
	var g := _ray(space, p + Vector3.UP * 0.4, p + Vector3.DOWN * 0.8)
	if not g.is_empty():
		var gp: Vector3 = g.position
		p.y = lerpf(p.y, gp.y, 0.5)
		vel_y[i] = 0.0
	else:
		vel_y[i] = maxf(vel_y[i] - gravity * delta, -15.0)
		p.y += vel_y[i] * delta
		if p.y < spawn_origin.y - 100.0:   # fell out of the world: respawn
			p = spawn_origin
			vel_y[i] = 0.0
	pos[i] = p

func _climb(i: int, delta: float, space: PhysicsDirectSpaceState3D) -> void:
	timer[i] += delta
	var p: Vector3 = pos[i]
	var n: Vector3 = normal[i]

	# Give up on timeout (stuck), or if there's a ceiling above (no ceiling walking)
	var c := _ray(space, p, p + Vector3.UP * 0.4)
	var ceiling_above := false
	if not c.is_empty():
		var cn: Vector3 = c.normal
		ceiling_above = cn.y < -0.5
	if timer[i] > max_climb_time or ceiling_above:
		state[i] = WALK
		var np: Vector3 = p + n * 0.3
		pos[i] = np
		vel_y[i] = 0.0
		_redirect(i, n)   # new random destination, preferably away from this wall
		dir[i] = _flat(own_target[i] - np).normalized()
		return

	# Wall gone? We're over the top edge
	var w := _ray(space, p + n * 0.1, p - n * 0.6)
	if w.is_empty():
		pos[i] = p - n * 0.35 + Vector3.UP * 0.15
		state[i] = WALK
		vel_y[i] = 0.0
		return

	var wn: Vector3 = w.normal
	var wp: Vector3 = w.position
	normal[i] = wn

	# Climb up with a little sideways drift, then stick to the surface
	var d: Vector3 = dir[i]
	var lateral: Vector3 = d - d.project(wn)
	p += (Vector3.UP * climb_speed + lateral.limit_length(1.0) * 0.5) * delta
	var off: float = (wp + wn * rat_radius - p).dot(wn)
	pos[i] = p + wn * off

func _write(i: int, delta: float) -> void:
	var k: float = 1.0 - exp(-10.0 * delta)
	var climbing: bool = state[i] == CLIMB
	var target_up: Vector3 = normal[i] if climbing else Vector3.UP
	var target_fwd: Vector3 = Vector3.UP if climbing else dir[i]

	var cur_up: Vector3 = up[i]
	cur_up = cur_up.lerp(target_up, k).normalized()
	up[i] = cur_up

	if target_fwd.length_squared() > 0.01:
		var cur_fwd: Vector3 = fwd[i]
		fwd[i] = cur_fwd.lerp(target_fwd.normalized(), k).normalized()

	var f: Vector3 = fwd[i]
	var z: Vector3 = f if flip_facing else -f
	var x: Vector3 = cur_up.cross(z)
	if x.length_squared() < 0.0001:
		x = Vector3.RIGHT
	x = x.normalized()
	var y: Vector3 = z.cross(x)
	z = x.cross(y)
	var b := Basis(x * rat_scale, y * rat_scale, z * rat_scale)
	multimesh.set_instance_transform(i, Transform3D(b, pos[i]))

func _steer(i: int, centroid: Vector3, heading: Vector3) -> Vector3:
	var p: Vector3 = pos[i]

	# Edge check: a rat that wanders into the margin gets a new destination inside the bounds
	if redirect_timer[i] <= 0.0 and _outside_margin(p):
		_redirect(i, _center() - p)

	var active: bool = redirect_timer[i] > 0.0
	if active:
		var ot: Vector3 = own_target[i]
		if _flat(ot - p).length() < 1.5:   # arrived: rejoin the horde
			redirect_timer[i] = 0.0
			active = false

	var goal: Vector3 = own_target[i] if active else roam_target
	var seek := _flat(goal - p).normalized()
	var cohesion := _flat(centroid - p).normalized()
	var seek_w: float = w_seek * (2.0 if active else 1.0)
	var group_w: float = 0.15 if active else 1.0   # redirected rats mostly ignore the pack

	var sep := Vector3.ZERO
	for _k in 8:   # sample a few random neighbors instead of checking everyone
		var j := randi() % count
		var d := _flat(p - pos[j])
		var dist := d.length()
		if j != i and dist < separation_radius and dist > 0.001:
			sep += d / (dist * dist)

	var result := seek * seek_w + cohesion * w_cohesion * group_w + heading * w_align * group_w + sep * w_separation
	return result.normalized()

# Give a rat its own random destination for a while.
# `toward` biases the choice to points in that direction (e.g. away from a wall, or back inward).
func _redirect(i: int, toward: Vector3 = Vector3.ZERO) -> void:
	var p: Vector3 = pos[i]
	var t := _random_point()
	var bias := _flat(toward)
	if bias.length_squared() > 0.0001:
		for _k in 8:
			if _flat(t - p).dot(bias) > 0.0:
				break
			t = _random_point()
	own_target[i] = t
	redirect_timer[i] = redirect_duration

func _margin() -> float:
	var half_w: float = minf(roam_max.x - roam_min.x, roam_max.z - roam_min.z) * 0.5
	return minf(edge_margin, half_w * 0.5)

func _outside_margin(p: Vector3) -> bool:
	var m := _margin()
	return p.x < roam_min.x + m or p.x > roam_max.x - m or p.z < roam_min.z + m or p.z > roam_max.z - m

func _center() -> Vector3:
	return (roam_min + roam_max) * 0.5

func _random_point() -> Vector3:
	var m := _margin()
	return Vector3(
		randf_range(roam_min.x + m, roam_max.x - m), 0.0,
		randf_range(roam_min.z + m, roam_max.z - m))

func _ray(space: PhysicsDirectSpaceState3D, from: Vector3, to: Vector3) -> Dictionary:
	query.from = from
	query.to = to
	return space.intersect_ray(query)

func _pick_target() -> void:
	roam_target = _random_point()

func _flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)
