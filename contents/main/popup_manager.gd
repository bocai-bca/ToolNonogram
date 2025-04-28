extends Node2D
class_name PopupManager
## 弹出菜单管理器。用于管理弹出菜单的创建和关闭、显示缩放、隔离背景

## 新建弹出菜单
#signal new_popup(popup_name: StringName)
## 关闭弹出菜单。需要由菜单实例订阅此信号，然后判断信号给定的菜单名称是否与自己相同
signal close_popup(popup_name: StringName)

## 伪单例FakeSingleton
static var fs: PopupManager:
	get:
		if (fs == null): #如果fs为空
			push_error("PopupManager: 在试图获取fs时无法返回有效值，因为：解引用fs时返回null。")
			return null
		return fs

@onready var n_back_color: ColorRect = $BackColor as ColorRect

## 背景颜色变化时间，与背景颜色的alpha关联
const BACK_COLOR_ALPHA_TIME: float = 0.6
## 背景颜色的最大alpha
const BACK_COLOR_ALPHA: float = 0.4

## [只读]各弹出菜单的场景资源，它们实例化后为不同的类型但均继承自DetailPopupBase
static var POPUPS_PACKED_SCENES: Dictionary[StringName, PackedScene] = {
	&"Paper_New": DetailPopupBase_Main_Paper_New.cps, #新建题纸
	&"About": DetailPopup_About.cps, #关于
}

## 当前运行中的所有菜单实例，用于遍历
#static var current_popups: Array[DetailPopupBase] = []
## 菜单数量计数，当菜单准备将自身移除时需要将此数减去1
static var alive_popup_count: int = 0
## 背景颜色变化计时器，与背景颜色的alpha关联，为0表示完全关闭背景颜色，为BACK_COLOR_ALPHA_TIME时表示完全开启背景颜色(alpha=BACK_COLOR_ALPHA)
static var back_color_alpha_timer: float = 0.0

func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	#new_popup.connect(on_new_popup) #new_popup信号连接方法
	pass

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口尺寸
	position = window_size / 2.0 #将自身居中到画面的一半
	n_back_color.position = position * -1.0 #移动背景颜色矩形的位置
	n_back_color.size = window_size #设置背景颜色矩形的尺寸
	if (alive_popup_count > 0): #如果菜单计数大于0，意味着当前有菜单激活
		back_color_alpha_timer = move_toward(back_color_alpha_timer, BACK_COLOR_ALPHA_TIME, delta) #更新背景颜色alpha计时器
		n_back_color.mouse_filter = Control.MOUSE_FILTER_STOP #开启背景鼠标阻塞
	else: #否则(菜单计数不大于0，意味着当前没有菜单激活)
		back_color_alpha_timer = move_toward(back_color_alpha_timer, 0.0, delta) #更新背景颜色alpha计时器
		n_back_color.mouse_filter = Control.MOUSE_FILTER_IGNORE #关闭背景鼠标阻塞
	n_back_color.color.a = lerpf(0.0, BACK_COLOR_ALPHA, back_color_alpha_timer / BACK_COLOR_ALPHA_TIME) #设置背景颜色alpha

## 添加弹出菜单实例，需传入一个由create_popup()构造的弹出菜单实例，本方法需要在fs可用时使用，否则会报错
## 需要注意的是，请勿重复以同一个节点作为参数调用此方法
static func add_popup(popup_node: DetailPopupBase) -> void:
	if (fs == null):
		push_error("PopupManager: 无法添加弹出菜单实例，因为：解引用fs时返回null。")
		return
	if (popup_node == null):
		push_error("PopupManager: 无法添加弹出菜单实例，因为：传入的参数\"popup_node\"为null。")
		return
	fs.add_child(popup_node) #添加为子节点
	alive_popup_count += 1 #增加1个弹出菜单数
	#current_popups.append(popup_node) #将该节点添加到数组

## 弹出菜单创建方法，调用此方法新建一个弹出菜单实例，但实例进入场景树等行为需要另外编写
static func create_popup(popup_name: StringName) -> DetailPopupBase:
	if (POPUPS_PACKED_SCENES.has(popup_name)): #如果场景资源字典包含给定的弹出菜单名称
		var popup: DetailPopupBase = POPUPS_PACKED_SCENES[popup_name].instantiate() as DetailPopupBase #实例化一个弹出菜单
		popup.popup_name = popup_name #设置弹出菜单的名称
		return popup #返回实例化的场景
	push_error("PopupManager: 在创建弹出菜单实例时被迫返回了null，因为：未能通过给定的弹出菜单名称在\"POPUPS_PACKED_SCENES\"中索引到结果。")
	return null
