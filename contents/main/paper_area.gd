extends Node2D
class_name PaperArea
## 题纸区域。用于组织和管理所有题纸显示层和处理输入

## 伪单例FakeSingleton
static var fs: PaperArea:
	get:
		if (fs == null): #如果fs为空
			push_error("PaperArea: 在试图获取fs时无法返回有效值，因为：解引用fs时返回null。")
			return null
		return fs

@onready var n_base_click: TextureButton = $BaseClick as TextureButton
@onready var n_base_grids: EditableGrids = $BaseGrids as EditableGrids
@onready var n_hover_grids: Array[EditableGrids] = [
	$HoverGrids_1 as EditableGrids,
	$HoverGrids_2 as EditableGrids,
	$HoverGrids_3 as EditableGrids,
	$HoverGrids_4 as EditableGrids,
	$HoverGrids_5 as EditableGrids,
	$HoverGrids_6 as EditableGrids,
]
@onready var n_back_color: ColorRect = $BackColor as ColorRect

## 偏移量动画倒计时器控制开关，为true时计时器继续计时，为false时暂停计时
static var is_allow_grids_animation_timer_update: bool = true
## 偏移量动画倒计时器，即为0时到达终点。这个计时器本该在EditableGrids类里以和相关的静态成员一起搭配使用，但是EditableGrids是非单例的类，不宜在它的_process中更新计时器，因此委托在此处进行
static var grids_animation_timer: float = 0.0
## 点击状态实例
static var click_state: ClickState = ClickState.new()
## 答题网格的纵向空间
static var grids_free_height: float = 0.0
## 当前是否允许鼠标在答题网格上的交互
static var can_mouse_interactive: bool:
	get:
		return (PopupManager.alive_popup_count == 0 and not Main.is_menu_open) #返回判据，返回true需要：当前没有弹出菜单、没有打开底部菜单
## [只读]焦点所在图层网格
var focus_layer_grids: EditableGrids:
	get:
		if (Main.focus_layer == 0): #如果焦点图层序号为0
			return n_base_grids #返回基底网格
		if (Main.focus_layer - 1 >= n_hover_grids.size()): #如果焦点序号大于悬浮网格数量
			push_error("PaperArea: 无法获取焦点所在图层网格并返回null，因为：Main.focus_layer所代表的焦点图层序号超出n_hover_grids列表记录的悬浮图层数量。")
			return null
		return n_hover_grids[Main.focus_layer - 1] #返回悬浮网格列表按这个方式的索引结果


