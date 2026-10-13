extends Area3D
@onready var gnome_runnin: AnimationPlayer = $"../Path3D/GnomeRunnin"

var player_detected := false

func _ready() -> void:
	body_entered.connect(_manual_on_body_entered)
	gnome_runnin.animation_finished.connect(_gnome)

func _manual_on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_detected = not player_detected
		if player_detected:
			gnome_runnin.play("gnome_run")
		else:
			gnome_runnin.stop()

	if body.is_in_group("bullet"):
		body.get_parent().queue_free()

func _gnome(_anim_name: StringName) -> void:
	player_detected = false
