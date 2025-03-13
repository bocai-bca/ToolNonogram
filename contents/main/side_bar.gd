extends Node2D
class_name SideBar
## 侧边栏。

@onready var n_bar_color: ColorRect = $BarColor as ColorRect
@onready var n_shadow: Sprite2D = $Shadow as Sprite2D
@onready var n_buttons: Array[SideButton] = [
	$SideButton_Misc as SideButton
]

## 侧边栏宽度比例，基于视口纵向长度
const BAR_WIDTH_SCALE: float = 1.0 / 6.0
## 阴影缩放X基值比例，基于视口纵向长度
const SHADOW_SCALE_X_BASE_SCALE: float = 2.0 / 1080.0

static var bar_width: float = 180.0

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size)
	position = Vector2(window_size.x, window_size.y / 2.0)
	n_bar_color.size = Vector2(window_size.y * BAR_WIDTH_SCALE, window_size.y)
	n_bar_color.position = Vector2(-n_bar_color.size.x, n_bar_color.size.y / -2.0)
	n_shadow.scale = Vector2(SHADOW_SCALE_X_BASE_SCALE * window_size.y, window_size.y)
	n_shadow.position = Vector2(n_bar_color.position.x - n_shadow.texture.get_size().x * n_shadow.scale.x / 2.0, 0.0)
	## 接下来写侧边按钮的排列和缩放
