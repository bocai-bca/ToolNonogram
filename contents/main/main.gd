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
	SCALER, #缩放工具
	RULER, #量尺工具
	UNDO_REDO, #撤销重做
	SELECTION_FAST_EDIT, #选区快速编辑
	SELECTION_EDIT_MANUALLY, #选区精确编辑
	SELECTION_UNDO_REDO, #选区撤销重做
	SELECTION_END, #选区结束
	BRUSH, #笔刷工具
	ERASER, #擦除工具
	FILL, #填充工具
	LOCK, #锁定工具
	SMART_LOCK, #智能锁定
}

const ICON_TEXTURES: Dictionary[StringName, CompressedTexture2D] = {
	&"Class_Interact": preload("res://contents/icon_class_interact_0.png"),
	&"Class_Selection": preload("res://contents/icon_class_selection_0.png"),
	&"Class_Edit": preload("res://contents/icon_class_edit_0.png"),
	&"Class_Lock": preload("res://contents/icon_class_lock_0.png"),
	&"Detail_Brush": preload("res://contents/icon_detail_brush_0.png"),
	&"Detail_Brush_Brush": preload("res://contents/icon_detail_brush_brush_0.png"),
	&"Detail_Brush_Pencil": preload("res://contents/icon_detail_brush_pencil_0.png"),
	&"Detail_Eraser": preload("res://contents/icon_detail_eraser_0.png"),
	&"Detail_Eraser_Dishcloth": preload("res://contents/icon_detail_eraser_dishcloth_0.png"),
	&"Detail_Eraser_Eraser": preload("res://contents/icon_detail_eraser_eraser_0.png"),
	&"Detail_Fill_Type_Fill": preload("res://contents/icon_detail_fill_type_fill.png"),
	&"Detail_Fill_Type_Cross": preload("res://contents/icon_detail_fill_type_cross.png"),
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
const TILE_NORMAL_SIZE: float = 160.0

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
## 各工具的详细层状态。随着将来添加越来越多的工具，请尽量考虑将工具的详细层配置数据存放在此成员中
static var tools_detail_state: ToolsDetailState = ToolsDetailState.new()
## 各菜单的详细状态数据(包含主菜单和弹出菜单)
static var menu_detail_state: MenuDetailState = MenuDetailState.new()

func _enter_tree() -> void:
	fs = self #定义伪单例
	get_window().min_size = WINDOW_SIZE_MINIMUM #设置窗口最小尺寸

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	n_paper_area.position = Vector2(LayersBar.bar_width, 0.0) #更新题纸区域的坐标

func push_error_format(source_class_name: String, error_handle: ErrorHandle, error_type: ErrorType) -> void:
	pass #### 以后写

## 按钮禁用检查，传入一个按钮名称，返回该按钮在当前状态下是否应该禁用(返回true代表禁用)。请妥善考虑本方法的调用频率
static func button_disable_check(button_name: StringName) -> bool:
	match (button_name):
		&"DetailButton_ScaleLarge": #侧边栏工具详细层按钮-放大
			return false
		&"DetailButton_ScaleSmall": #侧边栏工具详细层按钮-缩小
			return false
		&"DetailButton_BrushModeBrush": #侧边栏工具详细层按钮-笔刷工具.模式.画笔
			return tools_detail_state.brush_mode == ToolsDetailState.BrushMode.BRUSH
		&"DetailButton_BrushModePencil": #侧边栏工具详细层按钮-笔刷工具.模式.铅笔
			return tools_detail_state.brush_mode == ToolsDetailState.BrushMode.PENCIL
		&"DetailButton_BrushFillType_Fill": #侧边栏工具详细层按钮-笔刷工具.填充模式.实心块
			return tools_detail_state.brush_fill_type == ToolsDetailState.ToolFillType.FILL
		&"DetailButton_BrushFillType_Cross": #侧边栏工具详细层按钮-笔刷工具.填充模式.叉叉
			return tools_detail_state.brush_fill_type == ToolsDetailState.ToolFillType.CROSS
		&"DetailButton_EraserModeDishcloth": #侧边栏工具详细层按钮-擦除工具.模式.抹布
			return tools_detail_state.eraser_mode == ToolsDetailState.EraserMode.DISHCLOTH
		&"DetailButton_EraserModeEraser": #侧边栏工具详细层按钮-擦除工具.模式.橡皮
			return tools_detail_state.eraser_mode == ToolsDetailState.EraserMode.ERASER
	return false

#region 信号方法
## 任意按钮被点击时触发信号对应的捕获方法，按钮名具有以下前缀：SideButton表侧边栏底层按钮，MenuButton表菜单按钮，ClassButton表工具类别层按钮，DetailButton表工具详细层按钮，Popup表弹出菜单
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
			NumberBar.icon_texture = ICON_TEXTURES[&"Hand"] #将工具提示图标设为拖手图标
		&"ClassButton_Scaler": #侧边栏工具类别层按钮-缩放工具
			SideBar.fs.switch_focus(SideBar.FocusClass.INTERACT, FocusTool.SCALER) #将侧边栏焦点切换到交互-缩放工具
		&"ClassButton_Brush": #侧边栏工具类别层按钮-笔刷工具
			SideBar.fs.switch_focus(SideBar.FocusClass.EDIT, FocusTool.BRUSH) #将侧边栏焦点切换到擦写-笔刷工具
			if (tools_detail_state.brush_mode == ToolsDetailState.BrushMode.BRUSH): #如果笔刷模式为画笔
				NumberBar.icon_texture = ICON_TEXTURES[&"Detail_Brush_Brush"]
			else: #否则
				NumberBar.icon_texture = ICON_TEXTURES[&"Detail_Brush_Pencil"]
		&"ClassButton_Eraser": #侧边栏工具类别层按钮-擦除工具
			SideBar.fs.switch_focus(SideBar.FocusClass.EDIT, FocusTool.ERASER) #将侧边栏焦点切换到擦写-擦除工具
			if (tools_detail_state.eraser_mode == ToolsDetailState.EraserMode.DISHCLOTH): #如果擦除模式为抹布
				NumberBar.icon_texture = ICON_TEXTURES[&"Detail_Eraser_Dishcloth"]
			else: #否则
				NumberBar.icon_texture = ICON_TEXTURES[&"Detail_Eraser_Eraser"]
		&"DetailButton_Back": #侧边栏工具详细层按钮-返回类别层
			SideBar.fs.switch_focus(SideBar.focus_class, FocusTool.NONE) #将侧边栏焦点切换到上一级焦点类别
			NumberBar.icon_texture = ICON_TEXTURES[&"Hand"] #将工具提示图标设为拖手图标
		&"DetailButton_ScaleLarge": #侧边栏工具详细层按钮-放大
			EditableGrids.update_animation_data(EditableGrids.display_offset, clampi(grids_zoom_blocks - 1, 1, EditableGrids.global_grid_size.y)) #调用题纸网格类的更新动画方法
		&"DetailButton_ScaleSmall": #侧边栏工具详细层按钮-缩小
			EditableGrids.update_animation_data(EditableGrids.display_offset, clampi(grids_zoom_blocks + 1, 1, EditableGrids.global_grid_size.y)) #调用题纸网格类的更新动画方法
		&"DetailButton_BrushModeBrush": #侧边栏工具详细层按钮-笔刷工具.模式.画笔
			tools_detail_state.brush_mode = ToolsDetailState.BrushMode.BRUSH #将工具详细状态的笔刷模式设为画笔
			NumberBar.icon_texture = ICON_TEXTURES[&"Detail_Brush_Brush"] #将工具提示图标设为笔刷工具.画笔图标
		&"DetailButton_BrushModePencil": #侧边栏工具详细层按钮-笔刷工具.模式.铅笔
			tools_detail_state.brush_mode = ToolsDetailState.BrushMode.PENCIL #将工具详细状态的笔刷模式设为铅笔
			NumberBar.icon_texture = ICON_TEXTURES[&"Detail_Brush_Pencil"] #将工具提示图标设为笔刷工具.铅笔图标
		&"DetailButton_BrushFillType_Fill": #侧边栏工具详细层按钮-笔刷工具.填充模式.实心块填充
			tools_detail_state.brush_fill_type = ToolsDetailState.ToolFillType.FILL #将工具详细状态的笔刷填充模式设为实心块
		&"DetailButton_BrushFillType_Cross": #侧边栏工具详细层按钮-笔刷工具.填充模式.叉叉填充
			tools_detail_state.brush_fill_type = ToolsDetailState.ToolFillType.CROSS #将工具详细状态的笔刷填充模式设为叉叉
		&"DetailButton_EraserModeDishcloth": #侧边栏工具详细层按钮-擦除工具.模式.抹布
			tools_detail_state.eraser_mode = ToolsDetailState.EraserMode.DISHCLOTH #将工具详细状态的擦除模式设为抹布
			NumberBar.icon_texture = ICON_TEXTURES[&"Detail_Eraser_Dishcloth"] #将工具提示图标设为擦除工具.抹布图标
		&"DetailButton_EraserModeEraser": #侧边栏工具详细层按钮-擦除工具.模式.橡皮
			tools_detail_state.eraser_mode = ToolsDetailState.EraserMode.ERASER #将工具详细状态的擦除模式设为橡皮
			NumberBar.icon_texture = ICON_TEXTURES[&"Detail_Eraser_Eraser"] #将工具提示图标设为擦除工具.橡皮图标
		&"Popup_NewPaper_Mode_Puzzle": #弹出菜单-新建题纸.游戏模式.解题
			menu_detail_state.popup_newpaper_mode = MenuDetailState.GameMode.PUZZLE #将游戏模式设为解题
		&"Popup_NewPaper_Mode_Sandbox": #弹出菜单-新建题纸.游戏模式.沙盒
			menu_detail_state.popup_newpaper_mode = MenuDetailState.GameMode.SANDBOX #将游戏模式设为沙盒
		&"Popup_NewPaper_Confirm": #弹出菜单-新建题纸.确认并创建
			pass
		&"Popup_NewPaper_Cancel": #弹出菜单-新建题纸.取消
			pass
	SideBar.update_detail_buttons_disable() #更新按钮禁用状态
#endregion
