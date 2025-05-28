extends RefCounted
class_name UndoRedoServer
## 撤消重做服务器，以静态形式运行，提供全局共享的撤消重做记录的读写和托管服务

## 类-撤销重做对象，用于记录一个时刻中所有受撤消重做服务器影响的数据的历史记录
class UndoRedoObject:
	## 图层数量，与Main.activiting_layers_count对应
	var layers_count: int
	## 各图层的填充内容数据，元素数量应与layers_count相符，每个元素的索引与图层序号对应
	var layers_grids_data: Array[GridsData]
