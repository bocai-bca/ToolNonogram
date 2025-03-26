extends Node2D
class_name NumberBar
## 数字栏。涵盖题目数字横行、竖列和工具图标的节点树枝

## 伪单例FakeSingleton
static var fs: NumberBar

@onready var n_frame_background_up: ColorRect = $FrameBackground_Up as ColorRect
@onready var n_frame_background_side: ColorRect = $FrameBackground_Side as ColorRect
@onready var n_icon_background: ColorRect = $IconBackground as ColorRect
@onready var n_icon: Sprite2D = $Icon as Sprite2D

## 边框宽度率，影响边框厚度的乘数...(需要补充
const FRAME_THICKNESS_RATE: float = 0.025 #此值代表边框(一条边)占据规定的空间的比率
# 此乘数应用于什么基数是一个有待选择的问题，有两种选择：
# 	1.基于图标大小，这样边框相对于图标是固定粗细的，但是如果图标缩小，那么边框会一起缩得很细
#	2.基于窗口大小，这样边框相对于窗口是固定粗细的，如果窗口分辨率太大的话，边框会一起变得很粗

## 工具图标大小，单位是一条边的长度。(涵盖边框)
static var icon_size: float = 270.0 #该值目前是硬编码数字，但它应该能改为其占据窗口的比率，正如侧边栏和图层栏一样

func _enter_tree() -> void:
	fs = self #定义伪单例

func _process(delta: float) -> void:
	position.x = LayersBar.bar_width #更新数字栏坐标使其贴靠到图层栏的右上角
	## 00更新工具图标和图标背景
	var frame_thickness: float = icon_size * FRAME_THICKNESS_RATE #此处起的边框粗细度计算需要斟酌，需要决定边框粗细使用什么方案计算
	n_icon_background.size = Vector2(icon_size - 2.0 * frame_thickness, icon_size - 2.0 * frame_thickness)
	n_icon_background.position = Vector2(frame_thickness, frame_thickness)
	# 此处接着写工具图标的变换
	## /00
