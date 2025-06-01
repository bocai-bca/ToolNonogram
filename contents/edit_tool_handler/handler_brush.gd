extends EditToolHandler
class_name EditToolHandler_Brush
## 擦写工具处理器-画笔

## [虚函数-实现]过程方法，在工具按下的每个帧都调用此方法
func _process(click_state: PaperArea.ClickState, temp_grids_map: GridsData) -> void:
	if (Main.tools_detail_state.brush_fill_type == ToolsDetailState.ToolFillType.FILL): #如果工具处于实心块填充类型
		temp_grids_map.set_slot(click_state.current_grid_pos, PaperArea.LayerGridsSlot.FILL_NORMAL) #将临时网格的鼠标指针所在位置填充为无着色实心块
	elif (Main.tools_detail_state.brush_fill_type == ToolsDetailState.ToolFillType.CROSS): #如果工具处于叉叉填充类型
		temp_grids_map.set_slot(click_state.current_grid_pos, PaperArea.LayerGridsSlot.CROSS_NORMAL) #将临时网格的鼠标指针所在位置填充为无着色叉叉

## [虚函数-实现]结束方法，在工具停止按下的首个帧调用此方法
func _end(click_state: PaperArea.ClickState, temp_grids_map: GridsData, focus_grids_map: GridsData) -> void:
	focus_grids_map.be_merge_down(temp_grids_map)
