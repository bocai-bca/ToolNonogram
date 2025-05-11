extends Panel
class_name Main_Menu
## 菜单

## 本类中大量使用了对节点的引用，以及节点列表。后续可以考虑如何优化这里

## 伪单例FakeSingleton
static var fs: Main_Menu:
	get:
		if (fs == null): #如果fs为空
			push_error("Main_Menu: 在试图获取fs时无法返回有效值，因为：解引用fs时返回null。")
			return null
		return fs

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
@onready var n_menu_button_autofill_close: Button = $MenuContainer/AutofillButtons/MenuButton_AutofillClose as Button
@onready var n_menu_button_autofill_normal: Button = $MenuContainer/AutofillButtons/MenuButton_AutofillNormal as Button
@onready var n_menu_button_autofill_smart: Button = $MenuContainer/AutofillButtons/MenuButton_AutofillSmart as Button
@onready var n_menu_subtitle_paper: Label = $MenuContainer/SubTitle_Paper as Label
@onready var n_menu_subtitle_autofill: Label = $MenuContainer/SubTitle_Autofill as Label
@onready var n_menu_subtitle_misc: Label = $MenuContainer/SubTitle_Misc as Label
@onready var n_menu_subtitles: Array[Label] = [n_menu_subtitle_paper, n_menu_subtitle_autofill, n_menu_subtitle_misc]
@onready var n_menu_buttons_paper: Array[Button] = [n_menu_button_new,n_menu_button_open,n_menu_button_save,n_menu_button_clear,n_menu_button_sandboxize,n_menu_button_create_puzzle]
@onready var n_menu_buttons_autofill: Array[Button] = [n_menu_button_autofill_close, n_menu_button_autofill_normal, n_menu_button_autofill_smart]
@onready var n_menu_buttons_misc: Array[Button] = [n_menu_button_settings, n_menu_button_about]
@onready var n_text_length_test_button: Button = $TextLengthTestButton as Button
@onready var n_paper_buttons_container: GridContainer = $MenuContainer/PaperButtons as GridContainer
@onready var n_autofill_buttons_container: HBoxContainer = $MenuContainer/AutofillButtons as HBoxContainer
@onready var n_misc_buttons_container: HBoxContainer = $MenuContainer/MiscButtons as HBoxContainer
## 长度测试节点，其Y坐标用来测试菜单中按钮的总长度占用，以便计算缩放
@onready var n_length_test: Control = $MenuContainer/LengthTest as Control

## 菜单背景颜色，施加给self_modulate属性
const MENU_BACKGROUND_COLOR: Color = Color(0.9, 0.9, 0.9, 1.0)
## 菜单尺寸缩放倍率，基于视口尺寸
const MENU_SIZE: Vector2 = Vector2(0.9, 0.95)
## 菜单开关变换动画的过程时长，不可为零
const MENU_ANIMATION_TIME: float = 0.6
## 菜单开关变换动画的缓动曲线值，参见ease()
const MENU_ANIMATION_EASE_CURVE: float = 5.0
## 菜单面板的圆角半径，需要手动根据theme[Panel/styles/panel].corner_radius_top_*设置，用于容器的尺寸的计算
const MENU_THEME_PANEL_CORNER_RADIUS: float = 50.0
## 题纸系列按钮的网格列数，需要手动根据节点PaperButtons的columns设置，不可小于1，用于按钮的最小宽度计算
const PAPER_BUTTONS_COLUMNS: int = 3
## 自动填充系列按钮的网格列数，需要手动根据节点AutofillButtons的子节点数量设置，不可小于1，用于按钮的最小宽度计算
const AUTOFILL_BUTTONS_COLUMNS: int = 3
## 其他系列按钮的网格列数，需要手动根据节点MiscButtons的子节点数量设置，不可小于1，用于按钮的最小宽度计算
const MISC_BUTTONS_COLUMNS: int = 2
## Control节点主题设置中按钮的横向间隔长度，用于按钮的最小宽度计算
const BUTTONS_SPACING_X: float = 4.0
## Control节点主题设置中默认字体大小，用于按钮字体大小的计算
const DEFAULT_FONT_SIZE: float = 64.0
## Label节点主题设置中默认行间距大小，用于菜单纵向缩放计算
const DEFAULT_LABEL_LINE_SPACING: float = 3.0
## 纵向排列容器的默认元素间距，用于菜单纵向缩放计算
const DEFAULT_VBOX_CONTAINER_SEPARATION: float = 4.0
## 横向排列容器的默认元素间距，用于菜单纵向缩放计算
const DEFAULT_HBOX_CONTAINER_SEPARATION: float = 4.0
## 网格容器的默认元素纵向间距，用于菜单纵向缩放计算
const DEFAULT_GRID_CONTAINER_V_SEPARATION: float = 4.0

## 菜单阴影大小缓存
static var shadow_size: float = 108.0
## 菜单开关变换动画倒计时，为0.0时表示到达终点，时间的起点由常量MENU_ANIMATION_TIME决定
static var animation_timer: float = 0.0
## 菜单元素的默认总长，在节点第一次被process时初始化然后投入运作，为-1.0时表示未初始化
static var menu_elements_length: float = -1.0

