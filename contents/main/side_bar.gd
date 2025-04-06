extends Node2D
class_name SideBar
## 侧边栏。

## 存在一个视觉效果上的问题：当子层面板关闭时，其上面的内容会立刻消失，以至于用户可以在关闭菜单时看见菜单上按钮消失，这个问题应当优化

## 伪单例FakeSingleton
static var fs: SideBar:
	get:
		if (fs == null): #如果fs为空
			push_error("SideBar: 在试图获取fs时无法返回有效值，因为：解引用fs时返回null。")
			return null
		return fs

@onready var n_bar_color: ColorRect = $BarColor as ColorRect
@onready var n_shadow: Sprite2D = $Shadow as Sprite2D
@onready var n_buttons: Array[SideButton] = [ #参见BUTTONS_TEXTURES_NAME
	$SideButton_InteractClass as SideButton,
	$SideButton_SelectionClass as SideButton,
	$SideButton_EditClass as SideButton,
	$SideButton_LockClass as SideButton,
	$SideButton_Menu as SideButton,
]
@onready var n_tip_text: Label = $TipText as Label
@onready var n_tool_class_panel: Panel = $ToolClassPanel as Panel #工具类别层(中间层)面板
## 工具类别层按钮，简称为类别按钮，这些按钮没有固定的图标、按钮名、悬浮文本，全在变更焦点类别时被赋予，必要时还会隐藏
@onready var n_class_buttons: Array[SideButton] = [
	$ToolClassPanel/ClassButton_0 as SideButton,
	$ToolClassPanel/ClassButton_1 as SideButton,
	$ToolClassPanel/ClassButton_2 as SideButton,
	$ToolClassPanel/ClassButton_3 as SideButton,
	$ToolClassPanel/ClassButton_4 as SideButton,
]

## 侧边栏焦点所在层次
enum Panels{
	ROOT, #底部(最浅层)
	TOOL_CLASS, #工具类别(中间层)
	TOOL_DETAIL, #工具详情(最深层)
}
## 侧边栏焦点所在类别
enum FocusClass{
	NONE, #无
	INTERACT, #交互
	SELECTION, #选区
	EDIT, #擦写
	LOCK, #锁定
}

## 按钮纹理名称列表，索引按序一对一对应于n_buttons数组中的每个元素的索引(例如本数组[0]对应n_buttons[0])，值对应于Main.ICON_TEXTURES常量的键，以此来捆绑n_buttons中的节点实例使用的纹理资源
const BUTTONS_TEXTURES_NAME: Array[StringName] = [
	&"Interact_Point",
	&"Selection_Point",
	&"Edit_Point",
	&"Lock_Point",
	&"Menu",
]
## 侧边栏背景颜色，施加给n_bar_color的color属性
const BAR_COLOR_MODULATE: Color = Color(0.9, 0.9, 0.9, 1.0)
## 侧边栏阴影调制，施加给n_shadow的self_modulate属性
const BAR_SHADOW_MODULATE: Color = Color(0.0, 0.0, 0.0, 0.5)
## 侧边栏宽度乘数，基于视口纵向长度
const BAR_WIDTH_MULTI: float = 1.0 / 6.0
## 阴影缩放X基值乘数，基于视口纵向长度。设定合适的值以影响阴影的横向宽度，除数为默认窗口高度，被除数为想要的默认X缩放倍率(基于所使用纹理的尺寸的X)
const SHADOW_SCALE_X_BASE_MULTI: float = 2.0 / Main.WINDOW_SIZE_DEFAULT.y
## 侧边栏顶部提示文本纵向宽度乘数，基于视口纵向长度
const BAR_TEXT_SPACE_MULTI: float = 0.1
## 侧边栏底部空隔乘数，基于视口纵向长度
const BAR_BOTTOM_SPACE_MULTI: float = 0.05
## 按钮的横向长度占据侧边栏横向长度的百分比，用于控制按钮的大小
const BUTTON_WIDTH_OF_BAR_WIDTH_MULTI: float = 0.8
## 侧边栏顶部提示文本的字体大小乘数，基于提示文本节点的size.x属性
const BAR_TEXT_FONT_SIZE_MULTI: float = 32.0 / (BAR_WIDTH_MULTI * Main.WINDOW_SIZE_DEFAULT.y)
## 侧边栏顶部提示文本的淡入或淡出速度，单位是alpha数值量每秒
const BAR_TEXT_FADING_SPEED: float = 3.75
## 侧边栏子层面板圆角半径乘数，基于视口纵向长度
const TOOL_PANEL_CORNER_RADIUS_MULTI: float = 100.0 / Main.WINDOW_SIZE_DEFAULT.y
## 侧边栏子层面板纵向长度乘数，基于视口纵向长度
const TOOL_PANEL_HEIGHT_MULTI: float = 0.95
## 侧边栏子层面板阴影尺寸乘数，基于视口纵向长度
const TOOL_PANEL_SHADOW_SIZE_MULTI: float = 100.0 / Main.WINDOW_SIZE_DEFAULT.y
## 侧边栏子层面板开关动画时间，单位是秒
const TOOL_PANEL_ANIMATION_TIME: float = 0.8
## 侧边栏子层面板开关动画缓动曲线值
const TOOL_PANEL_ANIMATION_EASE_CURVE: float = 5.0
## 侧边栏工具类别层最底部的按钮的Y的乘数，基于视口纵向长度。即视口纵向长度*本值=最底部按钮的Y
const TOOL_CLASS_PANEL_BUTTON_BOTTOM_Y_MULTI: float = 0.8
## 侧边栏工具类别层按钮之间的Y间隔乘数，基于视口纵向长度
const TOOL_CLASS_PANEL_BUTTON_Y_SPACING_MULTI: float = 0.025

