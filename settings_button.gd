extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_settings_button_down() -> void:
	# 如果设置窗口被切换到后台，就先隐藏再显示
	$"../Window".visible = false
	$"../Window".visible = true

func _on_close_button_down() -> void:
	$"../Window".visible = false