func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	n_base_grids.is_layer_show = true #使基底图层可见

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	n_back_color.size = window_size #更新背景颜色矩形的尺寸
	position = Vector2(LayersBar.bar_width, 0.0) #更新题纸区域的坐标
	grids_free_height = window_size.y - NumberBar.bar_width #计算可用空间高度
	if (is_allow_grids_animation_timer_update): #如果当前允许计时器更新
		grids_animation_timer = move_toward(grids_animation_timer, 0.0, delta) #从EditableGrids的_process()方法中接替进行动画计时器更新任务
	## 00更新点击状态
	update_click_state()
	## /00
	## 01所有工具的行为
	if (can_mouse_interactive): #如果允许鼠标交互
		match (Main.focus_tool): #匹配焦点工具
			Main.FocusTool.NONE: #拖手工具
				## 答题网格移动
				if (click_state.pressed_at_area == ClickState.AreaOfPaper.GRIDS): #如果鼠标按下位置处于答题网格中
					if (click_state.is_pressing()): #如果鼠标正被按下
						if (click_state.is_just()): #如果是刚刚按下
							EditableGrids.animate_start_offset = EditableGrids.animate_now_offset #将起始偏移量设为当前的实际偏移量
						EditableGrids.update_offset_on_grabbing(click_state.last_update_pos - click_state.current_pos) #调用答题网格的更新偏移量方法
						grids_animation_timer = EditableGrids.ANIMATION_TIME #重设计时器时间
						is_allow_grids_animation_timer_update = false #关闭计时器
					else: #否则(鼠标没在按下)
						is_allow_grids_animation_timer_update = true #开启计时器
				## 顶部数字栏滚动
				elif (click_state.pressed_at_area == ClickState.AreaOfPaper.NUMBER_BAR_UP): #如果鼠标按下位置处于顶部数字栏
					if (click_state.is_pressing()): #如果鼠标正被按下
						if (click_state.is_just()): #如果是刚刚按下
							NumberArrayDisplayer.scroll_animation_start_offset.y = NumberArrayDisplayer.scroll_animation_now_offset.y #将起始量设为当前量
						NumberArrayDisplayer.update_offset_on_scrolling_up(click_state.current_pos.y - click_state.last_update_pos.y) #调用数字阵列显示器的顶部数字栏滚动更新方法(此处对传入参数作了取负)
						NumberBar.number_array_displayer_scroll_animation_timer_up = NumberArrayDisplayer.ANIMATION_TIME #重设计时器时间
						NumberBar.is_allow_number_array_displayer_scroll_animation_timer_up_update = false #关闭计时器
					else: #否则(鼠标没在按下)
						NumberBar.is_allow_number_array_displayer_scroll_animation_timer_up_update = true #开启计时器
				## 侧边数字栏滚动
				elif (click_state.pressed_at_area == ClickState.AreaOfPaper.NUMBER_BAR_SIDE): #如果鼠标按下位置处于侧边数字栏
					if (click_state.is_pressing()): #如果鼠标正被按下
						if (click_state.is_just()): #如果是刚刚按下
							NumberArrayDisplayer.scroll_animation_start_offset.x = NumberArrayDisplayer.scroll_animation_now_offset.x #将起始量设为当前量
						NumberArrayDisplayer.update_offset_on_scrolling_side(click_state.current_pos.x - click_state.last_update_pos.x) #调用数字阵列显示器的侧边数字栏滚动更新方法(此处对传入参数作了取负)
						NumberBar.number_array_displayer_scroll_animation_timer_side = NumberArrayDisplayer.ANIMATION_TIME #重设计时器时间
						NumberBar.is_allow_number_array_displayer_scroll_animation_timer_side_update = false #关闭计时器
					else: #否则(鼠标没在按下)
						NumberBar.is_allow_number_array_displayer_scroll_animation_timer_side_update = true #开启计时器
				## /
			Main.FocusTool.BRUSH: #笔刷工具
				if (click_state.is_pressing() and click_state.pressed_at_area == ClickState.AreaOfPaper.GRIDS): #如果鼠标正被点击，且按下位置处于答题网格中
					if (EditableGrids.is_pos_in_grid(click_state.current_grid_pos)): #如果鼠标所在的坐标有效
						match (Main.tools_detail_state.brush_fill_type): #匹配笔刷工具的填充类型
							ToolsDetailState.ToolFillType.FILL: #实心块
								n_base_grids.write_slot(click_state.current_grid_pos, EditableGrids.FillType.FILL) #将指定格子填写为实心块
							ToolsDetailState.ToolFillType.CROSS: #叉叉
								n_base_grids.write_slot(click_state.current_grid_pos, EditableGrids.FillType.CROSS) #将指定格子填写为叉叉
				elif (click_state.pressed_at_area == ClickState.AreaOfPaper.GRIDS and not click_state.is_pressing() and click_state.is_just()): #如果鼠标未被点击，且刚刚松开，且上一次按下位置是答题网格
					if (Main.game_mode == Main.GameMode.PUZZLE): #如果当前处于解题模式
						Main.win_check_flag = true #开启胜利检查旗标
			Main.FocusTool.ERASER: #擦除工具
				if (click_state.is_pressing() and click_state.pressed_at_area == ClickState.AreaOfPaper.GRIDS): #如果鼠标正被点击，且按下位置处于答题网格中
					if (EditableGrids.is_pos_in_grid(click_state.current_grid_pos)): #如果鼠标所在的坐标有效
						n_base_grids.clear_slot(click_state.current_grid_pos)
				elif (click_state.pressed_at_area == ClickState.AreaOfPaper.GRIDS and not click_state.is_pressing() and click_state.is_just()): #如果鼠标未被点击，且刚刚松开
					if (Main.game_mode == Main.GameMode.PUZZLE): #如果当前处于解题模式
						Main.win_check_flag = true #开启胜利检查旗标

func _physics_process(delta: float) -> void:
	pass

#region 系统级变更题纸的方法集
## 清空基本题纸的内容
func clear_base_grids() -> void:
	if (n_base_grids == null):
		push_error("PaperArea: 未能清空基本题纸，因为：解引用n_base_grids时返回null。")
		return
	elif (n_base_grids.n_edit_map == null):
		push_error("PaperArea: 未能清空基本题纸，因为：解引用n_base_grids.n_edit_map时返回null。")
		return
	n_base_grids.n_edit_map.clear()

## 重设网格尺寸(不会影响题纸的内容，可能导致内容超出新的尺寸)
func reset_grids_size(new_size: Vector2i) -> void:
	if (n_base_grids == null):
		push_error("PaperArea: 未能重设网格尺寸，因为：解引用n_base_grids时返回null。")
		return
	EditableGrids.global_grid_size = new_size #设置全局网格尺寸
	n_base_grids.resize_local_grids(new_size) #重绘基本题纸的本地网格
	Main.grids_zoom_blocks = new_size.y #设置新的缩放格子数，使得新网格适应全屏
#endregion

