extends Button

var timer: Timer
var timer_text: Timer
var timer_reset_text: Timer
var numbers = []
var used_numbers = []
var max_id: int
var min_id: int
var exclude_id: String
var is_node2d_init: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(size)
	size.x = 10
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.connect("timeout", close_window)
	timer.one_shot = true
	
	timer_text = Timer.new()
	add_child(timer_text)
	timer_text.wait_time = 3
	timer_text.connect("timeout",clean_text)
	timer_text.one_shot = true
	
	timer_reset_text = Timer.new()
	add_child(timer_reset_text)
	timer_reset_text.wait_time = 1
	timer_reset_text.connect("timeout", clean_reset_text)
	timer_reset_text.one_shot = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func shuffle_array(array: Array) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j = randi() % i+1
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp
 
func gen_array() -> Array:
	var temp:Array
	var result:Array
	var exclude_id_array = exclude_id.split(",", false)
	for i in range(min_id, max_id+1):
		temp.append(i)
	for j in exclude_id_array:
		temp.erase(int(j))
	print("生成学号数组：", temp)
	return temp
	
func gen_id(m_used_numbers: Array) -> void:
	if m_used_numbers.size() > 0:
		shuffle_array(m_used_numbers)
		var random_index = randi() % m_used_numbers.size()
		var random_number = m_used_numbers[random_index]
		m_used_numbers.remove_at(random_index)
		$Window/Label.text = str(random_number) + "号"
		$Label.text = "抽到学号" + str(random_number) + "号"
		print("抽到学号：", random_number)
		print("剩余学号：", m_used_numbers)
		print("剩余数组大小：", m_used_numbers.size())
	else:
		print("学号抽完了，无法继续抽取")

func sum_rand_number() -> void:
	if used_numbers.size() > 0:
		gen_id(used_numbers)
	else:
		print("学号抽完了，重新填充数组")
		reset_id_table()
		gen_id(used_numbers)

func reset_id_table() -> void:
	used_numbers.clear()
	used_numbers.append_array(numbers)
	
func close_window() -> void:
	$Window.visible = false
	timer.stop()

func _on_button_down() -> void:
	sum_rand_number()
	$Window.visible = true
	timer.start()
	timer_text.start()
	
func clean_text() -> void:
	timer_text.stop()
	$"Label".text = " "

func _on_reset_button_down() -> void:
	reset_id_table()
	print("重置按钮被点击")
	print("剩余学号：", used_numbers)
	print("剩余数组大小：", used_numbers.size())
	$Label.text = "  重置成功！"
	timer_reset_text.start()
	
func clean_reset_text() -> void:
	$Label.text = " "
	timer_reset_text.stop()

func _on_node_2d_data_changed(new_data: Variant, type: Variant) -> void:
	# 每次在设置中更改时都重置一下
	if type == "max_id":
		max_id = int(new_data)
	elif type == "min_id":
		min_id = int(new_data)
	elif type == "exclude_id":
		exclude_id = str(new_data)
	else:
		return
	if is_node2d_init:
		numbers = gen_array()
		reset_id_table()
		print("检测到学号设置被更改，重置列表")
		print(numbers)

func _on_node_2d_ready() -> void:
	is_node2d_init = true
	var parent = get_parent()
	max_id = parent.get_max_id()
	min_id = parent.get_min_id()
	exclude_id = parent.get_exclude_id()
	print("--------------------\n从父结点获取到学号信息：\n最大值：" + str(max_id) + "\n最小值：" + str(min_id) + "\n排除：" + str(exclude_id) + "\n--------------------")
	numbers = gen_array()
	reset_id_table()
	
