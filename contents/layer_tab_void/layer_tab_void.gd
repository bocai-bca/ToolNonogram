extends Node2D
class_name LayerTabVoid
## 图层虚标签。显示在图层栏上的标签(未显示的图层的标签)，用于点击切换图层

@onready var n_panel: Panel = $Panel as Panel
@onready var n_text: Label = $Text as Label
@onready var n_button: TextureButton = $Button as TextureButton

## 默认字体大小，需要手动根据主题中填写的值设置
const DEFAULT_FONT_SIZE: int = 135
## 默认圆角半径
const DEFAULT_CORNER_RADIUS: int = 30
## 默认边框厚度
const DEFAULT_BORDER_WIDTH: int = 10

## 面板的StyleBox资源
static var r_panel_stylebox: StyleBoxFlat = preload("res://contents/layer_tab_void/panel_stylebox.tres") as StyleBoxFlat

func _ready() -> void:
	n_button.button_down.connect(on_button_down)

## 信号方法-按钮被按下
func on_button_down() -> void:
	pass
