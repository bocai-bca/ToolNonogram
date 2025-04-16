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
	CLOTH, #抹布模式
	ERASER #橡皮模式
}

## 笔刷工具.模式
var brush_mode: BrushMode = BrushMode.BRUSH
## 擦除工具.模式
var eraser_mode: EraserMode = EraserMode.CLOTH
