extends Area3D
@export var portalColor: Color = Color(0.7, 0.7, 0.7)
@export var stopWhenEntered: bool = false
@onready var portal: MeshInstance3D = $Portal
@onready var portal_glow: SpotLight3D = $Portal/portal_glow
@onready var telesuccess: AudioStreamPlayer = $AltrC
@onready var activate: AudioStreamPlayer = $Enchant
@onready var activatefail: AudioStreamPlayer = $IlluFail

var portal_timeout: bool = false
var target_nodes
var target_portal = null
var deactivate_color = Color(0.29, 0.29, 0.29)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_manual_on_body_entered)
	if portal.material_override:
		changePortalColor(portal, portalColor)
	portal.material_override.set_shader_parameter("is_spinning", false)	
	target_nodes = get_tree().get_nodes_in_group("teleporter")
func _manual_on_body_entered(body: Node3D) -> void:
	if portalActive() && !body.is_in_group("bullet"):
		for node in target_nodes:
			if node != self && node.portal_glow.light_color == self.portal_glow.light_color:
				target_portal = node
				var forward_distance: float = 1
				var target_forward: Vector3 = -node.global_transform.basis.z
				var destination: Vector3 = node.global_position + (target_forward * forward_distance)
				#body.global_transform.basis = node.global_transform.basis.orthonormalized()
				body.global_position = destination
				var look_target: Vector3 = destination + target_forward
				body.look_at(look_target, Vector3.UP)
				body.rotate_y(PI) 
				telesuccess.play()
				if body is CharacterBody3D && stopWhenEntered:
					body.velocity = Vector3.ZERO
				setPortalTimeout()
		
	if body.is_in_group("bullet"):
		var portals_of_color_count = 0
		for node in target_nodes:
			if node.portal_glow.light_color == ColorList.color_list[ColorList.colorindex]:
				portals_of_color_count += 1
		if portals_of_color_count < 2 && portal_glow.light_color != deactivate_color:
			changePortalColor(portal, ColorList.color_list[ColorList.colorindex])
			activate.play()
		else:
			activatefail.play()
		body.get_parent().queue_free()

func changePortalColor(targetPortal, color):
	var unique_material = portal.material_override.duplicate()
	targetPortal.material_override = unique_material
	targetPortal.material_override.set_shader_parameter("ColorParameter", color)
	targetPortal.material_override.set_shader_parameter("is_spinning", true)
	targetPortal.get_node("portal_glow").light_color = color
	
func portalActive():
	if portal_glow.light_color == Color(0.7, 0.7, 0.7) || portal_glow.light_color == deactivate_color:
		return false
	return true

func setPortalTimeout():
	var color_store = portal_glow.light_color
	changePortalColor(portal, deactivate_color)
	changePortalColor(target_portal.get_node("Portal"), deactivate_color)
	await get_tree().create_timer(3.0).timeout
	changePortalColor(portal, color_store)
	changePortalColor(target_portal.get_node("Portal"), color_store)

func _process(_delta: float) -> void:
	pass
