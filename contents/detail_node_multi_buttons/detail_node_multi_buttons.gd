extends VBoxContainer
class_name DetailNode_MultiButtons
## 详细层节点-多按钮

## 类场景封包ClassPackedScene
static var cps: PackedScene = preload("res://contents/detail_node_multi_buttons/detail_node_multi_buttons.tscn") as PackedScene

## 按钮的样式盒，每个数组中容纳四个元素，分别代表: 正常、悬浮、按下、禁用
static var top_button_styleboxes: Array[StyleBoxFlat]
static var middle_button_styleboxes: Array[StyleBoxFlat]
static var bottom_button_styleboxes: Array[StyleBoxFlat]

## 每个按钮的默认尺寸，需要根据根节点的size属性手动设置，用于图标的缩放计算
const DEFAULT_SIZE_PER_BUTTON: Vector2 = Vector2(120.0, 120.0)
## 按钮圆角半径乘数，基于视口纵向长度
const CORNER_RADIUS_MULTI: float = 30.0 / Main.WINDOW_SIZE_DEFAULT.y
## 按钮边角细节
const BUTTON_STYLEBOX_CORNER_DETAIL: int = 5
## 按钮背景颜色-正常
const BUTTON_STYLEBOX_BG_COLOR_NORMAL: Color = Color(0.8, 0.8, 0.8, 1.0)
## 按钮背景颜色-悬浮
const BUTTON_STYLEBOX_BG_COLOR_HOVER: Color = Color(0.7, 0.7, 0.7, 1.0)
## 按钮背景颜色-点击
const BUTTON_STYLEBOX_BG_COLOR_PRESSED: Color = Color(0.6, 0.6, 0.6, 1.0)
## 按钮背景颜色-禁用
const BUTTON_STYLEBOX_BG_COLOR_DISABLED: Color = Color(0.75, 0.75, 0.75, 1.0)

static func _static_init() -> void:
	var stylebox_top_normal: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_top_normal.bg_color = BUTTON_STYLEBOX_BG_COLOR_NORMAL
	stylebox_top_normal.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	var stylebox_top_hover: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_top_hover.bg_color = BUTTON_STYLEBOX_BG_COLOR_HOVER
	stylebox_top_hover.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	var stylebox_top_pressed: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_top_pressed.bg_color = BUTTON_STYLEBOX_BG_COLOR_PRESSED
	stylebox_top_pressed.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	var stylebox_top_disabled: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_top_disabled.bg_color = BUTTON_STYLEBOX_BG_COLOR_DISABLED
	stylebox_top_disabled.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	top_button_styleboxes = [stylebox_top_normal, stylebox_top_hover, stylebox_top_pressed, stylebox_top_disabled]
	var stylebox_middle_normal: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_middle_normal.bg_color = BUTTON_STYLEBOX_BG_COLOR_NORMAL
	stylebox_middle_normal.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	var stylebox_middle_hover: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_middle_hover.bg_color = BUTTON_STYLEBOX_BG_COLOR_HOVER
	stylebox_middle_hover.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	var stylebox_middle_pressed: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_middle_pressed.bg_color = BUTTON_STYLEBOX_BG_COLOR_PRESSED
	stylebox_middle_pressed.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	var stylebox_middle_disabled: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_middle_disabled.bg_color = BUTTON_STYLEBOX_BG_COLOR_DISABLED
	stylebox_middle_disabled.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	middle_button_styleboxes = [stylebox_middle_normal, stylebox_middle_hover, stylebox_middle_pressed, stylebox_middle_disabled]
	var stylebox_bottom_normal: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_bottom_normal.bg_color = BUTTON_STYLEBOX_BG_COLOR_NORMAL
	stylebox_bottom_normal.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	var stylebox_bottom_hover: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_bottom_hover.bg_color = BUTTON_STYLEBOX_BG_COLOR_HOVER
	stylebox_bottom_hover.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	var stylebox_bottom_pressed: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_bottom_pressed.bg_color = BUTTON_STYLEBOX_BG_COLOR_PRESSED
	stylebox_bottom_pressed.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	var stylebox_bottom_disabled:  StyleBoxFlat = StyleBoxFlat.new()
	stylebox_bottom_disabled.bg_color = BUTTON_STYLEBOX_BG_COLOR_DISABLED
	stylebox_bottom_disabled.corner_detail = BUTTON_STYLEBOX_CORNER_DETAIL
	bottom_button_styleboxes = [stylebox_bottom_normal, stylebox_bottom_hover, stylebox_bottom_pressed, stylebox_bottom_disabled]

