extends Node2D
class_name SideBar
## 侧边栏。

## 存在一个视觉效果上的问题：当子层面板关闭时，其上面的内容会立刻消失，以至于用户可以在关闭菜单时看见菜单上按钮消失，这个问题应当优化
## 当前决定详细层的按钮,除了返回按钮,其他均使用Control类节点实现,就像菜单面板一样

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
	#$SideButton_SelectionClass as SideButton,
	#$SideButton_LayersClass as SideButton,
	$SideButton_EditClass as SideButton,
	$SideButton_LockClass as SideButton,
	$SideButton_Menu as SideButton,
]
@onready var n_tip_text: Label = $TipText as Label
@onready var n_tip_text_class: Label = $ToolClassPanel/TipText as Label
@onready var n_tool_class_panel: Panel = $ToolClassPanel as Panel #工具类别层(中间层)面板
@onready var n_tool_detail_panel: Panel = $ToolDetailPanel as Panel #工具详细层(最深层)面板
## 工具类别层按钮，简称为类别按钮，这些按钮没有固定的图标、按钮名、悬浮文本，全在变更焦点类别时被赋予，必要时还会隐藏
@onready var n_class_buttons: Array[SideButton] = [
	$ToolClassPanel/ClassButton_0 as SideButton,
	$ToolClassPanel/ClassButton_1 as SideButton,
	$ToolClassPanel/ClassButton_2 as SideButton,
	$ToolClassPanel/ClassButton_3 as SideButton,
	$ToolClassPanel/ClassButton_4 as SideButton,
]
## 工具详细层的节点
@onready var n_detail_nodes_container: VBoxContainer = $ToolDetailPanel/ButtonsContainer as VBoxContainer
@onready var n_detail_button_back: SideButton = $ToolDetailPanel/DetailNode_Back as SideButton

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
	#SELECTION, #选区
	EDIT, #擦写
	LOCK, #锁定,
	#LAYER, #图层
}
## 详细层节点类型
enum DetailNodeType{
	MULTI_BUTTONS, #多按钮
	SINGLE_BUTTON, #单按钮
	BOOL_SWITCH, #二元切换按钮
	COLOR_SWITCH, #颜色切换按钮
	SPACING, #分隔线
}

