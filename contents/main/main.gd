extends Node2D
class_name Main
## 主场景根类。也代表着游戏的中枢

## 伪单例FakeSingleton
static var fs: Main:
	get:
		if (fs == null): #如果fs为空
			push_error("Main: 在试图获取fs时无法返回有效值，因为：解引用fs时返回null。")
			return null
		return fs

#@onready var n_back_color: ColorRect = $BackColor as ColorRect
#@onready var n_paper_area: Node2D = $PaperArea as Node2D
@onready var n_menu_cover_button: TextureButton = $MenuCoverButton as TextureButton

## 工具数织报错处理方式
enum ErrorHandle{

}
## 工具数织报错原因类型
enum ErrorType{
	NULL_REFERENCE, #解引用时取得意外的空引用

}
## 游戏模式(只用于游戏系统，和MenuDetailState.GameMode无关)
enum GameMode{
	PUZZLE, #解题
	SANDBOX, #沙盒
}
## 自动填充状态
enum AutoFill{
	OFF, #关闭
	COMMON, #一般
	SMART, #智能
}
## 焦点所在的工具，联动于SideBar的工具详细层
enum FocusTool{
	NONE, #无，也是拖手工具
	SCALER, #缩放工具
	RULER, #量尺工具
	UNDO_REDO, #撤销重做
	LAYERS, #图层管理
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
	&"Class_Layers": preload("res://contents/icon_back_0.png"),
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
## 最多允许拥有几个图层及图层栏标签(不包含基底图层)
const MAX_LAYER_COUNT: int = 6

## [只读]自动填充服务器实例，存放一个自动填充服务器实例，通过更改不同的初始赋值可以指定使用不同的(基于不同算法的)自动填充服务器
static var AUTOFILL_SERVER_INSTANCE: AutoFillServerBase = AutoFillServer_DirectionfulScanning.new()

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
## 当前答题网格缩放格数，单位为格。代表当前画面长宽比下纵向能显示多少个格子
static var grids_zoom_blocks: int = 5
## 焦点工具，联动于SideBar
static var focus_tool: FocusTool = FocusTool.NONE
## 各工具的详细层状态。随着将来添加越来越多的工具，请尽量考虑将工具的详细层配置数据存放在此成员中
static var tools_detail_state: ToolsDetailState = ToolsDetailState.new()
## 各菜单的详细状态数据(包含主菜单和弹出菜单)
static var menu_detail_state: MenuDetailState = MenuDetailState.new()
## 游戏模式，初始化时默认处于沙盒模式
static var game_mode: GameMode = GameMode.SANDBOX
## 自动填充状态，初始化时默认处于一般模式
static var auto_fill: AutoFill = AutoFill.COMMON
## 题目数据
static var puzzle_data: PuzzleData
## 当前使用的种子(用于解题模式记录当前题目的种子)
static var current_seed: String
## 通关检查旗标，为true时需要进行通关检查，考虑进行弃用
#static var win_check_flag: bool = false
## 解题计时器-小时，更新计时器只需要给秒加数即可，重置计时器需要给三个数分别设置为0
static var puzzle_timer_hour: int = 0
## 解题计时器-分钟，更新计时器只需要给秒加数即可，重置计时器需要给三个数分别设置为0
static var puzzle_timer_minute: int = 0:
	set(value):
		puzzle_timer_minute = value
		puzzle_timer_hour += puzzle_timer_minute / 60
		puzzle_timer_minute %= 60
## 解题计时器-秒，更新计时器只需要给秒加数即可，重置计时器需要给三个数分别设置为0
static var puzzle_timer_second: float = 0.0:
	set(value):
		puzzle_timer_second = value
		puzzle_timer_minute += puzzle_timer_second / 60.0
		puzzle_timer_second = fmod(puzzle_timer_second, 60.0)
## 当前所在的焦点图层序号(0为基底图层)
static var focus_layer: int = 0
## 当前已有图层数量，表达方式为当前启用的图层中最高的序号数
static var activiting_layers_count: int = 0
## 全局网格尺寸
static var global_grid_size: Vector2i = Vector2i(5, 5) #网格实例的节点的初始尺寸是5*5

func _enter_tree() -> void:
	fs = self #定义伪单例
	get_window().min_size = WINDOW_SIZE_MINIMUM #设置窗口最小尺寸

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	#n_paper_area.position = Vector2(LayersBar.bar_width, 0.0) #更新题纸区域的坐标
	## 00Debug
	if (Input.is_action_just_pressed(&"debug_print")):
		debug_print()
	## /00

func _physics_process(delta: float) -> void:
	## 00通关检查
	#if (win_check_flag): #如果需要检查通关
		#win_check_flag = false #关闭通关检查旗标
		#if (check_puzzle_win()): #如果检查胜利时返回为true
			#puzzle_win() #使解题模式胜利
	## /00
	## 01计时器更新
	if (game_mode == GameMode.PUZZLE): #如果当前是解题模式
		puzzle_timer_second += delta #计时器加数
	## /01

func push_error_format(source_class_name: String, error_handle: ErrorHandle, error_type: ErrorType) -> void:
	pass #### 以后写

## 一个调试用的临时方法，由本实例_process调用，按下输入映射的debug_print动作即可触发
## 请通过在本方法内写入print以实现输出调试信息
func debug_print() -> void:
	pass

#func get_file_lines() -> void:
	#var num: int = 0
	#var scripts: PackedStringArray = get_file_in_folders_resursion("res://") #如果使用其他路径确保末尾带/
	#for script in scripts:
		#var fa: FileAccess = FileAccess.open(script, FileAccess.READ)
		#var lines: int = fa.get_as_text().count("\n")
		#print(script, "=", lines)
		#num += lines
	#print("总计=",num)
#func get_file_in_folders_resursion(path: String) -> PackedStringArray:
	#var files: PackedStringArray = []
	#var da: DirAccess = DirAccess.open(path)
	#for file in da.get_files():
		#if (file.ends_with(".gd")):
			#files.append(path + file)
	#for dir in da.get_directories():
		#files.append_array(get_file_in_folders_resursion(path + dir + "/"))
	#return files

## 本方法尚不确定是否要投入使用，目前考虑稍微降低一点抽象程度
## 新建游戏的高级封装，返回成功与否(如果因各种原因导致最终没有新建游戏，将返回false)
#static func start_new_game(new_mode: GameMode, new_game_settings: NewGameSettings) -> bool:
	#match (new_mode): #匹配游戏模式
		#GameMode.PUZZLE: #解题模式
			#return true
		#GameMode.SANDBOX: #沙盒模式
			#if (start_new_sandbox_old(new_game_settings.clear_grids, new_game_settings.size)): #如果新建沙盒模式时成功
				#game_mode = GameMode.SANDBOX #将游戏模式调整为沙盒
				#return true
			#return false
	#return false

## 新建解题模式游戏的低级封装
## 本方法已不适应新的需求，需逐渐被解除依赖最终彻底弃用
static func start_new_puzzle_old(new_puzzle_data: PuzzleData, new_size: Vector2i, new_seed: String) -> void:
	PaperArea.fs.clear_base_grids() #清空基本题纸的内容
	PaperArea.fs.reset_grids_size(new_size) #重设网格尺寸(不影响题纸内容)
	NumberBar.fs.resize_grids(new_size) #重设数字栏网格尺寸(不影响内容)
	puzzle_data = new_puzzle_data #设置题目数据
	current_seed = new_seed #记录种子
	NumberBar.fs.set_number_array_displayers(new_puzzle_data) #设置数字栏
	game_mode = GameMode.PUZZLE #将游戏模式设为解题
	## 00重设计时器
	puzzle_timer_hour = 0
	puzzle_timer_minute = 0
	puzzle_timer_second = 0.0
	## /00

## 新建沙盒模式游戏的低级封装
## 本方法已不适应新的需求，需逐渐被解除依赖最终彻底弃用
static func start_new_sandbox_old(clear_grids: bool, new_size: Vector2i) -> void:
	if (clear_grids): #如果需要清空网格
		PaperArea.fs.clear_base_grids() #清空基本题纸的内容
		#### 此处缺少当不清空网格时清除处于新尺寸画布外的笔迹的清除操作(如沙盒化)
	PaperArea.fs.reset_grids_size(new_size) #重设网格尺寸(不影响题纸内容)
	NumberBar.fs.resize_grids(new_size) #重设数字栏网格尺寸(不影响内容)
	game_mode = GameMode.SANDBOX #将游戏模式设为沙盒

## 新建沙盒模式游戏的低级封装(新)
static func start_new_sandbox(new_size: Vector2i) -> void:
	pass

## 沙盒化(只在解题模式有效)
static func sandboxize() -> void:
	game_mode = GameMode.SANDBOX #将模式设为沙盒模式
	NumberBar.fs.clear_number_array_displayers() #清除数字栏数字
	#### 今后加入了填充着色以后还要写对着色的剔除，使所有填充都恢复为默认填充

## 检查解题模式胜利，返回判断结果
static func check_puzzle_win() -> bool:
	return puzzle_data.is_same(PaperArea.fs.n_base_grids.to_grids_data().to_puzzle_data())

## 使解题模式胜利
static func puzzle_win() -> void:
	sandboxize() #沙盒化
	var win_popup: DetailPopup_Win = PopupManager.create_popup(&"Win") as DetailPopup_Win #新建胜利弹窗
	PopupManager.add_popup(win_popup) #将弹窗添加到场景树
	win_popup.set_contents(current_seed, global_grid_size, puzzle_timer_hour, puzzle_timer_minute, int(puzzle_timer_second)) #设置弹窗的信息

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
		#&"SideButton_SelectionClass": #侧边栏按钮-选区类
			#SideBar.fs.switch_focus(SideBar.FocusClass.SELECTION, FocusTool.NONE) #将侧边栏焦点切换到类别层的选区类
		&"SideButton_EditClass": #侧边栏按钮-擦写类
			SideBar.fs.switch_focus(SideBar.FocusClass.EDIT, FocusTool.NONE) #将侧边栏焦点切换到类别层的擦写类
		&"SideButton_LockClass": #侧边栏按钮-锁定类
			SideBar.fs.switch_focus(SideBar.FocusClass.LOCK, FocusTool.NONE) #将侧边栏焦点切换到类别层的锁定类
		&"SideButton_Menu": #侧边栏按钮-菜单
			is_menu_open = true #打开菜单
		&"MenuButton_CloseMenu": #菜单按钮-关闭菜单
			is_menu_open = false #关闭菜单
		&"MenuButton_Paper_New": #菜单按钮-新建题纸
			PopupManager.add_popup(PopupManager.create_popup(&"Paper_New")) #新建一个新建题纸弹出菜单
			is_menu_open = false #关闭菜单
		&"MenuButton_Clear": #菜单按钮-清除网格
			PaperArea.fs.clear_base_grids() #清空基本题纸的内容
			is_menu_open = false #关闭菜单
		&"MenuButton_About": #菜单按钮-关于
			PopupManager.add_popup(PopupManager.create_popup(&"About")) #新建一个关于弹出菜单
			is_menu_open = false #关闭菜单
		&"ClassButton_Back": #侧边栏工具类别层按钮-返回底部
			SideBar.fs.switch_focus(SideBar.FocusClass.NONE, FocusTool.NONE) #将侧边栏焦点切换到底部
			NumberBar.icon_texture = ICON_TEXTURES[&"Hand"] #将工具提示图标设为拖手图标
		&"ClassButton_Scaler": #侧边栏工具类别层按钮-缩放工具
			SideBar.fs.switch_focus(SideBar.FocusClass.INTERACT, FocusTool.SCALER) #将侧边栏焦点切换到交互-缩放工具
		&"ClassButton_UndoRedo": #侧边栏工具类别层按钮-撤销重做
			SideBar.fs.switch_focus(SideBar.FocusClass.INTERACT, FocusTool.UNDO_REDO) #将侧边栏焦点切换到交互-撤销重做
		&"ClassButton_Layers": #侧边栏工具类别层按钮-图层管理
			SideBar.fs.switch_focus(SideBar.FocusClass.INTERACT, FocusTool.LAYERS) #将侧边栏焦点切换倒交互-图层管理
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
		&"DetailButton_ScalerNumberBarLarger": #侧边栏工具详细层按钮-数字栏放大
			NumberBar.fs.icon_zoom_larger() #放大
		&"DetailButton_ScalerNumberBarSmaller": #侧边栏工具详细层按钮-数字栏缩小
			NumberBar.fs.icon_zoom_smaller() #缩小
		&"DetailButton_ScalerGridsLarger": #侧边栏工具详细层按钮-答题网格放大
			EditableGrids.update_animation_data(EditableGrids.display_offset, clampi(grids_zoom_blocks - 1, 1, global_grid_size.y)) #调用题纸网格类的更新动画方法
		&"DetailButton_ScalerGridsSmaller": #侧边栏工具详细层按钮-答题网格缩小
			EditableGrids.update_animation_data(EditableGrids.display_offset, clampi(grids_zoom_blocks + 1, 1, global_grid_size.y)) #调用题纸网格类的更新动画方法
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
			if (menu_detail_state.popup_newpaper_mode == MenuDetailState.GameMode.PUZZLE): #如果选择的模式为解题
				print("Main: 正在尝试新建解题游戏")
				var seed: String
				var seed_deserializated: SeedParser.SeedDeserializated = SeedParser.SeedDeserializated.new() #创建一个反序列化种子实例
				if (menu_detail_state.popup_newpaper_seed.is_empty()): #如果种子为空
					print("Main: 种子为空，正在随机创建种子")
					seed = PuzzleManager.random_seed() #随机创建种子
				else: #否则(种子不为空)
					seed = menu_detail_state.popup_newpaper_seed.to_upper() #使用玩家在菜单里填写的种子
				print("Main: 使用种子:\"", seed, "\"")
				if (SeedParser.fully_seed_check(seed, seed_deserializated)): #将参数传入种子解析器的完全检查方法，如果返回true也就是种子合法且可用
					print("Main: 种子验证通过，正在新建解题游戏")
					## 创建新解题游戏
					PopupManager.fs.emit_signal(&"close_popup", &"Paper_New") #关闭菜单
					start_new_puzzle_old( #开始新解题游戏
						seed_deserializated.generator._generate(seed_deserializated, menu_detail_state.popup_newpaper_size).to_puzzle_data(), #题目数据
						menu_detail_state.popup_newpaper_size, #尺寸
						seed #种子
					)
				else: #否则(种子不合法或不可用)
					print("Main: 种子验证未被通过，取消新建解题游戏")
					PopupManager.fs.emit_signal(&"custom_popup_notify", &"New_Paper_SeedInvalid") #通知新建题纸菜单种子不可用
			else: #否则(选择的模式为沙盒)
				print("Main: 正在尝试新建沙盒游戏")
				start_new_sandbox_old(true, menu_detail_state.popup_newpaper_size) #创建新沙盒模式游戏
				PopupManager.fs.emit_signal(&"close_popup", &"Paper_New") #关闭菜单
			menu_detail_state.popup_newpaper_seed = "" #清空记录在菜单上的种子
			menu_detail_state.popup_newpaper_size = Vector2i(5, 5) #重置尺寸设置
		&"Popup_NewPaper_Cancel": #弹出菜单-新建题纸.取消
			PopupManager.fs.emit_signal(&"close_popup", &"Paper_New") #关闭菜单
			menu_detail_state.popup_newpaper_size = Vector2i(5, 5) #重置尺寸设置
		&"Popup_About_Back": #弹出菜单-关于.返回
			PopupManager.fs.emit_signal(&"close_popup", &"About") #关闭菜单
		&"Popup_Win_CopySeed": #弹出菜单-胜利.复制种子
			print("正在复制种子到操作系统剪贴板")
			DisplayServer.clipboard_set(current_seed) #将种子放置到系统的剪贴板
		&"Popup_Win_Back": #弹出菜单-胜利.返回
			PopupManager.fs.emit_signal(&"close_popup", &"Win")
	SideBar.update_detail_buttons_disable() #更新按钮禁用状态
#endregion

## 本类型不确定是否要投入使用
## 类-新游戏设置数据，不含游戏模式
class NewGameSettings:
	## 尺寸
	var size: Vector2i
	## 是否清除答题网格，只在沙盒模式生效(因为解题模式必定清除网格)。用于区分新建沙盒和题纸沙盒化
	var clear_grids: bool
	## 种子，只在解题模式生效
	var seed: String
