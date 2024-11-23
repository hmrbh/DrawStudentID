extends Area2D

var drag_pos: Vector2i
var timer2: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_position(read_window_pos())
	
	timer2 = Timer.new()
	add_child(timer2)
	timer2.wait_time = 0.2
	timer2.connect("timeout", save_window_pos)
	timer2.one_shot = false
	timer2.start()
	
	DisplayServer.window_set_position(read_window_pos())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_dragging:
		# 让窗体边框与鼠标一直保持相同的距离，这样的拖动效果更自然
		drag_pos = DisplayServer.mouse_get_position() + pos_difference
		DisplayServer.window_set_position(drag_pos)

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

func save_window_pos() -> void:
	var window_pos = DisplayServer.window_get_position()
	var config = ConfigFile.new()
	config.save("./SettingsData.cfg")
	config.load("./SettingsData.cfg")
	config.set_value("WindowPosition", "x", str(window_pos.x))
	config.set_value("WindowPosition", "y", str(window_pos.y))
	config.save("./SettingsData.cfg")

func read_window_pos() -> Vector2i:
	var config = ConfigFile.new()
	var err = config.load("./SettingsData.cfg")
	if err != OK:
		config.save("./SettingsData.cfg")
		config.load("./SettingsData.cfg")
		save_window_pos()
		return DisplayServer.window_get_position()
	else:
		# 配置文件内容为空或缺少键值，无法读取到内容
		if !config.get_value("WindowPosition", "x", false):
			save_window_pos()
		# config.get_value()
		# 第三个参数表示如果没有读取到内容，返回什么值
		# 所以这个参数必须为整数
		return Vector2i(
			int(config.get_value("WindowPosition", "x", 0)),
			int(config.get_value("WindowPosition", "y", 0))
			)
