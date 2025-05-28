extends RefCounted
class_name UndoRedoServer_Array
## 撤消重做服务器，以静态形式运行，提供全局共享的撤消重做记录的读写和托管服务

## 最大对象数量，当记录的对象数量超出此数值时将丢弃最早的对象
const MAX_OBJECTS_COUNT: int = 30

## 撤消重做对象列表
static var objects: Array[UndoRedoObject] = []
## 当前索引，用于访问objects，表示当前撤销重做的位置在objects中的何处
static var current_index: int = 0

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
