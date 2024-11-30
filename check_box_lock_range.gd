extends CheckBox

var parent
var is_lock_id_range: bool
var is_init: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_init = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func is_check_box_init() -> bool:
	return is_init
	
func _on_node_2d_ready() -> void:
	parent = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	is_lock_id_range = parent.get_is_lock_id_range()
	
	get_node(".").button_pressed = is_lock_id_range
	
	is_init = true
