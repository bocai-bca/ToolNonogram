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

## 排列方向
@export var direction: Direction
## 显示的数字(缓存，不代表实际构成数字的节点的内容)
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
	## 01更新数字节点
	## /01

## 设置新数字，将重新放置节点
func set_number_nodes(new_number: Array[PackedInt32Array]) -> void:
	numbers = new_number #记录新显示的数字
	## 00清除旧的数字节点
	for node in n_numbers.get_children(): #遍历Numbers的所有子节点
		node.queue_free() #清除子节点
	## /00
	## 01创建数字节点

	## /01

## 类场景实例化方法
#static func create(new_direction: Direction) -> NumberArrayDisplayer:
	#var node: NumberArrayDisplayer = cps.instantiate()
	#node.direction = new_direction
	#return node
