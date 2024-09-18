extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 确保窗口位置紧贴屏幕右侧
	_align_window_to_right()
	get_tree().root.set_transparent_background(true)

func _align_window_to_right() -> void:
	var screen_size = DisplayServer.window_get_size().x
	var window_size = 382
	# 计算窗口应该在屏幕上的位置
	var new_position_x = screen_size - window_size

	get_viewport_rect().position = Vector2(new_position_x, 1000)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
