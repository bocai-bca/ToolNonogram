extends LayerTabBase
class_name LayerTabVoid
## 图层虚标签。显示在图层栏上的标签(未显示的图层的标签)，用于点击切换图层

@onready var n_panel: Panel = $Panel as Panel
@onready var n_text: Label = $Text as Label
@onready var n_button: TextureButton = $Button as TextureButton

## 默认边框厚度
const DEFAULT_BORDER_WIDTH: int = 10
## 变更alpha的速度，单位为秒
const ALPHA_DIFF_SPEED: float = 2.0
## alpha值-不显示
const ALPHA_HIDE: float = 0.0
## alpha值-通常
const ALPHA_NORMAL: float = 0.7
## alpha值-高亮
const ALPHA_HIGHLIGHT: float = 1.0

## 面板的StyleBox资源
static var r_panel_stylebox: StyleBoxFlat = preload("res://contents/layer_tab_void/panel_stylebox.tres") as StyleBoxFlat
## 序号
@export var index: int
## 当前鼠标指针是否在内
var is_mouse_inside: bool = false

func _ready() -> void:
	n_button.button_down.connect(on_button_down)
	n_button.mouse_entered.connect(on_mouse_entered)
	n_button.mouse_exited.connect(on_mouse_exited)
	n_text.text = str(index)

## 信号方法-按钮被按下
func on_button_down() -> void:
	pass

## 信号方法-鼠标进入
func on_mouse_entered() -> void:
	is_mouse_inside = true #标记为鼠标在内部

## 信号方法-鼠标离开
func on_mouse_exited() -> void:
	is_mouse_inside = false #标记为鼠标不在内部
