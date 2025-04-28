extends RefCounted
class_name MenuDetailState
## 菜单状态数据，用于记录各个菜单的设置状态，如新建题纸菜单的模式是沙盒还是解题
## 使用时需要将本类实例化为一个实例使用

## 游戏模式
enum GameMode{
	PUZZLE, #解题
	SANDBOX, #沙盒
}

## 弹出菜单-新建题纸.游戏模式
var popup_newpaper_mode: GameMode = GameMode.PUZZLE
## 弹出菜单-新建题纸.尺寸
var popup_newpaper_size: Vector2i = Vector2i(5, 5)
## 弹出菜单-新建题纸.种子
var popup_newpaper_seed: String = ""
