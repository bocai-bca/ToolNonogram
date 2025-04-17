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
## 按钮圆角半径乘数，基于视口纵向长度
const CORNER_RADIUS_MULTI: float = 30.0 / Main.WINDOW_SIZE_DEFAULT.y

## 按钮名称
var button_name: StringName
## 悬浮文本
var hover_tip_text: String
## 图标资源，用来在按钮添加到场景树之前为按钮指定纹理
var icon_texture: CompressedTexture2D

func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	button_down.connect(on_button_down)
	button_up.connect(on_button_up)
	n_icon.texture = icon_texture
	button_trigged.connect(Main.on_button_trigged, CONNECT_DEFERRED) #将本节点的按钮触发信号连接到Main.on_button_trigged()方法

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	custom_minimum_size.y = size.x #使按钮长宽比变为1:1
	n_icon.scale = Vector2(size.x / DEFAULT_SIZE.x, size.y / DEFAULT_SIZE.y) #计算图标的缩放变换，为按钮根节点的实际尺寸除以默认尺寸，该结果乘入图标的缩放中即可将图标缩放至按钮相当
	n_icon.position = Vector2(size.x / 2.0, size.y / 2.0)
	var style_boxes: Array[StyleBoxFlat] #创建一个列表用于存储StyleBox
	for style_box_name in theme.get_stylebox_list("Button"): #遍历Button类的所有StyleBox
		style_boxes.append(theme.get_stylebox(style_box_name, "Button") as StyleBoxFlat) #获取一个StyleBox并添加到列表中
	for style_box in style_boxes: #遍历所有获取到的StyleBox
		## 设置每个边角的圆角半径
		style_box.corner_radius_bottom_left = window_size.y * CORNER_RADIUS_MULTI
		style_box.corner_radius_bottom_right = style_box.corner_radius_bottom_left
		style_box.corner_radius_top_left = style_box.corner_radius_bottom_left
		style_box.corner_radius_top_right = style_box.corner_radius_bottom_left

## 检查自身是否需要禁用并更新禁用状态
func check_disable() -> void:
	disabled = Main.button_disable_check(button_name)

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
