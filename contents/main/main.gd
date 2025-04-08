extends Node2D
class_name Main
## 主场景根类

## 伪单例FakeSingleton
static var fs: Main:
	get:
		if (fs == null): #如果fs为空
			push_error("Main: 在试图获取fs时无法返回有效值，因为：解引用fs时返回null。")
			return null
		return fs

#@onready var n_back_color: ColorRect = $BackColor as ColorRect
@onready var n_paper_area: Node2D = $PaperArea as Node2D
@onready var n_menu_cover_button: TextureButton = $MenuCoverButton as TextureButton

enum ErrorHandle{

}
## 工具数织报错原因类型
enum ErrorType{
	NULL_REFERENCE, #解引用时取得意外的空引用

}
## 焦点所在的工具，联动于SideBar的工具详细层
enum FocusTool{
	NONE, #无，也是拖手工具
	BRUSH, #笔刷工具
}

const ICON_TEXTURES: Dictionary[StringName, CompressedTexture2D] = {
	&"Interact_Point": preload("res://contents/icon_interact_0_point.png"),
	&"Selection_Point": preload("res://contents/icon_selection_0_point.png"),
	&"Edit_Point": preload("res://contents/icon_edit_point_0.png"),
	&"Lock_Point": preload("res://contents/icon_lock_point_0.png"),
	&"Hand": preload("res://contents/icon_hand_0.png"),
	&"Menu": preload("res://contents/icon_menu_0.png"),
	&"Back": preload("res://contents/icon_back_0.png"),
}

## 窗口最小尺寸
const WINDOW_SIZE_MINIMUM: Vector2i = Vector2i(960, 540)
## 窗口默认尺寸
const WINDOW_SIZE_DEFAULT: Vector2i = Vector2i(1920, 1080)
## 默认题纸上的工具图标占画面纵向宽度比率
const NUMBER_BAR_ICON_SIZE_RATE: float = 0.25
## 砖瓦一般大小(边长)，单位是像素，该值需要手动参考tile_set中的砖瓦像素尺寸设定值。用于参与网格的变换计算
const TILE_NORMAL_SIZE: float = 16.0

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
## 焦点工具，联动于SideBar
static var focus_tool: FocusTool = FocusTool.NONE

func _enter_tree() -> void:
	fs = self #定义伪单例
	get_window().min_size = WINDOW_SIZE_MINIMUM #设置窗口最小尺寸

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	n_paper_area.position = Vector2(LayersBar.bar_width, 0.0) #更新题纸区域的坐标

func push_error_format(source_class_name: String, error_handle: ErrorHandle, error_type: ErrorType) -> void:
	pass #### 以后写

#region 信号方法
## 任意按钮被点击时触发信号对应的捕获方法，按钮名具有以下前缀：SideButton表侧边栏底层按钮，MenuButton表菜单按钮，ClassButton表工具类别层按钮，DetailButton表工具详细层按钮
static func on_button_trigged(button_name: StringName) -> void:
	match (button_name): #匹配检查button_name
		&"SideButton_InteractClass": #侧边栏按钮-交互类
			SideBar.fs.switch_focus(SideBar.FocusClass.INTERACT, FocusTool.NONE) #将侧边栏焦点切换到类别层的交互类
		&"SideButton_SelectionClass": #侧边栏按钮-选区类
			SideBar.fs.switch_focus(SideBar.FocusClass.SELECTION, FocusTool.NONE) #将侧边栏焦点切换到类别层的选区类
		&"SideButton_EditClass": #侧边栏按钮-擦写类
			SideBar.fs.switch_focus(SideBar.FocusClass.EDIT, FocusTool.NONE) #将侧边栏焦点切换到类别层的擦写类
		&"SideButton_LockClass": #侧边栏按钮-锁定类
			SideBar.fs.switch_focus(SideBar.FocusClass.LOCK, FocusTool.NONE) #将侧边栏焦点切换到类别层的锁定类
		&"SideButton_Menu": #侧边栏按钮-菜单
			is_menu_open = true #打开菜单
		&"MenuButton_CloseMenu": #菜单按钮-关闭菜单
			is_menu_open = false #关闭菜单
		&"ClassButton_Back": #侧边栏工具类别层按钮-返回底部
			SideBar.fs.switch_focus(SideBar.FocusClass.NONE, FocusTool.NONE) #将侧边栏焦点切换到底部
		&"ClassButton_Brush": #侧边栏工具类别层按钮-笔刷工具
			SideBar.fs.switch_focus(SideBar.FocusClass.EDIT, FocusTool.BRUSH) #将侧边栏焦点切换到底部
		&"DetailButton_Back": #侧边栏工具详细层按钮-返回类别层
			SideBar.fs.switch_focus(SideBar.focus_class, FocusTool.NONE) #将侧边栏焦点切换到上一级焦点类别
#endregion