func _process(delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	for button in get_children() as Array[DetailNode_MultiButtons_Member]: #遍历所有子节点
		button.custom_minimum_size.y = button.size.x
		button.n_icon.scale = Vector2.ONE * minf(button.size.x / DEFAULT_SIZE_PER_BUTTON.x, button.size.y / DEFAULT_SIZE_PER_BUTTON.y) #计算图标的缩放变换，为按钮根节点的实际尺寸除以默认尺寸，该结果乘入图标的缩放中即可将图标缩放至按钮相当
		button.n_icon.position = button.size / 2.0
		if (button.get_index() == 0): #如果当前按钮是第一个按钮
			button.add_theme_stylebox_override(&"normal", top_button_styleboxes[0])
			button.add_theme_stylebox_override(&"hover", top_button_styleboxes[1])
			button.add_theme_stylebox_override(&"pressed", top_button_styleboxes[2])
			button.add_theme_stylebox_override(&"disabled", top_button_styleboxes[3])
		elif (button.get_index() == get_child_count() - 1): #否则如果当前按钮是最后一个按钮
			button.add_theme_stylebox_override(&"normal", bottom_button_styleboxes[0])
			button.add_theme_stylebox_override(&"hover", bottom_button_styleboxes[1])
			button.add_theme_stylebox_override(&"pressed", bottom_button_styleboxes[2])
			button.add_theme_stylebox_override(&"disabled", bottom_button_styleboxes[3])
		else: #否则(当前按钮既不是第一个也不是最后一个)
			button.add_theme_stylebox_override(&"normal", middle_button_styleboxes[0])
			button.add_theme_stylebox_override(&"hover", middle_button_styleboxes[1])
			button.add_theme_stylebox_override(&"pressed", middle_button_styleboxes[2])
			button.add_theme_stylebox_override(&"disabled", middle_button_styleboxes[3])
	for stylebox in top_button_styleboxes: #遍历顶部按钮样式盒
		stylebox.corner_radius_top_left = CORNER_RADIUS_MULTI * window_size.y #设置左上角圆角半径
		stylebox.corner_radius_top_right = stylebox.corner_radius_top_left #设置右上角圆角半径
	for stylebox in bottom_button_styleboxes: #遍历底部按钮样式盒
		stylebox.corner_radius_bottom_left = CORNER_RADIUS_MULTI * window_size.y #设置左下角圆角半径
		stylebox.corner_radius_bottom_right = stylebox.corner_radius_bottom_left #设置右下角圆角半径

## 检查自身的按钮成员们各自是否需要禁用并更新它们的禁用状态
func check_disable() -> void:
	for node in get_children() as Array[DetailNode_MultiButtons_Member]:
		node.is_enable = not Main.button_disable_check(node.button_name)

## 类场景实例化方法
static func create(new_button_names: Array[StringName], new_textures: Array[CompressedTexture2D], new_tip_texts: PackedStringArray) -> DetailNode_MultiButtons:
	if (not (new_button_names.size() == new_textures.size() and new_textures.size() == new_tip_texts.size())): #如果输入参数的三个数组元素数量存在不同
		push_error("DetailNode_MultiButtons: 类场景实例化方法将返回null，因为：给定的数组参数不具有相同的元素数量。")
		return null
	var node: DetailNode_MultiButtons = cps.instantiate()
	for i in new_button_names.size(): #按索引遍历按钮名称列表
		var button: DetailNode_MultiButtons_Member = DetailNode_MultiButtons_Member.create(new_button_names[i], new_textures[i], new_tip_texts[i], middle_button_styleboxes) #实例化一个按钮实例并记录在局部变量中
		if (button == null):
			push_error("DetailNode_MultiButtons: 类场景实例化过程中未能添加第",i+1,"个按钮实例为类场景的子节点，因为：详细层多按钮节点成员类场景实例化方法返回了null。")
			continue
		node.add_child(button) #将新的按钮实例添加为多按钮实例的子节点
	return node
