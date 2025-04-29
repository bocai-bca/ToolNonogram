extends DetailPopupBase
class_name DetailPopupBase_Main_Paper_New
## 详细信息弹窗-菜单.题纸.新建

## 类场景封包ClassPackedScene
static var cps: PackedScene = preload("res://contents/detail_popup/detail_popup_menu_paper_new.tscn") as PackedScene

@onready var n_oimcontainer_mode: OneInMultiButtonContainer = $RootContainer/OIMContainer_Mode as OneInMultiButtonContainer
@onready var n_button_mode_puzzle: Button = $RootContainer/OIMContainer_Mode/Button_ModePuzzle as Button
@onready var n_button_mode_sandbox: Button = $RootContainer/OIMContainer_Mode/Button_ModeSandbox as Button
@onready var n_lineedit_seed: LineEdit = $RootContainer/ModeTextContainer/LineEdit_Seed as LineEdit
@onready var n_button_confirm: Button = $RootContainer/Container_BottomButton/Button_Confirm as Button
@onready var n_button_cancel: Button = $RootContainer/Container_BottomButton/Button_Cancel as Button
@onready var n_spinbox_size_x: SpinBox = $RootContainer/Container_Size/SpinBox_SizeX as SpinBox
@onready var n_spinbox_size_y: SpinBox = $RootContainer/Container_Size/SpinBox_SizeX as SpinBox
@onready var n_tiptext_seedinvalid: Label = $RootContainer/TipText_SeedInvalid as Label

## 种子不合法提示文本的消隐时间(被用作除数，不可为0)
const SEED_INVALID_TIP_FADEOUT_TIME: float = 2.5

func _ready() -> void:
	## Prefix
	PopupManager.fs.close_popup.connect(check_close_signal) #将关闭弹出菜单信号连接到方法
	PopupManager.fs.custom_popup_notify.connect(_check_custom_notify) #检查自定义消息
	## /Prefix
	n_button_mode_puzzle.pressed.connect( #题纸模式.解题
		func():
			_store_data()
			Main.on_button_trigged(&"Popup_NewPaper_Mode_Puzzle")
			_read_data()
	)
	n_button_mode_sandbox.pressed.connect( #题纸模式.沙盒
		func():
			_store_data()
			Main.on_button_trigged(&"Popup_NewPaper_Mode_Sandbox")
			_read_data()
	)
	n_button_confirm.pressed.connect( #确认并创建(确认)
		func():
			_store_data()
			Main.on_button_trigged(&"Popup_NewPaper_Confirm")
			_read_data()
	)
	n_button_cancel.pressed.connect( #取消
		func():
			_store_data()
			Main.on_button_trigged(&"Popup_NewPaper_Cancel")
			_read_data()
	)
	n_lineedit_seed.text_changed.connect( #种子输入框变动
		func(_new_text: String):
			_store_data()
	)
	_read_data()

func _process(delta: float) -> void:
	## Prefix
	var window_size: Vector2 = Vector2(get_window().size) #获取窗口大小
	## /Prefix
	n_tiptext_seedinvalid.self_modulate.a = move_toward(n_tiptext_seedinvalid.self_modulate.a, 0.0, delta / 1.5) #更新种子不合法提示文本的alpha消隐
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

## [虚函数-实现]从Main类读取菜单状态并更新本实例的各项状态
func _read_data() -> void:
	match (Main.menu_detail_state.popup_newpaper_mode): #匹配游戏模式
		MenuDetailState.GameMode.PUZZLE: #解题模式
			n_oimcontainer_mode.set_button_disable(n_button_mode_puzzle) #禁用解题模式按钮
			n_lineedit_seed.visible = true #使种子输入框可见
		MenuDetailState.GameMode.SANDBOX: #沙盒模式
			n_oimcontainer_mode.set_button_disable(n_button_mode_sandbox) #禁用沙盒模式按钮
			n_lineedit_seed.visible = false #使种子输入框不可见
	n_spinbox_size_x.value = Main.menu_detail_state.popup_newpaper_size.x #设置题纸尺寸的X
	n_spinbox_size_y.value = Main.menu_detail_state.popup_newpaper_size.y #设置题纸尺寸的Y
	n_lineedit_seed.text = Main.menu_detail_state.popup_newpaper_seed #设置输入的种子

## [虚函数-实现]将本实例的各项状态保存到Main类的菜单状态
func _store_data() -> void:
	Main.menu_detail_state.popup_newpaper_seed = n_lineedit_seed.text #保存输入的种子
	Main.menu_detail_state.popup_newpaper_size = Vector2i(int(n_spinbox_size_x.value), int(n_spinbox_size_y.value)) #保存题纸尺寸SpinBox的值

## [虚函数-声明]检查自定义消息
func _check_custom_notify(notice: StringName) -> void:
	match (notice): #匹配自定义消息
		&"New_Paper_SeedInvalid": #种子不合法
			n_tiptext_seedinvalid.self_modulate.a = 1.0 #将种子不合法Label显示
