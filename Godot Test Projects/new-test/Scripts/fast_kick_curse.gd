extends Area3D

@onready var kick_curse: VideoStreamPlayer = $"../player/Head/Camera3D/SubViewportContainer/SubViewport/VideoStreamPlayer"
var player_detected := false
var loops := 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_manual_on_body_entered)
	kick_curse.finished.connect(_video_end)
	
func _manual_on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not player_detected:
		player_detected = true
		loops = 3
		kick_curse.modulate.a = 0.4
		kick_curse.speed_scale = 7.0
		kick_curse.play()
		
	if body.is_in_group("bullet"):
		body.get_parent().queue_free()

func _video_end() -> void: 
	loops -= 1 
	if loops > 0:  
		kick_curse.play()
		
func _process(_delta: float) -> void:
	pass