## [只读]工具类别层交互类按钮的数据列表，按按钮由上到下的顺序排序
static var INTERACT_CLASS_BUTTONS_DATA_LIST: Array[ClassButtonDataObject] = [
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
]
## [只读]工具类别层选区类按钮的数据列表，按按钮由上到下的顺序排序
static var SELECTION_CLASS_BUTTONS_DATA_LIST: Array[ClassButtonDataObject] = [
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
]
## [只读]工具类别层擦写类按钮的数据列表，按按钮由上到下的顺序排序
static var EDIT_CLASS_BUTTONS_DATA_LIST: Array[ClassButtonDataObject] = [
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
]
## [只读]工具类别层锁定类按钮的数据列表，按按钮由上到下的顺序排序
static var LOCK_CLASS_BUTTONS_DATA_LIST: Array[ClassButtonDataObject] = [
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back"),
]

## 按钮的默认长度，该值必须通过读取按钮实例的TextureButton的size属性获取。默认只在本节点ready时读取一次
static var button_width_default: float
## 按钮的当前长度，相当于经过变换计算后的button_width_default
static var button_width: float
## 表示侧边栏横向长度的变量，对其他类型而言应当只读
static var bar_width: float = 180.0
## 表示现在是否应显示提示文本，由SideButton类型修改
static var should_show_tip_text: bool = false
## 应显示的提示文本，由SideButton类型修改
static var tip_text: String:
	get:
		if (fs != null and fs.n_tip_text != null): #防空引用
			return fs.n_tip_text.text
		return "" #未能引用到节点时返回空字符串
	set(value):
		if (fs != null and fs.n_tip_text != null): #防空引用
			fs.n_tip_text.text = value
## 侧边栏的焦点处于哪个面板层上
static var focus_panel: Panels = Panels.ROOT
## 侧边栏的焦点处于哪个工具类别上
static var focus_class: FocusClass = FocusClass.NONE
## 侧边栏工具类别层(中间层)面板开关倒计时器
static var tool_class_panel_animation_timer: float = 0.0
## 侧边栏工具详情层(最深层)面板开关倒计时器
static var tool_detail_panel_animation_timer: float = 0.0
## 记录正在被工具类别层使用的类别按钮，方便进行排列
static var class_buttons_using: Array[SideButton]

