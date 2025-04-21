extends Node2D
class_name EditableGrids
## 游戏版面可编辑网格。用于显示和容纳版面网格和棋子的类

@onready var n_grid_map: TileMapLayer = $GridMap as TileMapLayer
@onready var n_edit_map: TileMapLayer = $EditMap as TileMapLayer

enum FillType{
	EMPTY, #空格
	BLOCK, #实心块
	CROSS, #叉叉
}

## 偏移量动画和缩放动画的动画播放速度，以偏移量动画举例即从实际动画偏移量从动画起始偏移量过度到终点显示偏移量所需的时间
const ANIMATION_TIME: float = 0.25
## 偏移量动画和缩放动画的插值缓动曲线
const ANIMATION_EASE: float = -2.0

## 显示偏移量(网格的整数坐标移动偏移量)，表示当前画面中最左上角的格子应当是网格中的哪个坐标的格子
static var display_offset: Vector2i = Vector2i(0, 0)
## 实际动画偏移量(节点的浮点数坐标偏移量)，相当于以浮点数表示的display_offset，与节点的坐标挂钩最紧密的坐标
#static var animate_display_offset: Vector2 = Vector2(0.0, 0.0)
## 动画起始偏移量(节点的浮点数坐标偏移量的缓动起始值)，用于计算节点的实际坐标
static var animate_start_offset: Vector2 = Vector2(0.0, 0.0)
## [只读]动画终点偏移量(节点的浮点数坐标偏移量的缓动终点值)，用于计算节点的实际坐标
static var animate_end_offset: Vector2:
	get:
		return display_offset * Main.TILE_NORMAL_SIZE
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
## 本地网格尺寸，表示本EditableGrids实例中TileMapLayer节点所显示的网格尺寸，用于调整大小时读写
var local_grid_size: Vector2i = Vector2i(5, 5)

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	#animation_timer = move_toward(animation_timer, 0.0, delta) #更新偏移量动画倒计时器 #转移到由PaperArea执行
	## 00更新网格的变换
	var free_height: float = window_size.y - NumberBar.bar_width #计算可用空间高度
	global_scale_rate = free_height / (animate_now_zoom_blocks * Main.TILE_NORMAL_SIZE) #计算全局缩放率
	scale = global_scale_rate *  Vector2.ONE #计算缩放的值
	position = Vector2(NumberBar.bar_width, NumberBar.bar_width) - animate_now_offset #计算坐标并应用
	## /00

## 获取鼠标指针处于的格子坐标(原点为0,0)
func get_mouse_pos() -> Vector2i:
	return n_grid_map.local_to_map(get_local_mouse_position())

## 对一个格子进行写入(擦除有专门的方法，不能用这个擦除)，不含非法坐标检测。本方法是临时测试用的，以后需要重写
func write_slot(pos: Vector2i, fill_type: FillType) -> void:
	n_edit_map.set_cell(pos, 0, get_type_atlas_coords(fill_type))

## 对一个格子进行擦除，不含非法坐标检测。本方法是临时测试用的，以后可能需要重写
func clear_slot(pos: Vector2i) -> void:
	n_edit_map.erase_cell(pos)

## 进行凌驾于动画之上的网格实际偏移量更新，使用拖手工具拖拽网格时需每帧调用此方法。参数请传入一个鼠标于一帧内在屏幕上坐标的移动量
static func update_offset_on_grabbing(offset_delta: Vector2) -> void:
	animate_start_offset = (animate_start_offset + offset_delta * global_scale_rate) #将本次的偏移量加进动画起始移动量
	animate_start_offset = Vector2(clampf(animate_start_offset.x, 0.0, (EditableGrids.global_grid_size.x - 1) * Main.TILE_NORMAL_SIZE), clampf(animate_start_offset.y, 0.0, (EditableGrids.global_grid_size.y - 1) * Main.TILE_NORMAL_SIZE)) #钳制坐标，防止超出左上角屏幕范围
	display_offset = Vector2i((animate_start_offset / Main.TILE_NORMAL_SIZE).round()) #将动画起始偏移量除以砖瓦大小后取整
	animate_start_zoom_blocks = animate_now_zoom_blocks #将起始缩放格子数设为当前的缩放格子数

## 更新动画数据，调用此方法来设定新的动画缓动目标值，包含网格的缩放和偏移量，设置动画的新目标值会重置动画计时器，因此请勿尽可能降低调用此方法的频率
static func update_animation_data(new_display_offset: Vector2i, new_zoom_blocks: int) -> void:
	animate_start_offset = animate_now_offset #将起始偏移量设为当前的实际偏移量
	display_offset = new_display_offset #设置新的目标偏移量
	animate_start_zoom_blocks = animate_now_zoom_blocks #将起始缩放格子数设为当前的缩放格子数
	Main.grids_zoom_blocks = new_zoom_blocks #设置新的缩放格子数
	PaperArea.grids_animation_timer = ANIMATION_TIME #重设动画计时器

## 给定一个格子填充类型，返回一个图集中对应砖瓦的二维向量索引
static func get_type_atlas_coords(fill_type: FillType) -> Vector2i:
	match (fill_type): #匹配填充类型
		FillType.EMPTY: #空格
			return Vector2i(-1, -1)
		FillType.BLOCK: #实心块
			return Vector2i(1, 1)
		FillType.CROSS: #叉叉
			return Vector2i(2, 1)
	return Vector2i(0, 0)

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
		for y in new_size: #遍历Y
			n_grid_map.set_cell(Vector2i(x, y), 0, Vector2i(2, 0)) #