## 按钮纹理名称列表，索引按序一对一对应于n_buttons数组中的每个元素的索引(例如本数组[0]对应n_buttons[0])，值对应于Main.ICON_TEXTURES常量的键，以此来捆绑n_buttons中的节点实例使用的纹理资源
const BUTTONS_TEXTURES_NAME: Array[StringName] = [
	&"Class_Interact",
	#&"Class_Selection",
	#&"Class_Layers",
	&"Class_Edit",
	&"Class_Lock",
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
## 侧边栏类别层面板纵向长度乘数，基于视口纵向长度
const TOOL_CLASS_PANEL_HEIGHT_MULTI: float = 0.95
## 侧边栏详细层面板纵向长度乘数，基于视口纵向长度
const TOOL_DETAIL_PANEL_HEIGHT_MULTI: float = 0.9
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
## 侧边栏工具详细层最顶部的按钮的Y的乘数，基于详细层面板纵向尺寸长度。即纵向尺寸长度*本值=最顶部按钮的Y
const TOOL_DETAIL_PANEL_BUTTON_TOP_Y_MULTI: float = 0.15
## 侧边栏工具详细层的返回按钮的Y的乘数，基于详细层面板纵向尺寸长度
const TOOL_DETAIL_PANEL_BACK_BUTTON_Y_MULTI: float = ((Main.WINDOW_SIZE_DEFAULT.y * TOOL_DETAIL_PANEL_HEIGHT_MULTI) - BAR_WIDTH_MULTI * BUTTON_WIDTH_OF_BAR_WIDTH_MULTI * 0.5 - 0.5 * (BAR_WIDTH_MULTI * Main.WINDOW_SIZE_DEFAULT.y - BAR_WIDTH_MULTI * BUTTON_WIDTH_OF_BAR_WIDTH_MULTI)) / (Main.WINDOW_SIZE_DEFAULT.y * TOOL_DETAIL_PANEL_HEIGHT_MULTI)

## [只读]工具类别层交互类按钮的数据列表，按按钮由上到下的顺序排序
static var INTERACT_CLASS_BUTTONS_DATA_LIST: Array[ClassButtonDataObject] = [
	ClassButtonDataObject.new(&"ClassButton_Scaler", &"Back", "交互\n缩放工具"),
	ClassButtonDataObject.new(&"ClassButton_Ruler", &"Back", "交互\n量尺工具"),
	ClassButtonDataObject.new(&"ClassButton_UndoRedo", &"Back", "交互\n撤销与重做"),
	ClassButtonDataObject.new(&"ClassButton_Layers", &"Back", "交互\n图层管理"),
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back", "返回\n"),
]
## [只读]工具类别层选区类按钮的数据列表，按按钮由上到下的顺序排序
#static var SELECTION_CLASS_BUTTONS_DATA_LIST: Array[ClassButtonDataObject] = [
	#### 暂时计划删除选区类
	#ClassButtonDataObject.new(&"ClassButton_SelectionFastEdit", &"Back", "选区\n快速编辑"),
	#ClassButtonDataObject.new(&"ClassButton_SelectionEditManually", &"Back", "选区\n精确编辑"),
	#ClassButtonDataObject.new(&"ClassButton_SelectionUndoRedo", &"Back", "选区\n撤销与重做"),
	#ClassButtonDataObject.new(&"ClassButton_SelectionEnd", &"Back", "选区\n结束选区"),
	#ClassButtonDataObject.new(&"ClassButton_Back", &"Back", "返回\n"),
#]
## [只读]工具类别层擦写类按钮的数据列表，按按钮由上到下的顺序排序
static var EDIT_CLASS_BUTTONS_DATA_LIST: Array[ClassButtonDataObject] = [
	ClassButtonDataObject.new(&"ClassButton_Brush", &"Detail_Brush", "擦写\n笔刷工具"),
	ClassButtonDataObject.new(&"ClassButton_Eraser", &"Detail_Eraser", "擦写\n擦除工具"),
	ClassButtonDataObject.new(&"ClassButton_Fill", &"Back", "擦写\n填充工具"),
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back", "返回\n"),
]
## [只读]工具类别层锁定类按钮的数据列表，按按钮由上到下的顺序排序
static var LOCK_CLASS_BUTTONS_DATA_LIST: Array[ClassButtonDataObject] = [
	ClassButtonDataObject.new(&"ClassButton_Lock", &"Back", "锁定\n锁定工具"),
	ClassButtonDataObject.new(&"ClassButton_SmartLock", &"Back", "锁定\n智能锁定"),
	ClassButtonDataObject.new(&"ClassButton_Back", &"Back", "返回\n"),
]
## [只读]工具类别层图层类按钮的数据列表，按按钮由上到下的顺序排序
#static var LAYER_CLASS_BUTTONS_DATA_LIST: Array[ClassButtonDataObject] = [
	#### 暂不确定是否制作图层类
	#ClassButtonDataObject.new(&"ClassButton_Back", &"Back", "返回\n"),
#]
## [只读]缩放工具的详细层数据列表
static var TOOL_DETAIL_DATA_LIST_SCALER: Array[DetailNodeDataObject] = [
	DetailNodeDataObject.new(DetailNodeType.MULTI_BUTTONS, [&"DetailButton_ScalerNumberBarLarger", &"DetailButton_ScalerNumberBarSmaller"], [&"Back", &"Back"], ["数字栏\n放大", "数字栏\n缩小"]),
	DetailNodeDataObject.new(DetailNodeType.SINGLE_BUTTON, [&"DetailButton_ScalerNumberBarAdapt"], [&"Back"], ["数字栏\n适应内容"]),
	DetailNodeDataObject.new(DetailNodeType.MULTI_BUTTONS, [&"DetailButton_ScalerGridsMaximize", &"DetailButton_ScalerGridsLarger", &"DetailButton_ScalerGridsSmaller"], [&"Back", &"Back", &"Back"], ["答题网格\n最大化", "答题网格\n放大", "答题网格\n缩小"]),
]
## [只读]撤销重做的详细层数据列表
static var TOOL_DETAIL_DATA_LIST_UNDO_REDO: Array[DetailNodeDataObject] = [
	DetailNodeDataObject.new(DetailNodeType.SINGLE_BUTTON, [&"DetailButton_Undo"], [&"Back"], ["撤销\n"]),
	DetailNodeDataObject.new(DetailNodeType.SINGLE_BUTTON, [&"DetailButton_Redo"], [&"Back"], ["重做\n"]),
]
## [只读]图层管理的详细层数据列表
static var TOOL_DETAIL_DATA_LIST_LAYERS: Array[DetailNodeDataObject] = [
	DetailNodeDataObject.new(DetailNodeType.SINGLE_BUTTON, [&"DetailButton_LayersNew"], [&"Back"], ["图层管理\n新建图层"]),
	DetailNodeDataObject.new(DetailNodeType.MULTI_BUTTONS, [&"DetailButton_LayersMoveUp", &"DetailButton_LayersMoveDown"], [&"Back", &"Back"], ["图层管理\n向上移动", "图层管理\n向下移动"]),
	DetailNodeDataObject.new(DetailNodeType.SINGLE_BUTTON, [&"DetailButton_LayersMergeDown"], [&"Back"], ["图层管理\n向下合并"]),
	DetailNodeDataObject.new(DetailNodeType.SINGLE_BUTTON, [&"DetailButton_LayersDelete"], [&"Back"], ["图层管理\n删除图层"]),
]
## [只读]笔刷工具的详细层数据列表
static var TOOL_DETAIL_DATA_LIST_BRUSH: Array[DetailNodeDataObject] = [
	DetailNodeDataObject.new(DetailNodeType.MULTI_BUTTONS, [&"DetailButton_BrushModeBrush", &"DetailButton_BrushModePencil"], [&"Detail_Brush_Brush", &"Detail_Brush_Pencil"], ["笔刷模式\n画笔", "笔刷模式\n铅笔"]),
	DetailNodeDataObject.new(DetailNodeType.MULTI_BUTTONS, [&"DetailButton_BrushFillType_Fill", &"DetailButton_BrushFillType_Cross"], [&"Detail_Fill_Type_Fill", &"Detail_Fill_Type_Cross"], ["笔刷样式\n实心块", "笔刷样式\n叉叉"]),
]
## [只读]擦除工具的详细层数据列表
static var TOOL_DETAIL_DATA_LIST_ERASER: Array[DetailNodeDataObject] = [
	DetailNodeDataObject.new(DetailNodeType.MULTI_BUTTONS, [&"DetailButton_EraserModeDishcloth", &"DetailButton_EraserModeEraser"], [&"Detail_Eraser_Dishcloth", &"Detail_Eraser_Eraser"], ["擦除模式\n抹布", "擦除模式\n橡皮"]),
]

## 按钮的默认长度，该值必须通过读取按钮实例的TextureButton的size属性获取。默认只在本节点ready时读取一次
static var button_width_default: float
## 按钮的当前长度，相当于经过变换计算后的button_width_default
static var button_width: float
## [只读]按钮尺寸缩放率，该值基于侧边栏的横向长度求出，然后将其乘入按钮的scale以使按钮缩放至期望的大小
static var button_resize_rate: float:
	get:
		return button_width / button_width_default
## 表示侧边栏横向长度的变量，对其他类型而言应当只读
static var bar_width: float = 180.0
## 表示现在是否应显示提示文本，由SideButton类型修改
static var should_show_tip_text: bool = false
## 应显示的提示文本(所有提示文本节点共享同一提示文本)，由SideButton类型修改
static var tip_text: String:
	get:
		if (fs != null and fs.n_tip_text != null): #防空引用
			return fs.n_tip_text.text
		return "" #未能引用到节点时返回空字符串
	set(value):
		if (fs != null and fs.n_tip_text != null and fs.n_tip_text_class != null): #防空引用
			fs.n_tip_text.text = value
			fs.n_tip_text_class.text = value
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
## 记录工具详细层当前存在的所有按钮和分隔线(不包含返回按钮)，方便进行遍历
static var detail_nodes_list: Array[Control] = []

func _enter_tree() -> void:
	fs = self #定义伪单例

func _ready() -> void:
	button_width_default = n_buttons[0].n_button.size.x #读取按钮实例的TextureButton的size属性
	n_bar_color.color = BAR_COLOR_MODULATE #设置侧边栏颜色矩形的颜色
	n_shadow.self_modulate = BAR_SHADOW_MODULATE #设置侧边栏阴影的调制
	for i in n_buttons.size(): #按索引遍历n_buttons
		n_buttons[i].n_icon.texture = Main.ICON_TEXTURES[BUTTONS_TEXTURES_NAME[i]] #设置按钮的纹理
	n_detail_button_back.n_icon.texture = Main.ICON_TEXTURES[&"Back"] #给详细层返回按钮设置纹理

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
	n_tip_text.label_settings.font_size = int(BAR_TEXT_FONT_SIZE_MULTI * n_tip_text.size.x) #设置提示文本的字体大小，底部和纹理层的提示文本使用的是同一个LabelSettings
	if (should_show_tip_text): #如果当前应当显示提示文本
		var new_alpha: float = move_toward(n_tip_text.self_modulate.a, 1.0, delta * BAR_TEXT_FADING_SPEED) #线性地将提示文本的不透明度变换到1.0
		n_tip_text.self_modulate.a = new_alpha
		n_tip_text_class.self_modulate.a = new_alpha
	else: #否则(当前不应显示提示文本)
		var new_alpha: float = move_toward(n_tip_text.self_modulate.a, 0.0, delta * BAR_TEXT_FADING_SPEED) #线性地将提示文本的不透明度变换到0.0
		n_tip_text.self_modulate.a = new_alpha
		n_tip_text_class.self_modulate.a = new_alpha
	## /03
	## 04深层面板更新
	n_tool_class_panel.size = Vector2(bar_width, window_size.y * TOOL_CLASS_PANEL_HEIGHT_MULTI) #更新工具类别层面板的尺寸
	n_tip_text_class.size = Vector2(bar_width, window_size.y * BAR_TEXT_SPACE_MULTI) #更新类别层面板的提示文本尺寸
	n_tool_detail_panel.size = Vector2(bar_width, window_size.y * TOOL_DETAIL_PANEL_HEIGHT_MULTI) #更新工具详细层面板的尺寸
	var tool_class_panel_pos_open: Vector2 = Vector2(-bar_width, -0.5 * window_size.y) #计算出工具类别面板在完全展开时的坐标
	var tool_class_panel_pos_close: Vector2 = Vector2(window_size.y * TOOL_PANEL_SHADOW_SIZE_MULTI, -0.5 * window_size.y) #计算出工具类别面板在完全收起时的坐标
	var tool_detail_panel_pos_open: Vector2 = Vector2(-bar_width, -0.5 * window_size.y + (1.0 - TOOL_DETAIL_PANEL_HEIGHT_MULTI) * window_size.y) #计算出工具详细面板在完全展开时的坐标
	var tool_detail_panel_pos_close: Vector2 = Vector2(window_size.y * TOOL_PANEL_SHADOW_SIZE_MULTI, -0.5 * window_size.y + (1.0 - TOOL_DETAIL_PANEL_HEIGHT_MULTI) * window_size.y)
	var stylebox_editing: StyleBoxFlat #创建一个StyleBox变量用于修改
	## 	05工具类别层StyleBox更新
	stylebox_editing = n_tool_class_panel.theme.get_stylebox(&"panel", &"Panel") as StyleBoxFlat #获取工具类别层的StyleBox
	stylebox_editing.shadow_size = int(window_size.y * TOOL_PANEL_SHADOW_SIZE_MULTI) #设置StyleBox的阴影尺寸
	stylebox_editing.corner_radius_bottom_left = int(window_size.y * TOOL_PANEL_CORNER_RADIUS_MULTI) #设置StyleBox的圆角半径
	n_tool_class_panel.theme.set_stylebox(&"panel", &"Panel", stylebox_editing) #将修改好的StyleBox保存回工具类别层节点
	stylebox_editing = n_tool_detail_panel.theme.get_stylebox(&"panel", &"Panel") as StyleBoxFlat #获取工具详细层的StyleBox
	stylebox_editing.shadow_size = int(window_size.y * TOOL_PANEL_SHADOW_SIZE_MULTI) #设置StyleBox的阴影尺寸
	stylebox_editing.corner_radius_top_left = int(window_size.y * TOOL_PANEL_CORNER_RADIUS_MULTI) #设置StyleBox的圆角半径
	n_tool_detail_panel.theme.set_stylebox(&"panel", &"Panel", stylebox_editing) #将修改好的StyleBox保存回工具详细层节点
	## 	/05
	## 	06工具详细层StyleBox更新
	## 	/06
	## 	07深层面板位置更新
	tool_class_panel_animation_timer = move_toward(tool_class_panel_animation_timer, 0.0, delta) #工具类别层面板动画倒计时更新
	tool_detail_panel_animation_timer = move_toward(tool_detail_panel_animation_timer, 0.0, delta) #工具详细层面板动画倒计时更新
	var class_panel_ease_weight: float = ease(tool_class_panel_animation_timer / TOOL_PANEL_ANIMATION_TIME, TOOL_PANEL_ANIMATION_EASE_CURVE) #算好类别层插值点
	var detail_panel_ease_weight: float = ease(tool_detail_panel_animation_timer / TOOL_PANEL_ANIMATION_TIME, TOOL_PANEL_ANIMATION_EASE_CURVE) #算好详细层插值点
	match (focus_panel): #匹配焦点所在的面板层次
		Panels.ROOT: #底部，类别层详细层均不展开
			n_tool_class_panel.position = tool_class_panel_pos_close.lerp(tool_class_panel_pos_open, class_panel_ease_weight) #计算工具类别层面板的坐标，因为是倒计时所以向量插值的起点和终点取反，实际终点为收起
			n_tool_detail_panel.position = tool_detail_panel_pos_close.lerp(tool_detail_panel_pos_open, detail_panel_ease_weight) #计算工具详细层面板的坐标，因为是倒计时所以向量插值的起点和终点取反，实际终点为收起
		Panels.TOOL_CLASS: #类别层，类别层展开而详细层收起
			n_tool_class_panel.position = tool_class_panel_pos_open.lerp(tool_class_panel_pos_close, class_panel_ease_weight) #计算工具类别层面板的坐标，因为是倒计时所以向量插值的起点和终点取反，实际终点为展开
			n_tool_detail_panel.position = tool_detail_panel_pos_close.lerp(tool_detail_panel_pos_open, detail_panel_ease_weight) #计算工具详细层面板的坐标，因为是倒计时所以向量插值的起点和终点取反，实际终点为收起
		Panels.TOOL_DETAIL: #详细层，类别层详细层均展开
			n_tool_class_panel.position = tool_class_panel_pos_open.lerp(tool_class_panel_pos_close, class_panel_ease_weight) #计算工具类别层面板的坐标，因为是倒计时所以向量插值的起点和终点取反，实际终点为展开
			n_tool_detail_panel.position = tool_detail_panel_pos_open.lerp(tool_detail_panel_pos_close, detail_panel_ease_weight) #计算工具详细层面板的坐标，因为是倒计时所以向量插值的起点和终点取反，实际终点为展开
	## 	/07
	## 	08工具类别层按钮排列
	var button_y_offset_between: float = window_size.y * TOOL_CLASS_PANEL_BUTTON_Y_SPACING_MULTI #计算出一份按钮间隔长度
	for i in class_buttons_using.size(): #按索引遍历使用中的类别层按钮节点数组。注意此处需要逆着索引从下往上排列
		var j: int = class_buttons_using.size() - 1 - i #总数-1=索引总数，索引总数-索引数i=逆序索引数j
		class_buttons_using[j].position = Vector2(
			n_tool_class_panel.size.x / 2.0, #计算按钮的X坐标
			window_size.y * TOOL_CLASS_PANEL_BUTTON_BOTTOM_Y_MULTI - (button_y_offset_between + button_width) * j #计算按钮的Y坐标
		) #计算并应用按钮的Y坐标
		class_buttons_using[j].scale = Vector2.ONE * button_resize_rate #把按钮缩放率当尺寸来用，应用到按钮的尺寸上
	## 	/08
	## 	09工具详细层按钮排列
	n_detail_button_back.scale = Vector2.ONE * button_resize_rate #将按钮缩放率应用在详细层返回按钮上
	n_detail_button_back.position = Vector2(n_tool_detail_panel.size.x / 2.0, TOOL_DETAIL_PANEL_BACK_BUTTON_Y_MULTI * n_tool_detail_panel.size.y) #设置返回按钮的位置，该按钮位置是固定的，不受到详细层其他按钮的排列的影响
	n_detail_nodes_container.size = Vector2(button_width, n_tool_detail_panel.size.y - window_size.y * TOOL_PANEL_CORNER_RADIUS_MULTI)
	n_detail_nodes_container.position = Vector2((n_tool_detail_panel.size.x - n_detail_nodes_container.size.x) / 2.0, window_size.y * TOOL_PANEL_CORNER_RADIUS_MULTI)
	## 	/09
	## /04

## 切换焦点的高级封装，用于切换层次面板的展开和收起、按钮名称和纹理的设置、一些游戏系统变量的设置，理论上不允许出现输入的两个参数是不相符的层次连接关系的状况。目前还有焦点工具相关的操作没写
func switch_focus(target_class: FocusClass, target_detail: Main.FocusTool) -> void:
	#### 要做的事情：判断类别层和详细层何时需要打开或收起，并在其需要动的时候动，不需要动的时候不动。面板的开关与否是由焦点决定的，本函数只在改变了焦点的时候
	## 穷举判断面板是否应当切换开关状态
	#var new_should_class_panel_open: bool #一个布尔型，记录接下来的类别层面板是否应该打开
	#var current_class_panel_open: bool #一个布尔型，记录当前的类别曾面板是否是打开状态
	var new_focus_panel: Panels = get_new_focus_panel(target_class, target_detail) #获取接下来的焦点面板
	if (focus_panel != new_focus_panel): #如果焦点面板需要变动
		match (focus_panel):
			Panels.ROOT:
				match (new_focus_panel):
					Panels.TOOL_CLASS:
						## 打开类别层面板
						tool_class_panel_animation_timer = TOOL_PANEL_ANIMATION_TIME
					Panels.TOOL_DETAIL:
						## 打开类别层和详细层面板
						tool_class_panel_animation_timer = TOOL_PANEL_ANIMATION_TIME
						tool_detail_panel_animation_timer = TOOL_PANEL_ANIMATION_TIME
			Panels.TOOL_CLASS:
				match (new_focus_panel):
					Panels.ROOT:
						## 关闭类别层面板
						tool_class_panel_animation_timer = TOOL_PANEL_ANIMATION_TIME
					Panels.TOOL_DETAIL:
						## 打开详细层面板
						tool_detail_panel_animation_timer = TOOL_PANEL_ANIMATION_TIME
			Panels.TOOL_DETAIL:
				match (new_focus_panel):
					Panels.ROOT:
						## 关闭类别层和详细层面板
						tool_class_panel_animation_timer = TOOL_PANEL_ANIMATION_TIME
						tool_detail_panel_animation_timer = TOOL_PANEL_ANIMATION_TIME
					Panels.TOOL_CLASS:
						## 关闭详细层面板
						tool_detail_panel_animation_timer = TOOL_PANEL_ANIMATION_TIME
	switch_class_buttons_using(target_class) #将类别层按钮切换到目标类别
	switch_detail_button_using(target_detail) #将详细层按钮切换到目标工具
	Main.focus_tool = target_detail #将焦点工具设为传入参数
	focus_class = target_class #将焦点工具类别设为传入参数
	focus_panel = new_focus_panel #将焦点面板设为接下来应当处于的面板

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
				var j: int = INTERACT_CLASS_BUTTONS_DATA_LIST.size() - i - 1 #逆序索引
				n_class_buttons[j].is_enable = true #启用按钮
				class_buttons_using.append(n_class_buttons[j]) #将按钮添加到使用列表
				n_class_buttons[j].n_icon.texture = Main.ICON_TEXTURES[INTERACT_CLASS_BUTTONS_DATA_LIST[j].texture_name] #设置纹理
				n_class_buttons[j].button_name = INTERACT_CLASS_BUTTONS_DATA_LIST[j].button_name #设置按钮名称
				n_class_buttons[j].hover_tip_text = INTERACT_CLASS_BUTTONS_DATA_LIST[j].tip_text #设置按钮提示文本
		#FocusClass.SELECTION: #选区
			#for i in SELECTION_CLASS_BUTTONS_DATA_LIST.size(): #按索引遍历选区类按钮表
				#var j: int = SELECTION_CLASS_BUTTONS_DATA_LIST.size() - i - 1 #逆序索引
				#n_class_buttons[j].is_enable = true #启用按钮
				#class_buttons_using.append(n_class_buttons[j]) #将按钮添加到使用列表
				#n_class_buttons[j].n_icon.texture = Main.ICON_TEXTURES[SELECTION_CLASS_BUTTONS_DATA_LIST[j].texture_name] #设置纹理
				#n_class_buttons[j].button_name = SELECTION_CLASS_BUTTONS_DATA_LIST[j].button_name #设置按钮名称
				#n_class_buttons[j].hover_tip_text = SELECTION_CLASS_BUTTONS_DATA_LIST[j].tip_text #设置按钮提示文本
		FocusClass.EDIT: #擦写
			for i in EDIT_CLASS_BUTTONS_DATA_LIST.size(): #按索引遍历选区类按钮表
				var j: int = EDIT_CLASS_BUTTONS_DATA_LIST.size() - i - 1 #逆序索引
				n_class_buttons[j].is_enable = true #启用按钮
				class_buttons_using.append(n_class_buttons[j]) #将按钮添加到使用列表
				n_class_buttons[j].n_icon.texture = Main.ICON_TEXTURES[EDIT_CLASS_BUTTONS_DATA_LIST[j].texture_name] #设置纹理
				n_class_buttons[j].button_name = EDIT_CLASS_BUTTONS_DATA_LIST[j].button_name #设置按钮名称
				n_class_buttons[j].hover_tip_text = EDIT_CLASS_BUTTONS_DATA_LIST[j].tip_text #设置按钮提示文本
		FocusClass.LOCK: #锁定
			for i in LOCK_CLASS_BUTTONS_DATA_LIST.size(): #按索引遍历选区类按钮表
				var j: int = LOCK_CLASS_BUTTONS_DATA_LIST.size() - i - 1 #逆序索引
				n_class_buttons[j].is_enable = true #启用按钮
				class_buttons_using.append(n_class_buttons[j]) #将按钮添加到使用列表
				n_class_buttons[j].n_icon.texture = Main.ICON_TEXTURES[LOCK_CLASS_BUTTONS_DATA_LIST[j].texture_name] #设置纹理
				n_class_buttons[j].button_name = LOCK_CLASS_BUTTONS_DATA_LIST[j].button_name #设置按钮名称
				n_class_buttons[j].hover_tip_text = LOCK_CLASS_BUTTONS_DATA_LIST[j].tip_text #设置按钮提示文本
		#FocusClass.LAYER: #图层
			#for i in LAYER_CLASS_BUTTONS_DATA_LIST.size(): #按索引遍历选区类按钮表
				#var j: int = LAYER_CLASS_BUTTONS_DATA_LIST.size() - i - 1 #逆序索引
				#n_class_buttons[j].is_enable = true #启用按钮
				#class_buttons_using.append(n_class_buttons[j]) #将按钮添加到使用列表
				#n_class_buttons[j].n_icon.texture = Main.ICON_TEXTURES[LAYER_CLASS_BUTTONS_DATA_LIST[j].texture_name] #设置纹理
				#n_class_buttons[j].button_name = LAYER_CLASS_BUTTONS_DATA_LIST[j].button_name #设置按钮名称
				#n_class_buttons[j].hover_tip_text = LAYER_CLASS_BUTTONS_DATA_LIST[j].tip_text #设置按钮提示文本

## 清除和实例化详细层内容节点，例如详细层按钮、分隔符等
func switch_detail_button_using(target_focus_tool: Main.FocusTool) -> void:
	## 00清除所有按钮
	for n_detail_node in detail_nodes_list: #遍历所有被列表记录在案的详细层节点
		n_detail_node.queue_free() #将其标记为删除
	detail_nodes_list.clear() #清除详细层节点列表
	## /00
	## 01收集一份需要实例化的节点的列表
	var new_node_task_list: Array[DetailNodeDataObject] #声明一个列表，记录存放将要实例化的详细层节点的数据对象，一个数据对象代表一个实例化任务
	match (target_focus_tool): #匹配目标焦点工具
		Main.FocusTool.NONE: #无(拖手工具)
			new_node_task_list = [] #将实例化列表设为一个空列表
		Main.FocusTool.SCALER: #缩放工具
			new_node_task_list = TOOL_DETAIL_DATA_LIST_SCALER #将实例化任务列表设为缩放工具数据列表
		Main.FocusTool.UNDO_REDO: #撤销重做
			new_node_task_list = TOOL_DETAIL_DATA_LIST_UNDO_REDO #将实例化任务列表设为撤销重做数据列表
		Main.FocusTool.LAYERS: #图层管理
			new_node_task_list = TOOL_DETAIL_DATA_LIST_LAYERS #将实例化任务列表设为图层管理数据列表
		Main.FocusTool.BRUSH: #笔刷工具
			new_node_task_list = TOOL_DETAIL_DATA_LIST_BRUSH #将实例化任务列表设为笔刷数据列表
		Main.FocusTool.ERASER: #擦除工具
			new_node_task_list = TOOL_DETAIL_DATA_LIST_ERASER #将实例化任务列表设为擦除工具数据列表
		_: #default
			push_error("SideBar: 在创建详细层内容节点过程中未能收集到节点实例化任务列表，因为：target_focus_tool参数值不匹配任何已知的焦点工具。")
			return
	## /01
	## 02实例化节点到场景树中
	for new_node_task in new_node_task_list: #遍历实例化任务列表
		var new_node: Control
		if (new_node_task.node_type == DetailNodeType.SPACING): #如果任务是分隔线
			#### 创建一个分隔符，赋值给new_node
			pass
		else: #否则(任务不是分隔线)
			new_node = create_detail_button(new_node_task) #调用按钮节点创建方法获得一个节点
		n_detail_nodes_container.add_child(new_node) #将新创建的节点添加到场景树中
		detail_nodes_list.append(new_node) #将新创建的节点添加到列表中
		update_detail_buttons_disable()
	## /02

## 更新详细层按钮禁用状态，将遍历detail_nodes_list收录的所有详细层节点调用它们的check_disable()方法。本方法建议在按钮发生点击后等状况进行调用
static func update_detail_buttons_disable() -> void:
	for detail_node in detail_nodes_list:
		if (detail_node.has_method(&"check_disable")): #防调用不存在的方法
			detail_node.call(&"check_disable") #让详细层按钮检查自身是否应该禁用

## 详细层按钮节点创建方法，输入一个详细层节点数据对象，返回一个按钮节点
static func create_detail_button(button_data: DetailNodeDataObject) -> Control:
	if (button_data.button_names.size() < 1):
		push_error("SideBar: 详细层按钮节点创建方法将返回null，因为：在创建按钮类型\"DetailNodeType.SINGLE_BUTTON\"时不能接受空的按钮名称数组。")
		return null
	if (button_data.texture_names.size() < 1):
		push_error("SideBar: 详细层按钮节点创建方法将返回null，因为：在创建按钮类型\"DetailNodeType.SINGLE_BUTTON\"时不能接受空的按钮纹理名称数组。")
		return null
	if (not Main.ICON_TEXTURES.has_all(button_data.texture_names)):
		push_error("SideBar: 详细层按钮节点创建方法将返回null，因为：给定的按钮纹理名称数组中存在无法在\"Main.ICON_TEXTURES\"中索引到结果的元素。")
		return null
	match (button_data.node_type):
		DetailNodeType.SINGLE_BUTTON: #单按钮
			var node: DetailNode_SingleButton = DetailNode_SingleButton.create(button_data.button_names[0], Main.ICON_TEXTURES[button_data.texture_names[0]], button_data.tip_texts[0])
			if (node == null):
				push_error("SideBar: 详细层按钮节点创建方法将返回null，因为：类型\"DetailNode_SingleButton\"的类场景实例化方法返回了null。")
			return node
		DetailNodeType.MULTI_BUTTONS: #多按钮
			if (not (button_data.button_names.size() == button_data.texture_names.size() and button_data.texture_names.size() == button_data.tip_texts.size())): #如果按钮数据中的三个数组元素的元素数量不匹配
				push_error("SideBar: 详细层按钮节点创建方法将返回null，因为：给定的详细层按钮数据对象中包含的数组成员不具有相同的元素数量。")
				return null
			var textures: Array[CompressedTexture2D] #创建一个列表用于存放纹理资源
			for texture_name in button_data.texture_names: #遍历按钮纹理名称
				textures.append(Main.ICON_TEXTURES[texture_name]) #获取纹理资源并添加到纹理资源列表
			var node: DetailNode_MultiButtons = DetailNode_MultiButtons.create(button_data.button_names, textures, button_data.tip_texts)
			if (node == null):
				push_error("SideBar: 详细层按钮节点创建方法将返回null，因为：类型\"DetailNode_MultiButtons\"的类场景实例化方法返回了null。")
			return node
		DetailNodeType.COLOR_SWITCH: #颜色切换按钮
			return null ####
		DetailNodeType.BOOL_SWITCH: #二元切换按钮
			return null ####
	push_error("SideBar: 详细层按钮节点创建方法将返回null，因为：给定的按钮数据中按钮类型枚举值不在本方法受理范围内。")
	return null

## 根据给定的焦点类别和工具，返回一个应当处于的焦点面板。当给定参数不符合理应情况时，返回的结果可能不正确
static func get_new_focus_panel(new_focus_class: FocusClass, new_focus_detail: Main.FocusTool) -> Panels:
	if (new_focus_class == FocusClass.NONE):
		return Panels.ROOT
	else:
		if (new_focus_detail == Main.FocusTool.NONE):
			return Panels.TOOL_CLASS
		else:
			return Panels.TOOL_DETAIL

## 工具类别层按钮数据对象，一个实例代表一个按钮的数据，用于放置在一个数组里和其他实例一起代表一个类别中的所有工具按钮的实例化数据
class ClassButtonDataObject:
	var button_name: StringName #按钮名称，用于发出信号时跟随标识参数，对应Main.on_button_trigged()
	var texture_name: StringName #纹理名称，对应Main.ICON_TEXTURES
	var tip_text: String #提示文本
	func _init(new_button_name: StringName, new_texture_name: StringName, new_tip_text: String) -> void:
		button_name = new_button_name
		texture_name = new_texture_name
		tip_text = new_tip_text

## 工具详细层节点数据对象，一个实例代表一个节点的数据，用法与类别层按钮数据对象类似
class DetailNodeDataObject:
	var node_type: DetailNodeType #节点类别
	var button_names: Array[StringName] #一个按钮名称列表，只在节点是按钮时有效。用于发出信号时跟随标识参数，对应Main.on_button_trigged()
	var texture_names: Array[StringName] #一个纹理名称列表，只在节点是按钮时有效。
	var tip_texts: PackedStringArray
	func _init(new_node_type: DetailNodeType, new_button_names: Array[StringName] = [], new_texture_names: Array[StringName] = [], new_tip_texts: PackedStringArray = []) -> void:
		node_type = new_node_type
		button_names = new_button_names
		texture_names = new_texture_names
		tip_texts = new_tip_texts
