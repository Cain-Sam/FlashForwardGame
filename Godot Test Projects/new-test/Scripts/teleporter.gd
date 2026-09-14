extends Area3D
@export var sceneTo: String = "res://Scenes/main.tscn"
@export var portalColor: Color = Color(0.7, 0.7, 0.7)
@onready var portal: MeshInstance3D = $Portal
@onready var portal_glow: SpotLight3D = $Portal/portal_glow
@onready var telesuccess: AudioStreamPlayer = $AltrC
@onready var activate: AudioStreamPlayer = $Enchant
@onready var activatefail: AudioStreamPlayer = $IlluFail

var portal_active
var target_nodes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_manual_on_body_entered)
	if portal.material_override:
		changePortalColor(portalColor)
	portal.material_override.set_shader_parameter("is_spinning", false)	
	target_nodes = get_tree().get_nodes_in_group("teleporter")
func _manual_on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") && portalActive():
		for node in target_nodes:
			if node != self && node.portal_glow.light_color == self.portal_glow.light_color:
				var forward_distance: float = 1
				var target_forward: Vector3 = -node.global_transform.basis.z
				var destination: Vector3 = node.global_position + (target_forward * forward_distance)
				body.global_transform.basis = node.global_transform.basis.orthonormalized()
				body.rotate_y(PI) 
				body.global_position = destination
				telesuccess.play()
				#if body is CharacterBody3D:
					#body.velocity = Vector3.ZERO
		
	if body.is_in_group("bullet"):
		var portals_of_color_count = 0
		for node in target_nodes:
			if node.portal_glow.light_color == ColorList.color_list[ColorList.colorindex]:
				portals_of_color_count += 1
		if portals_of_color_count < 2:
			changePortalColor(ColorList.color_list[ColorList.colorindex])
			activate.play()
		else:
			activatefail.play()
		body.get_parent().queue_free()

func changePortalColor(color):
	var unique_material = portal.material_override.duplicate()
	portal.material_override = unique_material
	portal.material_override.set_shader_parameter("ColorParameter", color)
	portal.material_override.set_shader_parameter("is_spinning", true)
	portal_glow.light_color = color
	if portalActive():
		activate.play()
	
func portalActive():
	if portal_glow.light_color == Color(0.7, 0.7, 0.7):
		return false
	return true

func _process(_delta: float) -> void:
	pass
