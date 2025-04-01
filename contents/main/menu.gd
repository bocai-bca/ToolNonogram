extends Panel
class_name Main_Menu
## 菜单

## 伪单例FakeSingleton
static var fs: Main_Menu

@onready var n_menu_container: VBoxContainer = $MenuContainer as VBoxContainer
@onready var n_menu_button_close_menu: Button = $MenuContainer/MenuButton_CloseMenu as Button
@onready var n_menu_button_new: Button = $MenuContainer/PaperButtons/MenuButton_New as Button
@onready var n_menu_button_open: Button = $MenuContainer/PaperButtons/MenuButtton_Open as Button
@onready var n_menu_button_save: Button = $MenuContainer/PaperButtons/MenuButton_Save as Button
@onready var n_menu_button_clear: Button = $MenuContainer/PaperButtons/MenuButton_Clear as Button
@onready var n_menu_button_sandboxize: Button = $MenuContainer/PaperButtons/MenuButton_Sandboxize as Button
@onready var n_menu_button_create_puzzle: Button = $MenuContainer/PaperButtons/MenuButton_CreatePuzzle as Button
@onready var n_menu_button_settings: Button = $MenuContainer/MiscButtons/MenuButton_Settings as Button
@onready var n_menu_button_about: Button = $MenuContainer/MiscButtons/MenuButton_About as Button
@onready var n_menu_buttons_paper: Array[Button] = [n_menu_button_new,n_menu_button_open,n_menu_button_save,n_menu_button_clear,n_menu_button_sandboxize,n_menu_button_create_puzzle]
@onready var n_menu_buttons_misc: Array[Button] = [n_menu_button_settings, n_menu_button_about]
@onready var n_text_length_test_button: Button = $TextLengthTestButton as Button

## 菜单背景颜色，施加给self_modulate属性
const MENU_BACKGROUND_COLOR: Color = Color(0.9, 0.9, 0.9, 1.0)
## 菜单尺寸缩放倍率，基于视口尺寸
const MENU_SIZE: Vector2 = Vector2(0.9, 0.95)
## 菜单开关变换动画的过程时长，不可为零
const MENU_ANIMATION_TIME: float = 0.6
## 菜单面板的圆角半径，需要手动根据theme[Panel/styles/panel].corner_radius_top_*设置，用于容器的尺寸的计算
const MENU_THEME_PANEL_CORNER_RADIUS: float = 50.0
## 题纸系列按钮的网格列数，需要手动根据节点PaperButtons的columns设置，不可小于1，用于按钮的最小宽度计算
const PAPER_BUTTONS_COLUMNS: int = 3
## 其他系列按钮的网格列数，需要手动根据节点MiscButtons的子节点数量设置，不可小于1，用于按钮的最小宽度计算
const MISC_BUTTONS_COLUMNS: int = 2
## Control节点主题设置中按钮的横向间隔长度，用于按钮的最小宽度计算
const BUTTONS_SPACING_X: float = 4.0
## Control节点主题设置中默认字体大小，用于按钮字体大小的计算
const DEFAULT_FONT_SIZE: float = 64.0


## 菜单阴影大小缓存
static var shadow_size: float = 108.0
## 菜单开关变换动画倒计时，为0.0时表示到达终点，时间的起点由常量MENU_ANIMATION_TIME决定
static var animation_timer: float = 0.0

