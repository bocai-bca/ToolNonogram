extends Node2D
class_name SideBar
## 侧边栏。

## 伪单例FakeSingleton
static var fs: SideBar

@onready var n_bar_color: ColorRect = $BarColor as ColorRect
@onready var n_shadow: Sprite2D = $Shadow as Sprite2D
@onready var n_buttons: Array[SideButton] = [
	$SideButton_Misc as SideButton
]

## 侧边栏背景颜色，施加给n_bar_color的color属性
const BAR_COLOR_MODULATE: Color = Color(0.9, 0.9, 0.9, 1.0)
## 侧边栏阴影调制，施加给n_shadow的self_modulate属性
const BAR_SHADOW_MODULATE: Color = Color(0.0, 0.0, 0.0, 0.5)
## 侧边栏宽度乘数，基于视口纵向长度
const BAR_WIDTH_MULTI: float = 1.0 / 6.0
## 阴影缩放X基值乘数，基于视口纵向长度。设定合适的值以影响阴影的横向宽度，除数为默认窗口高度，被除数为想要的默认X缩放倍率(基于所使用纹理的尺寸的X)
const SHADOW_SCALE_X_BASE_MULTI: float = 2.0 / 1080.0
## 侧边栏顶部空隔乘数，基于视口纵向长度
const BAR_TOP_SPACE_MULTI: float = 0.2
## 侧边栏按钮默认纵向长度乘数，基于视口纵向长度
const BAR_BUTTON_HEIGHT_MULTI: float = 0.2
## 侧边栏按钮间隔乘数，基于视口纵向长度
const BAR_BUTTONS_SPACING_MULTI: float = 0.05
## 侧边栏底部空隔乘数，基于视口纵向长度
const BAR_BOTTOM_SPACE_MULTI: float = 0.1
## 按钮的横向长度占据侧边栏横向长度的百分比，用于控制按钮的大小
const BUTTON_WIDTH_OF_BAR_WIDTH_MULTI: float = 0.8

## 按钮的默认长度，该值必须通过读取按钮实例的TextureButton的size属性获取。默认只在本节点ready时读取一次
static var button_width_default: float
## 按钮的当前长度，相当于经过变换计算后的button_width_default
static var button_width: float
## 表示侧边栏横向长度的变量，对其他类型而言应当只读
static var bar_width: float = 180.0

func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	button_width_default = n_buttons[0].n_button.size.x #读取按钮实例的TextureButton的size属性
	n_bar_color.color = BAR_COLOR_MODULATE #设置侧边栏颜色矩形的颜色
	n_shadow.self_modulate = BAR_SHADOW_MODULATE #设置侧边栏阴影的调制

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	position = Vector2(window_size.x, window_size.y / 2.0) #将本节点的位置移动到窗口右侧中心
	## 00更新侧边栏位置和大小
	n_bar_color.size = Vector2(window_size.y * BAR_WIDTH_MULTI, window_size.y) #计算并应用侧边栏颜色矩形的新大小，使其保持固定长宽比
	bar_width = n_bar_color.size.x #将侧边栏颜色矩形的大小的X保存到本类型的成员变量中，以作缓存
	n_bar_color.position = Vector2(-n_bar_color.size.x, n_bar_color.size.y / -2.0) #计算并应用侧边栏颜色矩形的新位置，使其显示在画面右侧
	n_shadow.scale = Vector2(SHADOW_SCALE_X_BASE_MULTI * window_size.y, window_size.y) #计算并应用侧边栏阴影的新大小，使其保持固定长宽比
	n_shadow.position = Vector2(n_bar_color.position.x - n_shadow.texture.get_size().x * n_shadow.scale.x / 2.0, 0.0) #计算并应用侧边栏阴影的新位置，使其显示在画面右侧
	## /00
	## 01侧边按钮的缩放
	var button_resize_rate: float = BUTTON_WIDTH_OF_BAR_WIDTH_MULTI * bar_width / button_width_default #按钮缩放率，该值基于侧边栏的横向长度求出，然后将其乘入按钮的scale以使按钮缩放至期望的大小
	for n_button in n_buttons: #遍历所有按钮实例
		n_button.scale = Vector2.ONE * button_resize_rate #应用按钮缩放率到按钮实例
	## /01
	## 02侧边按钮的排列
	var y_offset: float = 0.0 #创建一个局部变量，表示最后一个已记录更新的按钮所在的位置的Y距离0.0的偏移量
	for i in n_buttons.size(): #以索引遍历所有按钮实例
		if (i >= n_buttons.size()): #如果当前索引超出按钮实例列表
			break #退出for
		n_buttons[i].position = Vector2(n_bar_color.position.x / 2.0, y_offset) #设置按钮的位置
		y_offset += button_width #给Y偏移量增加一个按钮的长度
		if (i != n_buttons.size() - 1): #如果当前不是最后一个按钮实例
			y_offset += BAR_BUTTONS_SPACING_MULTI * window_size.y #给Y偏移量增加一个按钮间隔空格的长度
	for n_button in n_buttons: #遍历所有按钮实例
		n_button.position.y -= y_offset / 2.0 #移动按钮实例的Y，使该按钮实例以全部按钮实例居中到侧边栏中心
	## /02
