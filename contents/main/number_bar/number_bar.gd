extends Node2D
class_name NumberBar
## 数字栏。涵盖题目数字横行、竖列和工具图标的节点树枝

## 目前有一个争议，就是图标的缩放方法、边框的缩放方法。边框目前打算跟随网格的缩放，使得全局的边框统一。图标打算也像网格一样保存一个变量记录缩放率，然后跟随窗口的变化一起变化
## 对于接下来的修改，只需要改一下边框厚度乘数这个量的取值方式即可，其他计算全都依靠该变量

## 边框的厚度接下来可能完全取决于砖瓦的边框，请思考如何控制砖瓦边框的厚度

## 伪单例FakeSingleton
static var fs: NumberBar

@onready var n_frame_background_up: ColorRect = $FrameBackground_Up as ColorRect
@onready var n_frame_background_side: ColorRect = $FrameBackground_Side as ColorRect
@onready var n_fill_background_up: ColorRect = $FillBackground_Up as ColorRect
@onready var n_fill_background_side: ColorRect = $FillBackground_Side as ColorRect
@onready var n_icon_fill_background: ColorRect = $IconFillBackground as ColorRect
@onready var n_icon: Sprite2D = $Icon as Sprite2D

## 边框宽度率，影响边框厚度的乘数，基数为工具图标的边长
const FRAME_THICKNESS_RATE: float = 0.025
# 此乘数应用于什么基数是一个有待选择的问题，有两种选择：(目前选择1)
# 	1.基于图标大小，这样边框相对于图标是固定粗细的，但是如果图标缩小，那么边框会一起缩得很细
#	2.基于窗口大小，这样边框相对于窗口是固定粗细的，如果窗口分辨率太大的话，边框会一起变得很粗
## 缩放率调整步长，使得调整一次缩放率能像调整一次网格一样具有固定的步长
const ZOOM_RATE_STEP_LENGTH: float = 0.1
## 默认缩放率
const ZOOM_RATE_DEFAULT: float = 0.2
## 缩放率边界值，用于限制避免缩放率超出合适范围，X表示最小值、Y表示最大值
const ZOOM_RATE_BOUND: Vector2 = Vector2(0.1, 0.4)

## 工具图标大小，单位是一条边的长度(涵盖边框)。
static var icon_size: float = Main.WINDOW_SIZE_DEFAULT.y * ZOOM_RATE_DEFAULT
## 缩放率，表示工具图标占据窗口纵向长度的比率
static var zoom_rate: float = ZOOM_RATE_DEFAULT

func _enter_tree() -> void:
	fs = self #定义伪单例

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口尺寸
	position.x = LayersBar.bar_width #更新数字栏坐标使其贴靠到图层栏的右上角
	## 00更新图标大小变量
	icon_size = window_size.y * zoom_rate #计算新的图标大小
	## /00
	## 01更新工具图标和图标背景
	var frame_thickness: float = icon_size * FRAME_THICKNESS_RATE #通过工具图标背景的边长和边框厚度乘数求一条边框的实际厚度
	n_icon_fill_background.size = Vector2(icon_size - 2.0 * frame_thickness, icon_size - 2.0 * frame_thickness) #计算工具图标背景大小并应用
	n_icon_fill_background.position = Vector2(frame_thickness, frame_thickness) #根据工具图标背景的大小计算坐标并引用
	# 此处接着写工具图标的变换
	## /01
	## 02更新边框背景和填充背景
	n_frame_background_up.size = Vector2(window_size.x - position.x, icon_size) #更新顶部边框背景的尺寸
	n_frame_background_side.size = Vector2(icon_size, window_size.y) #更新侧边边框背景的尺寸
	n_fill_background_up.position = Vector2(window_size.y + frame_thickness, frame_thickness) #更新顶部填充背景的坐标
	n_fill_background_up.size = Vector2(clampf(window_size.x - frame_thickness - window_size.y - LayersBar.bar_width, 0.0, window_size.x), icon_size - 2.0 * frame_thickness) #更新顶部填充背景的尺寸
	#n_fill_background_side.position = Vector2() #更新侧边填充背景的坐标
	## /02
