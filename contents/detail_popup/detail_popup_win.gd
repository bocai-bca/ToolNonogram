extends DetailPopupBase
class_name DetailPopup_Win
## 详细信息弹窗-胜利

## 类场景封包ClassPackedScene
static var cps: PackedScene = preload("res://contents/detail_popup/detail_popup_win.tscn") as PackedScene

@onready var n_button_copyseed: Button = $RootContainer/HBox/Button_CopySeed as Button
@onready var n_button_back: Button = $RootContainer/HBox/Button_Back as Button
@onready var n_rich_text: RichTextLabel = $RootContainer/RichText as RichTextLabel

## 未格式化的富文本模板
const RICH_TEXT_UNFORMATTED: String = "尺寸：{0} x {1}\n用时：{2}h {3}m {4}s\n种子：\n{5}"

## 当_ready()被子类重写时，需要在其内部加上相同内容
func _ready() -> void:
	## Prefix
	PopupManager.fs.close_popup.connect(check_close_signal) #将关闭弹出菜单信号连接到方法
	PopupManager.fs.custom_popup_notify.connect(_check_custom_notify) #检查自定义消息
	## /Prefix
	n_button_back.pressed.connect( #返回
		func():
			Main.on_button_trigged(&"Popup_Win_Back")
	)
	n_button_copyseed.pressed.connect( #复制种子
		func():
			Main.on_button_trigged(&"Popup_Win_CopySeed")
	)

## 当_process()被子类重写时，需要在其内部加上相同内容
func _process(delta: float) -> void:
	## Prefix
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	## /Prefix
	## Postfix
	var width_max_scale: float = MAX_WIDTH_MULTI * window_size.x / DEFAULT_SIZE.x #获取当前状况能使用的最大横向长度
	var height_max_scale: float = MAX_HEIGHT_MULTI * window_size.y / DEFAULT_SIZE.y #获取当前状况能使用的最大纵向长度
	scale = Vector2.ONE * minf(width_max_scale, height_max_scale) #选取最小的乘数应用于scale属性
	position = size * scale / -2.0 #将size与scale相乘得到其实际尺寸，除以-2得到其一半尺寸的负数，应用在坐标即使其居中在中心(0,0)位置
	var fade_y_multi: float #声明局部变量，表示动画过程中Y的偏移量乘数
	if (fade_timer >= 0.0): #如果滑动计时器大于等于0
		fade_y_multi = lerpf(FADEIN_POS_Y_MULTI, FADEOUT_POS_Y_MULTI, ease(fade_timer / FADE_TIME, EASE_CURVE)) #计算懒得讲自己看
	else: #否则(滑动计时器小于0)
		fade_y_multi = lerpf(FADEOUT_POS_Y_MULTI, FADEIN_POS_Y_MULTI, ease((FADE_TIME + fade_timer) / FADE_TIME, EASE_CURVE)) #计算懒得讲自己看，区别是进行了一个取反
	position.y += fade_y_multi * window_size.y #应用到Y
	update_timer(delta) #更新倒计时器
	update_free() #更新自主关闭
	## /Postfix

## 设置本弹窗中文本的内容
func set_contents(seed: String, grid_size: Vector2i, time_hours: int, time_minutes: int, time_seconds: int) -> void:
	n_rich_text.text = RICH_TEXT_UNFORMATTED.format([str(grid_size.x), str(grid_size.y), str(time_hours), str(time_minutes), str(time_seconds), seed])
