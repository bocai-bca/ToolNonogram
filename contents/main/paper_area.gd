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
	
]

## 偏移量动画倒计时器，即为0时到达终点。这个计时器本该在EditableGrids类里以和相关的静态成员一起搭配使用，但是EditableGrids是非单例的类，不宜在它的_process中更新计时器，因此委托在此处进行
static var grids_animation_timer: float = 0.0
## 点击状态实例
static var click_state: ClickState = ClickState.new()

func _process(delta: float) -> void:
	grids_animation_timer = move_toward(grids_animation_timer, 0.0, delta) #从EditableGrids的_process()方法中接替进行动画计时器更新任务

func _physics_process(delta: float) -> void:
	## 00更新点击状态
	update_click_state()
	## /00
	## 01所有工具的行为
	match (Main.focus_tool): #匹配焦点工具
		Main.FocusTool.NONE: #拖手工具
			pass
		Main.FocusTool.BRUSH: #笔刷工具
			if (click_state.is_pressing() and click_state.pressed_at_area == ClickState.AreaOfPaper.GRIDS): #如果鼠标正被点击，且按下位置处于答题网格中
				if (EditableGrids.is_pos_in_grid(click_state.current_pos)): #如果鼠标所在的坐标有效
					n_base_grids.write_slot(click_state.current_pos, EditableGrids.FillType.BLOCK)
		Main.FocusTool.ERASER: #擦除工具
			if (click_state.is_pressing() and click_state.pressed_at_area == ClickState.AreaOfPaper.GRIDS): #如果鼠标正被点击，且按下位置处于答题网格中
				if (EditableGrids.is_pos_in_grid(click_state.current_pos)): #如果鼠标所在的坐标有效
					n_base_grids.clear_slot(click_state.current_pos)

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
			click_state.current_pos = n_base_grids.get_mouse_pos() #设定当前鼠标所处的坐标
	## /00
	## 01点击状态
	if (click_state.press_state == ClickState.PressState.RELEASE or click_state.press_state == ClickState.PressState.JUST_RELEASED): #如果按下状态是松开或刚刚松开
		if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)): #如果左键正被按下
			click_state.press_state = ClickState.PressState.JUST_PRESSED #更新按下状态为刚刚按下
			##### 记录坐标
			click_state.pressed_at_area = click_state.current_at_area
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
	## 按下时所处的题纸区域。当当前状态不属于按下时，本变量的值是无效的、不可信的
	var pressed_at_area: AreaOfPaper
	## 按下时所处的抽象坐标，基于按下时所处的题纸区域。如果是工具图标的话此值无效，如果是网格的话代表网格上的坐标，而数字栏的话还需要设计
	var pressed_pos: Vector2i
	## 当前所处地题纸区域
	var current_at_area: AreaOfPaper
	## 当前所在的抽象坐标，基于当前所处的题纸区域。如果是工具图标的话此值无效，如果是网格的话代表网格上的坐标，而数字栏的话还需要设计
	var current_pos: Vector2i
	## 获取当前鼠标是否是按下的，是对易于理解但不易读的判断的封装方法。需通过一个ClickState实例访问
	func is_pressing() -> bool:
		return (press_state == PressState.PRESSING or press_state == PressState.JUST_PRESSED)
	## 获取当前鼠标是否是刚发生变更(JUST相关的状态)，是对易于理解但不易读的判断的封装方法。需通过一个ClickState实例访问
	func is_just() -> bool:
		return (press_state == PressState.JUST_RELEASED or press_state == PressState.JUST_PRESSED)
