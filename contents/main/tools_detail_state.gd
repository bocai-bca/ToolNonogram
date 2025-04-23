extends RefCounted
class_name ToolsDetailState
## 工具使用数据，用于记录各个工具的详细层所处状态，例如笔刷的颜色、模式等
## 使用时需要将本类实例化为一个实例使用

## 笔刷工具.模式
enum BrushMode{
	BRUSH, #画笔模式
	PENCIL #铅笔模式
}
## 擦除工具.模式
enum EraserMode{
	DISHCLOTH, #抹布模式
	ERASER #橡皮模式
}
## 工具填充类型
enum ToolFillType{
	FILL, #实心块填充
	CROSS, #叉叉
}

## 笔刷工具.模式
var brush_mode: BrushMode = BrushMode.BRUSH
## 笔刷工具.填充类型
var brush_fill_type: ToolFillType = ToolFillType.FILL
## 擦除工具.模式
var eraser_mode: EraserMode = EraserMode.DISHCLOTH
