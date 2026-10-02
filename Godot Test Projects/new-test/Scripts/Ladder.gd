extends StaticBody3D
@export var rungs = 1
@onready var ladder_height: CollisionShape3D = $Area3D/LadderHeight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rungNumber = 1
	while rungNumber < rungs:
		var newRung = self.duplicate()
		newRung.find_child("Area3D").queue_free()
		newRung.set_script(null)
		newRung.position.y += 0.2 * rungNumber
		get_parent().add_child.call_deferred(newRung)
		self.ladder_height.scale.y += 0.37
		rungNumber += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.ladder_mode = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.ladder_mode = false
