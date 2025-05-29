extends RefCounted
class_name UndoRedoServer_Array
## 撤消重做服务器，以静态形式运行，提供全局共享的撤消重做记录的读写和托管服务

## 最大对象数量，当记录的对象数量超出此数值时将丢弃最早的对象
const MAX_OBJECTS_COUNT: int = 30

## 撤消重做对象列表，排序是越往后越早，每次添加新元素采用push_front()
static var objects: Array[UndoRedoObject] = []
## 当前索引(或称焦点)，用于访问objects，表示当前撤销重做的位置在objects中的何处。当objects列表为空时本变量为0，尽管0也不是可用的索引
static var current_index: int = 0

## 获取当前焦点所在的撤消重做对象，如果列表为空会返回null，同时如果索引数不合法也有相应的特殊行为，代码不长自己看吧
static func get_current() -> UndoRedoObject:
	if (objects.is_empty()): #如果列表为空
		return null
	return objects[clampi(current_index, 0, objects.size() - 1)]

## 进行一次撤销并返回焦点到达的新位置(如果无法撤销时强制撤销会撤不动，仍然返回列表的最后一个元素，或者列表为空时引发引擎报错，请务必使用can_now_undo()进行安全检查)
static func undo() -> UndoRedoObject:
	current_index = clampi(current_index + 1, 0, objects.size() - 1) #向尾部移动一次索引
	return objects[current_index] #返回该索引处的撤消重做对象

## 进行一次重做并返回焦点到达的新位置(如果无法重做时强制重做会做不动，仍然返回列表的第一个元素，或者列表为空时引发引擎报错，请务必使用can_now_redo()进行安全检查)
static func redo() -> UndoRedoObject:
	current_index = clampi(current_index - 1, 0, objects.size() - 1) #向头部移动一次索引
	return objects[current_index] #返回该索引处的撤消重做对象

## 当前是否可以进行撤销，如果current_index不在正常范围内(0..objects.size)，本方法可能返回错误的结果
static func can_now_undo() -> bool:
	if (current_index >= objects.size() - 1): #如果索引数大于等于最后一个元素的索引
		return false #返回结果 当前不可撤销
	return true #返回结果 当前可以撤销

## 当前是否可以进行重做，如果current_index不在正常范围内(0..objects.size)，本方法可能返回错误的结果
static func can_now_redo() -> bool:
	if (0 < current_index and current_index < objects.size()): #如果索引数大于0且不超出最后一个元素的索引
		return true #返回结果 当前可以重做
	return false #返回结果 当前不可重做

## 清空撤消重做列表
static func clear() -> void:
	objects.clear()
	current_index = 0

## 插入新撤消重做对象到焦点处，将删除焦点所在位置到之前的列表头部之间的所有对象
## 当试图添加null时会拒绝并报错
static func insert_add(new_object: UndoRedoObject) -> void:
	if (new_object == null): #如果传入的新对象是null
		push_error("UndoRedoServer_Array: 取消插入新撤销重做对象到列表，因为：参数给定的新对象是null。")
		return
	while (current_index > 0): #如果索引数大于0就继续循环(意思是直到索引指向列表的第一个元素才停下，或者说索引指向的元素变为列表的第一个元素才停下)
		if (objects.is_empty()): #如果列表空了，但是正在继续循环
			push_error("UndoRedoServer_Array: 插入新撤销重做对象时出现故障，因为：削去焦点前的对象的循环动作尚未终止但对象列表已空。")
			current_index = 0 #将焦点索引强制移动到0
			break
		objects.remove_at(0) #从列表头部移除一个对象
		current_index -= 1 #焦点索引向头部移动一次
	objects.push_front(new_object) #将新对象添加到列表头部
	# 此处不需要操作索引数，因为焦点本来就要往前移动一次到达新的第一个元素，而这与元素插入的数组索引移动现象相抵消
	objects.resize(MAX_OBJECTS_COUNT) #截断列表末尾的超出长度上限的对象

## 添加新撤消重做对象到列表头部，并移动焦点到列表头部
## 当试图添加null时会拒绝并报错
static func add(new_object: UndoRedoObject) -> void:
	if (new_object == null): #如果传入的新对象是null
		push_error("UndoRedoServer_Array: 取消添加新撤销重做对象到列表，因为：参数给定的新对象是null。")
		return
	objects.push_front(new_object) #将新对象添加到列表头部
	current_index = 0 #将焦点移动到列表头部
	objects.resize(MAX_OBJECTS_COUNT) #截断列表末尾的超出长度上限的对象

## 创建一个新撤消重做对象并保存当前全局状况
static func create_object() -> UndoRedoObject:
	return UndoRedoObject.new(Main.activiting_layers_count, PaperArea.layers_grids_map, PaperArea.layers_lock_map)

## 类-撤销重做对象，用于记录一个时刻中所有受撤消重做服务器影响的数据的历史记录，以链表形式呈现和组织存储
class UndoRedoObject extends RefCounted:
	## 图层数量，与Main.activiting_layers_count对应
	var layers_count: int
	## 各图层的填充内容数据，元素数量应与layers_count相符，每个元素的索引与图层序号对应
	var layers_grids_data: Array[GridsData]
	## 各图层的锁定数据，元素数量应与layers_count相符，每个元素的索引与图层序号对应
	var layers_lock_data: Array[GridsData]
	## 
	func _init(new_layers_count: int, new_layer_grids: Array[GridsData], new_layer_lock: Array[GridsData]) -> void:
		layers_count = new_layers_count
		layers_grids_data = new_layer_grids
		layers_lock_data = new_layer_lock
