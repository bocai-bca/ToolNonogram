extends Node2D
class_name SideButton
## 侧边栏按钮。

@onready var n_body: CanvasGroup = $Body as CanvasGroup
@onready var n_up_capsule: MeshInstance2D = $Body/UpCapsule as MeshInstance2D
@onready var n_quad: MeshInstance2D = $Body/Quad as MeshInstance2D
@onready var n_down_capsule: MeshInstance2D = $Body/DownCapsule as MeshInstance2D
@onready var n_icon: MeshInstance2D = $Icon as MeshInstance2D
@onready var n_button: TextureButton = $Button as TextureButton

## 出厂默认大小，适用于100*100的图标尺寸
const DEFAULT_HIT_RECT: Rect2 = Rect2(-60.0, -60.0, 120.0, 120.0)
## 按钮体的调制(正常)
const BUTTON_BODY_MODULATE: Color = Color(0.8, 0.8, 0.8, 1.0)
## 按钮体的调制(悬浮)
const BUTTON_BODY_MODULATE_HOVER: Color = Color(0.9, 0.9, 0.9, 1.0)
## 按钮体的调制(按下)
const BUTTON_BODY_MODULATE_CLICK: Color = Color(0.5, 0.5, 0.5, 1.0)
## 按钮图标的调制(正常)
const BUTTON_ICON_MODULATE: Color = Color(0.0, 0.0, 0.0, 1.0)

## 判定框，对其赋值将影响本SideButton实例的视觉大小和按钮大小
var hit_rect: Rect2 = DEFAULT_HIT_RECT:
	get:
		return hit_rect
	set(value):
		if (not is_node_ready()): #如果节点还没ready
			## 报错并不进行操作
			push_error("SideButton: Attribute \"hit_rect\" setting was cancelled, because root node hasn't ready yet.")
			return
		n_button.size = value.size
		n_button.position = value.position
		(n_quad.mesh as QuadMesh).size = Vector2(value.size.x, value.size.y / 2.0)
		(n_up_capsule.mesh as CapsuleMesh).height = value.size.x
		(n_up_capsule.mesh as CapsuleMesh).radius = value.size.y / 4.0
		n_up_capsule.position = Vector2(0.0, value.size.y / -4.0)
		n_down_capsule.position = Vector2(0.0, value.size.y / 4.0)

func _ready() -> void:
	n_button.mouse_entered.connect(on_mouse_entered)
	n_button.mouse_exited.connect(on_mouse_exited)

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass
