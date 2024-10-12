extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_settings_button_down() -> void:
	$"../Window".visible = true

func _on_close_button_down() -> void:
	$"../Window".visible = false

func _on_startup_check_button_toggled(toggled_on: bool) -> void:
	var AddStartupCheckButton = $"Window/TabBar/TabContainer/通用/通用/Label2/AddStartupCheckButton"
	if toggled_on:
		AddStartupCheckButton.text = "开启"
		var result = []
		print(OS.get_executable_path().get_file())
		OS.execute("DrawStudentID_Helper.exe", ["--a", "\\" + OS.get_executable_path().get_file()], result)
		print(result[0])
	else:
		AddStartupCheckButton.text = "关闭"
		
		
