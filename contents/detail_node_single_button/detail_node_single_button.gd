extends Button
class_name DetailNode_SingleButton
## 详细层节点-单按钮

## 本类中首次设计了create()方法，该方法适用于一个类绑定于一个场景的根节点时用来实例化该场景的静态方法，其接受的参数应当是尽量具象的、避免封装

## 信号-按钮触发。将在本按钮被左键点击触发以后发出信号，请由需监听的类主动连接本按钮实例的信号
signal button_trigged(button_name: StringName)

## 类场景封包ClassPackedScene
static var cps: PackedScene = preload("res://contents/detail_node_single_button/detail_node_single_button.tscn") as PackedScene

@onready var n_icon: Sprite2D = $Icon as Sprite2D

## 默认尺寸，需要根据根节点的size属性手动设置，用于图标的缩放计算
const DEFAULT_SIZE: Vector2 = Vector2(120.0, 120.0)

## 按钮名称
var button_name: StringName
var hover_tip_text: String
var icon_texture: CompressedTexture2D

func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	button_down.connect(on_button_down)
	button_up.connect(on_button_up)
	n_icon.texture = icon_texture

func _process(delta: float) -> void:
	custom_minimum_size.y = size.x
	n_icon.scale = Vector2(size.x / DEFAULT_SIZE.x, size.y / DEFAULT_SIZE.y)
	n_icon.position = Vector2(size.x / 2.0, size.y / 2.0)

## 类场景实例化方法
static func create(new_button_name: StringName, new_texture: CompressedTexture2D, new_tip_text: String) -> DetailNode_SingleButton:
	var node: DetailNode_SingleButton = cps.instantiate()
	node.button_name = new_button_name
	node.icon_texture = new_texture
	node.hover_tip_text = new_tip_text
	return node

#region 信号方法

func on_mouse_entered() -> void:
	SideBar.should_show_tip_text = true #给SideBar开启提示文本显示
	SideBar.tip_text = hover_tip_text #给SideBar设置提示文本为本按钮的悬浮提示文本

func on_mouse_exited() -> void:
	if (SideBar.tip_text == hover_tip_text): #如果SideBar此时的提示文本是本按钮的
		SideBar.should_show_tip_text = false #关闭SideBar的提示文本显示

func on_button_down() -> void:
	pass

func on_button_up() -> void:
	if (is_hovered()):
		emit_signal(&"button_trigged", button_name)

#endregion
