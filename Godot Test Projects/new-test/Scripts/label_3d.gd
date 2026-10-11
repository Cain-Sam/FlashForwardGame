extends Label3D

var displayFps: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if displayFps:
		self.text = str(Engine.get_frames_per_second())
	else:
		self.text = str(GlobalVariables.lightAmmo)
	
func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("showfps")):
		displayFps = !displayFps
