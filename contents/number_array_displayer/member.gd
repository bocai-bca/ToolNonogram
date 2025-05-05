extends Label
class_name NumberArrayDisplayer_Member
## 数字阵列显示器成员

## 类场景封包ClassPackedScene
static var cps: PackedScene = preload("res://contents/number_array_displayer/member.tscn") as PackedScene

## 所属列数，零始制。当宿主数字阵列显示器为水平方向时，本实例将跟随本变量向右排列；当宿主为垂直方向时，本实例将跟随本变量向下排列
var column: int
## 所属高度，零始制。当宿主数字阵列显示器为水平方向时，本实例将跟随本变量向上排列；当宿主为垂直方向时，本实例将跟随本变量向左排列
var height: int

## 类场景实例化方法
static func create(new_column: int, new_height: int) -> NumberArrayDisplayer_Member:
	var node: NumberArrayDisplayer_Member = cps.instantiate()
	node.column = new_column
	node.height = new_height
	return node
