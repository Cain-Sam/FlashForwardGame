extends Node3D
@onready var door: RigidBody3D = $DOOR
@onready var door_mesh: MeshInstance3D = $DOOR/DoorMesh
@onready var hinge_joint_3d: HingeJoint3D = $HingeJoint3D
@export var doorMaterialOverride: Material = null
@export var kickBreakable: bool = true
@export var intensityBreak: float = 2.2
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") var angularLimitUpper: float = deg_to_rad(90.0)
@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") var angularLimitLower: float = deg_to_rad(-90.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	door_mesh.material_override = doorMaterialOverride
	door.intensityBreakThresh = intensityBreak
	door.kickBreakable = kickBreakable
	hinge_joint_3d.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, angularLimitUpper)
	hinge_joint_3d.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, angularLimitLower)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
