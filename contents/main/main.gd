extends Node2D
class_name Main
## 主场景根类

## 伪单例
static var fs: Main

@onready var n_back_color: ColorRect = $BackColor as ColorRect

func _enter_tree() -> void:
	fs = self
