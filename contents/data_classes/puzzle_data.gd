extends RefCounted
class_name PuzzleData
## 题目数据

## 题目横向数据，第一层表示横排的格子，第二层表示该格子从下向上排列的数字
var horizontal: Array[PackedInt32Array] = []
## 题目纵向数据，第一层表示竖排的格子，第二层示该格子从右向左排列的数字
var vertical: Array[PackedInt32Array] = []

## 检查与另一个PuzzleData是否相同
func is_same(puzzle_data: PuzzleData) -> bool:
	## 00检查外层元素数量匹配
	if (horizontal.size() != puzzle_data.horizontal.size()): #如果横向格数不匹配
		push_error("PuzzleData: 进行相同性检查时不正常地失败，因为：水平方向格子数不匹配。")
		return false #不正常检查失败，格数不匹配
	if (vertical.size() != puzzle_data.vertical.size()): #如果纵向格数不匹配
		push_error("PuzzleData: 进行相同性检查时不正常地失败，因为：垂直方向格子数不匹配。")
		return false #不正常检查失败，格数不匹配
	## /00
	## 01检查横向数据
	for i in horizontal.size(): #按索引遍历横向数据的所有数组
		if (horizontal[i] != puzzle_data.horizontal[i]): #如果对值类型类型化数组进行==运算符时返回false
			return false #正常检查失败，元素数量不匹配或元素值不匹配
	## /01
	## 02检查纵向数据
	for i in vertical.size(): #按索引遍历纵向数据的所有数组
		if (vertical[i] != puzzle_data.vertical[i]): #如果对值类型类型化数组进行==运算符时返回false
			return false #正常检查失败，元素数量不匹配或元素值不匹配
		#if (vertical[i].size() != puzzle_data.vertical[i].size()): #如果此数组与对照对象的此数组元素数量不匹配
			#return false #正常检查失败，元素数量不匹配
		#for j in vertical[i]: #按索引遍历该数组的元素
			#if (vertical[i][j] != puzzle_data.vertical[i][j]): #如果此索引与对照对象的此索引不匹配
				#return false #正常检查失败，元素值不匹配
	## /02
	return true #检查成功

##
static func from_grids_data(grids_data: GridsData) -> PuzzleData:
	var result: PuzzleData = PuzzleData.new()
	var size: Vector2i = grids_data.get_size() #获取本局面数据的尺寸
	#print("GridsData: 尺寸为", str(size))
	## 00顶部数字栏
	#var debug_str: String = "" #创建一个局部字符串，用于记录转换后的数组的调试输出文本
	for row in size.x: #遍历尺寸的X，以每一横排的竖向数字列执行内容
		var nums_array: PackedInt32Array = [] #新建本排数字列的数组
		var current_num: int = 0 #在扫描网格时记录连续实心块的长度数字
		for i in size.y: #遍历尺寸的Y
			i = size.y - 1 - i #将i变为逆序
			if (grids_data.get_slot(Vector2i(row, i)) == Generator.GridsDataSlotType.FILL): #扫描当前格如果是实心的
				current_num += 1 #增加记录数字
			else: #否则(是空心的)
				if (current_num > 0): #如果记录的连续实心块数字不是0，意味着上一个扫描的格子是实心的
					nums_array.append(current_num) #将记录的数字添加到数组
					current_num = 0 #重设记录的数字
		if (current_num > 0): #如果记录的连续实心块数字不是0，意味着上一个扫描的格子是实心的
			nums_array.append(current_num) #将记录的数字添加到数组
		elif (nums_array.is_empty()): #否则如果连续实心块是0且本排数字列尚未添加任何数字
			nums_array.append(0) #将0添加进去
		result.horizontal.append(nums_array) #将本排数字列的数组添加到水平数字栏
		#debug_str += str(nums_array) #将本排数字列转换到文本放进调试输出文本
	#print("GridsData: 转换出顶部数字栏:", debug_str)
	## /00
	#debug_str = "" #清空调试输出文本
	## 01侧边数字栏
	for row in size.y: #遍历尺寸的Y，以每一竖排的横向数字行执行内容
		var nums_array: PackedInt32Array = [] #新建本排数字行的数组
		var current_num: int = 0 #在扫描网格时记录连续实心块的长度数字
		for i in size.x: #遍历尺寸的X
			i = size.x - 1 - i #将i变为逆序
			if (grids_data.get_slot(Vector2i(i, row)) == Generator.GridsDataSlotType.FILL): #扫描当前格如果是实心的
				current_num += 1 #增加记录数字
			else: #否则(是空心的)
				if (current_num > 0): #如果记录的连续实心块数字不是0，意味着上一个扫描的格子是实心的
					nums_array.append(current_num) #将记录的数字添加到数组
					current_num = 0 #重设记录的数字
		if (current_num > 0): #如果记录的连续实心块数字不是0，意味着上一个扫描的格子是实心的
			nums_array.append(current_num) #将记录的数字添加到数组
		elif (nums_array.is_empty()): #否则如果连续实心块是0且本排数字行尚未添加任何数字
			nums_array.append(0) #将0添加进去
		result.vertical.append(nums_array) #将本排数字行的数组添加到垂直数字栏
		#debug_str += str(nums_array) #将本排数字列转换到文本放进调试输出文本
	#print("GridsData: 转换出侧边数字栏:", debug_str)
	## /01
	return result
