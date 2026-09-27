extends Area3D

@onready var lightanimations: AnimationPlayer = $"../Lightanimations"
var player_detected := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_manual_on_body_entered)
	
	
func _manual_on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not player_detected:
		player_detected = true
		lightanimations.play("lights_out")
		
	if body.is_in_group("bullet"):
		body.get_parent().queue_free()

func _process(_delta: float) -> void:
	pass
