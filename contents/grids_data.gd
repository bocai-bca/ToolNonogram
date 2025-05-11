extends RefCounted
class_name GridsData
## 局面数据，用于存储表达答题网格各格子填充状态的类型，也相当于是一个位深度为一字节的
## 每个格子能够存储一字节大小的整型(最大值可能是127)
## 每个格子可以随时读写，但不提供对矩形大小的变更
## 在外部时常通过枚举指代一个格子的填充类型，在GDScript下枚举可直接以整型读取，所以在本类中读写时只要确保写入方和读出方使用的是同一枚举，即可保留枚举信息

## 扁平数组，代表一个二维数组，采用y*a+x的方式进行排列(a为每个横排的元素数量)
var array: PackedByteArray = []
## 每个横排的元素数，能代表该"矩形"的横向宽度
var width: int

## 构造方法
func _init(size: Vector2i) -> void:
	width = size.x #设置横排元素数量
	array.resize(size.x * size.y) #初始化尺寸

## 读取，超出索引边界时返回给定的失败返回值(默认为0)
func get_slot(index: Vector2i, failed_return: int = 0) -> int:
	var i: int = index.y * width + index.x #计算扁平化索引
	if (i >= array.size()): #如果扁平化索引超出边界
		push_error("GridsData: 读取失败并返回了给定的失败返回值，因为：给定的二维索引在扁平化后超出扁平化数组边界。")
		return failed_return #返回失败值
	return array[i] #返回扁平化索引数索引的值

## 写入，超出索引边界时放弃写入
## 注意，本方法不提供对输入值的范围检查，将使用PackedByteArray.set()对指定索引位置进行写入，超出int8范围时会作何行为由该方法决定
func set_slot(index: Vector2i, value: int) -> void:
	var i: int = index.y * width + index.x #计算扁平化索引
	if (i >= array.size()): #如果扁平化索引超出边界
		push_error("GridsData: 写入失败并放弃写入，因为：给定的二维索引在扁平化后超出扁平化数组边界。")
		return
	array.set(i, value) #使用PackedByteArray.set()进行写入

## 获取尺寸
## 如果array被外界非法修改，本方法可能返回错误结果
func get_size() -> Vector2i:
	return Vector2i(width, array.size() / width) #X不用讲，Y的话是根据"长*高=面积"反过来得到"高=面积/长"
