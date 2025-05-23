extends Node2D
class_name SideButton
## 侧边栏按钮。

## 现在要研究的是如何给侧边按钮定义一套可用和不可用系统，使其优雅地在不可用时不可见、不可交互

## 信号-按钮触发。将在本按钮被左键点击触发以后发出信号，请由需监听的类主动连接本按钮实例的信号
signal button_trigged(button_name: StringName)

@onready var n_panel: Panel = $Panel as Panel
@onready var n_icon: Sprite2D = $Icon as Sprite2D
@onready var n_button: TextureButton = $Button as TextureButton

## 出厂默认大小，适用于100*100的图标尺寸
const DEFAULT_HIT_RECT: Rect2 = Rect2(-60.0, -60.0, 120.0, 120.0)
## 按钮体的调制(正常)，施加给n_body
const BUTTON_BODY_MODULATE: Color = Color(0.8, 0.8, 0.8, 1.0)
## 按钮体的调制(悬浮)，施加给n_body
const BUTTON_BODY_MODULATE_HOVER: Color = Color(0.7, 0.7, 0.7, 1.0)
## 按钮体的调制(按下)，施加给n_body
const BUTTON_BODY_MODULATE_CLICK: Color = Color(0.6, 0.6, 0.6, 1.0)
## 按钮图标的调制(正常)，施加给n_icon
const BUTTON_ICON_MODULATE: Color = Color(0.0, 0.0, 0.0, 1.0)

## 按钮名称，充当按钮的标识符的StringName，将在按钮被触发时跟随信号一并发出
@export var button_name: StringName
## 悬浮提示文本，当本按钮被鼠标悬浮时将显示在提示文本的文本
@export_multiline var hover_tip_text: String
## 判定框，对其赋值将影响本SideButton实例的视觉大小和按钮大小
var hit_rect: Rect2:
	get:
		return hit_rect
	set(value):
		if (not is_node_ready()): #如果节点还没ready
			## 00报错并不进行操作
			push_error("SideButton: 已取消对属性\"hit_rect\"的设置，因为：根节点尚未就绪。")
			return
			## /00
		n_button.size = value.size
		n_button.position = value.position
		n_panel.size = value.size.x * Vector2.ONE
## 按下状态，表示本按钮当前是否是被按下的状态
var is_down: bool = false
## 可用性，为false时按钮不可点击也不可见
var is_enable: bool:
	get:
		return is_enable
	set(value):
		if (n_button == null):
			push_error("SideButton: 已取消对属性\"is_enable\"的设置，因为：解引用n_button时返回null。")
			return
		n_button.disabled = not value
		if (not value):
			on_mouse_exited()
			visible = false
		else:
			visible = true

func _ready() -> void:
	n_button.mouse_entered.connect(on_mouse_entered)
	n_button.mouse_exited.connect(on_mouse_exited)
	n_button.button_down.connect(on_button_down)
	n_button.button_up.connect(on_button_up)
	hit_rect = DEFAULT_HIT_RECT
	button_trigged.connect(Main.on_button_trigged, CONNECT_DEFERRED) #将本节点的按钮触发信号连接到Main.on_button_trigged()方法
	is_enable = true

#region 信号方法
func on_mouse_entered() -> void:
	SideBar.should_show_tip_text = true #给SideBar开启提示文本显示
	SideBar.tip_text = hover_tip_text #给SideBar设置提示文本为本按钮的悬浮提示文本
	if (not is_down):
		n_panel.self_modulate = BUTTON_BODY_MODULATE_HOVER
	else:
		n_panel.self_modulate = BUTTON_BODY_MODULATE_CLICK
		pass

func on_mouse_exited() -> void:
	if (SideBar.tip_text == hover_tip_text): #如果SideBar此时的提示文本是本按钮的
		SideBar.should_show_tip_text = false #关闭SideBar的提示文本显示
	n_panel.self_modulate = BUTTON_BODY_MODULATE

func on_button_down() -> void:
	is_down = true
	n_panel.self_modulate = BUTTON_BODY_MODULATE_CLICK

func on_button_up() -> void:
	is_down = false
	if (n_button.is_hovered()):
		n_panel.self_modulate = BUTTON_BODY_MODULATE_HOVER
		emit_signal("button_trigged", button_name) #发出信号，广播本按钮被触发
	else:
		n_panel.self_modulate = BUTTON_BODY_MODULATE
#endregion
