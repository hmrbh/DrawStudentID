extends CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_size = DisplayServer.screen_get_size()
	DisplayServer.window_set_size(Vector2i(screen_size.x / 6, screen_size.y / 2.8))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