## 更新点击状态
func update_click_state() -> void:
	## 00坐标和区域
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	var mouse: Vector2 = get_local_mouse_position() #获取鼠标本地坐标(以PaperArea为参考系)
	if (mouse.x <= 0.0 or #鼠标X在题纸区域的左侧边界外
		mouse.x >= (window_size.x - SideBar.bar_width - LayersBar.bar_width) or #鼠标X在题纸区域的右侧边界外
		mouse.y <= 0.0 or #鼠标的Y在题纸区域的顶部边界外
		mouse.y >= window_size.y #鼠标的Y在题纸区域的底部边界外
	): #如果鼠标的X在题纸区域外
		click_state.current_at_area = ClickState.AreaOfPaper.OUT_OF_PAPER #设定当前所在区域为题纸区域外
	elif (mouse.x <= NumberBar.bar_width): #否则如果当前鼠标指针X位于数字栏内
		if (mouse.y <= NumberBar.bar_width): #如果当前鼠标指针Y位于数字栏内
			## 处于工具图标
			click_state.current_at_area = ClickState.AreaOfPaper.TOOL_ICON #设定当前所在区域为工具图标
		else: #否则(当前鼠标指针Y位于数字栏外)
			## 处于侧边数字栏
			click_state.current_at_area = ClickState.AreaOfPaper.NUMBER_BAR_SIDE #设定当前所在区域为侧边数字栏
	else: #否则(当前鼠标指针X位于数字栏外)
		if (mouse.y <= NumberBar.bar_width): #如果当前鼠标指针Y位于数字栏内
			## 处于顶部数字栏
			click_state.current_at_area = ClickState.AreaOfPaper.NUMBER_BAR_UP #设定当前所在区域为顶部数字栏
		else: #否则(当前鼠标指针Y位于数字栏外)
			## 处于答题网格
			click_state.current_at_area = ClickState.AreaOfPaper.GRIDS #设定当前所在区域为答题网格
	click_state.last_update_grid_pos = click_state.current_grid_pos #记录上次网格抽象坐标位置
	click_state.current_grid_pos = n_base_grids.get_mouse_pos() #设定当前鼠标所处的网格抽象坐标
	click_state.last_update_pos = click_state.current_pos #记录上次精确坐标位置
	click_state.current_pos = get_local_mouse_position() #设定当前鼠标所处的精确坐标
	## /00
	## 01点击状态
	if (click_state.press_state == ClickState.PressState.RELEASE or click_state.press_state == ClickState.PressState.JUST_RELEASED): #如果按下状态是松开或刚刚松开
		if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)): #如果左键正被按下
			click_state.press_state = ClickState.PressState.JUST_PRESSED #更新按下状态为刚刚按下
			## 记录网格抽象坐标
			click_state.pressed_at_area = click_state.current_at_area
			click_state.pressed_grid_pos = click_state.current_grid_pos
			## 记录精确坐标
			click_state.pressed_pos = click_state.current_pos
		else: #否则(如果左键未被按下)
			click_state.press_state = ClickState.PressState.RELEASE #更新按下状态为松开
	else: #否则(按下状态是按下或刚刚按下)
		if (not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)): #如果左键未被按下
			click_state.press_state = ClickState.PressState.JUST_RELEASED #更新按下状态为刚刚松开
		else: #否则(如果左键正被按下)
			click_state.press_state = ClickState.PressState.PRESSING #更新按下状态为按下
	## /01

## 类-点击状态
class ClickState:
	## 按下状态枚举
	enum PressState{
		RELEASE, #没在按下，不是刚松开
		JUST_RELEASED, #没在按下，且刚松开
		JUST_PRESSED, #按下状态，且刚按下
		PRESSING #按下状态，不是刚按下
	}
	## 题纸区域枚举
	enum AreaOfPaper{
		OUT_OF_PAPER, #题纸外
		TOOL_ICON, #工具图标
		NUMBER_BAR_UP, #顶部数字栏
		NUMBER_BAR_SIDE, #侧边数字栏
		GRIDS #网格
	}
	## 按下状态
	var press_state: PressState = PressState.RELEASE
	## 按下时所处的题纸区域。当当前状态不属于按下时，本变量的值表示上一次按下时所处的位置
	var pressed_at_area: AreaOfPaper
	## 按下时所处的抽象坐标，基于按下时所处的题纸区域。如果是工具图标的话此值无效，如果是网格的话代表网格上的坐标，而数字栏的话还需要设计
	var pressed_grid_pos: Vector2i = Vector2i(0, 0)
	## 当前所处地题纸区域
	var current_at_area: AreaOfPaper
	## 当前所在的抽象坐标，基于当前所处的题纸区域。如果是工具图标的话此值无效，如果是网格的话代表网格上的坐标，而数字栏的话还需要设计
	var current_grid_pos: Vector2i = Vector2i(0, 0)
	## 该click_state实例上一次更新时的current_grid_pos
	var last_update_grid_pos: Vector2i = Vector2i(0, 0)
	## 按下时的基于PaperArea的精确坐标
	var pressed_pos: Vector2 = Vector2(0.0, 0.0)
	## 当前所在的基于PaperArea的精确坐标
	var current_pos: Vector2 = Vector2(0.0, 0.0)
	## 该click_state实例上一次更新时的current_pos
	var last_update_pos: Vector2 = Vector2(0.0, 0.0)
	## 获取当前鼠标是否是按下的，是对易于理解但不易读的判断的封装方法。需通过一个ClickState实例访问
	func is_pressing() -> bool:
		return (press_state == PressState.PRESSING or press_state == PressState.JUST_PRESSED)
	## 获取当前鼠标是否是刚发生变更(JUST相关的状态)，是对易于理解但不易读的判断的封装方法。需通过一个ClickState实例访问
	func is_just() -> bool:
		return (press_state == PressState.JUST_RELEASED or press_state == PressState.JUST_PRESSED)
