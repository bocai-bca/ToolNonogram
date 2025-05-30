extends RefCounted
class_name EditToolHandler
## 擦写工具处理器

## 当前本实例是否处于开始状态，用于在_process()中确定该次调用是开始落笔还是持续过程
var is_started: bool = false

## [虚函数-声明]过程方法，在工具按下的每个帧都调用此方法
func _process() -> void:
	pass

## [虚函数-声明]结束方法，在工具停止按下的首个帧调用此方法
func _end() -> void:
	pass
