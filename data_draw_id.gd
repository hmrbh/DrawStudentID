extends Node2D

var max_id: int = 0
var min_id: int = 0
var exclude_id: String = " "

var database: SQLite

var is_lock_range_checked: bool = false

var is_cancel_input_password: bool

var is_enter_admin_password: bool = false

var read_is_lock_id_range

var regex = RegEx.new()

signal data_changed(new_data, type)

func update_data(new_data, type):
	emit_signal("data_changed", new_data, type)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_database()
	if str(database.select_rows("id_range", "", ["*"])) == "[]":
		data_init()
	var loded_id_range = database.select_rows("id_range", "", ["*"])[0]
	print(loded_id_range)
	$"Window/TabBar/TabContainer/通用/通用/Label/min".text =  str(loded_id_range["min"])
	$"Window/TabBar/TabContainer/通用/通用/Label/max".text =  str(loded_id_range["max"])
	$"Window/TabBar/TabContainer/通用/通用/Label/exclude".text =  str(loded_id_range["exclude"])
	max_id = int(database.select_rows("id_range", "", ["max"])[0]["max"])
	min_id = int(database.select_rows("id_range", "", ["min"])[0]["min"])
	exclude_id = str(database.select_rows("id_range", "", ["exclude"])[0]["exclude"])
	
	is_cancel_input_password = false

	if get_data("bool_settings", "is_lock_id_range") == "true":
		read_is_lock_id_range = true
		set_id_range_editable(false)
	else:
		read_is_lock_id_range = false
		set_id_range_editable(true)
	$Window/TabBar/TabContainer/通用/通用/CheckBox_Lock_Range.text = "锁定学号范围设置（%s）" % ("开启" if read_is_lock_id_range else "关闭")
	is_lock_range_checked = read_is_lock_id_range
	
func set_id_range_editable(editable: bool) -> void:
	$"Window/TabBar/TabContainer/通用/通用/Label/max".editable = editable
	$"Window/TabBar/TabContainer/通用/通用/Label/min".editable = editable
	$"Window/TabBar/TabContainer/通用/通用/Label/exclude".editable = editable
		
func get_is_lock_id_range() -> bool:
	return read_is_lock_id_range
	
func get_max_id() -> int:
	return max_id

func get_min_id() -> int:
	return min_id
	
func get_exclude_id() -> String:
	return exclude_id

func create_database() -> void:
	database = SQLite.new()
	database.path = "res://sqlite_data.db"
	database.open_db()
	
	var table_id_range = {
		"min": {
			"data_type": "int",
		},
		"max": {
			"data_type": "int",
		},
		"exclude": {
			"data_type": "text"
		}
	}
	
	var table_bool_settings = {
		"is_lock_id_range": {
			"data_type": "int",
		},
	}
	
	var table_string_settings = {
		"admin_password": {
			"data_type": "text",
		},
	}
	database.create_table("id_range", table_id_range)
	database.create_table("bool_settings", table_bool_settings)
	database.create_table("string_data", table_string_settings)
	
func _on_min_id_text_edit_changed(new_text: String) -> void:
	# 如果输入了非数字值就不记录直接退出
	if not new_text.is_valid_int() and not new_text.is_empty():
		print("错误输入！")
		show_settings_error_dialog("位于设置->通用->设置学号范围->学号最小值输入框", "请检查您是否在此输入了非整数值")
		return
		
	if int(new_text) > int(max_id) and not new_text.is_empty():
		print("错误输入！")
		show_settings_error_dialog("位于设置->通用->设置学号范围->学号最小值输入框", "最小学号必须小于最大学号")
		return
		
	elif not new_text.is_empty():
		var new_min_id = int(new_text)
		print("调整最小学号为：", change_data_id_range("min", new_min_id))
		update_data(new_min_id, "min_id")

