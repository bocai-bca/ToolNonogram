extends RefCounted
class_name UndoRedoServer_LinkedList
## 撤消重做服务器，以静态形式运行，提供全局共享的撤消重做记录的读写和托管服务

## 链表写起来好几把麻烦，不写了，这个类烂尾，我去写Array的

## 警告！严禁外界按不合规的操作修改本类的成员变量，损坏链表的连接结构会引发内存泄露

## 撤销重做服务器使用链表来记录整个撤消重做步骤队列，每个步骤使用UndoRedoObject(撤消重做对象)存储
## 每个对象以链表的形式组织和存储

## 伪单例FakeSingleton
#static var fs: UndoRedoServer:
	#get:
		#if (fs == null): #如果fs为空
			#push_error("UndoRedoServer: 在试图获取fs时无法返回有效值，因为：解引用fs时返回null。")
			#return null
		#return fs

## 最大历史记录长度
const MAX_LIST_LENGTH: int = 30

## 当前所在对象，如果当前是撤销重做步骤的最末尾(即无法重做的状态)，本变量与last_object将引用同一个UndoRedoObject
static var current_object: UndoRedoObject = null
## 最后一个(创建时间最晚的)对象
static var last_object: UndoRedoObject = null
## 第一个(创建时间最早的)对象
static var first_object: UndoRedoObject = null
## 链表长度
static var list_length: int = 0

## 当前是否可以进行撤销
static func can_now_undo() -> bool:
	if (current_object.last != null): #如果当前对象拥有上一个对象
		return true
	return false

## 当前是否可以进行重做
static func can_now_redo() -> bool:
	if (current_object.next != null): #如果当前对象拥有下一个对象
		return true
	return false

## 清空撤消重做步骤队列，即释放所有撤消重做对象
static func clear() -> void:
	var pointer: UndoRedoObject = last_object #创建局部撤消重做对象变量，代表一个指针指向一个撤消重做对象
	while (true): #进入无限循环
		if (pointer == null): #如果指向的撤消重做对象是null
			break #结束循环
		var this_obj: UndoRedoObject = pointer #记录当前的撤消重做对象
		pointer = pointer.last #将指针转移到上一个撤消重做对象
		this_obj.free() #释放记录的撤消重做对象
	last_object = null #去除last_object的引用
	first_object = null #去除first_object的引用
	current_object = null #去除current_object的引用

## 保存全局状态并添加到历史记录列表的高级封装
static func save_and_append() -> void:
	append(create_object())
	if (list_length > MAX_LIST_LENGTH): #当链表长度超出最大长度限制时
		remove_first() #移除链表中的第一个对象

## 创建一个新撤消重做对象并保存当前全局状况
static func create_object() -> UndoRedoObject:
	return UndoRedoObject.new(Main.activiting_layers_count, PaperArea.layers_grids_map, PaperArea.layers_lock_map)

## 将新撤消重做对象添加到链表的末尾，或作为链表的第一个节点，不会影响焦点所在位置(current_object)，不会限制链表长度
## 警告，本方法只要进行调用就会累积链表长度，如果传入null会导致链表长度计数错误和链表断链引发内存泄露的问题，请务必确保传入的对象有效并持续地可用(如果后续对象被释放也将导致链表断链)
static func append(new_object: UndoRedoObject) -> void:
	if (last_object != null): #如果存在最后一个对象
		last_object.append(new_object) #建立连接关系
	else: #否则(不存在最后一个对象，即当前的新对象是整个链表的首个对象)
		first_object = new_object #记录新对象为第一个对象
	last_object = new_object #更改last_object的引用
	list_length += 1 #累积一个链表长度计数

## 削去第一个对象，用于限制链表长度
static func remove_first() -> void:
	if (first_object == null): #如果不存在第一个对象
		return
	var target_object: UndoRedoObject = first_object #暂时持有引用
	first_object = first_object.next #将第一个对象指针向链表子孙方向推动一个对象，如果该对象的next为null，则会导致第一个对象被记录为null
	target_object.free() #释放对象

## 类-撤销重做对象，用于记录一个时刻中所有受撤消重做服务器影响的数据的历史记录，以链表形式呈现和组织存储
class UndoRedoObject extends RefCounted:
	## 图层数量，与Main.activiting_layers_count对应
	var layers_count: int
	## 各图层的填充内容数据，元素数量应与layers_count相符，每个元素的索引与图层序号对应
	var layers_grids_data: Array[GridsData]
	## 各图层的锁定数据，元素数量应与layers_count相符，每个元素的索引与图层序号对应
	var layers_lock_data: Array[GridsData]
	## 链表的下一个对象
	var next: UndoRedoObject
	## 链表的上一个对象
	var last: UndoRedoObject
	## 
	func _init(new_layers_count: int, new_layer_grids: Array[GridsData], new_layer_lock: Array[GridsData]) -> void:
		layers_count = new_layers_count
		layers_grids_data = new_layer_grids
		layers_lock_data = new_layer_lock
	## 在本对象实例后连接一个新对象
	func append(next_object: UndoRedoObject) -> void:
		next = next_object #将本实例的next设为传入的新对象
		next_object.last = self #将新对象的last设为本实例
	## 向后方获取对象(时间轴上更旧的对象)，可以传入一个int表示向后获取几步，如果因为链表到头了或者其他原因而未能获取到可用实例将返回null
	func get_backward(step: int = 1) -> UndoRedoObject:
		var pointer: UndoRedoObject = self
		while (step >= 1): #如果有剩余步数
			pointer = last #将指针对象向后移动
			if (pointer == null): #如果指针对象解引用为null
				return null
			step -= 1 #消耗一个步数
		return pointer
	## 向前方获取对象(时间轴上更新的对象)，可以传入一个int表示向前获取几步，如果因为链表到头了或者其他原因而未能获取到可用实例将返回null
	func get_forward(step: int = 1) -> UndoRedoObject:
		var pointer: UndoRedoObject = self
		while (step >= 1): #如果有剩余步数
			pointer = next #将指针对象向前移动
			if (pointer == null): #如果指针对象解引用为null
				return null
			step -= 1 #消耗一个步数
		return pointer
