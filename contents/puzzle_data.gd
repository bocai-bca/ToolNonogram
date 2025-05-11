extends RefCounted
class_name PuzzleData
## 题目数据

## 题目横向数据，第一层表示横排的格子，第二层表示该格子从下向上排列的数字
var horizontal: Array[PackedInt32Array] = []
## 题目纵向数据，第一层表示竖排的格子，第二层示该格子从右向左排列的数字
var vertical: Array[PackedInt32Array] = []
