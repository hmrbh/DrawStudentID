extends Node2D

@export var max_id: int = 0
@export var min_id: int = 0

var database: SQLite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_database()
	if str(database.select_rows("id_range", "", ["*"])) == "[]":
		# 插入一些初始数据
		database.query("INSERT INTO id_range (min, max) VALUES (1, 10);")
		print("检测到键值为空，插入一些初始数据防止更新失败")
	var loded_id_range = database.select_rows("id_range", "", ["*"])[0]
	$"SettingsButton/Window/TabBar/TabContainer/通用/通用/Label/min".text =  str(loded_id_range["min"])
	$"SettingsButton/Window/TabBar/TabContainer/通用/通用/Label/max".text =  str(loded_id_range["max"])
	max_id = int(database.select_rows("id_range", "", ["max"])[0]["max"])
	min_id = int(database.select_rows("id_range", "", ["min"])[0]["min"])

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
	if str(database.select_rows("id_range", "", ["*"])) == "[]":
		create_database()
		# 插入一些初始数据
		database.query("INSERT INTO id_range (min, max) VALUES (1, 10);")
		print("检测到键值为空，插入一些初始数据防止更新失败")
	database.query("UPDATE id_range SET min = " + str(new_min_id) + ";")
	print(database.select_rows("id_range", "", ["*"]))
	min_id = int(database.select_rows("id_range", "", ["min"])[0]["min"])
	print("学号范围最小值被更改为：", min_id)

func _on_max_id_text_edit_changed(new_text: String) -> void:
	# 如果输入了非数字值就不记录直接退出
	if not new_text.is_valid_int() and not new_text.is_empty():
		print("错误输入！")
		show_settings_error_dialog("位于设置->通用->设置学号范围->学号最大值输入框", "请检查您是否在此输入了非整数值")
		return
	
	var new_max_id = int(new_text)
	if str(database.select_rows("id_range", "", ["*"])) == "[]":
		create_database()
		# 插入一些初始数据
		database.query("INSERT INTO id_range (min, max) VALUES (1, 10);")
		print("检测到键值为空，插入一些初始数据防止更新失败")
	database.query("UPDATE id_range SET max = " + str(new_max_id) + ";")
	print(database.select_rows("id_range", "", ["*"]))
	max_id = int(database.select_rows("id_range", "", ["max"])[0]["max"])
	print("学号范围最大值被更改为：", max_id)

	
func show_settings_error_dialog(location: String, tip_msg: String) -> void:
	$SettingsButton/AcceptDialog.visible = true
	$SettingsButton/AcceptDialog.dialog_text = "您在设置项中输入了错误的内容\n" + location + "\n" + tip_msg