func _on_max_id_text_edit_changed(new_text: String) -> void:
	# 如果输入了非数字值就不记录直接退出
	if not new_text.is_valid_int() and not new_text.is_empty():
		print("错误输入！")
		show_settings_error_dialog("位于设置->通用->设置学号范围->学号最大值输入框", "请检查您是否在此输入了非整数值")
		return
		
	if int(new_text) < int(min_id) and not new_text.is_empty():
		print("错误输入！")
		show_settings_error_dialog("位于设置->通用->设置学号范围->学号最大值输入框", "最大学号必须大于最小学号")
		return
		
	elif not new_text.is_empty():
		var new_max_id = int(new_text)
		print("调整最大学号为：", change_data_id_range("max", new_max_id))
		update_data(new_max_id, "max_id")
	
func show_settings_error_dialog(location: String, tip_msg: String) -> void:
	$Window/AcceptDialog.visible = true
	$Window/AcceptDialog.dialog_text = "您在设置项中输入了错误的内容\n" + location + "\n" + tip_msg


func _on_exclude_id_text_edit_changed(new_text: String) -> void:
	# 匹配数字和英文逗号
	var pattern = "^[0-9,]+$"
	# 编译正则表达式
	regex.compile(pattern)
	var result = regex.search(new_text)

	if result:
		print("排除学号输入有效: ", new_text)
		print("更改排除学号为：", change_data_id_range("exclude", new_text))
		update_data(new_text, "exclude_id")
	else:
		if not new_text.is_empty():
			print("排除学号输入无效: ", new_text)
			show_settings_error_dialog("位于设置->通用->设置学号范围->排除学号输入框", "注意必须使用英文逗号来分隔学号\n请确认您是否输入了除数字和英文逗号之外的字符")

func change_data_id_range(key, new_value) -> String:
	return change_data("id_range", key, new_value)
	
func change_data(rows:String, key, new_value) -> String:
	if str(database.select_rows(rows, "", ["*"])) == "[]":
		create_database()
		data_init()
	database.query("UPDATE " + rows + " SET " + key + " = " + "'" +str(new_value) + "'" + ";")
	return str(database.select_rows(rows, "", [key])[0][key])

func get_data(rows:String, key) -> String:
	if str(database.select_rows(rows, "", ["*"])) == "[]":
		create_database()
		data_init()
	return str(database.select_rows(rows, "", [key])[0][key])
	
# 判断指定键值是否存在数据
func data_is_exists(rows:String, key) -> bool:
	if (database.select_rows(rows, "", [key])[0][key]).is_empty():
		return false
	else:
		return true
		
# 当数据库为空时，插入一些初始数据
func data_init() -> void:
	database.query("INSERT INTO id_range (min, max, exclude) VALUES (1, 38, \"\");")
	database.query("INSERT INTO string_data (admin_password) VALUES (\"\");")
	database.query("INSERT INTO bool_settings (is_lock_id_range) VALUES (\"\");")
	print("检测到键值为空，插入一些初始数据防止更新失败")

var first_time_checked_is_lock_range = true
func _on_lock_id_range_check_box_toggled(toggled_on: bool) -> void:
	# 如果是第一次为了同步数据库中的数据而被触发的，那么就跳过
	var checkbox_node = get_node("Window/TabBar/TabContainer/通用/通用/CheckBox_Lock_Range")
	if !checkbox_node.is_check_box_init():
		return
		
	$Window/TabBar/TabContainer/通用/通用/CheckBox_Lock_Range.text = "锁定学号范围设置（%s）" % ("开启" if toggled_on else "关闭")
	
	# 如果新状态与旧状态相同，则不执行任何操作
	if toggled_on == is_lock_range_checked and !first_time_checked_is_lock_range:
		first_time_checked_is_lock_range = false
		return
	first_time_checked_is_lock_range = false
	
	is_lock_range_checked = toggled_on
	# 如果复选框被开启且没有设置过密码，则弹出设置密码窗口
	if is_lock_range_checked and get_data("string_data", "admin_password").is_empty():
		$Window/SetPasswordWindow.visible = true
		return
		
	# 如果复选框被开启，并且设置过管理员密码
	elif is_lock_range_checked and not get_data("string_data", "admin_password").is_empty():
		$Window/InputPasswordWindow.visible = true
	elif not is_lock_range_checked and not get_data("string_data", "admin_password").is_empty():
		$Window/InputPasswordWindow.visible = true

		
