extends Node2D
class_name EditableGrids
## 游戏版面可编辑网格。用于显示和容纳版面网格和棋子的类

@onready var n_grid_map: TileMapLayer = $GridMap as TileMapLayer

## 显示偏移量(坐标移动偏移量)，表示当前画面中最左上角的格子应当是网格中的哪个坐标的格子
static var display_offset: Vector2i = Vector2i(0, 0)
## 网格尺寸
static var grid_size: Vector2i = Vector2i(5, 5) #网格实例的节点的初始尺寸是5*5

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	## 00更新网格的变换
	var free_height: float = window_size.y - NumberBar.bar_width #计算可用空间高度
	scale = free_height / (Main.grids_zoom_blocks * Main.TILE_NORMAL_SIZE) *  Vector2.ONE #计算缩放的值
	var actually_offset: Vector2 = display_offset * Main.TILE_NORMAL_SIZE #计算实际的坐标移动偏移量
	position = Vector2(NumberBar.bar_width, NumberBar.bar_width) - actually_offset #计算坐标并应用
	## /00

## 重新设置网格尺寸，也就是格子数(未来会写显示不同内容的砖瓦图节点，那些节点不受本函数影响，本函数应当只负责改变背景的大小
static func resize_grid(new_size: Vector2i) -> void:
	pass
