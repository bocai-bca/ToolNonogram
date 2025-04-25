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

## [只读]各弹出菜单的场景资源，它们实例化后为不同的类型但均继承自DetailPopupBase
static var POPUPS_PACKED_SCENES: Dictionary[StringName, PackedScene] = {
	&"Paper_New": DetailPopupBase_Main_Paper_New.cps, #新建题纸
}

## 当前运行中的所有菜单实例，用于遍历
static var current_popups: Array[DetailPopupBase] = []

func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	#new_popup.connect(on_new_popup) #new_popup信号连接方法
	pass

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口尺寸
	position = window_size / 2.0 #将自身居中到画面的一半

## 弹出菜单创建方法，调用此方法新建一个弹出菜单实例，但实例进入场景树等行为需要另外编写
static func create_popup(popup_name: StringName) -> DetailPopupBase:
	if (POPUPS_PACKED_SCENES.has(popup_name)): #如果场景资源字典包含给定的弹出菜单名称
		return POPUPS_PACKED_SCENES[popup_name].instantiate() as DetailPopupBase #返回实例化的场景
	push_error("PopupManager: 在创建弹出菜单实例时被迫返回了null，因为：未能通过给定的弹出菜单名称在\"POPUPS_PACKED_SCENES\"中索引到结果。")
	return null
