extends Node2D
class_name LayersBar
## 图层栏

## 标签分为一般LayerTab和LayerTabVoid(虚标签)，本来计划这些全都是动态的节点，即用即生成，但是想了想决定都静态使用
## 图层栏上涉及点击的全都是静止的LayerTabBase节点，剩下的都是和图层网格一块动的只负责视觉的标签节点

## 信号-图层标签被点击，附带一个表示被点击标签所属序号的参数
signal tab_clicked(index: int)

## 伪单例FakeSingleton
static var fs: LayersBar:
	get:
		if (fs == null): #如果fs为空
			push_error("LayersBar: 在试图获取fs时无法返回有效值，因为：解引用fs时返回null。")
			return null
		return fs

@onready var n_back_color: ColorRect = $BackColor as ColorRect
@onready var n_shadow: Sprite2D = $Shadow as Sprite2D
@onready var n_base_tab: LayerTab = $BaseLayerTab as LayerTab
@onready var n_void_tabs: Array[LayerTabVoid] = [
	$LayerTabVoid_1 as LayerTabVoid,
	$LayerTabVoid_2 as LayerTabVoid,
	$LayerTabVoid_3 as LayerTabVoid,
	$LayerTabVoid_4 as LayerTabVoid,
	$LayerTabVoid_5 as LayerTabVoid,
	$LayerTabVoid_6 as LayerTabVoid,
]

## 图层栏背景颜色，施加给n_back_color的color属性
const BAR_BACKGROUND_COLOR: Color = Color(0.5, 0.5, 0.5, 1.0)
## 图层栏阴影调制，施加给n_shadow的self_modulate属性
const BAR_SHADOW_MODULATE: Color = Color(0.0, 0.0, 0.0, 0.4)
## 图层栏宽度乘数，基于视口纵向长度
const BAR_WIDTH_MULTI: float = 1.0 / 8.0
## 阴影缩放X基值乘数，基于视口纵向长度。设定合适的值以影响阴影的横向宽度，除数为默认窗口高度，被除数为想要的默认X缩放倍率(基于所使用纹理的尺寸的X)
const SHADOW_SCALE_X_BASE_MULTI: float = 2.0 / 1080.0

## 图层栏横向宽度
static var bar_width: float = 135.0

func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	n_back_color.color = BAR_BACKGROUND_COLOR #设置图层栏背景颜色
	n_shadow.self_modulate = BAR_SHADOW_MODULATE #设置图层栏阴影的调制

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	## 00更新图层栏的大小
	bar_width = window_size.y * BAR_WIDTH_MULTI #计算图层栏的横向宽度
	n_back_color.size = Vector2(bar_width, window_size.y) #设置图层栏背景颜色矩形的大小
	n_shadow.scale = Vector2(SHADOW_SCALE_X_BASE_MULTI * window_size.y, window_size.y) #设置阴影的大小
	n_shadow.position = Vector2(bar_width - n_shadow.texture.get_size().x * n_shadow.scale.x / 2.0, window_size.y / 2.0) #设置阴影的位置
	## /00
	## 01更新虚标签
	for i in n_void_tabs.size(): #按索引遍历虚标签节点列表
		if (i < Main.focus_layer): #索引数+1=标签序号，如果索引数小于焦点图层序号，意味着当前虚标签为焦点或在焦点图层之下(即应当显示此虚标签对应的图层)
			n_void_tabs[i].modulate.a = move_toward(n_void_tabs[i].modulate.a, LayerTabVoid.ALPHA_HIDE, delta * LayerTabVoid.ALPHA_DIFF_SPEED) #更新alpha到隐藏值
		else: #否则(虚标签在焦点之上，即此虚标签对应的图层应当不显示，那么就需要显示虚标签)
			if (n_void_tabs[i].is_mouse_inside): #如果鼠标在该虚标签内
				n_void_tabs[i].modulate.a = move_toward(n_void_tabs[i].modulate.a, LayerTabVoid.ALPHA_HIGHLIGHT, delta * LayerTabVoid.ALPHA_DIFF_SPEED) #更新alpha到高亮值
			else: #否则(鼠标不在该虚标签内)
				n_void_tabs[i].modulate.a = move_toward(n_void_tabs[i].modulate.a, LayerTabVoid.ALPHA_NORMAL, delta * LayerTabVoid.ALPHA_DIFF_SPEED) #更新alpha到正常值
	## /01

## 类-图层颜色数据对象
class LayerColorDataObject:
	## 图层栏标签颜色(正常)
	var tab_color_normal: Color
	## 图层栏标签颜色(悬浮)
	var tab_color_hover: Color
	## 图层栏标签颜色(按下)
	var tab_color_pressed: Color
	## 网格线框颜色
	var grids_color: Color
	## 网格背景颜色
	var grids_background_color: Color
	func _init(new_tab_color_normal: Color, new_tab_color_hover: Color, new_tab_color_pressed: Color, new_grids_color: Color, new_grids_background_color: Color) -> void:
		tab_color_normal = new_tab_color_normal
		tab_color_hover = new_tab_color_hover
		tab_color_pressed = new_tab_color_pressed
		grids_color = new_grids_color
		grids_background_color = new_grids_background_color
