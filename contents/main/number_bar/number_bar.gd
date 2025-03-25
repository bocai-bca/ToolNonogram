extends Node2D
class_name NumberBar
## 数字栏。涵盖题目数字横行、竖列和工具图标的节点树枝

## 伪单例FakeSingleton
static var fs: NumberBar



func _enter_tree() -> void:
	fs = self #定义伪单例

func _process(delta: float) -> void:
	position.x = LayersBar.bar_width #更新数字栏坐标使其贴靠到图层栏的右上角
	
