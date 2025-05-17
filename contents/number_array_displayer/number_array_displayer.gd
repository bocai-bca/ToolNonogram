extends SubViewportContainer
class_name NumberArrayDisplayer
## 数字阵列显示器。用于在数字栏上将题目数据呈现为数织题目数字

## 类场景封包ClassPackedScene
#static var cps: PackedScene = preload("res://contents/number_array_displayer/number_array_displayer.tscn") as PackedScene

@onready var n_viewport: SubViewport = $DisplayerViewport as SubViewport
@onready var n_numbers: Control = $DisplayerViewport/Numbers as Control
@onready var n_text_length_tester: Label = $TextLengthTester as Label

## 排列方向
enum Direction{
	HORIZONTAL, #水平
	VERTICAL, #垂直
}

## 默认字体大小，需要手动根据本类的子节点使用的主题的默认字体设置
const DEFAULT_FONT_SIZE: float = 162.0
## 滚动动画的动画播放速度，即从动画起始滚动量过度到动画终点滚动量所需的时间
const ANIMATION_TIME: float = 0.25
## 滚动动画的插值缓动曲线
const ANIMATION_EASE: float = -2.0

## [只读]单边边长，即答题网格中一个格子的边长，用于计算数字
static var side_length: float:
	get:
		return Main.TILE_NORMAL_SIZE * EditableGrids.global_scale_rate
## 滚动单位数量，X分量表示垂直排列的数字阵列显示器的左右滚动(值越大越显示左侧的数字)，Y分量表示水平排列的数字阵列显示器的上下滚动(值越大越显示上方的数字)
static var scroll: Vector2i = Vector2i(0, 0)
## 最高滚动单位数量，一单位长度是一个数字的长度(即一个side_length)，用于限制数字阵列显示器可以滚动的距离
static var max_scroll_units: Vector2i = Vector2i(0, 0)
## 滚动动画起始量(节点的浮点数坐标偏移量的缓动起始值)，用于计算节点的实际坐标
static var scroll_animation_start_offset: Vector2 = Vector2(0.0, 0.0)
## [只读]滚动动画终点量(节点的浮点数坐标偏移量的缓动终点值)，用于计算节点的实际坐标
static var scroll_animation_end_offset: Vector2:
	get:
		return scroll * side_length
## [只读]滚动动画当前量，用于计算节点的实际坐标
static var scroll_animation_now_offset: Vector2:
	get:
		return Vector2(
			lerpf(scroll_animation_end_offset.x, scroll_animation_start_offset.x, ease(NumberBar.number_array_displayer_scroll_animation_timer_side / ANIMATION_TIME, ANIMATION_EASE)),
			lerpf(scroll_animation_end_offset.y, scroll_animation_start_offset.y, ease(NumberBar.number_array_displayer_scroll_animation_timer_up / ANIMATION_TIME, ANIMATION_EASE))
		)
## 排列方向
@export var direction: Direction
## 显示的数字(缓存，不代表实际构成数字的节点的内容)，第一层索引代表行列，第二层索引代表同一行列内的一群数字
## 对于水平的数字阵列显示器：
## 	随第一层索引数增大，节点向右排列
## 	随第二层索引数增大，节点向上叠放
## 对于垂直的数字阵列显示器：
## 	随第一层索引数增大，节点向下排列
## 	随第二层索引数增大，节点向左叠放
var numbers: Array[PackedInt32Array]

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	## 00更新视口属性
	if (direction == Direction.HORIZONTAL): #如果是水平的数字栏
		n_viewport.size = Vector2i(Vector2(window_size.x - NumberBar.bar_width - LayersBar.bar_width, NumberBar.bar_width)) #设置视口尺寸
		position = Vector2(NumberBar.bar_width, 0.0) #设置坐标
	else: #否则(是垂直的数字栏)
		n_viewport.size = Vector2i(Vector2(NumberBar.bar_width, window_size.y - NumberBar.bar_width)) #设置视口尺寸
		position = Vector2(0.0, NumberBar.bar_width) #设置坐标
	## /00
	## 01更新Numbers控制节点
	if (direction == Direction.HORIZONTAL): #如果本数字阵列显示器的方向是水平的
		#### 实验中
		#n_numbers.position = Vector2(-EditableGrids.animate_now_offset.x, NumberBar.bar_width)
		n_numbers.position = Vector2(-EditableGrids.animate_now_offset.x, NumberBar.bar_width + scroll_animation_now_offset.y - NumberBar.frame_thickness)
	else: #否则(本数字阵列显示器的方向是垂直)
		n_numbers.position = Vector2(NumberBar.bar_width + scroll_animation_now_offset.x - NumberBar.frame_thickness, -EditableGrids.animate_now_offset.y)
	## /01

