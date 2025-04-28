extends PanelContainer
class_name DetailPopupBase
## 详细信息弹窗基类。一种一次性的弹窗

## 目前需要设计它的实例化方案，有两种选择：
## 	1.通过PackedScene资源生成固定的弹窗 √
## 	2.通过代码中的数组记录数据然后自己实现构造方法

## 与Main交互的设计理念：
## 	需尽可能设计为与Main的菜单数据存储进行托管，弹出菜单应当尽量减少数据交由自己管理的情况，同时需要在保证性能良好的情况下多与Main沟通

## 弹出菜单场景，通过弹出菜单名索引该字典可获得一个PackedScene，将该PackedScene实例化即可
const POPUP_MENU_SCENES: Dictionary[StringName, PackedScene] = {
	&"Menu_Paper_New": preload("res://contents/detail_popup/detail_popup_menu_paper_new.tscn"), #菜单.题纸.新建
}
## 弹出菜单的默认尺寸
const DEFAULT_SIZE: Vector2 = Vector2(1536.0, 864.0)
## 滑入滑出动画的缓动曲线值，参见ease()
const EASE_CURVE: float = 5.0
## 滑动动画时间，单位为秒
const FADE_TIME: float = 0.6
## 滑入动画时间，单位为秒，表示菜单从实例化到淡入完成所需的时间(0[100%] <=== this[0%])
#const FADEIN_TIME: float = 1.25
## 滑出动画时间，单位为秒，表示菜单从屏幕中间离开到屏幕外所需的时间(-1*this[100%] <=== 0[0%])
#const FADEOUT_TIME: float = FADEIN_TIME
## 滑入动画的落点位置Y乘数(相对于视口中心)，基于视口纵向长度
const FADEIN_POS_Y_MULTI: float = 0.0
## 滑出动画的落点位置Y乘数(相对于视口中心)，基于视口纵向长度
const FADEOUT_POS_Y_MULTI: float = -1.5
## 弹出菜单纵向最大长度乘数，基于视口纵向长度
const MAX_HEIGHT_MULTI: float = 0.8
## 弹出菜单横向最大长度乘数，基于视口横向长度
const MAX_WIDTH_MULTI: float = 0.8

## 本弹出菜单启用状态(简称存活态)，为true时一切正常运作，为false时菜单将会自主关闭并自毁
var alive: bool = true:
	get:
		return alive
	set(value):
		if (not value): #如果传入值为否
			disabled = true #使本菜单禁用
		alive = value
## 本弹出菜单禁用状态，为true时整个菜单的交互会被禁用，用于需要让用户等待而暂时阻止用户对菜单进行交互的时候，或者是菜单打开或关闭的期间。关于本属性的具体效果实现需要在子类中手动实现(可以搭配DisableBlocker)
var disabled: bool = false
## 本弹出菜单滑入滑出动画倒计时器，为0时菜单处于屏幕中央，其余状况时为absf(this)/FADE_TIME时处于画面最外部
var fade_timer: float = FADE_TIME
## 本弹出菜单的名称。目前该属性设计于被PopupManager的弹出菜单创建方法赋值
var popup_name: StringName 

## 当_ready()被子类重写时，需要在其内部加上相同内容
func _ready() -> void:
	## Prefix
	PopupManager.fs.close_popup.connect(check_close_signal) #将关闭弹出菜单信号连接到方法
	## /Prefix

## 当_process()被子类重写时，需要在其内部加上相同内容
func _process(delta: float) -> void:
	## Prefix
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	## /Prefix
	## Postfix
	var width_max_scale: float = MAX_WIDTH_MULTI * window_size.x / DEFAULT_SIZE.x #获取当前状况能使用的最大横向长度
	var height_max_scale: float = MAX_HEIGHT_MULTI * window_size.y / DEFAULT_SIZE.y #获取当前状况能使用的最大纵向长度
	scale = Vector2.ONE * minf(width_max_scale, height_max_scale) #选取最小的乘数应用于scale属性
	position = size * scale / -2.0 #将size与scale相乘得到其实际尺寸，除以-2得到其一半尺寸的负数，应用在坐标即使其居中在中心(0,0)位置
	var fade_y_multi: float #声明局部变量，表示动画过程中Y的偏移量乘数
	if (fade_timer >= 0.0): #如果滑动计时器大于等于0
		fade_y_multi = lerpf(FADEIN_POS_Y_MULTI, FADEOUT_POS_Y_MULTI, ease(fade_timer / FADE_TIME, EASE_CURVE)) #计算懒得讲自己看
	else: #否则(滑动计时器小于0)
		fade_y_multi = lerpf(FADEOUT_POS_Y_MULTI, FADEIN_POS_Y_MULTI, ease((FADE_TIME + fade_timer) / FADE_TIME, EASE_CURVE)) #计算懒得讲自己看，区别是进行了一个取反
	position.y += fade_y_multi * window_size.y #应用到Y
	update_timer(delta) #更新倒计时器
	update_free() #更新自主关闭
	## /Postfix

## 检查关闭信号。当受到关闭弹出菜单的信号的时候检查需要被关闭的菜单名，如果自身符合该名称则将自身的alive属性设为false
func check_close_signal(close_name: StringName) -> void:
	if (close_name == popup_name): #如果传入参数的关闭目标名称与自身名称相符
		alive = false #将自身的存活态设为false
		PopupManager.alive_popup_count -= 1 #在弹出菜单管理器中减去一个弹出菜单数

## 更新倒计时器，请在子类的_process()的开头调用此方法
func update_timer(delta: float) -> void:
	if (alive): #如果当前为存活态
		fade_timer = move_toward(fade_timer, 0.0, delta) #更新倒计时器
	else: #否则(当前不为存活态)
		fade_timer = move_toward(fade_timer, -FADE_TIME, delta) #更新倒计时器

## 更新自主关闭与销毁，请在子类的_process()的结尾调用此方法
func update_free() -> void:
	if (not alive and fade_timer == -FADE_TIME): #如果不是存活态且滑入滑出动画计时器已达到完全滑出状态
		queue_free() #标记清除

## [虚函数-声明]从Main类读取菜单状态并更新本实例的各项状态
func _read_data() -> void: pass

## [虚函数-声明]将本实例的各项状态保存到Main类的菜单状态
func _store_data() -> void: pass
