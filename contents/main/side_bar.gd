extends Node2D
class_name SideBar
## 侧边栏。

@onready var n_bar_color: ColorRect = $BarColor as ColorRect
@onready var n_shadow: Sprite2D = $Shadow as Sprite2D
@onready var n_buttons: Array[SideButton] = [
	$SideButton_Misc as SideButton
]

## 侧边栏宽度乘数，基于视口纵向长度
const BAR_WIDTH_MULTI: float = 1.0 / 6.0
## 阴影缩放X基值乘数，基于视口纵向长度
const SHADOW_SCALE_X_BASE_MULTI: float = 2.0 / 1080.0
## 侧边栏顶部空隔乘数，基于视口纵向长度
const BAR_TOP_SPACE_MULTI: float = 0.2
## 侧边栏按钮默认纵向长度乘数，基于视口纵向宽度
const BAR_BUTTON_HEIGHT_MULTI: float = 0.2
## 侧边栏按钮间隔乘数，基于视口纵向长度
const BAR_BUTTONS_SPACING_MULTI: float = 0.05
## 侧边栏底部空隔乘数，基于视口纵向长度
const BAR_BOTTOM_SPACE_MULTI: float = 0.1
## 按钮最大缩放率
const BUTTON_RESIZE_RATE_MAX: float = 1.0

static var bar_width: float = 180.0

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size)
	position = Vector2(window_size.x, window_size.y / 2.0)
	n_bar_color.size = Vector2(window_size.y * BAR_WIDTH_MULTI, window_size.y)
	n_bar_color.position = Vector2(-n_bar_color.size.x, n_bar_color.size.y / -2.0)
	n_shadow.scale = Vector2(SHADOW_SCALE_X_BASE_MULTI * window_size.y, window_size.y)
	n_shadow.position = Vector2(n_bar_color.position.x - n_shadow.texture.get_size().x * n_shadow.scale.x / 2.0, 0.0)
	## 侧边按钮的排列和缩放
	var buttons_space: Vector2 = Vector2((window_size.x * BAR_TOP_SPACE_MULTI + window_size.x * (1.0 - BAR_BOTTOM_SPACE_MULTI)) / 2.0, (1.0 - BAR_BOTTOM_SPACE_MULTI - BAR_TOP_SPACE_MULTI) * window_size.x) #用于放置所有按钮的按钮空间，x表示按钮空间的中点Y的值，y表示按钮空间的半长
	var buttons_total_size: float = n_buttons.size() * window_size.x * BAR_BUTTON_HEIGHT_MULTI + clampi(n_buttons.size() - 1, 0, 114514) * window_size.x * BAR_BUTTONS_SPACING_MULTI #计算所有按钮所占据的空间纵向长度，包括它们之间的间隙
	var resize_rate: float = buttons_space.y * 2 / buttons_total_size #求按钮缩放率，该值应被乘入按钮的缩放大小中
	resize_rate = clampf(resize_rate, 0.0, BUTTON_RESIZE_RATE_MAX)
	for n_button in n_buttons:
		n_button.scale = Vector2.ONE * resize_rate
