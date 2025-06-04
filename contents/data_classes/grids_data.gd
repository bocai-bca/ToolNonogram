extends RefCounted
class_name GridsData
## 局面数据，用于存储表达答题网格各格子填充状态的类型，也相当于是一个位深度为一字节的通用二维图
## 每个格子能够存储一字节大小的整型(最大值可能是127)
## 每个格子可以随时读写，但不提供对矩形大小的变更
## 在外部时常通过枚举指代一个格子的填充类型，在GDScript下枚举可直接以整型读取，所以在本类中读写时只要确保写入方和读出方使用的是同一枚举，即可保留枚举信息

## 格子类型，本枚举与EditableGrids.FillType功能类似但请注意避免混淆，请在生成器相关的场合中尽可能使用本枚举
## 本枚举弃用，因为需要使GridsData按照高度自由的容器使用设计。先前生成器使用的枚举现转由Generator定义，先前EditableGrids使用的枚举现转由PaperArea定义
#enum SlotType{
	#EMPTY = 0, #空格
	#FILL = 1, #实心块
#}

## 扁平数组，相当于GridsData实例所存储的数据，代表一个二维数组，采用y*a+x的方式进行排列(a为每个横排的元素数量)
var array: PackedByteArray = []
## 每个横排的元素数，能代表该"矩形"的横向宽度
var width: int

## 构造方法，将返回一个尺寸为给定尺寸、填充内容为0的GridsData实例
func _init(size: Vector2i, init_fill: int = 0) -> void:
	width = size.x #设置横排元素数量
	array.resize(size.x * size.y) #初始化尺寸
	array.fill(init_fill) #将内容设为全空

## 读取，超出索引边界时返回给定的失败返回值(默认为0)
func get_slot(index: Vector2i, failed_return: int = 0) -> int:
	var i: int = index.y * width + index.x #计算扁平化索引
	if (i >= array.size()): #如果扁平化索引超出边界
		push_error("GridsData: 读取失败并返回了给定的失败返回值，因为：给定的二维索引在扁平化后超出扁平化数组边界。")
		return failed_return #返回失败值
	return array[i] #返回扁平化索引数索引的值

## 写入，超出索引边界时放弃写入
## 注意，本方法不提供对输入值的范围检查，将使用PackedByteArray.set()对指定索引位置进行写入，超出int8范围时会作何行为由该方法决定
func set_slot(index: Vector2i, slot_value: int) -> void:
	var i: int = index.y * width + index.x #计算扁平化索引
	if (i >= array.size()): #如果扁平化索引超出边界
		push_error("GridsData: 写入失败并放弃写入，因为：给定的二维索引在扁平化后超出扁平化数组边界。")
		return
	array.set(i, slot_value) #使用PackedByteArray.set()进行写入

## 获取尺寸
## 如果array被外界非法修改，本方法可能返回错误结果
func get_size() -> Vector2i:
	return Vector2i(width, array.size() / width) #X不用讲，Y的话是根据"长*高=面积"反过来得到"高=面积/长"

## 被向下合并，类似于图像编辑软件的两个图层合并，本方法应由图层关系于下方被合并的GridsData执行，传入的参数是图层关系于上方的GridsData
## 上方的GridsData中所有非0格子都将覆盖方法执行方GridsData的格子
## 例如：
## 	A = [0, 1, 0] 被合并方
## 	B = [1, 0, 1] 合并方
## 	A.be_merge_down(B)
## 	A = [1, 1, 1] 合并完成后的被合并方
func be_merge_down(up_layer: GridsData) -> void:
	var grids_size: Vector2i = get_size() #获取尺寸
	if (grids_size != up_layer.get_size()): #尺寸不匹配
		push_error("GridsData: 取消合并，因为：给定的GridsData实例与本实例的尺寸不匹配。")
		return
	for x in grids_size: #遍历X
		for y in grids_size: #遍历Y
			var slot_value: int = up_layer.get_slot(Vector2i(x, y)) #合并方的当前坐标格子的值
			if (slot_value != 0): #如果合并方该格子的值不为0
				set_slot(Vector2i(x, y), slot_value) #将被合并方的该格子设为合并方该格子的值

