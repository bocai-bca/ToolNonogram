extends Button
class_name DisableBlocker
## 禁用输入阻拦按钮，用于起到阻止鼠标对其遮盖的按钮进行交互的节点
## 本类的实例仅适用于DetailPopupBase及其子类的节点作为父节点的情况，不满足该情况当进入场景树时
## 本类的脚本不提供对其尺寸和位置的设置，通常应当考虑将其以适当关系置于Control控件树中，以自动设置相应属性

## 类场景封包ClassPackedScene
static var cps: PackedScene = preload("res://contents/detail_popup/disable_blocker.tscn") as PackedScene

func _process(delta: float) -> void:
	if (not get_parent() is DetailPopupBase): #如果其父节点不是DetailPopupBase或其子类
		push_error("DisableBlocker: 将进行自我删除，因为：父节点不是DetailPopupBase或其的继承。")
		queue_free()
		return
	visible = (get_parent() as DetailPopupBase).disabled #设置本节点的可见性，与父级菜单的启用与否相反
