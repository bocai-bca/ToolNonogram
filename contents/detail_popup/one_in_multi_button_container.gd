extends BoxContainer
class_name OneInMultiButtonContainer
## 多选一按钮排列容器。本脚本可放置于任何继承自BoxContainer的节点上
## 本脚本功能与使用方法：
## 	需要放置于只容纳了继承自BaseButton的节点的BoxContainer节点或其继承节点
## 	(以下将放置了本脚本的BoxContainer节点及其继承节点称呼为"本实例")
## 	本实例会在ready后监听其子节点的pressed()信号
## 	当一个按钮被触发后，该按钮会被禁用，而其他按钮会被启用

func _ready() -> void:
	for child in get_children() as Array: #遍历子节点
		if (not child is BaseButton): #如果当前子节点不是继承自BaseButton
			push_error("OneInMultiButtonContainer: 在遍历子节点以连接信号时被迫跳过元素，因为：当前遍历的节点是null或不继承自BaseButton。")
			continue
		(child as BaseButton).pressed.connect(set_button_disable.bind(child)) #将按钮的按下信号连接到方法

## 设置按钮禁用，参数传入的按钮实例将被禁用，其他按钮将被启用。无论因何种原因未能成功禁用目标实例，其余子节点都将被启用
func set_button_disable(disable_target: BaseButton) -> void:
	for child in get_children() as Array: #遍历子节点
		if (not child is BaseButton): #如果当前子节点不是继承自BaseButton
			push_error("OneInMultiButtonContainer: 在遍历子节点以连接信号时被迫跳过元素，因为：当前遍历的节点是null或不继承自BaseButton。")
			continue
		(child as BaseButton).disabled = false #启用按钮
	if (disable_target != null): #如果禁用目标不是null
		disable_target.disabled = true #禁用按钮
	else: #否则(禁用目标是null)
		push_error("OneInMultiButtonContainer: 未能成功禁用目标实例，因为：参数传入的目标实例是null。")

#func on_button_pressed(button_node: BaseButton) -> void:
#	set_buttons_disable(button_node)
