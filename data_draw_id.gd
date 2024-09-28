extends Node2D

var database: SQLite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_database()
	if str(database.select_rows("id_range", "", ["*"])) == "[]":
		# 插入一些初始数据
		database.query("INSERT INTO id_range (min, max) VALUES (1, 10);")
		print("检测到键值为空，插入一些初始数据防止更新失败")
	var loded_id_range = database.select_rows("id_range", "", ["*"])[0]
	$"SettingsButton/Window/TabBar/TabContainer/通用/Label/min".text =  str(loded_id_range["min"])
	$"SettingsButton/Window/TabBar/TabContainer/通用/Label/max".text =  str(loded_id_range["max"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	var new_min_id = int(new_text)
	if str(database.select_rows("id_range", "", ["*"])) == "[]":
		create_database()
		# 插入一些初始数据
		database.query("INSERT INTO id_range (min, max) VALUES (1, 10);")
		print("检测到键值为空，插入一些初始数据防止更新失败")
	database.query("UPDATE id_range SET min = " + str(new_min_id) + ";")
	print(database.select_rows("id_range", "", ["*"]))

func _on_max_id_text_edit_changed(new_text: String) -> void:
	var new_max_id = int(new_text)
	if str(database.select_rows("id_range", "", ["*"])) == "[]":
		create_database()
		# 插入一些初始数据
		database.query("INSERT INTO id_range (min, max) VALUES (1, 10);")
		print("检测到键值为空，插入一些初始数据防止更新失败")
	database.query("UPDATE id_range SET max = " + str(new_max_id) + ";")
	print(database.select_rows("id_range", "", ["*"]))


func _on_min_id_text_edit_ready() -> void:
	print(111)
	
