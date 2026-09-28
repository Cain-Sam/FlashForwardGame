extends Area3D
@onready var loading: CanvasLayer = $Loading
@export var sceneTo: String = "res://Scenes/main.tscn"
@export var portalColor: Color = Color(0.72, 0.36, 0.30)
@onready var portal: MeshInstance3D = $LevelTrans/Portal
@onready var portal_glow: SpotLight3D = $LevelTrans/Wall/Hole/portal_glow


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		changePortalColor(portalColor)
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		loadIntoLevel()

	if body.is_in_group("bullet"):
		changePortalColor(GlobalVariables.get_color())
		body.get_parent().queue_free()
		# Refund ammo, but not if we used paint
		if !body.is_in_group("paint"):
			GlobalVariables.lightAmmo += 1

func changePortalColor(color):
	var unique_material = portal.material_override.duplicate()
	portal.material_override = unique_material
	portal.material_override.set_shader_parameter("ColorParameter", color)
	portal_glow.light_color = color

func loadIntoLevel():
	loading.show()
	GlobalVariables.infinite_ammo = false
	# Small timeout to make sure loading text appears before loading actually starts
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(sceneTo)
