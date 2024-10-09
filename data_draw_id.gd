extends Node2D

var max_id: int = 0
var min_id: int = 0
var exclude_id: String = " "

var database: SQLite

var regex = RegEx.new()

signal data_changed(new_data, type)

func update_data(new_data, type):
	emit_signal("data_changed", new_data, type)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_database()
	if str(database.select_rows("id_range", "", ["*"])) == "[]":
		# 插入一些初始数据
		database.query("INSERT INTO id_range (min, max, exclude) VALUES (1, 38, \"\");")
		print("检测到键值为空，插入一些初始数据防止更新失败")
	var loded_id_range = database.select_rows("id_range", "", ["*"])[0]
	print(loded_id_range)
	$"Area2D/SettingsButton/Window/TabBar/TabContainer/通用/通用/Label/min".text =  str(loded_id_range["min"])
	$"Area2D/SettingsButton/Window/TabBar/TabContainer/通用/通用/Label/max".text =  str(loded_id_range["max"])
	$"Area2D/SettingsButton/Window/TabBar/TabContainer/通用/通用/Label/exclude".text =  str(loded_id_range["exclude"])
	max_id = int(database.select_rows("id_range", "", ["max"])[0]["max"])
	min_id = int(database.select_rows("id_range", "", ["min"])[0]["min"])
	exclude_id = str(database.select_rows("id_range", "", ["exclude"])[0]["exclude"])

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
	
	var table_data = {
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
	
	database.create_table("id_range", table_data)
	
func _on_min_id_text_edit_changed(new_text: String) -> void:
	# 如果输入了非数字值就不记录直接退出
	if not new_text.is_valid_int() and not new_text.is_empty():
		print("错误输入！")
		show_settings_error_dialog("位于设置->通用->设置学号范围->学号最小值输入框", "请检查您是否在此输入了非整数值")
		return
	var new_min_id = int(new_text)
	print("调整最小学号为：", change_data_by_key("min", new_min_id))
	update_data(new_min_id, "min_id")

func _on_max_id_text_edit_changed(new_text: String) -> void:
	# 如果输入了非数字值就不记录直接退出
	if not new_text.is_valid_int() and not new_text.is_empty():
		print("错误输入！")
		show_settings_error_dialog("位于设置->通用->设置学号范围->学号最大值输入框", "请检查您是否在此输入了非整数值")
		return
	
	var new_max_id = int(new_text)
	print("调整最大学号为：", change_data_by_key("max", new_max_id))
	update_data(new_max_id, "max_id")
	
func show_settings_error_dialog(location: String, tip_msg: String) -> void:
	$SettingsButton/Window/AcceptDialog.visible = true
	$SettingsButton/Window/AcceptDialog.dialog_text = "您在设置项中输入了错误的内容\n" + location + "\n" + tip_msg


func _on_exclude_id_text_edit_changed(new_text: String) -> void:
	# 匹配数字和英文逗号
	var pattern = "^[0-9,]+$"
	# 编译正则表达式
	regex.compile(pattern)
	var result = regex.search(new_text)

	if result:
		print("排除学号输入有效: ", new_text)
		print("更改排除学号为：", change_data_by_key("exclude", new_text))
		update_data(new_text, "exclude_id")
	else:
		if not new_text.is_empty():
			print("排除学号输入无效: ", new_text)
			show_settings_error_dialog("位于设置->通用->设置学号范围->排除学号输入框", "注意必须使用英文逗号来分隔学号\n请确认您是否输入了除数字和英文逗号之外的字符")

func change_data_by_key(key, new_value) -> String:
	if str(database.select_rows("id_range", "", ["*"])) == "[]":
		create_database()
		# 插入一些初始数据
		database.query("INSERT INTO id_range (min, max, exclude) VALUES (1, 38, \"\");")
		print("检测到键值为空，插入一些初始数据防止更新失败")
	database.query("UPDATE id_range SET " + key + " = " + "'" +str(new_value) + "'" + ";")
	print(database.select_rows("id_range", "", ["*"]))
	return str(database.select_rows("id_range", "", [key])[0][key])
