extends Node2D
class_name EditableGrids
## 游戏版面可编辑网格。用于显示和容纳版面网格和棋子的类

@onready var n_back_color: ColorRect = $BackColor as ColorRect
## 网格层，用于显示答题网格的网格本身的层
@onready var n_grid_map: TileMapLayer = $GridMap as TileMapLayer
## 修改层，用于显示玩家可以修改填充内容的填充层
@onready var n_edit_map: TileMapLayer = $EditMap as TileMapLayer

enum FillType{
	EMPTY, #空格
	FILL, #实心块
	CROSS, #叉叉
}

## 偏移量动画和缩放动画的动画播放速度，以偏移量动画举例即从实际动画偏移量从动画起始偏移量过度到终点显示偏移量所需的时间
const ANIMATION_TIME: float = 0.25
## 偏移量动画和缩放动画的插值缓动曲线
const ANIMATION_EASE: float = -2.0
## 基底网格的背景颜色
const BASE_GRIDS_BACK_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
## 悬浮网格的背景颜色
const HOVER_GRIDS_BACK_COLOR: Color = Color(1.0, 1.0, 1.0, 0.5)
## 图层翻动效果时间
const LAYER_FLIP_TIME: float = 0.6
## 图层翻动效果缓动曲线值
const LAYER_FLIP_EASE_CURVE: float = 5.0

## 显示偏移量(网格的整数坐标移动偏移量)，表示当前画面中最左上角的格子应当是网格中的哪个坐标的格子
static var display_offset: Vector2i = Vector2i(0, 0)
## 实际动画偏移量(节点的浮点数坐标偏移量)，相当于以浮点数表示的display_offset，与节点的坐标挂钩最紧密的坐标
#static var animate_display_offset: Vector2 = Vector2(0.0, 0.0)
## 动画起始偏移量(节点的浮点数坐标偏移量的缓动起始值)，用于计算节点的实际坐标
static var animate_start_offset: Vector2 = Vector2(0.0, 0.0)
## [只读]动画终点偏移量(节点的浮点数坐标偏移量的缓动终点值)，用于计算节点的实际坐标
static var animate_end_offset: Vector2:
	get:
		return display_offset * Main.TILE_NORMAL_SIZE * global_scale_rate
## [只读]偏移量动画的当前插值，用于计算节点的实际坐标
static var animate_now_offset: Vector2:
	get:
		return animate_end_offset.lerp(animate_start_offset, ease(PaperArea.grids_animation_timer / ANIMATION_TIME, ANIMATION_EASE))
## 动画起始缩放格子数(格子显示数的缓动起始值)，用于计算节点的实际缩放率。终点是Main.grids_zoom_blocks
static var animate_start_zoom_blocks: float = 5.0
## [只读]缩放格子数动画的当前插值，用于计算节点的实际缩放率
static var animate_now_zoom_blocks: float:
	get:
		return lerpf(float(Main.grids_zoom_blocks), animate_start_zoom_blocks, ease(PaperArea.grids_animation_timer / ANIMATION_TIME, ANIMATION_EASE))
#static var animation_timer: float = 0.0 #交由PaperArea处理，请访问PaperArea.grids_animation_timer
## 全局网格尺寸
static var global_grid_size: Vector2i = Vector2i(5, 5) #网格实例的节点的初始尺寸是5*5
## 全局缩放率
static var global_scale_rate: float = 1.0
## 是否是基底网格
@export var is_base_grids: bool
## 本地网格尺寸，表示本EditableGrids实例中TileMapLayer节点所显示的网格尺寸，用于调整大小时读写
var local_grid_size: Vector2i = Vector2i(5, 5)
## 当前网格所隶属于的图层是否显示，控制图层翻动效果的目的地
var is_layer_show: bool = false:
	set(value):
		is_layer_show = value
		layer_flip_timer = LAYER_FLIP_TIME
## 图层翻动效果动画倒计时器
var layer_flip_timer: float = 0.0

