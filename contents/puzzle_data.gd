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