# 取消输入管理员密码
func _on_cancel_input_password_button_down() -> void:
	$Window/InputPasswordWindow.visible = false
	# 恢复复选框状态，但不触发_on_lock_id_range_check_box_toggled函数
	is_lock_range_checked = !is_lock_range_checked
	# 更新复选框按钮状态
	$Window/TabBar/TabContainer/通用/通用/CheckBox_Lock_Range.button_pressed = is_lock_range_checked

# 确认设置管理员密码
func _on_button_button_down() -> void:
	$Window/SetPasswordWindow.visible = false
	$Window/TabBar/TabContainer/通用/通用/CheckBox_Lock_Range.button_pressed = true

var is_enter_password = [false, false]
var enter_password = ["", ""]

func _on_password_line_edit_text_changed(new_text: String) -> void:
	is_enter_password[0] = true
	enter_password[0] = new_text
	$Window/SetPasswordWindow/Label4.text = " "

func _on_password_confirm_text_changed(new_text: String) -> void:
	is_enter_password[1] = true
	enter_password[1] = new_text
	$Window/SetPasswordWindow/Label4.text = " "

func _process(_delta: float) -> void:
	# 只有两个输入框都输入了密码才启用确认按钮
	if is_enter_password[0] && is_enter_password[1] \
	&& !enter_password[0].is_empty() && !enter_password[1].is_empty():
		$Window/SetPasswordWindow/Button.disabled = false
	else:
		$Window/SetPasswordWindow/Button.disabled = true
		
	if is_enter_admin_password:
		$Window/InputPasswordWindow/Button.disabled = false
	else:
		$Window/InputPasswordWindow/Button.disabled = true

func _on_confirm_password_button_pressed() -> void:
	if enter_password[0] != enter_password[1]:
		# 当两个输入框中的密码不一致时，禁用确认按钮，并让输入管理员密码
		# 的窗口重新显示，并在底部用文字提示两次输入的密码不一致
		print("两次输入的密码不一致！")
		$Window/SetPasswordWindow/Button.disabled = true
		$Window/SetPasswordWindow.visible = true
		$Window/SetPasswordWindow/Label4.text = "两次输入的密码不一致！"
		$Window/TabBar/TabContainer/通用/通用/CheckBox_Lock_Range.button_pressed = false
	else:
		$Window/TabBar/TabContainer/通用/通用/CheckBox_Lock_Range.button_pressed = true
		change_data("string_data", "admin_password", enter_password[1])
		set_id_range_editable(false)

# 取消设置管理员密码
func _on_cancel_setting_password_button_down() -> void:
	$Window/SetPasswordWindow.visible = false
	$Window/TabBar/TabContainer/通用/通用/CheckBox_Lock_Range.button_pressed = false

var input_password:String

func _on_input_password_line_edit_changed(new_text: String) -> void:
	if new_text.is_empty():
		is_enter_admin_password = false
	else:
		is_enter_admin_password = true
		input_password = new_text

func _on_confirm_input_password_button_down() -> void:
	$Window/InputPasswordWindow.visible = false
	var password = get_data("string_data", "admin_password")
	if not get_data("string_data", "admin_password").is_empty():
		if input_password != password:
			$Window/InputPasswordWindow.visible = true
			$Window/InputPasswordWindow/LineEdit.text = ""
			$Window/InputPasswordWindow/ErrorMsg.text = "密码错误，请重新输入！"
		else:
			$Window/InputPasswordWindow/LineEdit.text = ""
			$Window/InputPasswordWindow/ErrorMsg.text = " "
			set_id_range_editable(!is_lock_range_checked)
			change_data("bool_settings", "is_lock_id_range", is_lock_range_checked)
	else:
		$Window/SetPasswordWindow.visible = true