func _physics_process(delta: float) -> void:
	## 00更新数字节点
	for member in n_numbers.get_children() as Array[NumberArrayDisplayer_Member]: #遍历成员
		if (direction == Direction.HORIZONTAL): #如果本数字阵列显示器的方向是水平的
			member.add_theme_font_size_override(&"font_size", int(side_length / get_text_min_width(member.text).z * DEFAULT_FONT_SIZE)) #覆写字体大小使其填满格子
			member.size = Vector2.ZERO
			member.position = Vector2(
				side_length * (2.0 * member.column + 1.0) / 2.0 - member.size.x / 2.0,
				side_length * -(member.height + 1)
			)
		else: #否则(本数字阵列显示器的方向是垂直)
			member.add_theme_font_size_override(&"font_size", int(side_length / get_text_min_width(member.text).z * DEFAULT_FONT_SIZE)) #覆写字体大小使其填满格子
			member.size = Vector2.ZERO
			member.position = Vector2(
				side_length * -(member.height + 0.5) - member.size.x / 2.0,
				#side_length * (2.0 * member.column + 1.0) / 2.0 - member.size.y / 2.0
				side_length * member.column
			)
	## /00

## 设置新数字，将重新放置节点
func set_numbers(new_numbers: Array[PackedInt32Array]) -> void:
	numbers = new_numbers #记录新显示的数字
	## 00清除旧的数字节点
	clear_numbers()
	## /00
	## 01创建数字节点
	for i in numbers.size(): #按索引遍历数字列表的第一层
		for j in numbers[i].size(): #按索引遍历数字列表的第二层
			var member: NumberArrayDisplayer_Member = NumberArrayDisplayer_Member.create(i, numbers[i].size() - 1 - j) #创建成员，传入的列数是i，传入的高度是逆序的j
			member.text = str(numbers[i][numbers[i].size() - 1 - j]) #设置成员的数字
			member.self_modulate = Color(0.0, 0.0, 0.0, 1.0) #设置成员的颜色
			n_numbers.add_child(member) #将创建的成员加入子节点
		if (direction == Direction.HORIZONTAL): #如果本数字阵列显示器的方向是水平的
			if (numbers[i].size() - 1 > max_scroll_units.y): #如果同一竖列的数字数量-1大于记录的最大滚动单位数
				max_scroll_units.y = numbers[i].size() - 1 #将上下向最大滚动单位数记录为它
		else: #否则(方向是垂直的)
			if (numbers[i].size() - 1 > max_scroll_units.x): #如果同一横行的数字数量-1大于记录的最大滚动单位数
				max_scroll_units.x = numbers[i].size() - 1 #将左右向最大滚动单位数记录为它
	## /01

## 清除数字(用于沙盒模式)
func clear_numbers() -> void:
	for node in n_numbers.get_children(): #遍历Numbers的所有子节点
		node.queue_free() #清除子节点
	#max_scroll_units = Vector2(0, 0) #清除最大滚动单位数
	scroll = Vector2i(0, 0) #重置滚动单位数

## 获取文本的最小尺寸，输出结果的X和Y是尺寸XY，Z是这两个数中的最大值
func get_text_min_width(text: String) -> Vector3:
	n_text_length_tester.text = text
	return Vector3(n_text_length_tester.size.x, n_text_length_tester.size.y, maxf(n_text_length_tester.size.x, n_text_length_tester.size.y))

## 进行凌驾于动画之上的顶部数字栏滚动实际量更新，使用拖手工具拖拽网格时需每帧调用此方法。参数请传入一个鼠标于一帧内在屏幕上坐标的移动量
static func update_offset_on_scrolling_up(offset_delta: float) -> void:
	scroll_animation_start_offset.y += offset_delta #将新的偏移量加入滚动起始量中
	scroll_animation_start_offset.y = clampf(scroll_animation_start_offset.y, 0.0, max_scroll_units.y * side_length) #钳制滚动偏移量数字，防止超出范围
	scroll.y = int(roundf(scroll_animation_start_offset.y / side_length)) #根据偏移量逆向到滚动单位数

## 进行凌驾于动画之上的侧边数字栏滚动实际量更新，使用拖手工具拖拽网格时需每帧调用此方法。参数请传入一个鼠标于一帧内在屏幕上坐标的移动量
static func update_offset_on_scrolling_side(offset_delta: float) -> void:
	scroll_animation_start_offset.x += offset_delta #将新的偏移量加入滚动起始量中
	scroll_animation_start_offset.x = clampf(scroll_animation_start_offset.x, 0.0, max_scroll_units.x * side_length) #钳制滚动偏移量数字，防止超出范围
	scroll.x = int(roundf(scroll_animation_start_offset.x / side_length)) #根据偏移量逆向到滚动单位数

## 类场景实例化方法
#static func create(new_direction: Direction) -> NumberArrayDisplayer:
	#var node: NumberArrayDisplayer = cps.instantiate()
	#node.direction = new_direction
	#return node
