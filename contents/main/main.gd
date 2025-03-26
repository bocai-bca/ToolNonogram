extends Node2D
class_name Main
## 主场景根类

## 伪单例FakeSingleton
static var fs: Main

@onready var n_back_color: ColorRect = $BackColor as ColorRect
@onready var n_base_grids: EditableGrids = $BaseGrids as EditableGrids

## 窗口最小尺寸
const WINDOW_SIZE_MINIMUM: Vector2i = Vector2i(960, 540)
## 窗口默认尺寸
const WINDOW_SIZE_DEFAULT: Vector2i = Vector2i(1920, 1080)
## 默认题纸上的工具图标占画面纵向宽度比率
const NUMBER_BAR_ICON_SIZE_RATE: float = 0.25

## 当前答题网格缩放格数，单位为格。代表当前画面长宽比下横向能显示多少列格子
static var grids_zoom_blocks: int = 5

func _enter_tree() -> void:
	fs = self #定义伪单例
	get_window().min_size = WINDOW_SIZE_MINIMUM #设置窗口最小尺寸

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	n_back_color.size = get_window().size
