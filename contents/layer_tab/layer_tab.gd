extends Node2D
class_name LayerTab
## 图层标签。显示在图层栏上的标签，用于点击切换图层

@onready var n_panel: Panel = $Panel as Panel
@onready var n_number: Label = $Number as Label

## 默认字体大小，需要手动根据主题中填写的值设置
const DEFAULT_FONT_SIZE: int = 64
## 默认圆角半径
const DEFAULT_CORNER_RADIUS: int = 30

static var panel_stylebox: StyleBoxFlat = preload("res://contents/layer_tab/panel_stylebox.tres") as StyleBoxFlat

## 序号，零始制。同时影响该实例在Y上的位置
var index: int:
	set(value):
		if (n_number == null):
			push_error("LayerTab: 取消了对属性\"index\"的设置行为，因为：解引用n_number时返回null。")
			return
		index = value
		n_number.text = str(index)

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	## 00更新面板
	n_panel.size = Vector2(LayersBar.bar_width, window_size.y / LayersBar.MAX_TAB_COUNT) #设置尺寸
	panel_stylebox.corner_radius_top_left = int(DEFAULT_CORNER_RADIUS * window_size.y / Main.WINDOW_SIZE_DEFAULT.y) #设置左上角圆角半径
	panel_stylebox.corner_radius_bottom_left = panel_stylebox.corner_radius_top_left #设置左下角圆角半径
	## /00
	## 01更新数字
	n_number.add_theme_font_size_override(&"font_size", DEFAULT_FONT_SIZE * window_size.y / Main.WINDOW_SIZE_DEFAULT.y) #更新字体大小
	n_number.size = Vector2.ZERO #重设尺寸到最小
	n_number.position = (n_panel.size - n_number.size) / 2.0 #更新位置
	## /01