func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	## 00将按钮的触发信号连接到一个lambda方法，该方法会调用Main的按钮触发方法，相当于将信号直接连接到Main并使用硬编码赋予一个按钮名
	n_menu_button_close_menu.pressed.connect( #关闭菜单
		func(): Main.on_button_trigged(&"MenuButton_CloseMenu"))
	n_menu_button_new.pressed.connect( #新建题纸
		func(): Main.on_button_trigged(&"MenuButton_Paper_New"))
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
		position = open_target_pos.lerp(close_target_pos, ease(animation_timer / MENU_ANIMATION_TIME, MENU_ANIMATION_EASE_CURVE)) #使坐标从关闭状态变换到开启状态，由于计时器是反着计时的，为0.0时才是终点，所以move_toward时需要将起点和终点取反
	else: #否则(当前菜单是关闭状态)
		position = close_target_pos.lerp(open_target_pos, ease(animation_timer / MENU_ANIMATION_TIME, MENU_ANIMATION_EASE_CURVE)) #使坐标从关闭状态变换到开启状态，由于计时器是反着计时的，为0.0时才是终点，所以move_toward时需要将起点和终点取反
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
		n_paper_button.add_theme_font_size_override(&"font_size", int(clampf(n_paper_button.custom_minimum_size.x / test_text_length(n_paper_button.text), 0.0, 1.0) * DEFAULT_FONT_SIZE)) #计算并设置使文本能完全放置在按钮中所需的最大字体大小
	var minimum_width_for_per_autofill_button: float = (menu_container_size.x - BUTTONS_SPACING_X * (AUTOFILL_BUTTONS_COLUMNS - 1)) / AUTOFILL_BUTTONS_COLUMNS #计算每个属于自动填充系列的按钮的最小宽度属性的值
	for n_autofill_button in n_menu_buttons_autofill: #遍历所有属于自动填充系列的按钮
		n_autofill_button.custom_minimum_size = Vector2(minimum_width_for_per_autofill_button, 0.0) #设置自定义最小尺寸
		n_autofill_button.add_theme_font_size_override(&"font_size", int(clampf(n_autofill_button.custom_minimum_size.x / test_text_length(n_autofill_button.text), 0.0, 1.0) * DEFAULT_FONT_SIZE)) #计算并设置使文本能完全放置在按钮中所需的最大字体大小
	var minimum_width_for_per_misc_button: float = (menu_container_size.x - BUTTONS_SPACING_X * (MISC_BUTTONS_COLUMNS - 1)) / MISC_BUTTONS_COLUMNS #计算每个属于其他系列的按钮的最小宽度属性的值
	for n_misc_button in n_menu_buttons_misc: #遍历所有属于其他系列的按钮
		n_misc_button.custom_minimum_size = Vector2(minimum_width_for_per_misc_button, 0.0) #设置自定义最小尺寸
		n_misc_button.add_theme_font_size_override(&"font_size", int(clampf(n_misc_button.custom_minimum_size.x / test_text_length(n_misc_button.text), 0.0, 1.0) * DEFAULT_FONT_SIZE)) #计算并设置使文本能完全放置在按钮中所需的最大字体大小
	## 	03纵向缩放。此处一些尺寸计算需要与先前横向缩放的数值取最小值
	if (menu_elements_length == -1.0): #如果元素长度未被初始化
		menu_elements_length = n_length_test.position.y #给元素长度初始化
	var vertical_resize_rate: float = clampf(menu_container_size.y / menu_elements_length, 0.1, 1.0) #根据当下菜单中元素实际的长度占用和容器能够提供的最大长度，计算按钮字体等属性的垂直缩放倍率，该倍率应被钳制在0-1之间(含)，因为超过1代表按钮将主动放大到占满空间
	for n_menu_subtitle_node in n_menu_subtitles: #遍历所有菜单小标题
		n_menu_subtitle_node.add_theme_font_size_override(&"font_size", int(vertical_resize_rate * DEFAULT_FONT_SIZE)) #设置字体大小
		n_menu_subtitle_node.add_theme_constant_override(&"line_spacing", int(vertical_resize_rate * DEFAULT_LABEL_LINE_SPACING)) #设置行间距
	for n_menu_button_node in n_menu_buttons_paper + n_menu_buttons_autofill + n_menu_buttons_misc: #遍历所有按钮
		n_menu_button_node.add_theme_font_size_override(&"font_size", int(minf(vertical_resize_rate * DEFAULT_FONT_SIZE, n_menu_button_node.get_theme_font_size(&"font_size")))) #设置字体大小
	n_menu_button_close_menu.add_theme_font_size_override(&"font_size", int(vertical_resize_rate * DEFAULT_FONT_SIZE)) #设置字体大小
	n_paper_buttons_container.add_theme_constant_override(&"v_separation", int(DEFAULT_GRID_CONTAINER_V_SEPARATION * vertical_resize_rate)) #在网格容器(题纸)的纵向元素间距上应用缩放率
	n_autofill_buttons_container.add_theme_constant_override(&"separation", int(DEFAULT_HBOX_CONTAINER_SEPARATION * vertical_resize_rate)) #在横向排列容器(自动填充)的纵向元素间距上应用缩放率
	n_misc_buttons_container.add_theme_constant_override(&"separation", int(DEFAULT_HBOX_CONTAINER_SEPARATION * vertical_resize_rate)) #在横向排列容器(其他)的元素间距上应用缩放率
	add_theme_constant_override(&"separation", int(DEFAULT_VBOX_CONTAINER_SEPARATION * vertical_resize_rate)) #在纵向排列容器的元素间距上应用缩放率
	## 	/03
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
