extends Button
class_name DetailNode_SingleButton
## 详细层节点-单按钮

## 信号-按钮触发。将在本按钮被左键点击触发以后发出信号，请由需监听的类主动连接本按钮实例的信号
signal button_trigged(button_name: StringName)

## 类的场景封包ClassPackedScene
static var cps: PackedScene:
	get:
		return preload("res://contents/detail_node_single_button/detail_node_single_button.tscn") as PackedScene

@onready var n_icon: Sprite2D = $Icon as Sprite2D

## 按钮名称
var button_name: StringName

func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	button_down.connect(on_button_down)
	button_up.connect(on_button_up)

func _process(delta: float) -> void:
	custom_minimum_size.y = size.x

static func create(new_button_name: StringName, new_texture: ) -> DetailNode_SingleButton:
	return null #####

#region 信号方法

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass

func on_button_down() -> void:
	pass

func on_button_up() -> void:
	if (is_hovered()):
		emit_signal(&"button_trigged", button_name)

#endregion