func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	button_width_default = n_buttons[0].n_button.size.x #读取按钮实例的TextureButton的size属性
	n_bar_color.color = BAR_COLOR_MODULATE #设置侧边栏颜色矩形的颜色
	n_shadow.self_modulate = BAR_SHADOW_MODULATE #设置侧边栏阴影的调制
	for i in n_buttons.size(): #按索引遍历n_buttons
		n_buttons[i].n_icon.texture = Main.ICON_TEXTURES[BUTTONS_TEXTURES_NAME[i]] #设置按钮的纹理

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	position = Vector2(window_size.x, window_size.y / 2.0) #将本节点的位置移动到窗口右侧中心
	## 00更新侧边栏位置和大小
	n_bar_color.size = Vector2(window_size.y * BAR_WIDTH_MULTI, window_size.y) #计算并应用侧边栏颜色矩形的新大小，使其保持固定长宽比
	bar_width = n_bar_color.size.x #将侧边栏颜色矩形的大小的X保存到本类型的成员变量中，以作缓存
	n_bar_color.position = Vector2(-n_bar_color.size.x, n_bar_color.size.y / -2.0) #计算并应用侧边栏颜色矩形的新位置，使其显示在画面右侧
	n_shadow.scale = Vector2(SHADOW_SCALE_X_BASE_MULTI * window_size.y, window_size.y) #计算并应用侧边栏阴影的新大小，使其保持固定长宽比
	n_shadow.position = Vector2(n_bar_color.position.x - n_shadow.texture.get_size().x * n_shadow.scale.x / 2.0, 0.0) #计算并应用侧边栏阴影的新位置，使其显示在画面右侧
	## /00
	## 01侧边按钮的缩放
	button_width = BUTTON_WIDTH_OF_BAR_WIDTH_MULTI * bar_width #算出按钮宽度并存储到变量button_width
	var button_resize_rate: float = button_width / button_width_default #按钮尺寸缩放率，该值基于侧边栏的横向长度求出，然后将其乘入按钮的scale以使按钮缩放至期望的大小
	## /01
	## 02侧边按钮的排列
	var buttons_space: float = window_size.y * (1.0 - BAR_TEXT_SPACE_MULTI - BAR_BOTTOM_SPACE_MULTI) #取得按钮空间长度
	var per_spacing: float = buttons_space / (n_buttons.size() + 1) #将按钮空间平均分割[按钮数量]刀，取其中的每个切断点作为按钮的位置
	var center_offset: float = ((1.0 - BAR_BOTTOM_SPACE_MULTI + BAR_TEXT_SPACE_MULTI) / 2.0 - 0.5) * window_size.y #中心点偏移，由于侧边栏上有顶部文本和底部空格的存在，允许按钮们待的空间有限，并且会导致按钮居中的中心点发生偏移，此值是从原点0.0起向按钮居中点偏移的量
	for i in n_buttons.size(): #按索引遍历按钮实例列表
		n_buttons[i].position.y = (i + 1) * per_spacing #将按钮按序变换到每个分割点的位置
		n_buttons[i].position.y -= buttons_space / 2.0 #减半个按钮空间长度以居中按钮(而非让按钮从原点往下开始分布)
	var retrans_multi: float = buttons_space / (per_spacing * (n_buttons.size() - 1) + button_width) #计算变换率，空间长度除以当前按钮总共占用的长度。该值将乘入每个按钮的坐标的Y，使按钮以原点为中心进行适当位置缩放，从而让按钮不超出限定空间且不影响总体之间的分布均匀度
	for n_button in n_buttons: #遍历所有按钮实例
		n_button.scale = Vector2.ONE * button_resize_rate #应用按钮尺寸缩放率到按钮实例
		n_button.position.y = n_button.position.y * retrans_multi + center_offset #将位置变换率和中心点偏移应用到按钮
		n_button.position.x = n_bar_color.position.x / 2.0 #设置按钮的X坐标
	## /02
	## 03更新提示文本
	n_tip_text.position = n_bar_color.position #设置提示文本的位置
	n_tip_text.size = Vector2(n_bar_color.size.x, window_size.y * BAR_TEXT_SPACE_MULTI) #设置提示文本的尺寸
	n_tip_text.label_settings.font_size = BAR_TEXT_FONT_SIZE_MULTI * n_tip_text.size.x #设置提示文本的字体大小
	if (should_show_tip_text): #如果当前应当显示提示文本
		n_tip_text.self_modulate.a = move_toward(n_tip_text.self_modulate.a, 1.0, delta * BAR_TEXT_FADING_SPEED) #线性地将提示文本的不透明度变换到1.0
	else: #否则(当前不应显示提示文本)
		n_tip_text.self_modulate.a = move_toward(n_tip_text.self_modulate.a, 0.0, delta * BAR_TEXT_FADING_SPEED) #线性地将提示文本的不透明度变换到0.0
	## /03
	## 04深层面板更新
	n_tool_class_panel.size = Vector2(bar_width, window_size.y * TOOL_PANEL_HEIGHT_MULTI) #更新工具类别层面板的尺寸
	var tool_class_panel_pos_open: Vector2 = Vector2(-bar_width, -0.5 * window_size.y) #计算出工具类别面板在完全展开时的坐标
	var tool_class_panel_pos_close: Vector2 = Vector2(window_size.y * TOOL_PANEL_SHADOW_SIZE_MULTI, -0.5 * window_size.y) #计算出工具类别面板在完全收起时的坐标
	var stylebox_editing: StyleBoxFlat #创建一个StyleBox变量用于修改
	## 	05工具类别层StyleBox更新
	stylebox_editing = n_tool_class_panel.theme.get_stylebox(&"panel", &"Panel") as StyleBoxFlat #获取工具类别层的StyleBox
	stylebox_editing.shadow_size = window_size.y * TOOL_PANEL_SHADOW_SIZE_MULTI #设置StyleBox的阴影尺寸
	stylebox_editing.corner_radius_bottom_left = window_size.y * TOOL_PANEL_CORNER_RADIUS_MULTI #设置StyleBox的圆角半径
	n_tool_class_panel.theme.set_stylebox(&"panel", &"Panel", stylebox_editing) #将修改好的StyleBox保存回工具类别层节点
	## 	/05
	## 	06工具详细层StyleBox更新
	## 	/06
	## 	07深层面板位置更新
	tool_class_panel_animation_timer = move_toward(tool_class_panel_animation_timer, 0.0, delta) #工具类别层面板动画倒计时更新
	tool_detail_panel_animation_timer = move_toward(tool_detail_panel_animation_timer, 0.0, delta) #工具详细层面板动画倒计时更新
	match (focus_panel): #匹配焦点所在的面板层次
		Panels.ROOT: #底部，类别层详细层均不展开
			n_tool_class_panel.position = tool_class_panel_pos_close.lerp(tool_class_panel_pos_open, ease(tool_class_panel_animation_timer / TOOL_PANEL_ANIMATION_TIME, TOOL_PANEL_ANIMATION_EASE_CURVE)) #计算工具类别层面板的坐标，因为是倒计时所以向量插值的起点和终点取反，实际终点为收起
			#### 工具详细层的坐标
		Panels.TOOL_CLASS: #类别层，类别层展开而详细层收起
			n_tool_class_panel.position = tool_class_panel_pos_open.lerp(tool_class_panel_pos_close, ease(tool_class_panel_animation_timer / TOOL_PANEL_ANIMATION_TIME, TOOL_PANEL_ANIMATION_EASE_CURVE)) #计算工具类别层面板的坐标，因为是倒计时所以向量插值的起点和终点取反，实际终点为展开
			#### 工具详细层的坐标
		Panels.TOOL_DETAIL: #详细层，类别层详细层均展开
			n_tool_class_panel.position = tool_class_panel_pos_open.lerp(tool_class_panel_pos_close, ease(tool_class_panel_animation_timer / TOOL_PANEL_ANIMATION_TIME, TOOL_PANEL_ANIMATION_EASE_CURVE)) #计算工具类别层面板的坐标，因为是倒计时所以向量插值的起点和终点取反，实际终点为展开
			#### 工具详细层的坐标
	## 	/07
	## 	08工具类别层按钮排列
	var button_y_offset: float = window_size.y * TOOL_CLASS_PANEL_BUTTON_Y_SPACING_MULTI #计算出一份按钮间隔长度
	for i in class_buttons_using.size(): #按索引遍历使用中的类别层按钮节点数组。注意此处需要逆着索引从下往上排列
		var j: int = class_buttons_using.size() - 1 - i #总数-1=索引总数，索引总数-索引数i=逆序索引数j
		class_buttons_using[j].position = Vector2(
			n_tool_class_panel.size.x / 2.0, #计算按钮的X坐标
			window_size.y * TOOL_CLASS_PANEL_BUTTON_BOTTOM_Y_MULTI - (button_y_offset + button_width) * j #计算按钮的Y坐标
		) #计算并应用按钮的Y坐标
		class_buttons_using[j].scale = Vector2.ONE * button_resize_rate #直接拿上面算好的按钮缩放率下来用，爽
	## 	/08
	## /04

