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
	## 02设置方向
	if (direction == Direction.UNSPECIFIED): #如果方向未指定
		pass #### 这里继续写方向指定，接下来要看看click_state提供了哪些数据，好进行方向判断
	## /02
	if (Main.tools_detail_state.brush_fill_type == ToolsDetailState.ToolFillType.FILL): #如果工具处于实心块填充类型
		temp_grids_map.set_slot(click_state.current_grid_pos, PaperArea.LayerGridsSlot.FILL_NORMAL) #将临时网格的鼠标指针所在位置填充为无着色实心块
	elif (Main.tools_detail_state.brush_fill_type == ToolsDetailState.ToolFillType.CROSS): #如果工具处于叉叉填充类型
		temp_grids_map.set_slot(click_state.current_grid_pos, PaperArea.LayerGridsSlot.CROSS_NORMAL) #将临时网格的鼠标指针所在位置填充为无着色叉叉

## [虚函数-实现]结束方法，在工具停止按下的首个帧调用此方法
func _end(click_state: PaperArea.ClickState, temp_grids_map: GridsData, focus_grids_map: GridsData) -> void:
	## 00合并临时图层到真实焦点图层
	focus_grids_map.be_merge_down(temp_grids_map)
	## /00
	## 01复位处理器成员变量
	is_inited = false
	direction = Direction.UNSPECIFIED
	## /01
