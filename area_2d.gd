extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_dragging:
			# 让窗体边框与鼠标一直保持相同的距离，这样的拖动效果更自然
			var drag_pos = DisplayServer.mouse_get_position() + pos_difference
			DisplayServer.window_set_position(drag_pos)
			print("当前窗口位置：", drag_pos)

var pos_difference: Vector2i
var can_dragging = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				can_dragging = true
				# 计算窗口0，0位置与鼠标位置的差值
				pos_difference = DisplayServer.window_get_position() - DisplayServer.mouse_get_position()
			else:
				can_dragging = false
