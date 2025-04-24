extends DetailPopupBase
class_name DetailPopupBase_Main_Paper_New
## 详细信息弹窗-菜单.题纸.新建

@onready var n_oimcontainer_mode: OneInMultiButtonContainer = $RootContainer/OIMContainer_Mode as OneInMultiButtonContainer
@onready var n_button_mode_puzzle: Button = $RootContainer/OIMContainer_Type/Button_ModePuzzle as Button
@onready var n_button_mode_sandbox: Button = $RootContainer/OIMContainer_Type/Button_ModeSandbox as Button
@onready var n_lineedit_seed: LineEdit = $RootContainer/ModeTextContainer/LineEdit_Seed as LineEdit
@onready var n_button_confirm: Button = $RootContainer/Container_BottomButton/Button_Confirm as Button
@onready var n_button_cancel: Button = $RootContainer/Container_BottomButton/Button_Cancel as Button
@onready var n_block_button: Button = $BlockButton as Button
@onready var n_spinbox_size_x: SpinBox = $RootContainer/Container_Size/SpinBox_SizeX as SpinBox
@onready var n_spinbox_size_y: SpinBox = $RootContainer/Container_Size/SpinBox_SizeX as SpinBox

func _ready() -> void:
	n_button_mode_puzzle.pressed.connect( #题纸模式.解题
		func(): Main.on_button_trigged(&"Popup_NewPaper_Mode_Puzzle")
	)
	n_button_mode_sandbox.pressed.connect( #题纸模式.沙盒
		func(): Main.on_button_trigged(&"Popup_NewPaper_Mode_Sandbox")
	)
	n_button_confirm.pressed.connect( #确认并创建(确认)
		func(): Main.on_button_trigged(&"Popup_NewPaper_Confirm")
	)
	n_button_cancel.pressed.connect( #取消
		func(): Main.on_button_trigged(&"Popup_NewPaper_Cancel")
	)

## 从Main类读取菜单状态并更新本实例的各项状态。为避免n_oimcontainer_mode.set_button_disable()被连续两次调用，本方法应设计为只在菜单被初始化时使用，而不是每次数据变化时就使用
func read_data() -> void:
	match (Main.menu_detail_state.popup_newpaper_mode): #匹配游戏模式
		MenuDetailState.GameMode.PUZZLE: #解题模式
			n_oimcontainer_mode.set_button_disable(n_button_mode_puzzle) #禁用解题模式按钮
			n_lineedit_seed.visible = true #使种子输入框可见
		MenuDetailState.GameMode.SANDBOX: #沙盒模式
			n_oimcontainer_mode.set_button_disable(n_button_mode_sandbox) #禁用沙盒模式按钮
			n_lineedit_seed.visible = false #使种子输入框不可见
	n_spinbox_size_x.value = Main.menu_detail_state.popup_newpaper_size.x #设置题纸尺寸的X
	n_spinbox_size_y.value = Main.menu_detail_state.popup_newpaper_size.y #设置题纸尺寸的Y

## 将本实例的各项状态保存到Main类的菜单状态
func store_data() -> void:
	pass
