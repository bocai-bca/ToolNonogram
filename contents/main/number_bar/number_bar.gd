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
@onready var n_number_array_displayer_up: NumberArrayDisplayer = $NumberArrayDisplayer_Up as NumberArrayDisplayer
@onready var n_number_array_displayer_side: NumberArrayDisplayer = $NumberArrayDisplayer_Side as NumberArrayDisplayer

## 边框宽度率，影响边框厚度的乘数，基数为工具图标的边长
const FRAME_THICKNESS_RATE: float = 0.05
# 此乘数应用于什么基数是一个有待选择的问题，有两种选择：(目前选择1)
# 	1.基于图标大小，这样边框相对于图标是固定粗细的，但是如果图标缩小，那么边框会一起缩得很细
#	2.基于窗口大小，这样边框相对于窗口是固定粗细的，如果窗口分辨率太大的话，边框会一起变得很粗
## 缩放率调整步长，使得调整一次缩放率能像调整一次网格一样具有固定的步长
const ZOOM_RATE_STEP_LENGTH: float = 0.1
## 默认缩放率
const ZOOM_RATE_DEFAULT: float = 0.3
## 缩放率边界值，用于限制避免缩放率超出合适范围，X表示最小值、Y表示最大值
const ZOOM_RATE_BOUND: Vector2 = Vector2(0.1, 0.5)
## 缩放率动画计时器时间
const ZOOM_RATE_ANIMATION_TIME: float = 0.25
## 缩放率动画插值缓动曲线值
const ZOOM_RATE_ANIMATION_EASE_CURVE: float = -2.0
## 工具图标的图标纹理显示节点n_icon相对于整个工具图标区域(含边框)的缩放比率
const ICON_DISPLAY_SCALE_RATE: float = 0.9
## 数字栏填充颜色，目前该颜色不会自动应用在节点上，是一个代码层面未被使用的常量
const NUMBER_BAR_FILL_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
## TileSet中用于顶部数字栏网格的图块在砖瓦图集中的索引坐标
const UP_GRIDS_ATLAS_COORDS: Vector2i = Vector2i(3, 0)
## TileSet中用于侧边数字栏网格的图块在砖瓦图集中的索引坐标
const SIDE_GRIDS_ATLAS_COORDS: Vector2i = Vector2i(0, 1)

## 数字栏的宽度(纵向或横向)，也是工具图标大小，单位是一条边的长度(涵盖边框)。
static var bar_width: float = Main.WINDOW_SIZE_DEFAULT.y * ZOOM_RATE_DEFAULT
## 缩放率实际值，表示工具图标占据窗口纵向长度的比率
static var zoom_rate: float = ZOOM_RATE_DEFAULT
## 缩放率动画倒计时器，为0即到达缩放率实际值
static var zoom_rate_animation_timer: float = 0.0
## 缩放率动画历史值
static var zoom_rate_last: float = zoom_rate
## [只读]缩放率动画当前值，由缩放率动画历史值和实际值通过
static var zoom_rate_now: float:
	get:
		return lerpf(zoom_rate, zoom_rate_last, ease(zoom_rate_animation_timer / ZOOM_RATE_ANIMATION_TIME, ZOOM_RATE_ANIMATION_EASE_CURVE))
## 图标纹理，即左上角的大图标显示的纹理，对本属性写入可直接修改该图标
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
	zoom_rate_animation_timer = move_toward(zoom_rate_animation_timer, 0.0, delta) #更新缩放率动画计时器
	## 00更新图标大小变量
	bar_width = window_size.y * zoom_rate_now #计算新的图标大小
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
	n_number_grids_up.position = Vector2(bar_width - EditableGrids.animate_now_offset.x, 0.0) #计算并应用顶部砖瓦图的位置
	n_number_grids_side.scale = n_number_grids_up.scale #直接拿来顶部砖瓦图的缩放用
	n_number_grids_side.position = Vector2(0.0, bar_width - EditableGrids.animate_now_offset.y) #计算并应用侧边砖瓦图的位置
	n_number_grids_up.scale.y = NumberBar.bar_width / (Main.TILE_NORMAL_SIZE) #将顶部数字栏网格的纵向缩放变换到刚好填充顶部数字栏的空间
	n_number_grids_side.scale.x = NumberBar.bar_width / (Main.TILE_NORMAL_SIZE) #将侧边数字栏网格的横向缩放变换到刚好填充侧边数字栏的空间
	## /03

## 放大工具图标
func icon_zoom_larger() -> void:
	var new_zoom_rate: float = zoom_rate + ZOOM_RATE_STEP_LENGTH #计算进行放大后的缩放率
	if (new_zoom_rate > ZOOM_RATE_BOUND.y): #如果新缩放率超出最大值边界
		return
	zoom_rate_last = zoom_rate_now #记录进行放大时的实际值
	zoom_rate = new_zoom_rate #更改缩放率
	zoom_rate_animation_timer = ZOOM_RATE_ANIMATION_TIME #重设缩放率动画计时器

## 缩小工具图标
func icon_zoom_smaller() -> void:
	var new_zoom_rate: float = zoom_rate - ZOOM_RATE_STEP_LENGTH #计算进行缩小后的缩放率
	if (new_zoom_rate < ZOOM_RATE_BOUND.x): #如果新缩放率超出最小值边界
		return
	zoom_rate_last = zoom_rate_now #记录进行缩小时的实际值
	zoom_rate = new_zoom_rate #更改缩放率
	zoom_rate_animation_timer = ZOOM_RATE_ANIMATION_TIME #重设缩放率动画计时器

## 设置数字栏的数字
func set_number_array_displayers(puzzle_data: PuzzleData) -> void:
	n_number_array_displayer_up.set_numbers(puzzle_data.horizontal) #将水平题目数据设置给顶部的数字阵列显示器
	n_number_array_displayer_side.set_numbers(puzzle_data.vertical) #将垂直题目数据设置给侧边的数字阵列显示器

## 重设数字栏网格尺寸(不影响显示内容，只影响网格)
func resize_grids(new_size: Vector2i) -> void:
	if (n_number_grids_up != null and n_number_grids_side != null): #如果俩节点都不为null
		n_number_grids_up.clear() #清除顶部数字栏网格
		n_number_grids_side.clear() #清除侧边数字栏网格
		for x in new_size.x:
			n_number_grids_up.set_cell(Vector2i(x, 0), 0, UP_GRIDS_ATLAS_COORDS) #设置格子
		for y in new_size.y:
			n_number_grids_side.set_cell(Vector2i(0, y), 0, SIDE_GRIDS_ATLAS_COORDS) #设置格子
		return
	push_error("NumberBar: 无法设置数字栏网格尺寸，因为：解引用n_number_grids_up和n_number_grids_side时其中至少一个返回了null。")