## 复制当前GridsData实例，返回另一个独立的新GridsData实例
func duplicate() -> GridsData:
	var new_grids_data: GridsData = GridsData.new(get_size()) #新建一个空的GridsData实例
	new_grids_data.array = array.duplicate() #将本实例的array复制一份放到新实例
	return new_grids_data #返回新实例

## 转换到PuzzleData
## 相同GridsData转换出的PuzzleData的引用是不同的，若要对比PuzzleData是否相同可以使用PuzzleData.is_same()
#func to_puzzle_data() -> PuzzleData:
	##print("GridsData: 正在转换到PuzzleData")
	#var result: PuzzleData = PuzzleData.new()
	#var size: Vector2i = get_size() #获取本局面数据的尺寸
	##print("GridsData: 尺寸为", str(size))
	### 00顶部数字栏
	#var debug_str: String = "" #创建一个局部字符串，用于记录转换后的数组的调试输出文本
	#for row in size.x: #遍历尺寸的X，以每一横排的竖向数字列执行内容
		#var nums_array: PackedInt32Array = [] #新建本排数字列的数组
		#var current_num: int = 0 #在扫描网格时记录连续实心块的长度数字
		#for i in size.y: #遍历尺寸的Y
			#i = size.y - 1 - i #将i变为逆序
			#if (get_slot(Vector2i(row, i)) == SlotType.FILL): #扫描当前格如果是实心的
				#current_num += 1 #增加记录数字
			#else: #否则(是空心的)
				#if (current_num > 0): #如果记录的连续实心块数字不是0，意味着上一个扫描的格子是实心的
					#nums_array.append(current_num) #将记录的数字添加到数组
					#current_num = 0 #重设记录的数字
		#if (current_num > 0): #如果记录的连续实心块数字不是0，意味着上一个扫描的格子是实心的
			#nums_array.append(current_num) #将记录的数字添加到数组
		#elif (nums_array.is_empty()): #否则如果连续实心块是0且本排数字列尚未添加任何数字
			#nums_array.append(0) #将0添加进去
		#result.horizontal.append(nums_array) #将本排数字列的数组添加到水平数字栏
		#debug_str += str(nums_array) #将本排数字列转换到文本放进调试输出文本
	##print("GridsData: 转换出顶部数字栏:", debug_str)
	### /00
	#debug_str = "" #清空调试输出文本
	### 01侧边数字栏
	#for row in size.y: #遍历尺寸的Y，以每一竖排的横向数字行执行内容
		#var nums_array: PackedInt32Array = [] #新建本排数字行的数组
		#var current_num: int = 0 #在扫描网格时记录连续实心块的长度数字
		#for i in size.x: #遍历尺寸的X
			#i = size.x - 1 - i #将i变为逆序
			#if (get_slot(Vector2i(i, row)) == SlotType.FILL): #扫描当前格如果是实心的
				#current_num += 1 #增加记录数字
			#else: #否则(是空心的)
				#if (current_num > 0): #如果记录的连续实心块数字不是0，意味着上一个扫描的格子是实心的
					#nums_array.append(current_num) #将记录的数字添加到数组
					#current_num = 0 #重设记录的数字
		#if (current_num > 0): #如果记录的连续实心块数字不是0，意味着上一个扫描的格子是实心的
			#nums_array.append(current_num) #将记录的数字添加到数组
		#elif (nums_array.is_empty()): #否则如果连续实心块是0且本排数字行尚未添加任何数字
			#nums_array.append(0) #将0添加进去
		#result.vertical.append(nums_array) #将本排数字行的数组添加到垂直数字栏
		#debug_str += str(nums_array) #将本排数字列转换到文本放进调试输出文本
	##print("GridsData: 转换出侧边数字栏:", debug_str)
	### /01
	#return result
