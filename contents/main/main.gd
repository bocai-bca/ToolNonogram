extends Node2D
class_name Main
## 主场景根类

## 伪单例FakeSingleton
static var fs: Main

@onready var n_back_color: ColorRect = $BackColor as ColorRect
@onready var n_base_grids: EditableGrids = $BaseGrids as EditableGrids
@onready var n_menu_cover_button: TextureButton = $MenuCoverButton as TextureButton

const ICON_TEXTURES: Dictionary[StringName, CompressedTexture2D] = {
	&"Interact_Point": preload("res://contents/icon_interact_0_point.png"),
	&"Selection_Point": preload("res://contents/icon_selection_0_point.png"),
	&"Edit_Point": preload("res://contents/icon_edit_point_0.png"),
	&"Hand": preload("res://contents/icon_hand_0.png"),
	&"Menu": preload("res://contents/icon_menu_0.png"),
}

## 窗口最小尺寸
const WINDOW_SIZE_MINIMUM: Vector2i = Vector2i(960, 540)
## 窗口默认尺寸
const WINDOW_SIZE_DEFAULT: Vector2i = Vector2i(1920, 1080)
## 默认题纸上的工具图标占画面纵向宽度比率
const NUMBER_BAR_ICON_SIZE_RATE: float = 0.25

## 当前菜单是否处于开启状态
static var is_menu_open: bool:
	get:
		return is_menu_open
	set(value):
		Main_Menu.animation_timer = Main_Menu.MENU_ANIMATION_TIME #将倒计时设置到起点
		is_menu_open = value
		if (not (fs != null and fs.n_menu_cover_button != null)): #防空引用
			push_error("Main: 在设置属性\"is_menu_open\"时取消对对象\"n_menu_cover_button\"的属性\"mouse_filter\"的设置，因为：解引用fs或fs.n_menu_cover_button时返回null。")
			return
		if (value): #如果传入的参数是true
			fs.n_menu_cover_button.mouse_filter = Control.MOUSE_FILTER_STOP #开启菜单遮掩按钮的鼠标输入拦截
		else: #否则(传入的参数是false)
			fs.n_menu_cover_button.mouse_filter = Control.MOUSE_FILTER_IGNORE #关闭菜单遮掩按钮的鼠标输入拦截
## 当前答题网格缩放格数，单位为格。代表当前画面长宽比下横向能显示多少列格子
static var grids_zoom_blocks: int = 5

func _enter_tree() -> void:
	fs = self #定义伪单例
	get_window().min_size = WINDOW_SIZE_MINIMUM #设置窗口最小尺寸

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	n_back_color.size = get_window().size

#region 信号方法
static func on_button_trigged(button_name: StringName) -> void:
	match (button_name): #匹配检查button_name
		&"SideButton_Menu": #侧边栏按钮-菜单
			is_menu_open = true #打开菜单
		&"MenuButton_CloseMenu": #菜单按钮-关闭菜单
			is_menu_open = false #关闭菜单
#endregion