func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	## 00将按钮的触发信号连接到一个lambda方法，该方法会调用Main的按钮触发方法，相当于将信号直接连接到Main并使用硬编码赋予一个按钮名
	n_menu_button_close_menu.pressed.connect( #关闭菜单
		func(): Main.on_button_trigged(&"MenuButton_CloseMenu"))
	n_menu_button_new.pressed.connect( #新建题纸
		func(): Main.on_button_trigged(&"MenuButton_New"))
	n_menu_button_open.pressed.connect( #打开题纸
		func(): Main.on_button_trigged(&"MenuButton_Open"))
	n_menu_button_save.pressed.connect( #保存题纸
		func(): Main.on_button_trigged(&"MenuButton_Save"))
	n_menu_button_clear.pressed.connect( #清除网格
		func(): Main.on_button_trigged(&"MenuButton_Clear"))
	n_menu_button_sandboxize.pressed.connect( #沙盒化
		func(): Main.on_button_trigged(&"MenuButton_Sandboxize"))
	n_menu_button_create_puzzle.pressed.connect( #创建题目
		func(): Main.on_button_trigged(&"MenuButton_CreatePuzzle"))
	n_menu_button_settings.pressed.connect( #设置
		func(): Main.on_button_trigged(&"MenuButton_Settings"))
	n_menu_button_about.pressed.connect( #关于
		func(): Main.on_button_trigged(&"MenuButton_About"))
	## /00
	

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
	var menu_container_size: Vector2 = Vector2(size.x - 2.0 * MENU_THEME_PANEL_CORNER_RADIUS, size.y - MENU_THEME_PANEL_CORNER_RADIUS) #计算并应用菜单容器的尺寸
	#n_menu_container.size需要被延迟设置
	n_menu_container.position = MENU_THEME_PANEL_CORNER_RADIUS * Vector2.ONE #计算并应用菜单容器的坐标
	## /01
	## 02更新按钮的尺寸属性
	var minimum_width_for_per_paper_button: float = (menu_container_size.x - BUTTONS_SPACING_X * (PAPER_BUTTONS_COLUMNS - 1)) / PAPER_BUTTONS_COLUMNS #计算每个属于题纸系列的按钮的最小宽度属性的值
	for n_paper_button in n_menu_buttons_paper: #遍历所有属于题纸系列的按钮
		n_paper_button.custom_minimum_size = Vector2(minimum_width_for_per_paper_button, 0.0) #设置自定义最小尺寸
		n_paper_button.add_theme_font_size_override(&"font_size", clampf(n_paper_button.custom_minimum_size.x / test_text_length(n_paper_button.text), 0.0, 1.0) * DEFAULT_FONT_SIZE) #计算并设置使文本能完全放置在按钮中所需的最大字体大小
	var minimum_width_for_per_misc_button: float = (menu_container_size.x - BUTTONS_SPACING_X * (MISC_BUTTONS_COLUMNS - 1)) / MISC_BUTTONS_COLUMNS #计算每个属于其他系列的按钮的最小宽度属性的值
	for n_misc_button in n_menu_buttons_misc: #遍历所有属于其他系列的按钮
		n_misc_button.custom_minimum_size = Vector2(minimum_width_for_per_misc_button, 0.0) #设置自定义最小尺寸		
		n_misc_button.add_theme_font_size_override(&"font_size", clampf(n_misc_button.custom_minimum_size.x / test_text_length(n_misc_button.text), 0.0, 1.0) * DEFAULT_FONT_SIZE) #计算并设置使文本能完全放置在按钮中所需的最大字体大小
	## /02
	n_menu_container.size = menu_container_size #设置菜单容器尺寸
	

## 测试文本长度，测试置于菜单按钮中的文本想要显示全所需的长度，返回该长度。测试节点使用默认主题字体大小，该值应当与常量DEFAULT_FONT_SIZE相同。
## 本方法必须在ready之后调用，如果在ready之前调用或其他原因导致调用本方法时n_text_length_test_button为null，本方法将报错并返回0.0
func test_text_length(text: String) -> float:
	if (n_text_length_test_button == null):
		push_error("Main_Menu: 方法test_text_length()提前退出，因为：解引用n_text_length_test_button时返回null。")
		return 0.0
	## 00测试节点复原
	n_text_length_test_button.text = ""
	n_text_length_test_button.size = Vector2.ZERO
	## /00
	## 01输入测试文本并获取文本
	n_text_length_test_button.text = text
	n_text_length_test_button.size = Vector2.ZERO
	return n_text_length_test_button.size.x
