extends Button
class_name DetailNode_MultiButtons_Member
## 详细层节点-多按钮成员

## 信号-按钮触发。将在本按钮被左键点击触发以后发出信号，请由需监听的类主动连接本按钮实例的信号
signal button_trigged(button_name: StringName)

## 类场景封包ClassPackedScene
static var cps: PackedScene = preload("res://contents/detail_node_multi_buttons/multi_buttons_member.tscn") as PackedScene

@onready var n_icon: Sprite2D = $Icon as Sprite2D

## 按钮名称
var button_name: StringName
## 悬浮提示文本
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

## 类场景实例化方法
static func create(new_button_name: StringName, new_texture: CompressedTexture2D, new_tip_text: String, styleboxes: Array[StyleBoxFlat]) -> DetailNode_MultiButtons_Member:
	var node: DetailNode_MultiButtons_Member = cps.instantiate()
	node.button_name = new_button_name
	node.icon_texture = new_texture
	node.hover_tip_text = new_tip_text
	node.add_theme_stylebox_override(&"normal", styleboxes[0])
	node.add_theme_stylebox_override(&"hover", styleboxes[1])
	node.add_theme_stylebox_override(&"pressed", styleboxes[2])
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
