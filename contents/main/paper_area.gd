extends Node2D
class_name PaperArea
## 题纸区域。用于组织和管理所有题纸显示层和处理输入

@onready var n_base_click: TextureButton = $BaseClick as TextureButton
@onready var n_base_grids: EditableGrids = $BaseGrids as EditableGrids
@onready var n_hover_grids: Array[EditableGrids] = [
	
]

static var click_state: ClickState

func _physics_process(delta: float) -> void:
	pass

## 类-点击状态
class ClickState:
	## 按下状态枚举
	enum PressState{
		RELEASE, #没在按下，不是刚松开
		JUST_RELEASED, #没在按下，且刚松开
		JUST_PRESSED, #按下状态，且刚按下
		PRESSING #按下状态，不是刚按下
	}
	## 题纸区域枚举
	enum AreaOfPaper{
		TOOL_ICON, #工具图标
		NUMBER_BAR_UP, #顶部数字栏
		NUMBER_BAR_SIDE, #侧边数字栏
		GRIDS #网格
	}
	## 按下状态
	var press_state: PressState = PressState.RELEASE
	## 按下时所处的题纸区域
	var pressed_at_area: AreaOfPaper
	## 当前所在的抽象坐标，基于按下时所处的题纸区域。如果是工具图标的话此值无效，如果是网格的话代表网格上的坐标，而数字栏的话还需要设计
	var current_pos: Vector2i
