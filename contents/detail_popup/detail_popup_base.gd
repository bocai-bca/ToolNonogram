extends PanelContainer
class_name DetailPopupBase
## 详细信息弹窗基类。一种一次性的弹窗

## 目前需要设计它的实例化方案，有两种选择：
## 	1.通过PackedScene资源生成固定的弹窗 √
## 	2.通过代码中的数组记录数据然后自己实现构造方法

## 弹出菜单场景，通过弹出菜单名索引该字典可获得一个PackedScene，将该PackedScene实例化即可
const POPUP_MENU_SCENES: Dictionary[StringName, PackedScene] = {
	&"Menu_Paper_New": preload("res://contents/detail_popup/detail_popup_menu_paper_new.tscn"), #菜单.题纸.新建
}
## 滑入动画时间，单位为秒，表示菜单从实例化到淡入完成所需的时间(0[100%] <=== this[0%])
const FADEIN_TIME: float = 1.25
## 滑出动画时间，单位为秒，表示菜单从屏幕中间离开到屏幕外所需的时间(-1*this[100%] <=== 0[0%])
const FADEOUT_TIME: float = FADEIN_TIME

## 本弹出菜单启用状态(简称存活态)，为true时一切正常运作，为false时菜单将会自主关闭并自毁
var alive: bool = true:
	get:
		return alive
	set(value):
		if (not value): #如果传入值为否
			disabled = true #使本菜单禁用
		alive = value
## 本弹出菜单禁用状态，为true时整个菜单的交互会被禁用，用于需要让用户等待而暂时阻止用户对菜单进行交互的时候，或者是菜单打开或关闭的期间。关于本属性的具体效果实现需要在子类中手动实现
var disabled: bool = false
## 本弹出菜单滑入滑出动画倒计时器，为0时表示菜单完全从屏幕外移动至中央位置
var fade_timer: float = FADEIN_TIME
## 本弹出菜单的名称。目前需要设计该值由谁赋予
var popup_name: StringName 

## 更新倒计时器，请在子类的_process()的开头调用此方法
func update_timer(delta: float) -> void:
	if (alive): #如果当前为存活态
		fade_timer = move_toward(fade_timer, 0.0, delta) #更新倒计时器
	else: #否则(当前不为存活态)
		fade_timer = move_toward(fade_timer, -FADEOUT_TIME, delta) #更新倒计时器

## 更新自主关闭与销毁，请在子类的_process()的结尾调用此方法
func update_free() -> void:
	if (not alive and fade_timer == -FADEOUT_TIME): #如果不是存活态且滑入滑出动画计时器已达到完全滑出状态
		queue_free() #标记清除

## 获取经过缓动曲线修饰的当前滑入滑出动画位置百分比插值(0.0[屏幕中心] - 1.0[屏幕外])
func get_fade_weight() -> float:
	if (fade_timer >= 0.0): #如果倒计时器值是大于等于0的
		return fade_timer / FADEIN_TIME #返回以滑入时间为标准的结果
	else: #否则(倒计时器的值是小于0的)
		return -1.0 * fade_timer / FADEOUT_TIME #返回以滑出时间为标准的结果

## [虚函数-声明]从Main类读取菜单状态并更新本实例的各项状态
func _read_data() -> void: pass

## [虚函数-声明]将本实例的各项状态保存到Main类的菜单状态
func _store_data() -> void: pass
