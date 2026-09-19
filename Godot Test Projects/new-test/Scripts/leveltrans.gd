extends Area3D
@onready var loading: CanvasLayer = $Loading
@export var sceneTo: String = "res://Scenes/main.tscn"
@export var portalColor: Color = Color(0.72, 0.36, 0.30)
@onready var portal: MeshInstance3D = $LevelTrans/Portal
@onready var portal_glow: SpotLight3D = $LevelTrans/Wall/Hole/portal_glow


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_manual_on_body_entered)
	if portal.material_override:
		changePortalColor(portalColor)
	
func _manual_on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		loading.show()
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file(sceneTo)
	if body.is_in_group("bullet"):
		changePortalColor(ColorList.color_list[ColorList.colorindex].darkened(ColorList.darken_list[ColorList.darkenindex]))
		body.get_parent().queue_free()

func changePortalColor(color):
	var unique_material = portal.material_override.duplicate()
	portal.material_override = unique_material
	portal.material_override.set_shader_parameter("ColorParameter", color)
	portal_glow.light_color = color
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
