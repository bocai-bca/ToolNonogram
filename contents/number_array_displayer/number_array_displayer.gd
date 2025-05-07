extends SubViewportContainer
class_name NumberArrayDisplayer
## 数字阵列显示器

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

## [只读]单边边长，即答题网格中一个格子的边长，用于计算数字
static var side_length: float:
	get:
		return Main.TILE_NORMAL_SIZE * EditableGrids.global_scale_rate
## 滚动单位数量，X分量表示垂直排列的数字阵列显示器的左右滚动(值越大越显示左侧的数字)，Y分量表示水平排列的数字阵列显示器的上下滚动(值越大越显示上方的数字)
static var scroll: Vector2i = Vector2i(0, 0)
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
## 最高滚动单位数量，一单位长度是一个数字的长度(即一个side_length)，用于限制数字阵列显示器可以滚动的距离。若本实例的方向是水平的，则本变量用于限制垂直方向的滚动，反之用于限制水平方向的滚动
var max_scroll_units: int = 0

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
	## 01更新数字节点
	for member in n_numbers.get_children() as Array[NumberArrayDisplayer_Member]: #遍历成员
		if (direction == Direction.HORIZONTAL): #如果本数字阵列显示器的方向是水平的
			member.position = Vector2(member.column, -member.height) * side_length #计算坐标
		else: #否则(本数字阵列显示器的方向是垂直)
			member.position = Vector2(-member.height, member.column) * side_length #计算坐标
	## /01
	## 02更新Numbers控制节点
	## /02

## 设置新数字，将重新放置节点
func set_number_nodes(new_number: Array[PackedInt32Array]) -> void:
	numbers = new_number #记录新显示的数字
	## 00清除旧的数字节点
	for node in n_numbers.get_children(): #遍历Numbers的所有子节点
		node.queue_free() #清除子节点
	max_scroll_units = 0 #清除最大滚动单位数
	## /00
	## 01创建数字节点
	for i in numbers.size(): #按索引遍历数字列表的第一层
		for j in numbers[i].size(): #按索引遍历数字列表的第二层
			var member: NumberArrayDisplayer_Member = NumberArrayDisplayer_Member.create(i, numbers[i].size() - 1 - j) #创建成员，传入的列数是i，传入的高度是逆序的j
			member.text = str(numbers[i][numbers[i].size() - 1 - j]) #设置成员的数字
			n_numbers.add_child(member) #将创建的成员加入子节点
		if (numbers[i].size() - 1 > max_scroll_units): #如果同一行列的数字数量-1大于记录的最大滚动单位数
			max_scroll_units = numbers[i].size() - 1 #将最大滚动单位数记录为它
	## /01

## 类场景实例化方法
#static func create(new_direction: Direction) -> NumberArrayDisplayer:
	#var node: NumberArrayDisplayer = cps.instantiate()
	#node.direction = new_direction
	#return node
