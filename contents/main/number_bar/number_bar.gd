extends Node2D
class_name NumberBar
## 数字栏。涵盖题目数字横行、竖列和工具图标的节点树枝

## 由于决定采取全面使用TileMapLayer的计划，边框的厚度将由TileSet决定，之前的策略需要颠覆，以后需考虑从代码中删去FRAME_THICKNESS_RATE及其相关的计算

## 伪单例FakeSingleton
static var fs: NumberBar:
	get:
		if (fs == null): #如果fs为空
			push_error("NumberBar: 在试图获取fs时无法返回有效值，因为：解引用fs时返回null。")
			return null
		return fs

@onready var n_frame_background_up: ColorRect = $FrameBackground_Up as ColorRect
@onready var n_frame_background_side: ColorRect = $FrameBackground_Side as ColorRect
@onready var n_fill_background_up: ColorRect = $FillBackground_Up as ColorRect
@onready var n_fill_background_side: ColorRect = $FillBackground_Side as ColorRect
@onready var n_icon_fill_background: ColorRect = $IconFillBackground as ColorRect
@onready var n_icon: Sprite2D = $Icon as Sprite2D
@onready var n_number_grids_up: TileMapLayer = $NumberGrids_Up as TileMapLayer
@onready var n_number_grids_side: TileMapLayer = $NumberGrids_Side as TileMapLayer

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
## 工具图标的图标纹理显示节点n_icon相对于整个工具图标区域(含边框)的缩放比率
const ICON_DISPLAY_SCALE_RATE: float = 0.95
## 数字栏填充颜色，目前该颜色不会自动应用在节点上，是一个代码层面未被使用的常量
const NUMBER_BAR_FILL_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)

## 数字栏的宽度(纵向或横向)，也是工具图标大小，单位是一条边的长度(涵盖边框)。
static var bar_width: float = Main.WINDOW_SIZE_DEFAULT.y * ZOOM_RATE_DEFAULT
## 缩放率，表示工具图标占据窗口纵向长度的比率
static var zoom_rate: float = ZOOM_RATE_DEFAULT
static var icon_texture: Texture2D:
	get:
		if (fs != null && fs.n_icon != null): #防空引用
			return fs.n_icon.texture
		return null
	set(value):
		if (fs != null && fs.n_icon != null): #防空引用
			fs.n_icon.texture = value #给n_icon节点设置新纹理
			icon_texture_resolution = value.get_width() #将新纹理的横向长度保存到本类的静态成员icon_texture_resolution以作缓存使用
			return
		push_error("NumberBar: 已取消对属性\"icon_texture\"的设置，因为：解引用fs或fs.n_icon时返回null。")
## 工具图标纹理分辨率缓存，单位是X边的长度，当设置icon_texture时会被赋值。此处的初始赋值请手动根据n_icon(Sprite2D)的纹理的横向长度填写
static var icon_texture_resolution: float = 100.0

func _enter_tree() -> void:
	fs = self #定义伪单例

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口尺寸
	position.x = LayersBar.bar_width #更新数字栏坐标使其贴靠到图层栏的右上角
	## 00更新图标大小变量
	bar_width = window_size.y * zoom_rate #计算新的图标大小
	## /00
	## 01更新工具图标和图标背景
	var frame_thickness: float = bar_width * FRAME_THICKNESS_RATE #通过工具图标背景的边长和边框厚度乘数求一条边框的实际厚度
	n_icon_fill_background.size = (bar_width - 2.0 * frame_thickness) * Vector2.ONE #计算工具图标背景大小并应用
	n_icon_fill_background.position = frame_thickness * Vector2.ONE #根据工具图标背景的大小计算坐标并应用
	n_icon.scale = bar_width * ICON_DISPLAY_SCALE_RATE / icon_texture_resolution * Vector2.ONE #计算工具图标节点的缩放并应用
	n_icon.position = bar_width / 2.0 * Vector2.ONE
	## /01
	## 02更新边框背景和填充背景
	n_frame_background_up.size = Vector2(window_size.x - position.x, bar_width) #更新顶部边框背景的尺寸
	n_frame_background_side.size = Vector2(bar_width, window_size.y) #更新侧边边框背景的尺寸
	n_fill_background_up.position = Vector2(bar_width, frame_thickness) #更新顶部填充背景的坐标
	n_fill_background_up.size = Vector2(window_size.x - LayersBar.bar_width - bar_width, bar_width - 2.0 * frame_thickness) #更新顶部填充背景的尺寸
	n_fill_background_side.position = Vector2(frame_thickness, bar_width) #更新侧边填充背景的坐标
	n_fill_background_side.size = Vector2(bar_width - 2.0 * frame_thickness, window_size.y - bar_width) #更新侧边填充背景的尺寸
	## /02
	## 03更新砖瓦图
	n_number_grids_up.scale = (window_size.y - NumberBar.bar_width) / (EditableGrids.animate_now_zoom_blocks * Main.TILE_NORMAL_SIZE) *  Vector2.ONE #计算并应用顶部砖瓦图的缩放
	n_number_grids_up.position = Vector2(EditableGrids.animate_now_offset.x + bar_width, 0.0) #计算并应用顶部砖瓦图的位置
	n_number_grids_side.scale = n_number_grids_up.scale #直接拿来顶部砖瓦图的缩放用
	n_number_grids_side.position = Vector2(0.0, EditableGrids.animate_now_offset.x + bar_width) #计算并应用侧边砖瓦图的位置
	## /03
