extends Area3D
@onready var loading: CanvasLayer = $Loading



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# This forces the signal to connect via code on startup
	body_entered.connect(_manual_on_body_entered)

func _manual_on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		loading.show()
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://Scenes/main.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