func _ready() -> void:
	## 00设置颜色
	if (is_base_grids): #如果是基底网格
		n_back_color.color = BASE_GRIDS_BACK_COLOR #将背景颜色设为基底网格
	else:
		n_back_color.color = HOVER_GRIDS_BACK_COLOR #将背景颜色设为悬浮网格
	## /00

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	layer_flip_timer = move_toward(layer_flip_timer, 0.0, delta) #更新翻页计时器
	## 00更新网格的变换
	global_scale_rate = PaperArea.grids_free_height / (animate_now_zoom_blocks * Main.TILE_NORMAL_SIZE) #计算全局缩放率
	scale = global_scale_rate * Vector2.ONE #计算缩放的值
	var pos_show: Vector2 = Vector2(NumberBar.bar_width, NumberBar.bar_width) - animate_now_offset #计算图层显示时的坐标
	var pos_hide: Vector2 = Vector2(pos_show.x, pos_show.y - window_size.y) #计算图层隐藏时的坐标
	if (is_layer_show): #如果本图层显示
		position = pos_show.lerp(pos_hide, ease(layer_flip_timer / LAYER_FLIP_TIME, LAYER_FLIP_EASE_CURVE)) #应用插值后的坐标
	else: #否则(如果本图层不显示)
		position = pos_hide.lerp(pos_show, ease(layer_flip_timer / LAYER_FLIP_TIME, LAYER_FLIP_EASE_CURVE)) #应用插值后的坐标
	## /00
	## 01更新背景
	n_back_color.size = local_grid_size * Main.TILE_NORMAL_SIZE #更新背景颜色矩形的尺寸为视口尺寸
	#n_back_color.position = Vector2(-position.x / scale.x, -position.y / scale.y + window_size.y - n_back_color.size.y) #将本类根节点的坐标的相反数赋给背景颜色矩形的坐标，达到使其坐标恒定处于一个原点的作用
	## /01

## 获取鼠标指针处于的格子坐标(原点为0,0)
func get_mouse_pos() -> Vector2i:
	return n_grid_map.local_to_map(get_local_mouse_position())

## 对一个格子进行写入(擦除有专门的方法，不能用这个擦除)，不含非法坐标检测。本方法是临时测试用的，以后需要重写
func write_slot(pos: Vector2i, fill_type: FillType) -> void:
	n_edit_map.set_cell(pos, 0, fill_type_to_atlas_coords(fill_type))

## 对一个格子进行擦除，不含非法坐标检测。本方法是临时测试用的，以后可能需要重写
func clear_slot(pos: Vector2i) -> void:
	n_edit_map.erase_cell(pos)

## 进行凌驾于动画之上的网格实际偏移量更新，使用拖手工具拖拽网格时需每帧调用此方法。参数请传入一个鼠标于一帧内在屏幕上坐标的移动量
static func update_offset_on_grabbing(offset_delta: Vector2) -> void:
	animate_start_offset += offset_delta #将本次的偏移量加进动画起始移动量
	var start_offset_clamped: Vector2 = Vector2(
		clampf(animate_start_offset.x, 0.0, (EditableGrids.global_grid_size.x - 1) * Main.TILE_NORMAL_SIZE * global_scale_rate),
		clampf(animate_start_offset.y, 0.0, (EditableGrids.global_grid_size.y - 1) * Main.TILE_NORMAL_SIZE * global_scale_rate)
	) #钳制坐标，防止超出左上角屏幕范围
	display_offset = Vector2i((start_offset_clamped / Main.TILE_NORMAL_SIZE / global_scale_rate).round()) #将动画起始偏移量除以砖瓦大小和全局缩放率后取整
	animate_start_zoom_blocks = animate_now_zoom_blocks #将起始缩放格子数设为当前的缩放格子数

## 更新动画数据，调用此方法来设定新的动画缓动目标值，包含网格的缩放和偏移量，设置动画的新目标值会重置动画计时器，因此请勿尽可能降低调用此方法的频率
static func update_animation_data(new_display_offset: Vector2i, new_zoom_blocks: int) -> void:
	animate_start_offset = animate_now_offset #将起始偏移量设为当前的实际偏移量
	display_offset = new_display_offset #设置新的目标偏移量
	animate_start_zoom_blocks = animate_now_zoom_blocks #将起始缩放格子数设为当前的缩放格子数
	Main.grids_zoom_blocks = new_zoom_blocks #设置新的缩放格子数
	PaperArea.grids_animation_timer = ANIMATION_TIME #重设动画计时器

