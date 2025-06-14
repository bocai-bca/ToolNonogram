extends EditToolHandler
class_name EditToolHandler_Pencil
## 擦写工具处理器-铅笔

## 方向
enum Direction{
	UNSPECIFIED, #未确定
	HORIZONTAL, #水平方向
	VERTICAL, #垂直方向
}

## 是否初始化(当开始落笔时未初始化表示此次process调用是本次落笔的第一刻)
var is_inited: bool = false
## 方向
var direction: Direction = Direction.UNSPECIFIED

## [虚函数-实现]过程方法，在工具按下的每个帧都调用此方法
func _process(click_state: PaperArea.ClickState, temp_grids_map: GridsData) -> void:
	## 00清空临时图层
	temp_grids_map.fill(PaperArea.LayerGridsSlot.EMPTY) #清空临时图层
	## /00
	## 01初始化检查和行为
	if (not is_inited): #如果尚未初始化
		pass
	## /01
	var current_fill_type: PaperArea.LayerGridsSlot = PaperArea.LayerGridsSlot.EMPTY #创建局部变量记录当前使用的填充类型(实心块还是叉叉)
	match (Main.tools_detail_state.brush_fill_type): #匹配工具详细层状态的笔刷填充类型
		ToolsDetailState.ToolFillType.FILL: #实心块
			current_fill_type = PaperArea.LayerGridsSlot.FILL_NORMAL #将填充类型设为无着色实心块
		ToolsDetailState.ToolFillType.CROSS: #叉叉
			current_fill_type = PaperArea.LayerGridsSlot.CROSS_NORMAL #将填充类型设为无着色叉叉
	## 02设置方向
	if (direction == Direction.UNSPECIFIED): #如果方向未指定
		var pos_offset: Vector2i = (click_state.current_grid_pos - click_state.pressed_grid_pos).abs() #计算当前帧鼠标的网格坐标与按下时网格坐标的差值
		if (pos_offset.x >= pos_offset.y): #如果坐标差值的X大于等于Y
			direction = Direction.HORIZONTAL #将方向设为水平
		else: #否则(坐标差值的X小于Y)
			direction = Direction.VERTICAL #将方向设为垂直
		temp_grids_map.set_slot(click_state.current_grid_pos, current_fill_type) #将鼠标当前所在格子填充为指定的填充类型
	## /02
	else: #否则(方向已指定)
		var end_pos: Vector2i = click_state.pressed_grid_pos #声明局部Vec2i记录本次铅笔工具的终点位置
		match (direction): #匹配方向
			Direction.HORIZONTAL: #水平
				end_pos.x = click_state.current_grid_pos.x #更新且仅更新目标坐标的X到鼠标所在网格坐标的X
				for x in range(mini(click_state.current_grid_pos.x, end_pos.x), maxi(click_state.current_grid_pos.x, end_pos.x) + 1): #遍历所需填充的格子
					temp_grids_map.set_slot(Vector2i(x, end_pos.y), current_fill_type) #将当前遍历到达的坐标填充为指定的填充类型
			Direction.VERTICAL: #垂直
				end_pos.y = click_state.current_grid_pos.y #更新且仅更新目标坐标的Y到鼠标所在网格坐标的Y
				for y in range(mini(click_state.current_grid_pos.y, end_pos.y), maxi(click_state.current_grid_pos.y, end_pos.y) + 1): #遍历所需填充的格子
					temp_grids_map.set_slot(Vector2i(end_pos.x, y), current_fill_type) #将当前遍历到达的坐标填充为指定的填充类型

## [虚函数-实现]结束方法，在工具停止按下的首个帧调用此方法
func _end(click_state: PaperArea.ClickState, temp_grids_map: GridsData, focus_grids_map: GridsData) -> void:
	## 00合并临时图层到真实焦点图层
	focus_grids_map.be_merge_down(temp_grids_map)
	## /00
	## 01复位处理器成员变量
	is_inited = false
	direction = Direction.UNSPECIFIED
	## /01
