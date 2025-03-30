extends Panel
class_name Main_Menu
## 菜单

## 伪单例FakeSingleton
static var fs: Main_Menu

@onready var n_menu_container: VBoxContainer = $MenuContainer as VBoxContainer
@onready var n_close_menu_button: Button = $MenuContainer/CloseMenuButton as Button

## 菜单背景颜色，施加给self_modulate属性
const MENU_BACKGROUND_COLOR: Color = Color(0.9, 0.9, 0.9, 1.0)
## 菜单尺寸缩放倍率，基于视口尺寸
const MENU_SIZE: Vector2 = Vector2(0.9, 0.95)
## 菜单开关变换动画的过程时长，不可为零
const MENU_ANIMATION_TIME: float = 0.8
## 菜单面板的圆角半径，需要手动根据theme[Panel/styles/panel].corner_radius_top_*设置，用于容器的尺寸的计算
const MENU_THEME_PANEL_CORNER_RADIUS: float = 50.0

## 菜单阴影大小缓存
static var shadow_size: float = 108.0
## 菜单开关变换动画倒计时，为0.0时表示到达终点，时间的起点由常量MENU_ANIMATION_TIME决定
static var animation_timer: float = 0.0

func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	n_close_menu_button.pressed.connect( #将关闭菜单按钮的触发信号连接到一个lambda方法，该方法会调用Main的按钮触发方法，相当于将信号直接连接到Main并使用硬编码赋予一个按钮名
		func():
			Main.on_button_trigged(&"MenuButton_CloseMenu") #调用Main的按钮触发信号函数，传入代表关闭菜单按钮的按钮名
	)

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口尺寸
	## 00更新菜单面板的位置和尺寸
	var open_target_pos: Vector2 = Vector2(window_size.x * (1.0 - MENU_SIZE.x) / 2.0, window_size.y * (1.0 - MENU_SIZE.y)) #计算菜单完全展开时的坐标
	var close_target_pos: Vector2 = Vector2(window_size.x * (1.0 - MENU_SIZE.x) / 2.0, window_size.y + shadow_size) #计算菜单完全收起时的坐标
	animation_timer = move_toward(animation_timer, 0.0, delta) #更新倒计时
	if (Main.is_menu_open): #如果当前菜单是开启状态
		position = open_target_pos.lerp(close_target_pos, ease(animation_timer / MENU_ANIMATION_TIME, 5.0)) #使坐标从关闭状态变换到开启状态，由于计时器是反着计时的，为0.0时才是终点，所以move_toward时需要将起点和终点取反
	else: #否则(当前菜单是关闭状态)
		position = close_target_pos.lerp(open_target_pos, ease(animation_timer / MENU_ANIMATION_TIME, 5.0)) #使坐标从关闭状态变换到开启状态，由于计时器是反着计时的，为0.0时才是终点，所以move_toward时需要将起点和终点取反
	size = MENU_SIZE * window_size #计算并应用尺寸
	## /00
	## 01更新菜单容器的位置和尺寸
	n_menu_container.size = Vector2(size.x - 2.0 * MENU_THEME_PANEL_CORNER_RADIUS, size.y - MENU_THEME_PANEL_CORNER_RADIUS) #计算并应用菜单容器的尺寸
	n_menu_container.position = MENU_THEME_PANEL_CORNER_RADIUS * Vector2.ONE #计算并应用菜单容器的坐标
	## /01