## 给定一个格子填充类型，返回一个图集中对应砖瓦的二维向量索引
## 与atlas_coords_to_fill_type()互为反方法
static func fill_type_to_atlas_coords(fill_type: FillType) -> Vector2i:
	match (fill_type): #匹配填充类型
		FillType.EMPTY: #空格
			return Vector2i(-1, -1)
		FillType.FILL: #实心块
			return Vector2i(1, 1)
		FillType.CROSS: #叉叉
			return Vector2i(2, 1)
	return Vector2i(0, 0)

## 给定一个具体中对应砖瓦的二维向量索引，返回一个格子填充类型。若给定的二维向量无效，则返回0
## fill_type_to_atlas_coords()互为反方法
static func atlas_coords_to_fill_type(coords: Vector2i) -> FillType:
	match (coords): #匹配二维向量索引
		Vector2i(-1, -1): #空格
			return FillType.EMPTY
		Vector2i(1, 1): #实心块
			return FillType.FILL
		Vector2i(2, 1): #叉叉
			return FillType.CROSS
	return 0

## 检测给定的整数坐标是否在网格内，或者说是否是个在当前网格尺寸中有效的格子坐标
static func is_pos_in_grid(pos: Vector2i) -> bool:
	if (pos.x < 0 or pos.y < 0): #如果坐标任一值小于0
		return false #返回否
	if (pos.x >= global_grid_size.x or pos.y >= global_grid_size.y): #如果坐标任一值大于其对应的尺寸的值
		return false #返回否
	return true #返回是

## 重新设置本地网格尺寸，也就是格子数(未来会写显示不同内容的砖瓦图节点，那些节点不受本函数影响，本函数应当只负责改变背景(GridMap)的大小
func resize_local_grids(new_size: Vector2i) -> void:
	#### 以后需要写一个在更改大小时会删除新尺寸范围外的内容地图的内容的功能
	if (n_grid_map == null):
		push_error("EditableGrids: 在执行方法\"resize_local_grids\"时被迫提前返回，因为：解引用n_grid_map时返回null。")
		return
	n_grid_map.clear() #清除背景网格地图
	for x in new_size.x: #遍历X
		for y in new_size.y: #遍历Y
			n_grid_map.set_cell(Vector2i(x, y), 0, Vector2i(2, 0)) #

## 转换到GridsData，用于检测答题网格是否通关。转换时需要按GridsData.SlotType存储格子信息，而不是本类的FillType
## 本方法今后可以考虑废弃重写，因为现在EditableGrids类不会自己存便于读取的局面数据，需要从TileMapLayer节点里还原格子的数据，这个过程是费劲的
func to_grids_data() -> GridsData:
	var result: GridsData = GridsData.new(global_grid_size) #新建一个GridsData实例，用于寄存和返回结果
	for x in global_grid_size.x: #遍历全局尺寸的X
		for y in global_grid_size.y: #遍历全局尺寸的Y
			result.set_slot( #给result的特定格子设置数据
				Vector2i(x, y), #将要操作的result的格子
				fill_type_to_grids_data_slot_type( #将本类的FillType枚举转换到GridsData类的SlotType枚举
					atlas_coords_to_fill_type( #根据图集砖瓦索引找到该格子对应的FillType
						n_edit_map.get_cell_atlas_coords( #获取修改层上给定坐标处格子的图集砖瓦索引
							Vector2i(x, y) #将要读取的修改层格子
						)
					)
				)
			)
	return result

## 将本类的FillType枚举转换到GridsData的SlotType枚举，使用空格作为无接住时的返回值
static func fill_type_to_grids_data_slot_type(fill_type: FillType) -> GridsData.SlotType:
	match (fill_type): #匹配填充类型
		FillType.EMPTY: #空格
			return GridsData.SlotType.EMPTY
		FillType.FILL: #实心块
			return GridsData.SlotType.FILL
		_:
			return GridsData.SlotType.EMPTY
