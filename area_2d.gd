extends Area2D

var drag_pos: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_position(read_window_pos())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_dragging:
			# 让窗体边框与鼠标一直保持相同的距离，这样的拖动效果更自然
			drag_pos = DisplayServer.mouse_get_position() + pos_difference
			DisplayServer.window_set_position(drag_pos)
			record_window_pos(drag_pos)
			print("当前窗口位置：", drag_pos)
	record_window_pos(DisplayServer.window_get_position())

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

func record_window_pos(pos: Vector2i) -> void:
	var config = ConfigFile.new()
	config.save("./SettingsData.cfg")
	config.load("./SettingsData.cfg")
	config.set_value("WindowPosition", "x", str(pos.x))
	config.set_value("WindowPosition", "y", str(pos.y))
	config.save("./SettingsData.cfg")
	print("保存窗口位置信息：", pos)

func read_window_pos() -> Vector2i:
	var config = ConfigFile.new()
	var err = config.load("./SettingsData.cfg")
	if err != OK:
		config.save("./SettingsData.cfg")
		config.load("./SettingsData.cfg")
		return Vector2i(0,0)
	return Vector2i(int(config.get_value("WindowPosition", "x")),int(config.get_value("WindowPosition", "y")))