## 切换焦点的高级封装，用于切换层次面板的展开和收起、按钮名称和纹理的设置、一些游戏系统变量的设置，理论上不允许出现输入的两个参数是不相符的层次连接关系的状况。目前还有焦点工具相关的操作没写
func switch_focus(target_class: FocusClass, target_detail: Main.FocusTool) -> void:
	Main.focus_tool = target_detail #将焦点工具设为传入参数
	switch_class_buttons_using(target_class) #将类别层按钮切换到目标类别
	focus_panel = Panels.TOOL_CLASS #设置焦点面板为类别层
	if (target_class == FocusClass.NONE): #如果焦点类别为无，意味着焦点在底部
		focus_panel = Panels.ROOT #设置焦点面板为底部
	if (target_detail != Main.FocusTool.NONE): #如果工具焦点类别不为无，意味着工具不是拖手，则需要展开详细层面板
		pass #### 展开详细层面板
		focus_panel = Panels.TOOL_DETAIL #设置焦点面板为详细层
	if (focus_class != target_class): #如果目标焦点类别与原本的焦点类别不同
		tool_class_panel_animation_timer = TOOL_PANEL_ANIMATION_TIME #重设工具类别层面板的动画计时器
	focus_class = target_class #将焦点工具类别设为传入参数

## 将工具类别层的按钮切换到特定类别焦点的布局上，将更新按钮使用列表、按钮的启用与否、按钮的名称和纹理(不是节点名)，不影响如focus_class等存在于本类中而非按钮中的变量
func switch_class_buttons_using(target_focus_class: FocusClass) -> void:
	for n_class_button in n_class_buttons: #遍历每个工具类别层按钮
		n_class_button.is_enable = false #将按钮禁用
	class_buttons_using = [] #清空工具类别层按钮使用列表
	match (target_focus_class): #匹配目标工具类别焦点
		FocusClass.NONE: #无
			return
		FocusClass.INTERACT: #交互
			for i in INTERACT_CLASS_BUTTONS_DATA_LIST.size(): #按索引遍历交互类按钮表
				n_class_buttons[i].is_enable = true #启用按钮
				class_buttons_using.append(n_class_buttons[i]) #将按钮添加到使用列表
				n_class_buttons[i].n_icon.texture = Main.ICON_TEXTURES[INTERACT_CLASS_BUTTONS_DATA_LIST[i].texture_name] #设置纹理
				n_class_buttons[i].button_name = INTERACT_CLASS_BUTTONS_DATA_LIST[i].button_name #设置按钮名称
		FocusClass.SELECTION: #选区
			for i in SELECTION_CLASS_BUTTONS_DATA_LIST.size(): #按索引遍历选区类按钮表
				n_class_buttons[i].is_enable = true #启用按钮
				class_buttons_using.append(n_class_buttons[i]) #将按钮添加到使用列表
				n_class_buttons[i].n_icon.texture = Main.ICON_TEXTURES[SELECTION_CLASS_BUTTONS_DATA_LIST[i].texture_name] #设置纹理
				n_class_buttons[i].button_name = SELECTION_CLASS_BUTTONS_DATA_LIST[i].button_name #设置按钮名称
		FocusClass.EDIT: #擦写
			for i in EDIT_CLASS_BUTTONS_DATA_LIST.size(): #按索引遍历选区类按钮表
				n_class_buttons[i].is_enable = true #启用按钮
				class_buttons_using.append(n_class_buttons[i]) #将按钮添加到使用列表
				n_class_buttons[i].n_icon.texture = Main.ICON_TEXTURES[EDIT_CLASS_BUTTONS_DATA_LIST[i].texture_name] #设置纹理
				n_class_buttons[i].button_name = EDIT_CLASS_BUTTONS_DATA_LIST[i].button_name #设置按钮名称
		FocusClass.LOCK: #锁定
			for i in LOCK_CLASS_BUTTONS_DATA_LIST.size(): #按索引遍历选区类按钮表
				n_class_buttons[i].is_enable = true #启用按钮
				class_buttons_using.append(n_class_buttons[i]) #将按钮添加到使用列表
				n_class_buttons[i].n_icon.texture = Main.ICON_TEXTURES[LOCK_CLASS_BUTTONS_DATA_LIST[i].texture_name] #设置纹理
				n_class_buttons[i].button_name = LOCK_CLASS_BUTTONS_DATA_LIST[i].button_name #设置按钮名称

## 工具类别层按钮数据对象，一个实例代表一个按钮的数据，用于放置在一个数组里和其他实例一起代表一个类别中的所有工具按钮的实例化数据
class ClassButtonDataObject:
	var button_name: StringName #按钮名称，用于发出信号时跟随标识参数，对应Main.on_button_trigged()
	var texture_name: StringName #纹理名称，对应Main.ICON_TEXTURES
	func _init(new_button_name: StringName, new_texture_name: StringName) -> void:
		button_name = new_button_name
		texture_name = new_texture_name
